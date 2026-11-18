/* ============================================================================
   HCM SENIOR | QUANTITATIVO ATUAL POR FILIAL
   Banco: Oracle | Data-base: hoje (TRUNC(SYSDATE))

   Um registro por EMPRESA + FILIAL.
   Todas as áreas de uma filial (inclusive administrativo e logística)
   são consolidadas na MESMA linha.

   População: TIPCOL = 1, admitidos até hoje, com situação atual
   cujo tipo não seja 7 (Demitido).
   Afastados permanecem no quantitativo.

   QTD_GERENTES (perfil gerencial/superior): GERENTE, COMPRADOR,
   SUPERVISOR ou DIRETOR no título do cargo, exceto DIRETORIA.
   Mesma classificação por título do relatório gerencial RE103.
   Preservado o alias QTD_GERENTES por compatibilidade com o BI.

   Alterar o escopo de empresa, se desejar, na linha comentada indicada.
   Indicadores:
   QTD_COLABORADORES = empregados que NAO pertencem ao perfil gerencial.
   QTD_GERENTES      = empregados do perfil gerencial/superior.
   QTD_MASCULINO     = todos os empregados masculinos (inclusive gerenciais).
   QTD_FEMININO      = todos os empregados femininos (inclusive gerenciais).
   TOTAL_COLABORADORES = todos os empregados do agrupamento.
   Conferencia: QTD_COLABORADORES + QTD_GERENTES = TOTAL_COLABORADORES.
   
   ============================================================================ */

WITH COLABORADORES_ATIVOS AS (
    SELECT
        F.NUMEMP,
        F.CODFIL,
        F.TIPCOL,
        F.NUMCAD,
        F.TIPSEX,
        C.TITRED AS DESCRICAO_CARGO,
        CASE
            WHEN (
                    UPPER(C.TITRED) LIKE '%GERENTE%'
                 OR UPPER(C.TITRED) LIKE '%COMPRADOR%'
                 OR UPPER(C.TITRED) LIKE '%SUPERVISOR%'
                 OR UPPER(C.TITRED) LIKE '%DIRETOR%'
                 )
             AND UPPER(C.TITRED) NOT LIKE '%DIRETORIA%'
            THEN 1 ELSE 0
        END AS FLG_PERFIL_GERENCIAL
    FROM R034FUN F
    INNER JOIN R010SIT S
        ON S.CODSIT = F.SITAFA
    LEFT JOIN R024CAR C
        ON C.ESTCAR = F.ESTCAR
       AND C.CODCAR = F.CODCAR
    WHERE F.TIPCOL = 1
      AND F.DATADM <= TRUNC(SYSDATE)
      AND S.TIPSIT <> 7
      -- S.TIPSIT <> 7 exclui desligados; afastados permanecem.
       AND F.NUMEMP = 8  -- opcional: restringir à empresa 8
)
SELECT
    B.NUMEMP                                  AS COD_EMPRESA,
    FIL.CODFIL                                AS COD_FILIAL,
    FIL.NOMFIL                                AS NOME_FILIAL,
    SUM(CASE WHEN B.FLG_PERFIL_GERENCIAL = 0 THEN 1 ELSE 0 END)
                                              AS QTD_COLABORADORES,
    SUM(B.FLG_PERFIL_GERENCIAL)               AS QTD_GERENTES,
    SUM(CASE WHEN B.TIPSEX = 'M' THEN 1 ELSE 0 END)
                                              AS QTD_MASCULINO,
    SUM(CASE WHEN B.TIPSEX = 'F' THEN 1 ELSE 0 END)
                                              AS QTD_FEMININO,
    COUNT(*)                                  AS TOTAL_COLABORADORES
FROM COLABORADORES_ATIVOS B
INNER JOIN R030FIL FIL
    ON FIL.NUMEMP = B.NUMEMP
   AND FIL.CODFIL = B.CODFIL
GROUP BY
    B.NUMEMP,
    FIL.CODFIL,
    FIL.NOMFIL
ORDER BY
    B.NUMEMP,
    FIL.CODFIL;
