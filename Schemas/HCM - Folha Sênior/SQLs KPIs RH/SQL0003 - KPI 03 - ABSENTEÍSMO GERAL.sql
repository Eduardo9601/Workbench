/* ===
   03 | ABSENTEISMO HCM | V1.0.5 (EQUIPES DO ORGANOGRAMA)
   BASE: V1.0.4, SEM ALTERACAO DA FORMULA OU CLASSIFICACAO DE HORAS.

   SAIDA: UMA LINHA POR EMPRESA / TIPO / CCU / TABORG / NUMLOC.
   - COD_LOCAL E DES_LOCAL CONTINUAM IDENTIFICANDO O CENTRO DE CUSTO.
   - COD_SUBDIVISAO TRAZ R016HIE.CODLOC VIGENTE EM CADA DIA.
   - DES_SUBDIVISAO TRAZ R016ORN.NOMLOC (NOME CADASTRAL ATUAL).
   - TAB_ORG E NUM_LOC PRESERVAM A CHAVE TECNICA DA EQUIPE.
   - UMA OCORRENCIA (CONTRATO/DIA) PERTENCE A UMA EQUIPE, NUNCA
     SIMULTANEAMENTE A UMA LINHA DE EQUIPE E A UM SUBTOTAL DE CCU.
   - SEM HISTORICO DE LOCAL, A LINHA FICA COMO SEM_ORGANOGRAMA;
     ESSA AUSENCIA NAO E MOTIVO PARA ELIMINAR HORAS DO CCU.

   FILTROS ORIGINAIS: :P_DATA_INICIO, :P_DATA_FIM (OBRIGATORIOS);
   :P_EMPRESA, :P_LOCAL (CCUTXT), :P_REDE, :P_REGIAO, :P_TIPO;
   0 / NULL = TODOS OS VALORES PARA OS FILTROS NAO TEMPORAIS.
   ATENCAO: FONTE DO PONTO E ELEGIBILIDADE CONTINUAM V1.0.4.
   VERSAO PARA VALIDACAO NO ORACLE, NAO HOMOLOGADA.
   ===================================================================== */
WITH
/* 01. PARAMETROS - APENAS PARA EXECUÇÃO NO ORACLE - REMOVER PARA SUBIR AO BI*/
PARAM AS (
    SELECT TRUNC(CAST(:P_DATA_INICIO AS DATE)) AS DT_INI,
           TRUNC(CAST(:P_DATA_FIM AS DATE)) AS DT_FIM,
           TO_NUMBER(NULLIF(TRIM(TO_CHAR(:P_EMPRESA)), '0')) AS EMP,
           CASE
             WHEN TRIM(TO_CHAR(:P_REDE)) IN ('1', '01', '001') THEN
              '001'
             WHEN TRIM(TO_CHAR(:P_REDE)) IN ('13', '013') THEN
              '013'
             ELSE
              NULLIF(LTRIM(TRIM(TO_CHAR(:P_REDE)), '0'), '')
           END AS REDE,
           TO_NUMBER(NULLIF(TRIM(TO_CHAR(:P_REGIAO)), '0')) AS REGIAO,
           CASE
             WHEN TRIM(TO_CHAR(:P_LOCAL)) IN ('0', '') THEN
              NULL
             ELSE
              LTRIM(TRIM(TO_CHAR(:P_LOCAL)), '0')
           END AS LOCAL,
           TO_NUMBER(NULLIF(TRIM(TO_CHAR(:P_TIPO)), '0')) AS TIPO
      FROM DUAL
),

/* 02. APURACOES ORIGINAIS (SOMENTE R066SIT) */
SIT_BASE AS (
    SELECT S.NUMEMP,
           S.TIPCOL,
           S.NUMCAD,
           TRUNC(S.DATAPU) AS DIA,
           S.CODSIT,
           S.QTDHOR AS MINUTOS
      FROM R066SIT S
     CROSS JOIN PARAM P
     WHERE S.DATAPU >= P.DT_INI
       AND S.DATAPU < P.DT_FIM + 1
       AND (P.EMP IS NULL OR S.NUMEMP = P.EMP)
),

