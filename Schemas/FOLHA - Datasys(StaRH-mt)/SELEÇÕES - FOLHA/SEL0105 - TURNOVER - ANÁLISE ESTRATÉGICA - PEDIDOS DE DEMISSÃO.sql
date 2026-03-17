/* SEL0105 - TURNOVER POR PEDIDOS DE DEMISSÃO ACUMULADO */
/* Acumulado do ano por UNIDADE, por REDE e EMPRESA */
/* Considera somente COD_DEMISSAO IN (14, 21) no numerador */

WITH
/* =========================================================
   PARÂMETROS
   ========================================================= */
PARAMS AS (
    /*SELECT TO_DATE('&DATA_INICIO', 'DD/MM/YYYY') AS D_INI,
           TO_DATE('&DATA_FIM',    'DD/MM/YYYY') AS D_FIM
      FROM DUAL*/

      SELECT :DATA_INICIO AS D_INI,
             :DATA_FIM AS D_FIM
      FROM DUAL
),

/* =========================================================
   CALENDÁRIO MENSAL
   ========================================================= */
DATAS_REF AS (
    SELECT ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1) AS DTA_INI,
           LAST_DAY(ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1)) AS DTA_FIM,
           TO_CHAR(ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1), 'MM/YYYY') AS MES_ANO,
           EXTRACT(YEAR FROM ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1)) AS ANO
      FROM PARAMS P
    CONNECT BY LEVEL <= MONTHS_BETWEEN(ADD_MONTHS(TRUNC(P.D_FIM, 'MM'), 1),
                                       TRUNC(P.D_INI, 'MM'))
),

/* =========================================================
   BASE MENSAL LIMPA
   - 1 linha por contrato x mês
   - amarra a lotação do contrato no fechamento do mês
   - usada para efetivo e admitidos
   ========================================================= */
BASE_MENSAL AS (
    SELECT DISTINCT
           M.ANO,
           M.DTA_INI,
           M.DTA_FIM,
           M.MES_ANO,

           CT.COD_CONTRATO,
           CT.DES_PESSOA,
           CT.DATA_ADMISSAO,
           CT.DATA_DEMISSAO,
           CT.COD_DEMISSAO,
           CT.STATUS,

           ORG.COD_EMP,
           ORG.COD_ORGANOGRAMA,
           ORG.COD_UNIDADE,
           ORG.DES_UNIDADE,
           ORG.COD_REDE,
           ORG.DES_REDE,
           ORG.COD_TIPO,

           FN.COD_FUNCAO,
           FN.DES_FUNCAO
      FROM DATAS_REF M
      JOIN V_DADOS_CONTRATO_AVT CT
        ON CT.DATA_ADMISSAO <= M.DTA_FIM
       AND NVL(CT.DATA_DEMISSAO, DATE '2999-12-31') >= M.DTA_INI
      JOIN VH_EST_ORG_CONTRATO_AVT ORG
        ON ORG.COD_CONTRATO = CT.COD_CONTRATO
       AND M.DTA_FIM BETWEEN ORG.DATA_INI_ORG AND ORG.DATA_FIM_ORG
      JOIN VH_CARGO_CONTRATO_AVT FN
        ON FN.COD_CONTRATO = CT.COD_CONTRATO
       AND M.DTA_FIM BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH
     WHERE ORG.COD_EMP = 8
       AND ORG.COD_TIPO IN (1, 2, 3)
       AND (
             (ORG.COD_TIPO = 1 AND ORG.EDICAO_ORG_4 IS NOT NULL)
             OR ORG.COD_TIPO IN (2, 3)
           )
       AND UPPER(FN.DES_FUNCAO) NOT LIKE '%ESTAGIARIO%'
       AND UPPER(FN.DES_FUNCAO) NOT LIKE '%APRENDIZ%'
       AND UPPER(FN.DES_FUNCAO) NOT LIKE '%TEMPORARIO%'
),

/* =========================================================
   BASE DE DEMITIDOS
   - amarra unidade/rede/função na DATA DA DEMISSÃO
   - usada somente para o numerador
   ========================================================= */
