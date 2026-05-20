/*P.L.R - KPIs DE AVALIAÇÃO*/


WITH

/* ===== Base mensal filtrada (TRUNC por mês — mantém a lógica) ===== */
BASE AS (
  SELECT T.*
  FROM GRZ_KPI_AVALIACAO_PLR_TB T
  WHERE TRUNC(T.DTA_INI, 'MM') BETWEEN :DATA_INICIO AND :DATA_FIM
),

/* ===== Agregações por unidade ===== */
DADOS_KPIS AS (
  SELECT DECODE(COD_UNIDADE,
                7022,
                22,
                7047,
                47,
                7059,
                59,
                7065,
                65,
                7138,
                138,
                7140,
                140,
                7183,
                183,
                7244,
                244,
                7353,
                353,
                7386,
                386,
                7412,
                412,
                7430,
                430,
                7442,
                442,
                7461,
                461,
                7466,
                466,
                7491,
                491,
                7543,
                543,
                7555,
                555,
                7570,
                570,
                7577,
                653,
                7587,
                587,
                7588,
                588,
                7592,
                592,
                7597,
                597,
                7601,
                601,
                7602,
                608,
                7620,
                620,
                7500,
                651,
                7051,
                652,
                7066,
                654,
                7643,
                643,
                COD_UNIDADE) AS COD_UNIDADE,
         
         MIN(DES_UNIDADE) AS DES_UNIDADE,
         MIN(REDE) AS REDE,
         MIN(REGIAO) AS REGIAO,
         MIN(DTA_INI) AS REF_INI,
         MAX(DTA_FIM) AS REF_FIM,
         
         SUM(NVL(VLR_ORCADO_VENDAS, 0)) AS VLR_ORCADO_VENDAS_ANO,
         SUM(NVL(VLR_REALIZADO, 0)) AS VLR_REALIZADO_ANO,
         SUM(NVL(VLR_VENDA_LIQUIDA, 0)) AS VLR_VENDA_LIQUIDA_ANO,
         SUM(NVL(VLR_LUCRO, 0)) AS VLR_LUCRO_ANO,
         SUM(NVL(VLR_MARGEM_ORC, 0)) AS VLR_MARGEM_ORC_ANO,
         SUM(NVL(VLR_MARGEM_REAL, 0)) AS VLR_MARGEM_REAL_ANO,
         SUM(NVL(VLR_FALTA_INVENTARIO, 0)) AS VLR_FALTA_INVENTARIO_ANO,
         SUM(NVL(VLR_CUSTO_FOLHA, 0)) AS VLR_CUSTO_FOLHA_ANO,
         SUM(NVL(VLR_VALE_TRANS, 0)) AS VLR_VALE_TRANS_ANO,
         SUM(NVL(VLR_VENDA_LOJA, 0)) AS VLR_VENDA_LOJA_ANO,
         SUM(NVL(VLR_VDA_DOMINGO, 0)) AS VLR_VDA_DOMINGO_ANO,
         SUM(NVL(TOTAL_HRS, 0)) AS TOTAL_HRS_ANO,
         SUM(NVL(ADMITIDOS, 0)) AS ADMITIDOS_ANO,
         SUM(NVL(DEMITIDOS, 0)) AS DEMITIDOS_ANO,
         
         SUM(NVL(VLR_PREVENTIVA, 0)) AS VLR_PREVENTIVA_ANO,
         COUNT(DISTINCT CASE
                 WHEN NVL(VLR_PREVENTIVA, 0) > 0 THEN
                  TRUNC(DTA_INI, 'MM')
               END) AS MESES_PREV_POSITIVO,
         
         SUM(NVL(VLR_CUSTO_PERM, 0)) AS CUSTO_PERM_ANO,
         SUM(NVL(VLR_ESTMEDIO_PERM, 0)) AS ESTMED_MEDIO_ANO,
         
         MAX(EFETIVO_INICIAL) KEEP(DENSE_RANK FIRST ORDER BY DTA_INI) AS EFETIVO_INICIAL_ANO,
         MAX(EFETIVO_FINAL) KEEP(DENSE_RANK LAST ORDER BY DTA_FIM) AS EFETIVO_FINAL_ANO,
         
         /* AJUSTE AQUI: Pegamos a média da coluna que já vem calculada da sua tabela */
         AVG(NVL(TURNOVER, 0)) AS MEDIA_TURNOVER_PERIODO,
         
         COUNT(DISTINCT TRUNC(DTA_INI, 'MM')) AS MESES_COBERTOS
    FROM BASE
   GROUP BY DECODE(COD_UNIDADE,
                   7022,
                   22,
                   7047,
                   47,
                   7059,
                   59,
                   7065,
                   65,
                   7138,
                   138,
                   7140,
                   140,
                   7183,
                   183,
                   7244,
                   244,
                   7353,
                   353,
                   7386,
                   386,
                   7412,
                   412,
                   7430,
                   430,
                   7442,
                   442,
                   7461,
                   461,
                   7466,
                   466,
                   7491,
                   491,
                   7543,
                   543,
                   7555,
                   555,
                   7570,
                   570,
                   7577,
                   653,
                   7587,
                   587,
                   7588,
                   588,
                   7592,
                   592,
                   7597,
                   597,
                   7601,
                   601,
                   7602,
                   608,
                   7620,
                   620,
                   7500,
                   651,
                   7051,
                   652,
                   7066,
                   654,
                   7643,
                   643,
                   COD_UNIDADE)
),