/* 03. CLASSIFICACAO EXPLICITA */
SIT_CLASS AS (
    SELECT B.*,
           CASE
             WHEN B.CODSIT = 1 THEN
              'TRABALHO'
             WHEN B.CODSIT = 15 THEN
              'FALTA'
             WHEN B.CODSIT IN (14, 64) THEN
              'ATESTADO'
             WHEN B.CODSIT IN (103, 585) THEN
              'ATRASO'
             WHEN B.CODSIT IN (301, 303, 305, 311, 313, 315, 318, 501,
                               502, 503, 505, 506, 511, 513, 515, 517, 520) THEN
              'EXTRAS'
             WHEN B.CODSIT IN (73, 581, 582, 583, 587) THEN
              'PENDENTE'
             ELSE
              'OUTRA'
           END AS CLASSE
      FROM SIT_BASE B
),

/* 04. UMA LINHA POR CONTRATO / DIA. SEM JOIN QUE MULTIPLIQUE HORAS */
SIT_DIA AS (
    SELECT NUMEMP,
           TIPCOL,
           NUMCAD,
           DIA,
           SUM(CASE
                 WHEN CLASSE = 'TRABALHO' THEN
                  MINUTOS
                 ELSE
                  0
               END) AS MIN_TRAB,
           SUM(CASE
                 WHEN CLASSE = 'FALTA' THEN
                  MINUTOS
                 ELSE
                  0
               END) AS MIN_FALTA,
           SUM(CASE
                 WHEN CLASSE = 'ATESTADO' THEN
                  MINUTOS
                 ELSE
                  0
               END) AS MIN_ATEST,
           SUM(CASE
                 WHEN CLASSE = 'ATRASO' THEN
                  MINUTOS
                 ELSE
                  0
               END) AS MIN_ATRASO,
           SUM(CASE
                 WHEN CLASSE = 'EXTRAS' THEN
                  MINUTOS
                 ELSE
                  0
               END) AS MIN_EXTRA,
           SUM(CASE
                 WHEN CLASSE = 'PENDENTE' THEN
                  MINUTOS
                 ELSE
                  0
               END) AS MIN_PEND,
           SUM(CASE
                 WHEN CLASSE = 'OUTRA' THEN
                  MINUTOS
                 ELSE
                  0
               END) AS MIN_OUTRA,
           COUNT(CASE
                   WHEN MINUTOS IS NULL OR MINUTOS < 0 THEN
                    1
                 END) AS QTD_QTDHOR_INVALIDA,
           COUNT(*) AS QTD_SITUACOES
      FROM SIT_CLASS
     GROUP BY NUMEMP, TIPCOL, NUMCAD, DIA
),

/* 05. DATA DE RESCISAO */
RESC AS (
    SELECT R.NUMEMP, R.TIPCOL, R.NUMCAD, MAX(R.DATDEM) AS DAT_DEM
      FROM R042RCM R
     GROUP BY R.NUMEMP, R.TIPCOL, R.NUMCAD
),

/* 06. VINCULOS DO DIA: NAO FILTRAR POR SITUACAO ATUAL */
VINC_DIA AS (
    SELECT S.*,
           F.DATADM,
           F.CODFIL,
           F.CODCCU,
           F.ESTCAR,
           F.CODCAR,
           F.TABORG,
           F.NUMLOC,
           F.SITAFA,
           R.DAT_DEM
      FROM SIT_DIA S
      JOIN R034FUN F
        ON F.NUMEMP = S.NUMEMP
       AND F.TIPCOL = S.TIPCOL
       AND F.NUMCAD = S.NUMCAD
      LEFT JOIN RESC R
        ON R.NUMEMP = S.NUMEMP
       AND R.TIPCOL = S.TIPCOL
       AND R.NUMCAD = S.NUMCAD
     WHERE F.DATADM < S.DIA + 1
       AND (R.DAT_DEM IS NULL OR R.DAT_DEM >= S.DIA)
),

/* 07. CENTRO DE CUSTO NA DATA */
HCC_DIA AS (
    SELECT NUMEMP, TIPCOL, NUMCAD, DIA, CODCCU
      FROM (SELECT V.NUMEMP,
                   V.TIPCOL,
                   V.NUMCAD,
                   V.DIA,
                   H.CODCCU,
                   ROW_NUMBER() OVER (PARTITION BY V.NUMEMP, V.TIPCOL, V.NUMCAD, V.DIA ORDER BY H.DATALT DESC NULLS LAST, H.CODCCU DESC) AS RN
              FROM VINC_DIA V
              LEFT JOIN R038HCC H
                ON H.NUMEMP = V.NUMEMP
               AND H.TIPCOL = V.TIPCOL
               AND H.NUMCAD = V.NUMCAD
               AND H.DATALT < V.DIA + 1)
     WHERE RN = 1
),

