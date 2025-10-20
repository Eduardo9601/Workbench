WITH
CONTRATOS AS (
  SELECT DISTINCT CT.STATUS,
                  CT.COD_CONTRATO,
                  CT.DES_PESSOA,
                  CT.DATA_NASCIMENTO,
                  CT.DATA_ADMISSAO,
                  CT.DATA_DEMISSAO,
                  CT.COD_VINCULO_EMPREG,
                  FN.COD_FUNCAO,
                  FN.DES_FUNCAO,
                  FN.DATA_INI_CLH,
                  FN.DATA_FIM_CLH,
                  HR.HR_BASE_MES,
                  HR.DATA_INI_HR,
                  HR.DATA_FIM_HR,
                  CT.IND_DEFICIENCIA,
                  CT.SEXO,
                  ORG.COD_EMP,
                  ORG.EDICAO_EMP,
                  ORG.DES_EMP,
                  ORG.COD_ORGANOGRAMA,
                  ORG.COD_UNIDADE,
                  ORG.DES_UNIDADE,
                  ORG.DATA_INI_ORG,
                  ORG.DATA_FIM_ORG,
                  CASE
                    WHEN ORG.COD_TIPO = 2 THEN
                     ORG.EDICAO_ORG_3
                    WHEN ORG.COD_TIPO = 3 THEN
                     ORG.EDICAO_ORG_3
                    ELSE
                     ORG.COD_UNIDADE
                  END AS COD_FILIAL,
                  CASE
                    WHEN ORG.COD_TIPO = 2 THEN
                     ORG.NOME3
                    WHEN ORG.COD_TIPO = 3 THEN
                     ORG.NOME3
                    ELSE
                     ORG.DES_UNIDADE
                  END AS DES_FILIAL,
                  CASE
                    WHEN ORG.COD_TIPO = 2 THEN
                     ORG.EDICAO_ORG_4
                    WHEN ORG.COD_TIPO = 3 THEN
                     ORG.EDICAO_ORG_4
                    ELSE
                     ORG.COD_UNIDADE
                  END AS COD_DIVISAO,
                  CASE
                    WHEN ORG.COD_TIPO = 2 THEN
                     ORG.NOME4
                    WHEN ORG.COD_TIPO = 3 THEN
                     ORG.NOME4
                    ELSE
                     ORG.DES_UNIDADE
                  END AS DES_DIVISAO,
                  ORG.COD_REDE,
                  ORG.DES_REDE,
                  ORG.COD_TIPO,
                  ORG.DES_TIPO
    FROM V_DADOS_CONTRATO_AVT CT
    JOIN VH_EST_ORG_CONTRATO_AVT ORG ON CT.COD_CONTRATO = ORG.COD_CONTRATO
    JOIN VH_HIST_HORAS_COLAB_AVT HR ON CT.COD_CONTRATO = HR.COD_CONTRATO
    JOIN VH_CARGO_CONTRATO_AVT FN ON CT.COD_CONTRATO = FN.COD_CONTRATO
   WHERE (CT.DATA_DEMISSAO IS NULL OR
          CT.DATA_DEMISSAO >= :DATA_INICIO)
     /*VERSÃO ALTERNATIVA
     ((TO_DATE('31/08/2025', 'DD/MM/YYYY') BETWEEN CT.DATA_ADMISSAO
     AND CT.DATA_DEMISSAO) OR (CT.DATA_ADMISSAO <= TO_DATE('31/08/2025', 'DD/MM/YYYY')
     AND CT.DATA_DEMISSAO IS NULL))*/
     AND :DATA_FIM BETWEEN ORG.DATA_INI_ORG AND ORG.DATA_FIM_ORG
     AND :DATA_FIM BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH
     AND :DATA_FIM BETWEEN HR.DATA_INI_HR AND HR.DATA_FIM_HR
     AND ORG.COD_EMP = 8
     AND FN.COD_FUNCAO = 68
     AND ORG.EDICAO_ORG_4 IS NOT NULL

),

