WITH

/* ===== Base mensal filtrada (TRUNC por mês — mantém a lógica) ===== */
BASE AS (
 -- VERSÃO FOLHA
  SELECT T.*
  FROM GRZ_KPI_AVALIACAO_PLR_TB T
  --CROSS JOIN PERIODO P
  WHERE TRUNC(T.DTA_INI,'MM') BETWEEN :DATA_INICIO AND :DATA_FIM


-- VERSÃO PL/SQL
 /*SELECT T.*
  FROM GRZ_KPI_AVALIACAO_PLR_TB T
  --CROSS JOIN PERIODO P
  WHERE TRUNC(T.DTA_INI,'MM') BETWEEN '&DTA_INI' AND '&DTA_FIM'*/

),

/* ===== Agregações por unidade (mesma regra do teu relatório) ===== */
DADOS_KPIS AS (
  SELECT
    --COD_UNIDADE,
    DECODE(COD_UNIDADE,
              7022, 22,
              7047, 47,
              7065, 65,
              7138, 138,
              7140, 140,
              7183, 183,
              7244, 244,
              7353, 353,
              7386, 386,
              7412, 412,
              7430, 430,
              7442, 442,
              7461, 461,
              7466, 466,
              7491, 491,
              7543, 543,
              7555, 555,
              7570, 570,
              7577, 653,
              7587, 587,
              7588, 588,
              7592, 592,
              7597, 597,
              7601, 601,
              7602, 608,
              7620, 620,
              7500, 651,
              7051, 652,
              7066, 654,
              COD_UNIDADE) COD_UNIDADE,
    MIN(DES_UNIDADE) AS DES_UNIDADE,
    MIN(REDE)  AS REDE,
    MIN(REGIAO) AS REGIAO,
    MIN(DTA_INI) AS REF_INI,
    MAX(DTA_FIM) AS REF_FIM,

    SUM(NVL(VLR_ORCADO_VENDAS,0))  AS VLR_ORCADO_VENDAS_ANO,
    SUM(NVL(VLR_REALIZADO,0))      AS VLR_REALIZADO_ANO,
    SUM(NVL(VLR_VENDA_LIQUIDA,0))  AS VLR_VENDA_LIQUIDA_ANO,
    SUM(NVL(VLR_LUCRO,0))          AS VLR_LUCRO_ANO,
    SUM(NVL(VLR_MARGEM_ORC,0))     AS VLR_MARGEM_ORC_ANO,
    SUM(NVL(VLR_MARGEM_REAL,0))    AS VLR_MARGEM_REAL_ANO,
    SUM(NVL(VLR_FALTA_INVENTARIO,0)) AS VLR_FALTA_INVENTARIO_ANO,
    SUM(NVL(VLR_CUSTO_FOLHA,0))    AS VLR_CUSTO_FOLHA_ANO,
    SUM(NVL(VLR_VENDA_LOJA,0))     AS VLR_VENDA_LOJA_ANO,
    SUM(NVL(VLR_VDA_DOMINGO,0))    AS VLR_VDA_DOMINGO_ANO,
    SUM(NVL(TOTAL_HRS,0))          AS TOTAL_HRS_ANO,
    SUM(NVL(ADMITIDOS,0))          AS ADMITIDOS_ANO,
    SUM(NVL(DEMITIDOS,0))          AS DEMITIDOS_ANO,

    SUM(NVL(VLR_PREVENTIVA,0))     AS VLR_PREVENTIVA_ANO,
    COUNT(DISTINCT CASE WHEN NVL(VLR_PREVENTIVA,0)>0 THEN TRUNC(DTA_INI,'MM') END) AS MESES_PREV_POSITIVO,

    SUM(NVL(VLR_CUSTO_PERM,0))     AS CUSTO_PERM_ANO,
    SUM(NVL(VLR_ESTMEDIO_PERM,0))  AS ESTMED_MEDIO_ANO,

    MAX(EFETIVO_INICIAL) KEEP (DENSE_RANK FIRST ORDER BY DTA_INI) AS EFETIVO_INICIAL_ANO,
    MAX(EFETIVO_FINAL)   KEEP (DENSE_RANK LAST  ORDER BY DTA_FIM) AS EFETIVO_FINAL_ANO,

    COUNT(DISTINCT TRUNC(DTA_INI,'MM')) AS MESES_COBERTOS
  FROM BASE
  GROUP BY DECODE(COD_UNIDADE,
              7022, 22,
              7047, 47,
              7065, 65,
              7138, 138,
              7140, 140,
              7183, 183,
              7244, 244,
              7353, 353,
              7386, 386,
              7412, 412,
              7430, 430,
              7442, 442,
              7461, 461,
              7466, 466,
              7491, 491,
              7543, 543,
              7555, 555,
              7570, 570,
              7577, 653,
              7587, 587,
              7588, 588,
              7592, 592,
              7597, 597,
              7601, 601,
              7602, 608,
              7620, 620,
              7500, 651,
              7051, 652,
              7066, 654,
              COD_UNIDADE)
)

