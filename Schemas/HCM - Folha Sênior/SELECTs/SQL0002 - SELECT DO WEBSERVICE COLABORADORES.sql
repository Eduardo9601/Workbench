/* ============================================================
   SELECT COMPLETO PARA VALIDACAO DIRETA NO ORACLE
   Baseado na regra atual do WebService.

   Ajustes mantidos:
   - somente TIPCOL = 1 (Empregado)
   - DDATDEM somente para SITAFA = 7; demais = NULL
   - DDATAFA e DDATTER = NULL quando SITAFA = 1 (Trabalhando) ou 7 (Demitido)
   - para nao demitidos, mantem a logica do ultimo afastamento
   - carga horaria convertida de minutos para horas (/60)
   - rede via R030FIL -> USU_TCADRED

   Informe :PNUMEMP, por exemplo 8.
   ============================================================ */

SELECT
    F.NUMEMP AS NNUMEMP,
    F.TIPCOL AS NTIPCOL,
    E.NOMEMP AS ANOMEMP,
    F.NUMCPF AS NNUMCPF,
    F.DATADM AS DDATADM,

    /* Data de demissao somente para demitidos */
    CASE
        WHEN F.SITAFA = 7 THEN F.DATAFA
        ELSE NULL
    END AS DDATDEM,

    F.DATNAS AS DDATNAS,
    C.EMAPAR AS AEMAPAR,

    CASE
        WHEN G1.CADGES IS NOT NULL THEN 1
        ELSE 0
    END AS NNIVCOL,

    CID.NOMCID AS ANOMCID,

    CASE
        WHEN GES.NUMCPF IS NULL THEN 0
        ELSE GES.NUMCPF
    END AS NCPFGES,

    /* Situacao final */
    CASE
        WHEN F.SITAFA = 7 THEN 7
        WHEN F.SITAFA <> 1
         AND AFA.SITAFA IS NOT NULL
        THEN AFA.SITAFA
        ELSE F.SITAFA
    END AS NSITAFA,

    SIT.DESSIT AS ADESSIT,

    /* Para demitidos, datas de afastamento ficam nulas */
    CASE
        WHEN F.SITAFA IN (1, 7) THEN NULL
        WHEN AFA.NUMCAD IS NOT NULL
        THEN AFA.DATAFA
        ELSE DATE '1900-12-31'
    END AS DDATAFA,

    CASE
        WHEN F.SITAFA IN (1, 7) THEN NULL
        WHEN AFA.NUMCAD IS NOT NULL
        THEN AFA.DATTER
        ELSE DATE '1900-12-31'
    END AS DDATTER,

    F.NUMCAD AS NNUMCAD,
    F.NOMFUN AS ANOMFUN,
    F.CODCCU AS ACODCCU,
    U.CCUTXT AS ACCUTXT,
    U.NOMCCU AS ANOMCCU,
    HCC.DATALT AS DALTCCU,
    F.CODCAR AS ACODCAR,
    CAR.TITRED AS ATITRED,
    HCA.DATALT AS DALTCAR,

    CASE
        WHEN FIL.USU_CODRED IS NULL THEN 0
        ELSE FIL.USU_CODRED
    END AS NCODRED,

    RED.USU_DESRED AS ADESRED,

    CASE
        WHEN ESC.HORMES IS NULL THEN 0
        ELSE TRUNC(ESC.HORMES / 60)
    END AS NHORMES

FROM R034FUN F

INNER JOIN R030EMP E
        ON E.NUMEMP = F.NUMEMP

LEFT JOIN R034CPL C
       ON C.NUMEMP = F.NUMEMP
      AND C.TIPCOL = F.TIPCOL
      AND C.NUMCAD = F.NUMCAD

LEFT JOIN R074CID CID
       ON CID.CODCID = C.CODCID

LEFT JOIN R018CCU U
       ON U.NUMEMP = F.NUMEMP
      AND U.CODCCU = F.CODCCU

LEFT JOIN R024CAR CAR
       ON CAR.ESTCAR = F.ESTCAR
      AND CAR.CODCAR = F.CODCAR

LEFT JOIN R006ESC ESC
       ON ESC.CODESC = F.CODESC

LEFT JOIN R030FIL FIL
       ON FIL.NUMEMP = F.NUMEMP
      AND FIL.CODFIL = F.CODFIL

LEFT JOIN USU_TCADRED RED
       ON RED.USU_CODRED = FIL.USU_CODRED