/* 08. FILIAL HISTORICA NA DATA */
HFI_DIA AS (
    SELECT NUMEMP,
           TIPCOL,
           NUMCAD,
           DIA,
           EMPATU,
           CODFIL,
           CODCCU,
           TABORG,
           NUMLOC
      FROM (SELECT V.NUMEMP,
                   V.TIPCOL,
                   V.NUMCAD,
                   V.DIA,
                   H.EMPATU,
                   H.CODFIL,
                   H.CODCCU,
                   H.TABORG,
                   H.NUMLOC,
                   ROW_NUMBER() OVER (PARTITION BY V.NUMEMP, V.TIPCOL, V.NUMCAD, V.DIA ORDER BY H.DATALT DESC NULLS LAST, H.CODFIL DESC) AS RN
              FROM VINC_DIA V
              LEFT JOIN R038HFI H
                ON H.NUMEMP = V.NUMEMP
               AND H.TIPCOL = V.TIPCOL
               AND H.NUMCAD = V.NUMCAD
               AND H.DATALT < V.DIA + 1)
     WHERE RN = 1
),

/* 09. LOCAL / ORGANOGRAMA HISTORICO NA DATA */
HLO_DIA AS (
    SELECT NUMEMP, TIPCOL, NUMCAD, DIA, TABORG, NUMLOC
      FROM (SELECT V.NUMEMP,
                   V.TIPCOL,
                   V.NUMCAD,
                   V.DIA,
                   H.TABORG,
                   H.NUMLOC,
                   ROW_NUMBER() OVER (PARTITION BY V.NUMEMP, V.TIPCOL, V.NUMCAD, V.DIA ORDER BY H.DATALT DESC NULLS LAST, H.NUMLOC DESC) AS RN
              FROM VINC_DIA V
              LEFT JOIN R038HLO H
                ON H.NUMEMP = V.NUMEMP
               AND H.TIPCOL = V.TIPCOL
               AND H.NUMCAD = V.NUMCAD
               AND H.DATALT < V.DIA + 1)
     WHERE RN = 1
),

/* 10. RESOLUCAO UNICA DA LOTACAO DO CONTRATO/DIA */
LOT_DIA AS (
    SELECT V.*,
           COALESCE(HF.EMPATU, V.NUMEMP) AS EMP_HIST,
           COALESCE(HF.CODFIL, V.CODFIL) AS FIL_HIST,
           COALESCE(HC.CODCCU, HF.CODCCU, V.CODCCU) AS CCU_HIST,
           COALESCE(HL.TABORG, HF.TABORG, V.TABORG) AS TAB_HIST,
           COALESCE(HL.NUMLOC, HF.NUMLOC, V.NUMLOC) AS LOC_HIST,
           CASE
             WHEN HC.CODCCU IS NOT NULL THEN
              'HCC'
             WHEN HF.CODCCU IS NOT NULL THEN
              'HFI'
             ELSE
              'FICHA_ATUAL'
           END AS FONTE_CCU
      FROM VINC_DIA V
      LEFT JOIN HCC_DIA HC
        ON HC.NUMEMP = V.NUMEMP
       AND HC.TIPCOL = V.TIPCOL
       AND HC.NUMCAD = V.NUMCAD
       AND HC.DIA = V.DIA
      LEFT JOIN HFI_DIA HF
        ON HF.NUMEMP = V.NUMEMP
       AND HF.TIPCOL = V.TIPCOL
       AND HF.NUMCAD = V.NUMCAD
       AND HF.DIA = V.DIA
      LEFT JOIN HLO_DIA HL
        ON HL.NUMEMP = V.NUMEMP
       AND HL.TIPCOL = V.TIPCOL
       AND HL.NUMCAD = V.NUMCAD
       AND HL.DIA = V.DIA
),

/* 11. ORGANOGRAMA VIGENTE NA DATA: SEM EXCLUIR O VINCULO */
ORG_DIA AS (
    SELECT NUMEMP, TIPCOL, NUMCAD, DIA, CODLOC
      FROM (SELECT L.NUMEMP,
                   L.TIPCOL,
                   L.NUMCAD,
                   L.DIA,
                   H.CODLOC,
                   ROW_NUMBER() OVER (PARTITION BY L.NUMEMP, L.TIPCOL, L.NUMCAD, L.DIA ORDER BY H.DATINI DESC NULLS LAST, H.NUMLOC DESC) AS RN
              FROM LOT_DIA L
              LEFT JOIN R016HIE H
                ON H.TABORG = L.TAB_HIST
               AND H.NUMLOC = L.LOC_HIST
               AND H.DATINI < L.DIA + 1
               AND (H.DATFIM IS NULL OR H.DATFIM >= L.DIA))
     WHERE RN = 1
),