BASE_DEMITIDOS AS (
    SELECT DISTINCT
           M.ANO,
           M.DTA_INI,
           M.DTA_FIM,
           M.MES_ANO,

           CT.COD_CONTRATO,
           CT.DES_PESSOA,
           CT.DATA_DEMISSAO,
           CT.COD_DEMISSAO,

           ORG.COD_EMP,
           ORG.COD_ORGANOGRAMA,
           ORG.COD_UNIDADE,
           ORG.DES_UNIDADE,
           ORG.COD_REDE,
           ORG.DES_REDE,
           ORG.COD_TIPO,

           FN.COD_FUNCAO,
           FN.DES_FUNCAO
      FROM DATAS_REF M
      JOIN V_DADOS_CONTRATO_AVT CT
        ON CT.DATA_DEMISSAO >= M.DTA_INI
       AND CT.DATA_DEMISSAO <= M.DTA_FIM
       AND CT.COD_DEMISSAO IN (14, 21)

      JOIN VH_EST_ORG_CONTRATO_AVT ORG
        ON ORG.COD_CONTRATO = CT.COD_CONTRATO
       AND CT.DATA_DEMISSAO >= ORG.DATA_INI_ORG
       AND CT.DATA_DEMISSAO <= ORG.DATA_FIM_ORG

      LEFT JOIN VH_CARGO_CONTRATO_AVT FN
        ON FN.COD_CONTRATO = CT.COD_CONTRATO
       AND CT.DATA_DEMISSAO >= FN.DATA_INI_CLH
       AND CT.DATA_DEMISSAO <= FN.DATA_FIM_CLH

     WHERE ORG.COD_EMP = 8
       AND ORG.COD_TIPO IN (1, 2, 3)
       AND (
             (ORG.COD_TIPO = 1 AND ORG.EDICAO_ORG_4 IS NOT NULL)
             OR ORG.COD_TIPO IN (2, 3)
           )
       AND (
             FN.COD_CONTRATO IS NULL
             OR (
                  UPPER(NVL(FN.DES_FUNCAO, '')) NOT LIKE '%ESTAGIARIO%'
              AND UPPER(NVL(FN.DES_FUNCAO, '')) NOT LIKE '%APRENDIZ%'
              AND UPPER(NVL(FN.DES_FUNCAO, '')) NOT LIKE '%TEMPORARIO%'
             )
           )
),
/* =========================================================
   DEMITIDOS MENSAIS - UNIDADE
   ========================================================= */
DEMITIDOS_UNIDADE AS (
    SELECT BD.ANO,
           BD.DTA_INI,
           BD.DTA_FIM,
           BD.COD_TIPO,
           BD.COD_ORGANOGRAMA,
           BD.COD_UNIDADE,
           BD.DES_UNIDADE,
           BD.COD_REDE,
           BD.DES_REDE,
           COUNT(DISTINCT BD.COD_CONTRATO) AS DEMITIDOS_MES
      FROM BASE_DEMITIDOS BD
     WHERE BD.COD_TIPO = 1
     GROUP BY BD.ANO,
              BD.DTA_INI,
              BD.DTA_FIM,
              BD.COD_TIPO,
              BD.COD_ORGANOGRAMA,
              BD.COD_UNIDADE,
              BD.DES_UNIDADE,
              BD.COD_REDE,
              BD.DES_REDE
),

/* =========================================================
   DEMITIDOS MENSAIS - REDE
   ========================================================= */
DEMITIDOS_REDE AS (
    SELECT BD.ANO,
           BD.DTA_INI,
           BD.DTA_FIM,
           BD.COD_TIPO,
           BD.COD_REDE,
           BD.DES_REDE,
           COUNT(DISTINCT BD.COD_CONTRATO) AS DEMITIDOS_MES
      FROM BASE_DEMITIDOS BD
     WHERE BD.COD_TIPO IN (1, 2, 3)
     GROUP BY BD.ANO,
              BD.DTA_INI,
              BD.DTA_FIM,
              BD.COD_TIPO,
              BD.COD_REDE,
              BD.DES_REDE
),