/* Ultima alteracao de Centro de Custo */
LEFT JOIN (
    SELECT
        NUMEMP,
        TIPCOL,
        NUMCAD,
        MAX(DATALT) AS DATALT
    FROM R038HCC
    WHERE NUMEMP = :PNUMEMP
    GROUP BY
        NUMEMP,
        TIPCOL,
        NUMCAD
) HCC
       ON HCC.NUMEMP = F.NUMEMP
      AND HCC.TIPCOL = F.TIPCOL
      AND HCC.NUMCAD = F.NUMCAD

/* Ultima alteracao de Cargo */
LEFT JOIN (
    SELECT
        NUMEMP,
        TIPCOL,
        NUMCAD,
        MAX(DATALT) AS DATALT
    FROM R038HCA
    WHERE NUMEMP = :PNUMEMP
    GROUP BY
        NUMEMP,
        TIPCOL,
        NUMCAD
) HCA
       ON HCA.NUMEMP = F.NUMEMP
      AND HCA.TIPCOL = F.TIPCOL
      AND HCA.NUMCAD = F.NUMCAD

/*
   Ultimo afastamento.
   Mantida a logica atual da regra: para demitidos, prioriza SITAFA = 7.
   No SELECT final DDATAFA/DDATTER sao NULL para SITAFA = 1 ou 7.
*/
LEFT JOIN (
    SELECT
        AX.NUMEMP,
        AX.TIPCOL,
        AX.NUMCAD,
        AX.DATAFA,
        AX.DATTER,
        AX.SITAFA
    FROM (
        SELECT
            A.NUMEMP,
            A.TIPCOL,
            A.NUMCAD,
            A.DATAFA,
            A.DATTER,
            A.SITAFA,
            ROW_NUMBER() OVER (
                PARTITION BY
                    A.NUMEMP,
                    A.TIPCOL,
                    A.NUMCAD
                ORDER BY
                    CASE
                        WHEN AF.SITAFA = 7
                         AND A.SITAFA = 7 THEN 0
                        WHEN AF.SITAFA <> 7 THEN 0
                        ELSE 1
                    END,
                    A.DATAFA DESC
            ) AS RN
        FROM R038AFA A

        INNER JOIN R034FUN AF
                ON AF.NUMEMP = A.NUMEMP
               AND AF.TIPCOL = A.TIPCOL
               AND AF.NUMCAD = A.NUMCAD

        WHERE A.NUMEMP = :PNUMEMP
          AND AF.TIPCOL = 1
    ) AX
    WHERE AX.RN = 1
) AFA
       ON AFA.NUMEMP = F.NUMEMP
      AND AFA.TIPCOL = F.TIPCOL
      AND AFA.NUMCAD = F.NUMCAD

/* Identifica se o colaborador aparece como gestor */
LEFT JOIN (
    SELECT DISTINCT
        EMPGES,
        TIPGES,
        CADGES
    FROM R009HPC
    WHERE EMPGES = :PNUMEMP
) G1
       ON G1.EMPGES = F.NUMEMP
      AND G1.TIPGES = F.TIPCOL
      AND G1.CADGES = F.NUMCAD

/* Busca um unico gestor por colaborador */
LEFT JOIN (
    SELECT
        HX.EMPCOL,
        HX.TIPCOL,
        HX.CADCOL,
        HX.EMPGES,
        HX.TIPGES,
        HX.CADGES
    FROM (
        SELECT
            H.EMPCOL,
            H.TIPCOL,
            H.CADCOL,
            H.EMPGES,
            H.TIPGES,
            H.CADGES,
            ROW_NUMBER() OVER (
                PARTITION BY
                    H.EMPCOL,
                    H.TIPCOL,
                    H.CADCOL
                ORDER BY
                    H.EMPGES,
                    H.TIPGES,
                    H.CADGES
            ) AS RN
        FROM R009HPC H
        WHERE H.EMPCOL = :PNUMEMP
    ) HX
    WHERE HX.RN = 1
) G2
       ON G2.EMPCOL = F.NUMEMP
      AND G2.TIPCOL = F.TIPCOL
      AND G2.CADCOL = F.NUMCAD

LEFT JOIN R034FUN GES
       ON GES.NUMEMP = G2.EMPGES
      AND GES.TIPCOL = G2.TIPGES
      AND GES.NUMCAD = G2.CADGES

/* Descricao da situacao final */
LEFT JOIN R010SIT SIT
       ON SIT.CODSIT =
          CASE
              WHEN F.SITAFA = 7 THEN 7
              WHEN F.SITAFA <> 1
               AND AFA.SITAFA IS NOT NULL
              THEN AFA.SITAFA
              ELSE F.SITAFA
          END

WHERE F.NUMEMP = :PNUMEMP
  AND F.TIPCOL = 1
  AND F.SITAFA <> 7
ORDER BY F.NUMCAD;