/* 12. R018CCU (C): USU_TIPFIL; R030FIL (FIL): USU_CODRED */
LOCAL_DIA AS (
    SELECT L.*,
           C.NOMCCU AS DES_CCU,
           C.USU_TIPFIL AS COD_TIPO,
           L.TAB_HIST AS TAB_ORG_EQUIPE,
           L.LOC_HIST AS NUM_LOC_EQUIPE,
           O.CODLOC AS COD_SUBDIVISAO,
           N.NOMLOC AS DES_SUBDIVISAO,
           CASE
             WHEN L.TAB_HIST IS NULL OR L.LOC_HIST IS NULL THEN
              'SEM_HISTORICO_ORG'
             WHEN O.CODLOC IS NULL THEN
              'SEM_HIERARQUIA_NA_DATA'
             WHEN N.NUMLOC IS NULL THEN
              'SEM_NOME_ORG'
             ELSE
              'OK'
           END AS STATUS_SUBDIVISAO,
           CASE
             WHEN TRIM(C.CCUTXT) IS NULL THEN
              NULL
             WHEN REGEXP_LIKE(TRIM(C.CCUTXT), '^[0-9]+$') THEN
              TO_CHAR(TO_NUMBER(TRIM(C.CCUTXT)))
             ELSE
              TRIM(C.CCUTXT)
           END AS COD_LOCAL,
           CASE
             WHEN C.USU_TIPFIL = 2 THEN
              '001'
             WHEN C.USU_TIPFIL = 3 THEN
              '013'
             WHEN C.USU_TIPFIL = 1 THEN
              TO_CHAR(FIL.USU_CODRED)
           END AS COD_REDE,
           CASE
             WHEN C.USU_TIPFIL = 2 THEN
              1 -- ADM: REGIAO 001
             WHEN C.USU_TIPFIL = 3 THEN
              13 -- CD:  REGIAO 013
             WHEN C.USU_TIPFIL = 1 AND FIL.USU_CODRED = 40 THEN
              940 -- FRANCO:  REGIAO 940
             WHEN C.USU_TIPFIL = 1 AND REGEXP_COUNT(O.CODLOC, '[.]') >= 3 AND
                  REGEXP_LIKE(REGEXP_SUBSTR(O.CODLOC, '[^.]+', 1, 3),
                              '^[0-9]+$') THEN
              TO_NUMBER(REGEXP_SUBSTR(O.CODLOC, '[^.]+', 1, 3))
           END AS COD_REGIAO
      FROM LOT_DIA L
      LEFT JOIN R018CCU C
        ON C.NUMEMP = L.EMP_HIST
       AND C.CODCCU = L.CCU_HIST
      LEFT JOIN R030FIL FIL
        ON FIL.NUMEMP = L.EMP_HIST
       AND FIL.CODFIL = L.FIL_HIST
      LEFT JOIN ORG_DIA O
        ON O.NUMEMP = L.NUMEMP
       AND O.TIPCOL = L.TIPCOL
       AND O.NUMCAD = L.NUMCAD
       AND O.DIA = L.DIA
      LEFT JOIN R016ORN N
        ON N.TABORG = L.TAB_HIST
       AND N.NUMLOC = L.LOC_HIST
),

/* 13. FATO DIARIO: UM CONTRATO, UM DIA, UMA LOTACAO */
FATO_DIA AS (
    SELECT L.NUMEMP,
           L.TIPCOL,
           L.NUMCAD,
           L.DIA,
           L.EMP_HIST AS EMPRESA,
           L.COD_TIPO,
           L.COD_LOCAL,
           NVL(L.DES_CCU, 'SEM DESCRICAO / LOTACAO') AS DES_LOCAL,
           L.TAB_ORG_EQUIPE,
           L.NUM_LOC_EQUIPE,
           L.COD_SUBDIVISAO,
           L.DES_SUBDIVISAO,
           L.STATUS_SUBDIVISAO,
           L.COD_REDE,
           L.COD_REGIAO,
           L.FONTE_CCU,
           L.ESTCAR,
           L.CODCAR,
           L.MIN_TRAB,
           L.MIN_FALTA,
           L.MIN_ATEST,
           L.MIN_ATRASO,
           L.MIN_EXTRA,
           L.MIN_PEND,
           L.MIN_OUTRA,
           L.QTD_QTDHOR_INVALIDA,
           L.QTD_SITUACOES,
           CASE
             WHEN L.COD_LOCAL IS NULL OR L.COD_TIPO IS NULL THEN
              'LOCAL_NAO_RESOLVIDO'
             WHEN L.FONTE_CCU = 'FICHA_ATUAL' THEN
              'HISTORICO_CCU_AUSENTE'
             WHEN L.COD_TIPO = 1 AND L.COD_REDE IS NULL THEN
              'REDE_AUSENTE'
             WHEN L.COD_TIPO = 1 AND L.COD_REGIAO IS NULL THEN
              'REGIAO_AUSENTE'
             ELSE
              'OK'
           END AS STATUS_LOT
      FROM LOCAL_DIA L
),