/* ============================ SAÍDA FINAL ============================ */
SELECT DK.COD_UNIDADE,
       DK.DES_UNIDADE,
       DK.REDE,
       DK.REGIAO,

       /* usa D_INI/D_FIM da CTE PERIODO */
       TO_CHAR(TRUNC(DK.REF_INI, 'MM'), 'MM/YYYY') || ' - ' ||
       TO_CHAR(DK.REF_FIM, 'MM/YYYY') AS APURACAO,
       DK.MESES_COBERTOS AS QTD_MESES,

       TO_CHAR(NVL(DK.VLR_ORCADO_VENDAS_ANO, 0), 'FM999G999G990D00') AS VLR_ORCADO_VENDAS,
       TO_CHAR(NVL(DK.VLR_REALIZADO_ANO, 0), 'FM999G999G990D00') AS VLR_REALIZADO,
       TO_CHAR(NVL(DK.VLR_VENDA_LIQUIDA_ANO, 0), 'FM999G999G990D00') AS VLR_VENDA_LIQUIDA,
       TO_CHAR(NVL(DK.VLR_VDA_DOMINGO_ANO, 0), 'FM999G999G990D00') AS VLR_VDA_DOMINGO,
       TO_CHAR(NVL(DK.VLR_LUCRO_ANO, 0), 'FM999G999G990D00') AS VLR_LUCRO,

       NVL(ROUND(100 * DK.VLR_MARGEM_REAL_ANO /
                 NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
                 2),
           0) AS MARGEM,
       NVL(ROUND(100 * DK.VLR_FALTA_INVENTARIO_ANO /
                 NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
                 2),
           0) AS INVENTARIO,
       NVL(ROUND(100 * DK.VLR_LUCRO_ANO /
                 NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
                 2),
           0) AS LUCRATIVIDADE,
       NVL(ROUND(100 * DK.VLR_CUSTO_FOLHA_ANO /
                 NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
                 2),
           0) AS FOLHA,

       CASE
         WHEN DK.MESES_PREV_POSITIVO > 0 THEN
          ROUND(DK.VLR_PREVENTIVA_ANO / DK.MESES_PREV_POSITIVO, 2)
         ELSE
          0
       END AS PREVENTIVA,

       NVL(CASE
             WHEN DK.CUSTO_PERM_ANO = 0 OR DK.ESTMED_MEDIO_ANO IS NULL THEN
              NULL
             ELSE
              ROUND(360 / (DK.CUSTO_PERM_ANO / (DK.ESTMED_MEDIO_ANO / 365.25)),
                    0)
           END,
           0) AS PERMANENCIA,

       NVL(TRUNC(NVL(DK.VLR_VENDA_LOJA_ANO, 0) /
                  NULLIF(DK.TOTAL_HRS_ANO, 0),
                  0),
            0) AS PRODUTIVIDADE,

        ROUND(CASE
         WHEN (DK.EFETIVO_INICIAL_ANO + DK.EFETIVO_FINAL_ANO) / 2 = 0 THEN
          0
         ELSE
          DK.DEMITIDOS_ANO * 100 /
          ((DK.EFETIVO_INICIAL_ANO + DK.EFETIVO_FINAL_ANO) / 2)
       END, 2) AS TURNOVER,

       DK.ADMITIDOS_ANO AS ADMITIDOS,
       DK.DEMITIDOS_ANO AS DEMITIDOS
  FROM DADOS_KPIS DK
--CROSS JOIN PERIODO P
--WHERE DK.REGIAO = 9999
 ORDER BY DK.COD_UNIDADE