/* =========================================================
   DEMITIDOS MENSAIS - EMPRESA
   ========================================================= */
DEMITIDOS_EMPRESA AS (
    SELECT BD.ANO,
           BD.DTA_INI,
           BD.DTA_FIM,
           COUNT(DISTINCT BD.COD_CONTRATO) AS DEMITIDOS_MES
      FROM BASE_DEMITIDOS BD
     WHERE BD.COD_TIPO IN (1, 2, 3)
     GROUP BY BD.ANO,
              BD.DTA_INI,
              BD.DTA_FIM
),

/* =========================================================
   MÉTRICAS MENSAIS - UNIDADE
   ========================================================= */
MENSAL_UNIDADE AS (
    SELECT CAST('UNIDADE' AS VARCHAR2(20)) AS NIVEL,
           CAST(BM.ANO AS NUMBER(4)) AS ANO,
           CAST(BM.DTA_INI AS DATE) AS DTA_INI,
           CAST(BM.DTA_FIM AS DATE) AS DTA_FIM,
           CAST(BM.COD_TIPO AS NUMBER(2)) AS COD_TIPO,
           CAST(BM.COD_ORGANOGRAMA AS VARCHAR2(30)) AS COD_ORGANOGRAMA,
           CAST(BM.COD_UNIDADE AS VARCHAR2(30)) AS COD_UNIDADE,
           CAST(BM.DES_UNIDADE AS VARCHAR2(200)) AS DES_UNIDADE,
           CAST(BM.COD_REDE AS VARCHAR2(30)) AS COD_REDE,
           CAST(BM.DES_REDE AS VARCHAR2(200)) AS DES_REDE,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO <= BM.DTA_INI
                AND NVL(BM.DATA_DEMISSAO, DATE '2999-12-31') >= BM.DTA_INI
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS EFETIVO_INICIAL_MES,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO <= BM.DTA_FIM
                AND NVL(BM.DATA_DEMISSAO, DATE '2999-12-31') >= BM.DTA_FIM
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS EFETIVO_FINAL_MES,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO BETWEEN BM.DTA_INI AND BM.DTA_FIM
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS ADMITIDOS_MES
      FROM BASE_MENSAL BM
     WHERE BM.COD_TIPO = 1
     GROUP BY BM.ANO,
              BM.DTA_INI,
              BM.DTA_FIM,
              BM.COD_TIPO,
              BM.COD_ORGANOGRAMA,
              BM.COD_UNIDADE,
              BM.DES_UNIDADE,
              BM.COD_REDE,
              BM.DES_REDE
),

/* =========================================================
   MÉTRICAS MENSAIS - REDE
   ========================================================= */
MENSAL_REDE AS (
    SELECT CAST('REDE' AS VARCHAR2(20)) AS NIVEL,
           CAST(BM.ANO AS NUMBER(4)) AS ANO,
           CAST(BM.DTA_INI AS DATE) AS DTA_INI,
           CAST(BM.DTA_FIM AS DATE) AS DTA_FIM,
           CAST(BM.COD_TIPO AS NUMBER(2)) AS COD_TIPO,
           CAST(NULL AS VARCHAR2(30)) AS COD_ORGANOGRAMA,
           CAST(NULL AS VARCHAR2(30)) AS COD_UNIDADE,
           CAST(NULL AS VARCHAR2(200)) AS DES_UNIDADE,
           CAST(BM.COD_REDE AS VARCHAR2(30)) AS COD_REDE,
           CAST(BM.DES_REDE AS VARCHAR2(200)) AS DES_REDE,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO <= BM.DTA_INI
                AND NVL(BM.DATA_DEMISSAO, DATE '2999-12-31') >= BM.DTA_INI
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS EFETIVO_INICIAL_MES,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO <= BM.DTA_FIM
                AND NVL(BM.DATA_DEMISSAO, DATE '2999-12-31') >= BM.DTA_FIM
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS EFETIVO_FINAL_MES,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO BETWEEN BM.DTA_INI AND BM.DTA_FIM
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS ADMITIDOS_MES
      FROM BASE_MENSAL BM
     WHERE BM.COD_TIPO IN (1, 2, 3)
     GROUP BY BM.ANO,
              BM.DTA_INI,
              BM.DTA_FIM,
              BM.COD_TIPO,
              BM.COD_REDE,
              BM.DES_REDE
),