/* 14. HISTORICO DE APURACAO DE PONTO VIGENTE NO DIA.
   R038APU.APUPON: 1 = NORMAL. OS DEMAIS TIPOS NAO ENTRAM NO INDICE.
   SEM HISTORICO TAMBEM NAO ENTRA, E DEVE SER AUDITADO. */
APU_DIA AS (
    SELECT NUMEMP, TIPCOL, NUMCAD, DIA, APUPON, INIAPU
      FROM (SELECT F.NUMEMP,
                   F.TIPCOL,
                   F.NUMCAD,
                   F.DIA,
                   H.APUPON,
                   H.INIAPU,
                   ROW_NUMBER() OVER (PARTITION BY F.NUMEMP, F.TIPCOL, F.NUMCAD, F.DIA ORDER BY H.INIAPU DESC NULLS LAST, H.APUPON DESC NULLS LAST) RN
              FROM FATO_DIA F
              LEFT JOIN R038APU H
                ON H.NUMEMP = F.NUMEMP
               AND H.TIPCOL = F.TIPCOL
               AND H.NUMCAD = F.NUMCAD
               AND H.INIAPU < F.DIA + 1)
     WHERE RN = 1
),

/* 15. CARGO HISTORICO VIGENTE NO DIA.
   QUANDO INEXISTENTE, USAR CODIGO DA FICHA ATUAL, COM ORIGEM VISIVEL. */
CAR_DIA AS (
    SELECT NUMEMP, TIPCOL, NUMCAD, DIA, ESTCAR, CODCAR, DATALT
      FROM (SELECT F.NUMEMP,
                   F.TIPCOL,
                   F.NUMCAD,
                   F.DIA,
                   H.ESTCAR,
                   H.CODCAR,
                   H.DATALT,
                   ROW_NUMBER() OVER (PARTITION BY F.NUMEMP, F.TIPCOL, F.NUMCAD, F.DIA ORDER BY H.DATALT DESC NULLS LAST, H.ESTCAR DESC NULLS LAST, H.CODCAR DESC NULLS LAST) RN
              FROM FATO_DIA F
              LEFT JOIN R038HCA H
                ON H.NUMEMP = F.NUMEMP
               AND H.TIPCOL = F.TIPCOL
               AND H.NUMCAD = F.NUMCAD
               AND H.DATALT < F.DIA + 1)
     WHERE RN = 1
),

/* 16. ELEGIBILIDADE, SEM ALTERAR OS MINUTOS APURADOS.
   0 = CARGO ELEGIVEL; 1 = APRENDIZ/ESTAGIARIO. */