STATUS_AFASTADOS AS (
  SELECT DISTINCT
         ORG.COD_EMP,
         CT.COD_CONTRATO,
         ORG.COD_ORGANOGRAMA,
         ORG.COD_UNIDADE,
         AF.COD_CAUSA_AFAST AS COD_AFAST,
         AFN.NOME_CAUSA_AFAST AS DES_AFAST,
         NVL(AF.COD_CAUSA_AFAST,0) AS STATUS_AFAST,
         AF.DATA_INICIO AS DATA_INI_AFAST,
         AF.DATA_FIM    AS DATA_FIM_AFAST
  FROM RHFP0306 AF,
       RHFP0300 CT,
       VH_EST_ORG_CONTRATO_AVT ORG,
       VH_CARGO_CONTRATO_AVT   FN,
       RHFP0100 AFN
  WHERE CT.COD_CONTRATO = AF.COD_CONTRATO(+)
    AND CT.COD_CONTRATO = ORG.COD_CONTRATO(+)
    AND CT.COD_CONTRATO = FN.COD_CONTRATO(+)
    AND AF.COD_CAUSA_AFAST = AFN.COD_CAUSA_AFAST(+)
    AND (CT.DATA_FIM IS NULL OR
         CT.DATA_FIM >= :DATA_INICIO)
    /*VERSÃO ALTERNATIVA
     ((TO_DATE('31/08/2025', 'DD/MM/YYYY') BETWEEN CT.DATA_INICIO
     AND CT.DATA_FIM) OR (CT.DATA_INICIO <= TO_DATE('31/08/2025', 'DD/MM/YYYY')
     AND CT.DATA_FIM IS NULL))*/
    AND :DATA_FIM BETWEEN AF.DATA_INICIO(+) AND AF.DATA_FIM(+)
    AND :DATA_FIM BETWEEN ORG.DATA_INI_ORG(+) AND ORG.DATA_FIM_ORG(+)
    AND :DATA_FIM BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH(+)
    AND ORG.COD_EMP = 8
    AND FN.COD_FUNCAO = 68

),

VENCIMENTOS AS (
  SELECT A.COD_CONTRATO,
         A.VALOR_VD AS VENCIMENTOS
  FROM RHFP1006 A
  JOIN RHFP1003 B ON B.COD_MESTRE_EVENTO = A.COD_MESTRE_EVENTO
  WHERE B.DATA_REFERENCIA BETWEEN :DATA_INICIO
                              AND :DATA_FIM
    AND B.COD_EVENTO IN (1, 13, 17, 19)
    AND A.COD_VD = 1001
),

MOVIMENTOS AS (
  SELECT COD_CONTRATO,
         NVL(VD1800_UNID, 0) AS UNIDADE_1800,
         NVL(VD1800_HORAS, 0) AS HORAS_1800,
         NVL(VD1801_UNID, 0) AS UNIDADE_1801,
         NVL(VD1801_HORAS, 0) AS HORAS_1801,
         NVL(VD1802_UNID, 0) AS UNIDADE_1802,
         NVL(VD1802_HORAS, 0) AS HORAS_1802,
         NVL(VD1803_UNID, 0) AS UNIDADE_1803,
         NVL(VD1803_HORAS, 0) AS HORAS_1803,
         NVL(VD1804_UNID, 0) AS UNIDADE_1804,
         NVL(VD1804_HORAS, 0) AS HORAS_1804,
         DATA_MOV
    FROM (SELECT COD_CONTRATO,
                 COD_VD,
                 TRUNC(VALOR_VD) AS UNIDADE,
                 QTDE_VD AS HORAS,
                 MAX(DATA_MOV) AS DATA_MOV
            FROM RHFP1004
           WHERE COD_VD IN (1800, 1801, 1802, 1803, 1804)
             AND DATA_MOV BETWEEN :DATA_INICIO AND :DATA_FIM
             AND COD_EVENTO IN (1, 13, 17, 19)
           GROUP BY COD_CONTRATO,
                    COD_VD,
                    VALOR_VD,
                    QTDE_VD
          ) PIVOT(MAX(UNIDADE) AS UNID, SUM(HORAS) AS HORAS FOR COD_VD IN (1800 AS VD1800, 1801 AS VD1801, 1802 AS VD1802, 1803 AS VD1803, 1804 AS VD1804))
),