/* =========================================================
   MÉTRICAS MENSAIS - EMPRESA
   ========================================================= */
MENSAL_EMPRESA AS (
    SELECT CAST('EMPRESA' AS VARCHAR2(20)) AS NIVEL,
           CAST(BM.ANO AS NUMBER(4)) AS ANO,
           CAST(BM.DTA_INI AS DATE) AS DTA_INI,
           CAST(BM.DTA_FIM AS DATE) AS DTA_FIM,
           CAST(0 AS NUMBER(2)) AS COD_TIPO,
           CAST(NULL AS VARCHAR2(30)) AS COD_ORGANOGRAMA,
           CAST(NULL AS VARCHAR2(30)) AS COD_UNIDADE,
           CAST('EMPRESA' AS VARCHAR2(200)) AS DES_UNIDADE,
           CAST(NULL AS VARCHAR2(30)) AS COD_REDE,
           CAST('EMPRESA' AS VARCHAR2(200)) AS DES_REDE,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO <= BM.DTA_INI
                AND NVL(BM.DATA_DEMISSAO, DATE '2999-12-31') >= BM.DTA_INI
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS EFETIVO_INICIAL_MES,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO <= BM.DTA_FIM
                AND NVL(BM.DATA_DEMISSAO, DATE '2999-12-31') >= BM.DTA_FIM
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS EFETIVO_FINAL_MES,

           CAST(COUNT(DISTINCT CASE
               WHEN BM.DATA_ADMISSAO BETWEEN BM.DTA_INI AND BM.DTA_FIM
               THEN BM.COD_CONTRATO
           END) AS NUMBER) AS ADMITIDOS_MES
      FROM BASE_MENSAL BM
     WHERE BM.COD_TIPO IN (1, 2, 3)
     GROUP BY BM.ANO,
              BM.DTA_INI,
              BM.DTA_FIM
),

/* =========================================================
   MENSAL FINAL - UNIDADE
   ========================================================= */
MENSAL_UNIDADE_FINAL AS (
    SELECT MU.NIVEL,
           MU.ANO,
           MU.DTA_INI,
           MU.DTA_FIM,
           MU.COD_TIPO,
           MU.COD_ORGANOGRAMA,
           MU.COD_UNIDADE,
           MU.DES_UNIDADE,
           MU.COD_REDE,
           MU.DES_REDE,
           MU.EFETIVO_INICIAL_MES,
           MU.EFETIVO_FINAL_MES,
           MU.ADMITIDOS_MES,
           CAST(NVL(DU.DEMITIDOS_MES, 0) AS NUMBER) AS DEMITIDOS_MES
      FROM MENSAL_UNIDADE MU
      LEFT JOIN DEMITIDOS_UNIDADE DU
        ON DU.ANO             = MU.ANO
       AND DU.DTA_INI         = MU.DTA_INI
       AND DU.DTA_FIM         = MU.DTA_FIM
       AND DU.COD_TIPO        = MU.COD_TIPO
       AND DU.COD_ORGANOGRAMA = MU.COD_ORGANOGRAMA
),

/* =========================================================
   MENSAL FINAL - REDE
   ========================================================= */