ELEG_DIA AS (
    SELECT F.*,
           P.APUPON,
           P.INIAPU AS DT_INI_APU,
           NVL(C.TITCAR, C.TITRED) AS DES_CARGO,
           CASE
             WHEN H.ESTCAR IS NOT NULL AND H.CODCAR IS NOT NULL THEN
              'R038HCA'
             ELSE
              'FICHA_ATUAL_SEM_HIST_CARGO'
           END AS FONTE_CARGO,
           CASE
             WHEN REGEXP_LIKE(TRANSLATE(UPPER(NVL(C.TITCAR,
                                                  NVL(C.TITRED, ' '))),
                                        'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                                        'AAAAAEEEEIIIIOOOOOUUUUC'),
                              'APRENDIZ|ESTAGI') THEN
              1
             ELSE
              0
           END AS FLAG_CARGO_EXCLUIR,
           CASE
             WHEN P.APUPON = 1 THEN
              'APURACAO_NORMAL'
             WHEN P.APUPON IS NULL THEN
              'SEM_HISTORICO_APURACAO'
             ELSE
              'DISPENSADO_OU_OUTRO_TIPO'
           END AS STATUS_APU
      FROM FATO_DIA F
      LEFT JOIN APU_DIA P
        ON P.NUMEMP = F.NUMEMP
       AND P.TIPCOL = F.TIPCOL
       AND P.NUMCAD = F.NUMCAD
       AND P.DIA = F.DIA
      LEFT JOIN CAR_DIA H
        ON H.NUMEMP = F.NUMEMP
       AND H.TIPCOL = F.TIPCOL
       AND H.NUMCAD = F.NUMCAD
       AND H.DIA = F.DIA
      LEFT JOIN R024CAR C
        ON C.ESTCAR = COALESCE(H.ESTCAR, F.ESTCAR)
       AND C.CODCAR = COALESCE(H.CODCAR, F.CODCAR)
),

/* 17. FILTROS APLICADOS AO FATO, ANTES DE RESUMIR */
FATO_FIL AS (
    SELECT F.*
      FROM ELEG_DIA F
     CROSS JOIN PARAM P
     WHERE F.APUPON = 1
          -- PARA PERMITIR APRENDIZ / ESTAGIARIO, COMENTE SOMENTE A LINHA ABAIXO:
       AND F.FLAG_CARGO_EXCLUIR = 0
       AND (P.TIPO IS NULL OR F.COD_TIPO = P.TIPO)
       AND (P.LOCAL IS NULL OR F.COD_LOCAL = P.LOCAL)
       AND (P.REDE IS NULL OR F.COD_REDE = P.REDE)
       AND (P.REGIAO IS NULL OR F.COD_REGIAO = P.REGIAO)
)


/* === RESULTADO - DETALHE POR EQUIPE: NAO GERA SUBTOTAL DO MESMO CCU AQUI. === */
SELECT F.EMPRESA AS EMPRESA,
       F.NUM_LOC_EQUIPE AS ORGANOGRAMA,
       NVL(F.COD_LOCAL, 'SEM_LOCAL') AS COD_LOCAL,
	   NVL(MAX(F.DES_SUBDIVISAO) KEEP(DENSE_RANK LAST ORDER BY F.DIA),
           'SEM_DESCRICAO_ORG') AS DES_LOCAL,
       F.COD_TIPO AS COD_TIPO,
       MAX(F.COD_REDE) KEEP(DENSE_RANK LAST ORDER BY F.DIA) AS COD_REDE,
       CASE
         WHEN F.COD_TIPO = 2 THEN
          '001'
         WHEN F.COD_TIPO = 3 THEN
          '013'
         ELSE
          TO_CHAR(MAX(F.COD_REGIAO) KEEP(DENSE_RANK LAST ORDER BY F.DIA))
       END AS COD_REGIAO,       
       NVL(MAX(F.COD_SUBDIVISAO) KEEP(DENSE_RANK LAST ORDER BY F.DIA),
           'SEM_ORGANOGRAMA') AS COD_SUBDIVISAO,
       NVL(MAX(F.DES_SUBDIVISAO) KEEP(DENSE_RANK LAST ORDER BY F.DIA),
           'SEM_DESCRICAO_ORG') AS DES_SUBDIVISAO,
       P.DT_INI AS DATA_INICIAL,
       P.DT_FIM AS DATA_FINAL,
       ROUND(SUM(F.MIN_TRAB) / 60, 2) AS HORAS_TRABALHADAS,
       ROUND(SUM(F.MIN_FALTA) / 60, 2) AS HORAS_FALTAS,
       ROUND(SUM(F.MIN_ATEST) / 60, 2) AS HORAS_ATESTADOS,
       '(FALTAS + ATESTADOS) * 100 / HORAS TRABALHADAS' AS FORMULA     
       
  FROM FATO_FIL F
 CROSS JOIN PARAM P
 WHERE F.MIN_TRAB <> 0
 GROUP BY F.EMPRESA,
          F.COD_TIPO,
          F.COD_LOCAL,
          F.TAB_ORG_EQUIPE,
          F.NUM_LOC_EQUIPE,
          P.DT_INI,
          P.DT_FIM
 ORDER BY CASE F.COD_TIPO
            WHEN 1 THEN
             1
            WHEN 2 THEN
             2
            WHEN 3 THEN
             3
            ELSE
             4
          END,
          CASE
            WHEN REGEXP_LIKE(F.COD_LOCAL, '^[0-9]+$') THEN
             TO_NUMBER(F.COD_LOCAL)
          END NULLS LAST,
          F.COD_LOCAL,
          COD_SUBDIVISAO;