/* NORMALIZA HORAS: valor no formato HH,MM -> HH + (MM/60) */
MOV_NORM AS (
  SELECT
    COD_CONTRATO,
    UNIDADE_1800, UNIDADE_1801, UNIDADE_1802, UNIDADE_1803, UNIDADE_1804,

    /* h=HH,MM -> mins_raw = arredonda para 2 casas, pega MM; carry de 60min -> +1h; minutos 0..59 -> fração */
    ( TRUNC(NVL(HORAS_1800,0))
      + FLOOR( MOD(ROUND(NVL(HORAS_1800,0)*100), 100) / 60 )
      + MOD( MOD(ROUND(NVL(HORAS_1800,0)*100), 100), 60 ) / 60
    ) AS HORAS_1800,

    ( TRUNC(NVL(HORAS_1801,0))
      + FLOOR( MOD(ROUND(NVL(HORAS_1801,0)*100), 100) / 60 )
      + MOD( MOD(ROUND(NVL(HORAS_1801,0)*100), 100), 60 ) / 60
    ) AS HORAS_1801,

    ( TRUNC(NVL(HORAS_1802,0))
      + FLOOR( MOD(ROUND(NVL(HORAS_1802,0)*100), 100) / 60 )
      + MOD( MOD(ROUND(NVL(HORAS_1802,0)*100), 100), 60 ) / 60
    ) AS HORAS_1802,

    ( TRUNC(NVL(HORAS_1803,0))
      + FLOOR( MOD(ROUND(NVL(HORAS_1803,0)*100), 100) / 60 )
      + MOD( MOD(ROUND(NVL(HORAS_1803,0)*100), 100), 60 ) / 60
    ) AS HORAS_1803,

    ( TRUNC(NVL(HORAS_1804,0))
      + FLOOR( MOD(ROUND(NVL(HORAS_1804,0)*100), 100) / 60 )
      + MOD( MOD(ROUND(NVL(HORAS_1804,0)*100), 100), 60 ) / 60
    ) AS HORAS_1804,

    DATA_MOV
  FROM MOVIMENTOS
),


BASE AS (
  SELECT M.COD_CONTRATO,
         CT.DES_PESSOA,
         CT.DES_UNIDADE,
         CT.HR_BASE_MES,
         TO_NUMBER(CT.HR_BASE_MES) AS HR_BASE_MES_NUM,
         V.VENCIMENTOS,
         M.UNIDADE_1800,
         M.HORAS_1800,
         M.UNIDADE_1801,
         M.HORAS_1801,
         M.UNIDADE_1802,
         M.HORAS_1802,
         M.UNIDADE_1803,
         M.HORAS_1803,
         M.UNIDADE_1804,
         M.HORAS_1804,
         NVL(M.HORAS_1800,0)*5 AS HORAS_MES_1800,
         NVL(M.HORAS_1801,0)*5 AS HORAS_MES_1801,
         NVL(M.HORAS_1802,0)*5 AS HORAS_MES_1802,
         NVL(M.HORAS_1803,0)*5 AS HORAS_MES_1803,
         NVL(M.HORAS_1804,0)*5 AS HORAS_MES_1804,
         COALESCE(NULLIF(TO_CHAR(M.UNIDADE_1800),'0'), CT.COD_UNIDADE) AS UNIDADE_CONTRA,
         M.DATA_MOV AS REFERENCIA
  FROM MOV_NORM M
  INNER JOIN VENCIMENTOS V ON V.COD_CONTRATO = M.COD_CONTRATO
  LEFT JOIN CONTRATOS CT ON M.COD_CONTRATO = CT.COD_CONTRATO
  LEFT JOIN STATUS_AFASTADOS AF ON AF.COD_CONTRATO = M.COD_CONTRATO
  WHERE (NVL(M.HORAS_1800,0)+NVL(M.HORAS_1801,0)+NVL(M.HORAS_1802,0)+NVL(M.HORAS_1803,0)+NVL(M.HORAS_1804,0)) > 0
    AND AF.STATUS_AFAST IN (0, 6, 7)
),