MENSAL_REDE_FINAL AS (
    SELECT MR.NIVEL,
           MR.ANO,
           MR.DTA_INI,
           MR.DTA_FIM,
           MR.COD_TIPO,
           MR.COD_ORGANOGRAMA,
           MR.COD_UNIDADE,
           MR.DES_UNIDADE,
           MR.COD_REDE,
           MR.DES_REDE,
           MR.EFETIVO_INICIAL_MES,
           MR.EFETIVO_FINAL_MES,
           MR.ADMITIDOS_MES,
           CAST(NVL(DR.DEMITIDOS_MES, 0) AS NUMBER) AS DEMITIDOS_MES
      FROM MENSAL_REDE MR
      LEFT JOIN DEMITIDOS_REDE DR
        ON DR.ANO      = MR.ANO
       AND DR.DTA_INI  = MR.DTA_INI
       AND DR.DTA_FIM  = MR.DTA_FIM
       AND DR.COD_TIPO = MR.COD_TIPO
       AND DR.COD_REDE = MR.COD_REDE
),

/* =========================================================
   MENSAL FINAL - EMPRESA
   ========================================================= */
MENSAL_EMPRESA_FINAL AS (
    SELECT ME.NIVEL,
           ME.ANO,
           ME.DTA_INI,
           ME.DTA_FIM,
           ME.COD_TIPO,
           ME.COD_ORGANOGRAMA,
           ME.COD_UNIDADE,
           ME.DES_UNIDADE,
           ME.COD_REDE,
           ME.DES_REDE,
           ME.EFETIVO_INICIAL_MES,
           ME.EFETIVO_FINAL_MES,
           ME.ADMITIDOS_MES,
           CAST(NVL(DE.DEMITIDOS_MES, 0) AS NUMBER) AS DEMITIDOS_MES
      FROM MENSAL_EMPRESA ME
      LEFT JOIN DEMITIDOS_EMPRESA DE
        ON DE.ANO     = ME.ANO
       AND DE.DTA_INI = ME.DTA_INI
       AND DE.DTA_FIM = ME.DTA_FIM
),

/* =========================================================
   CONSOLIDA OS 3 NÍVEIS
   ========================================================= */
BASE_CONSOLIDADA AS (
    SELECT NIVEL,
           ANO,
           DTA_INI,
           DTA_FIM,
           COD_TIPO,
           COD_ORGANOGRAMA,
           COD_UNIDADE,
           DES_UNIDADE,
           COD_REDE,
           DES_REDE,
           EFETIVO_INICIAL_MES,
           EFETIVO_FINAL_MES,
           ADMITIDOS_MES,
           DEMITIDOS_MES
      FROM MENSAL_UNIDADE_FINAL

    UNION ALL

    SELECT NIVEL,
           ANO,
           DTA_INI,
           DTA_FIM,
           COD_TIPO,
           COD_ORGANOGRAMA,
           COD_UNIDADE,
           DES_UNIDADE,
           COD_REDE,
           DES_REDE,
           EFETIVO_INICIAL_MES,
           EFETIVO_FINAL_MES,
           ADMITIDOS_MES,
           DEMITIDOS_MES
      FROM MENSAL_REDE_FINAL

    UNION ALL

    SELECT NIVEL,
           ANO,
           DTA_INI,
           DTA_FIM,
           COD_TIPO,
           COD_ORGANOGRAMA,
           COD_UNIDADE,
           DES_UNIDADE,
           COD_REDE,
           DES_REDE,
           EFETIVO_INICIAL_MES,
           EFETIVO_FINAL_MES,
           ADMITIDOS_MES,
           DEMITIDOS_MES
      FROM MENSAL_EMPRESA_FINAL
),

/* =========================================================
   ACUMULADO NO ANO
   ========================================================= */