METAS_BASE AS (
  SELECT
      COD_REDE,
      COD_CALCULO,
      VALOR1,
      VALOR2
  FROM NL.GRZ_CAD_CALCULO_APR_ANUAL@NLGRZ
  WHERE ANO = SUBSTR(:DATA_FIM, 7, 4)
    AND COD_CALCULO IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
),

METAS AS (
  SELECT
      COD_REDE,

      MAX(CASE WHEN COD_CALCULO = 1 THEN VALOR1 END) AS META_INVENTARIO,
      MAX(CASE WHEN COD_CALCULO = 2 THEN VALOR1 END) AS META_PERMANENCIA_VALOR1,
      MAX(CASE WHEN COD_CALCULO = 2 THEN VALOR2 END) AS META_PERMANENCIA_VALOR2,
      MAX(CASE WHEN COD_CALCULO = 3 THEN VALOR1 END) AS META_PREVENTIVA,
      MAX(CASE WHEN COD_CALCULO = 4 THEN VALOR1 END) AS META_VT,
      MAX(CASE WHEN COD_CALCULO = 5 THEN VALOR1 END) AS META_PRODUTIVIDADE,
      MAX(CASE WHEN COD_CALCULO = 6 THEN VALOR1 END) AS META_FOLHA,
      MAX(CASE WHEN COD_CALCULO = 7 THEN VALOR1 END) AS META_TURNOVER,
      MAX(CASE WHEN COD_CALCULO = 8 THEN VALOR1 END) AS META_TRAINEE,
      MAX(CASE WHEN COD_CALCULO = 9 THEN VALOR1 END) AS META_MARGEM
      /* se quiser o 10 depois, adiciona aqui */
  FROM METAS_BASE
  GROUP BY COD_REDE
),


/* ===== Pontuação anual ===== */
PONTUACAO AS (
  SELECT
    DECODE(A.COD_UNIDADE,
      7022, 22, 7047, 47, 7059, 59, 7065, 65, 7138, 138, 7140, 140, 7183, 183,
      7244, 244, 7353, 353, 7386, 386, 7412, 412, 7430, 430, 7442, 442, 7461, 461,
      7466, 466, 7491, 491, 7543, 543, 7555, 555, 7570, 570, 7577, 653, 7587, 587,
      7588, 588, 7592, 592, 7597, 597, 7601, 601, 7602, 608, 7620, 620, 7500, 651,
      7051, 652, 7066, 654, 7643, 643,
      A.COD_UNIDADE
    ) AS COD_UNIDADE,

    A.ANO,

    MAX(A.ORCADO)        AS PTS_ORCADO,
    MAX(A.LUCRO)         AS PTS_LUCRO,
    MAX(A.MARGEM)        AS PTS_MARGEM_ORC,
    MAX(A.MARGEM_PERC)   AS PTS_MARGEM_PERC,
    MAX(A.PERMANENCIA)   AS PTS_PERMANENCIA,
    MAX(A.INVENTARIO)    AS PTS_INVENTARIO,
    MAX(A.PREVENTIVA)    AS PTS_PREVENTIVA,
    MAX(A.PRODUTIVIDADE) AS PTS_PRODUTIVIDADE,
    MAX(A.TURN_OVER)     AS PTS_TURNOVER,
    MAX(A.FOLHA)         AS PTS_FOLHA,
    MAX(A.VALE_TRANSP)   AS PTS_VT,
    MAX(A.TREINAMENTO)   AS PTS_TREINAMENTO,
    MAX(A.TRAINEE)       AS PTS_TRAINEE
  FROM SISLOGWEB.GRZ_DADOS_CALCULO_APR_ANUAL@NLGRZ A
  WHERE A.ANO = :ANO
  GROUP BY
    DECODE(A.COD_UNIDADE,
      7022, 22, 7047, 47, 7059, 59, 7065, 65, 7138, 138, 7140, 140, 7183, 183,
      7244, 244, 7353, 353, 7386, 386, 7412, 412, 7430, 430, 7442, 442, 7461, 461,
      7466, 466, 7491, 491, 7543, 543, 7555, 555, 7570, 570, 7577, 653, 7587, 587,
      7588, 588, 7592, 592, 7597, 597, 7601, 601, 7602, 608, 7620, 620, 7500, 651,
      7051, 652, 7066, 654, 7643, 643,
      A.COD_UNIDADE
    ),
    A.ANO
),