RESULTADO AS (
  SELECT DISTINCT B.COD_CONTRATO,
                  B.DES_PESSOA,
                  1801 AS COD_VD,
                  B.UNIDADE_1801 AS UNIDADE,
                  B.HORAS_MES_1801 AS HORAS_MES,
                  NVL(ROUND(B.VENCIMENTOS * B.HORAS_MES_1801 /
                            NULLIF(B.HR_BASE_MES_NUM, 0),
                            2),
                      0) AS VALOR,
                  B.UNIDADE_CONTRA,
                  B.REFERENCIA
    FROM BASE B
   WHERE NVL(B.HORAS_MES_1801, 0) > 0
     AND NVL(B.UNIDADE_1801, 0) <> 0
  UNION ALL
  SELECT DISTINCT B.COD_CONTRATO,
                  B.DES_PESSOA,
                  1802,
                  B.UNIDADE_1802,
                  B.HORAS_MES_1802,
                  NVL(ROUND(B.VENCIMENTOS * B.HORAS_MES_1802 /
                            NULLIF(B.HR_BASE_MES_NUM, 0),
                            2),
                      0),
                  B.UNIDADE_CONTRA,
                  B.REFERENCIA
    FROM BASE B
   WHERE NVL(B.HORAS_MES_1802, 0) > 0
     AND NVL(B.UNIDADE_1802, 0) <> 0
  UNION ALL
  SELECT DISTINCT B.COD_CONTRATO,
                  B.DES_PESSOA,
                  1803,
                  B.UNIDADE_1803,
                  B.HORAS_MES_1803,
                  NVL(ROUND(B.VENCIMENTOS * B.HORAS_MES_1803 /
                            NULLIF(B.HR_BASE_MES_NUM, 0),
                            2),
                      0),
                  B.UNIDADE_CONTRA,
                  B.REFERENCIA
    FROM BASE B
   WHERE NVL(B.HORAS_MES_1803, 0) > 0
     AND NVL(B.UNIDADE_1803, 0) <> 0
  UNION ALL
  SELECT DISTINCT B.COD_CONTRATO,
                  B.DES_PESSOA,
                  1804,
                  B.UNIDADE_1804,
                  B.HORAS_MES_1804,
                  NVL(ROUND(B.VENCIMENTOS * B.HORAS_MES_1804 /
                            NULLIF(B.HR_BASE_MES_NUM, 0),
                            2),
                      0),
                  B.UNIDADE_CONTRA,
                  B.REFERENCIA
    FROM BASE B
   WHERE NVL(B.HORAS_MES_1804, 0) > 0
     AND NVL(B.UNIDADE_1804, 0) <> 0
)


SELECT
  '001' || LPAD(TRIM(TO_CHAR(NVL(UNIDADE, 0))), 7, '0') || '341101' ||
  RPAD(' ', 34) || 'D3045' || RPAD(' ', 200) ||
  LPAD( TO_CHAR(ROUND(VALOR * 100)) || TO_CHAR(REFERENCIA, 'DDMMYYYY') || '341101', 29, '0') ||
  RPAD(' ', 14) ||
  LPAD(TRIM(TO_CHAR(NVL(UNIDADE_CONTRA, 0))), 7, '0') ||
  RPAD(' ', 20) || '*' AS LINHA_ERP
FROM RESULTADO
ORDER BY TO_NUMBER(TRIM(UNIDADE_CONTRA)), TO_NUMBER(TRIM(UNIDADE))