ACUMULADO_ANO AS (
    SELECT BC.*,

           CASE
             WHEN BC.NIVEL = 'UNIDADE' THEN BC.COD_ORGANOGRAMA
             WHEN BC.NIVEL = 'REDE'    THEN BC.COD_REDE || '_TIPO_' || TO_CHAR(BC.COD_TIPO)
             ELSE 'EMPRESA'
           END AS CHAVE_NIVEL,

           SUM(BC.ADMITIDOS_MES) OVER (
               PARTITION BY BC.NIVEL,
                            CASE
                              WHEN BC.NIVEL = 'UNIDADE' THEN BC.COD_ORGANOGRAMA
                              WHEN BC.NIVEL = 'REDE'    THEN BC.COD_REDE || '_TIPO_' || TO_CHAR(BC.COD_TIPO)
                              ELSE 'EMPRESA'
                            END,
                            BC.ANO
               ORDER BY BC.DTA_FIM
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS ADMITIDOS_ANO,

           SUM(BC.DEMITIDOS_MES) OVER (
               PARTITION BY BC.NIVEL,
                            CASE
                              WHEN BC.NIVEL = 'UNIDADE' THEN BC.COD_ORGANOGRAMA
                              WHEN BC.NIVEL = 'REDE'    THEN BC.COD_REDE || '_TIPO_' || TO_CHAR(BC.COD_TIPO)
                              ELSE 'EMPRESA'
                            END,
                            BC.ANO
               ORDER BY BC.DTA_FIM
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS DEMITIDOS_ANO,

           FIRST_VALUE(BC.EFETIVO_INICIAL_MES) OVER (
               PARTITION BY BC.NIVEL,
                            CASE
                              WHEN BC.NIVEL = 'UNIDADE' THEN BC.COD_ORGANOGRAMA
                              WHEN BC.NIVEL = 'REDE'    THEN BC.COD_REDE || '_TIPO_' || TO_CHAR(BC.COD_TIPO)
                              ELSE 'EMPRESA'
                            END,
                            BC.ANO
               ORDER BY BC.DTA_FIM
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS EFETIVO_INICIAL_ANO,

           BC.EFETIVO_FINAL_MES AS EFETIVO_FINAL_ANO
      FROM BASE_CONSOLIDADA BC
),

/* =========================================================
   ÚLTIMO MÊS DO PERÍODO = FOTO FINAL DO ACUMULADO
   ========================================================= */
DADOS_KPIS AS (
    SELECT AA.NIVEL,
           AA.ANO,
           AA.COD_TIPO,
           AA.COD_ORGANOGRAMA,
           AA.COD_UNIDADE,
           AA.DES_UNIDADE,
           AA.COD_REDE,
           AA.DES_REDE,
           AA.EFETIVO_INICIAL_ANO,
           AA.EFETIVO_FINAL_ANO,
           AA.ADMITIDOS_ANO,
           AA.DEMITIDOS_ANO
      FROM ACUMULADO_ANO AA
     WHERE AA.DTA_FIM = (SELECT MAX(DTA_FIM) FROM DATAS_REF)
)

/* =========================================================
   SAÍDA FINAL
   ========================================================= */
SELECT DK.NIVEL,
       DK.ANO,
       DK.COD_TIPO,
       DK.COD_ORGANOGRAMA,
       DK.COD_UNIDADE,
       DK.DES_UNIDADE,
       DK.COD_REDE,
       DK.DES_REDE,
       DK.EFETIVO_INICIAL_ANO,
       DK.EFETIVO_FINAL_ANO,
       ROUND((DK.EFETIVO_INICIAL_ANO + DK.EFETIVO_FINAL_ANO) / 2, 2) AS EFETIVO_MEDIO_ANO,
       DK.ADMITIDOS_ANO AS ADMITIDOS,
       DK.DEMITIDOS_ANO AS DEMITIDOS,
       ROUND(
           CASE
             WHEN (NVL(DK.EFETIVO_INICIAL_ANO, 0) + NVL(DK.EFETIVO_FINAL_ANO, 0)) / 2 = 0 THEN 0
             ELSE DK.DEMITIDOS_ANO * 100 /
                  ((NVL(DK.EFETIVO_INICIAL_ANO, 0) + NVL(DK.EFETIVO_FINAL_ANO, 0)) / 2)
           END
       , 2) AS TURNOVER
  FROM DADOS_KPIS DK
 ORDER BY CASE DK.NIVEL
             WHEN 'UNIDADE' THEN 1
             WHEN 'REDE'    THEN 2
             ELSE 3
          END,
          DK.COD_TIPO,
          DK.COD_REDE,
          DK.COD_UNIDADE,
          DK.COD_ORGANOGRAMA