/* ===== Cálculo auxiliar ===== */
MARGEM_AUDITORIA AS (
  SELECT
    DK.COD_UNIDADE,
    ROUND(
      100 * DK.VLR_MARGEM_REAL_ANO / NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
      2
    ) AS MARGEM_2C,
    ROUND(
      100 * DK.VLR_MARGEM_REAL_ANO / NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
      1
    ) AS MARGEM_REGRA_1C
  FROM DADOS_KPIS DK
)

/* ============================ SAÍDA FINAL ============================ */
SELECT
  DK.COD_UNIDADE,
  DK.DES_UNIDADE,
  DK.REDE,
  DK.REGIAO,

  TO_CHAR(TRUNC(DK.REF_INI, 'MM'), 'MM/YYYY') || ' - ' ||
  TO_CHAR(DK.REF_FIM, 'MM/YYYY') AS APURACAO,

  DK.MESES_COBERTOS AS QTD_MESES,
  PT.ANO,

  TO_CHAR(NVL(DK.VLR_ORCADO_VENDAS_ANO, 0), 'FM999G999G990D00') AS VLR_ORCADO_VENDAS,
  TO_CHAR(NVL(DK.VLR_REALIZADO_ANO, 0), 'FM999G999G990D00')     AS VLR_REALIZADO,
  TO_CHAR(NVL(DK.VLR_VENDA_LIQUIDA_ANO, 0), 'FM999G999G990D00') AS VLR_VENDA_LIQUIDA,
  

  TO_CHAR(NVL(DK.VLR_LUCRO_ANO, 0), 'FM999G999G990D00')         AS VLR_LUCRO,
  TO_CHAR(NVL(DK.VLR_CUSTO_FOLHA_ANO, 0), 'FM999G999G990D00')   AS VLR_CUSTO_FOLHA,
  TO_CHAR(NVL(DK.VLR_VALE_TRANS_ANO, 0), 'FM999G999G990D00')    AS VLR_VALE_TRANS,
  
  NVL(PT.PTS_ORCADO, 0) AS PTS_ORCADO,

  MT.META_MARGEM AS META_MARGEM,
  NVL(MA.MARGEM_2C, 0)       AS MARGEM,
  NVL(PT.PTS_MARGEM_PERC, 0) AS PTS_MARGEM,
  
  MT.META_INVENTARIO AS META_INVENTARIO,
  NVL(
    ROUND(
      100 * DK.VLR_FALTA_INVENTARIO_ANO / NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
      2
    ),
    0
  ) AS INVENTARIO,
  NVL(PT.PTS_INVENTARIO, 0) AS PTS_INVENTARIO,
  
  /*AQUI FICA META DE LUCRO - VALIDAR QUAL O CORRETO*/
  NVL(
    ROUND(
      100 * DK.VLR_LUCRO_ANO / NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
      2
    ),
    0
  ) AS LUCRATIVIDADE,
  NVL(PT.PTS_LUCRO, 0) AS PTS_LUCRO,
  
  MT.META_FOLHA AS META_FOLHA,
  NVL(
    ROUND(
      100 * DK.VLR_CUSTO_FOLHA_ANO / NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
      2
    ),
    0
  ) AS FOLHA,
  NVL(PT.PTS_FOLHA, 0) AS PTS_FOLHA,

  MT.META_VT AS META_VT,
  NVL(
    ROUND(
      100 * DK.VLR_VALE_TRANS_ANO / NULLIF(DK.VLR_VENDA_LIQUIDA_ANO, 0),
      2
    ),
    0
  ) AS VT,
  NVL(PT.PTS_VT, 0) AS PTS_VT,
  
  MT.META_PREVENTIVA AS META_PREVENTIVA,
  CASE
    WHEN DK.MESES_PREV_POSITIVO > 0 THEN
      ROUND(DK.VLR_PREVENTIVA_ANO / DK.MESES_PREV_POSITIVO, 2)
    ELSE
      0
  END AS PREVENTIVA,*/
  NVL(PT.PTS_PREVENTIVA, 0) AS PTS_PREVENTIVA,
 
  TO_CHAR(MT.META_PERMANENCIA_VALOR1) || ' a ' || TO_CHAR(MT.META_PERMANENCIA_VALOR2) AS META_PERMANENCIA,
  NVL(
    CASE
      WHEN DK.CUSTO_PERM_ANO = 0 OR DK.ESTMED_MEDIO_ANO IS NULL THEN
        NULL
      ELSE
        ROUND(360 / (DK.CUSTO_PERM_ANO / (DK.ESTMED_MEDIO_ANO / 365.25)), 0)
    END,
    0
  ) AS PERMANENCIA,
  NVL(PT.PTS_PERMANENCIA, 0) AS PTS_PERMANENCIA,

  MT.META_PRODUTIVIDADE AS META_PRODUTIVIDADE,
  NVL(
    TRUNC(
      NVL(DK.VLR_VENDA_LOJA_ANO, 0) / NULLIF(DK.TOTAL_HRS_ANO, 0),
      0
    ),
    0
  ) AS PRODUTIVIDADE,
  NVL(PT.PTS_PRODUTIVIDADE, 0) AS PTS_PRODUTIVIDADE,

  /*AJUSTE AQUI: Agora ele puxa apenas o valor arredondado da média que calculamos no bloco DADOS_KPIS*/
  MT.META_TURNOVER AS META_TURNOVER,
  NVL(ROUND(DK.MEDIA_TURNOVER_PERIODO, 2), 0) AS TURNOVER,
  NVL(PT.PTS_TURNOVER, 0) AS PTS_TURNOVER,

  4 AS META_TRAINAMENTO,      
  NVL(PT.PTS_TREINAMENTO, 0) AS PTS_TREINAMENTO,
  
  MT.META_TRAINEE AS META_TRAINEE,
  NVL(PT.PTS_TRAINEE, 0)     AS PTS_TRAINEE,

  (
    NVL(PT.PTS_ORCADO, 0) +
    NVL(PT.PTS_LUCRO, 0) +
    NVL(PT.PTS_MARGEM_PERC, 0) +
    NVL(PT.PTS_PERMANENCIA, 0) +
    NVL(PT.PTS_INVENTARIO, 0) +
    NVL(PT.PTS_PREVENTIVA, 0) +
    NVL(PT.PTS_PRODUTIVIDADE, 0) +
    NVL(PT.PTS_TURNOVER, 0) +
    NVL(PT.PTS_FOLHA, 0) +
    NVL(PT.PTS_VT, 0) +
    NVL(PT.PTS_TREINAMENTO, 0) +
    NVL(PT.PTS_TRAINEE, 0)
  ) AS TOTAL_PTS,

  DK.ADMITIDOS_ANO AS ADMITIDOS,
  DK.DEMITIDOS_ANO AS DEMITIDOS

FROM DADOS_KPIS DK
LEFT JOIN PONTUACAO PT
  ON DK.COD_UNIDADE = PT.COD_UNIDADE
LEFT JOIN MARGEM_AUDITORIA MA
  ON DK.COD_UNIDADE = MA.COD_UNIDADE
LEFT JOIN METAS MT
  ON DK.REDE = MT.COD_REDE
ORDER BY DK.COD_UNIDADE



