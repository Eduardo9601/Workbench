/* ===========================================================
   ===== SQL PARA GERAR RELATÓRIO CONF. RATEIO SERVENTES =====
   ===== - MESMO QUE GERA O ARQUIVO CONTÁBIL =================
   =========================================================== */

WITH
PARAMS AS (

/*VERSÃO PARA USAR NO PL/SQL*/
/*SELECT TO_DATE('&DATA_INICIO', 'DD/MM/YYYY') AS D_INI,
       TO_DATE('&DATA_FIM', 'DD/MM/YYYY') AS D_FIM
  FROM DUAL*/



/*VERSÃO PARA USAR NO SAPINHO E DENTRO DA FOLHA*/
SELECT :DATA_INICIO AS D_INI, :DATA_FIM AS D_FIM FROM DUAL

),
/*CALENDÁRIO MENSAL DINÂMICO A PARTIR DOS PARÂMTROS ACIMA (PARAMS)*/
DATAS_REF AS (
  SELECT
  /* MÊS I INICIANDO NO 1º DIA DO MÊS DE D_INI */
   ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1) AS DTA_INI,
   LAST_DAY(ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1)) AS DTA_FIM,
   TO_CHAR(ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1), 'MM/YYYY') AS MES_ANO,
   /* ÍNDICE DO MÊS DENTRO DO PERÍODO */
   LEVEL AS IDX_MES,
   /* QUANTIDADE TOTAL DE MESES DO PERÍODO (MESMA EM TODAS AS LINHAS) */
   MONTHS_BETWEEN(ADD_MONTHS(TRUNC(P.D_FIM, 'MM'), 1), TRUNC(P.D_INI, 'MM')) AS QTD_MESES
    FROM PARAMS P
  CONNECT BY LEVEL <= MONTHS_BETWEEN(ADD_MONTHS(TRUNC(P.D_FIM, 'MM'), 1),
                                     TRUNC(P.D_INI, 'MM'))

),


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
    CROSS JOIN DATAS_REF D
   WHERE  CT.DATA_ADMISSAO <= D.DTA_FIM
     AND NVL(CT.DATA_DEMISSAO, DATE '2999-12-31') >= D.DTA_INI

          /*(CT.DATA_DEMISSAO IS NULL OR
          CT.DATA_DEMISSAO >= TO_DATE('01/09/2025', 'DD/MM/YYYY'))*/
     /*VERSÃO ALTERNATIVA
     ((TO_DATE('31/08/2025', 'DD/MM/YYYY') BETWEEN CT.DATA_ADMISSAO
     AND CT.DATA_DEMISSAO) OR (CT.DATA_ADMISSAO <= TO_DATE('31/08/2025', 'DD/MM/YYYY')
     AND CT.DATA_DEMISSAO IS NULL))*/
     AND D.DTA_INI BETWEEN ORG.DATA_INI_ORG AND ORG.DATA_FIM_ORG
     AND D.DTA_INI BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH
     AND D.DTA_INI BETWEEN HR.DATA_INI_HR AND HR.DATA_FIM_HR
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
       RHFP0100 AFN,
       DATAS_REF D
  WHERE CT.COD_CONTRATO = AF.COD_CONTRATO(+)
    AND CT.COD_CONTRATO = ORG.COD_CONTRATO(+)
    AND CT.COD_CONTRATO = FN.COD_CONTRATO(+)
    AND AF.COD_CAUSA_AFAST = AFN.COD_CAUSA_AFAST(+)
    AND CT.DATA_INICIO <= D.DTA_FIM
    AND NVL(CT.DATA_FIM, DATE '2999-12-31') >= D.DTA_INI
    /*AND (CT.DATA_FIM IS NULL OR
         CT.DATA_FIM >= TO_DATE('01/09/2025', 'DD/MM/YYYY'))*/
    /*VERSÃO ALTERNATIVA
     ((TO_DATE('31/08/2025', 'DD/MM/YYYY') BETWEEN CT.DATA_INICIO
     AND CT.DATA_FIM) OR (CT.DATA_INICIO <= TO_DATE('31/08/2025', 'DD/MM/YYYY')
     AND CT.DATA_FIM IS NULL))*/
    AND D.DTA_INI BETWEEN AF.DATA_INICIO(+) AND NVL(AF.DATA_FIM(+), DATE '2999-12-31')
    --AND TO_DATE('30/09/2025','DD/MM/YYYY') BETWEEN AF.DATA_INICIO(+) AND AF.DATA_FIM(+)
    AND D.DTA_INI BETWEEN ORG.DATA_INI_ORG(+) AND ORG.DATA_FIM_ORG(+)
    AND D.DTA_INI BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH(+)
    AND ORG.COD_EMP = 8
    AND FN.COD_FUNCAO = 68

),

VENCIMENTOS AS (
  SELECT A.COD_CONTRATO,
         C.NOME_EVENTO,
         A.VALOR_VD AS VENCIMENTOS
  FROM RHFP1006 A
  JOIN RHFP1003 B ON B.COD_MESTRE_EVENTO = A.COD_MESTRE_EVENTO
  LEFT JOIN RHFP1002 C ON B.COD_EVENTO = C.COD_EVENTO
  WHERE B.DATA_REFERENCIA BETWEEN TO_DATE('01/09/2025','DD/MM/YYYY')
                              AND TO_DATE('30/09/2025','DD/MM/YYYY')
    AND B.COD_EVENTO IN (1, 12, 13, 17, 19)
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
             AND DATA_MOV BETWEEN TO_DATE('01/09/2025', 'DD/MM/YYYY') AND
                 TO_DATE('30/09/2025', 'DD/MM/YYYY')
             AND COD_EVENTO IN (1, 12, 13, 17, 19)
             /*AND COD_CONTRATO IN (394006,
                                    394226,
                                    396617,
                                    97146)*/
           GROUP BY COD_CONTRATO,
                    COD_VD,
                    VALOR_VD,
                    QTDE_VD
          ) PIVOT(MAX(UNIDADE) AS UNID, SUM(HORAS) AS HORAS FOR COD_VD IN (1800 AS VD1800, 1801 AS VD1801, 1802 AS VD1802, 1803 AS VD1803, 1804 AS VD1804))
),

BASE AS (
  SELECT CT.COD_UNIDADE,
         CT.DES_UNIDADE,
         CT.COD_REDE,
         CT.DES_REDE,
         M.COD_CONTRATO,
         --CT.DES_PESSOA,
         CT.HR_BASE_MES,
         TO_NUMBER(CT.HR_BASE_MES) AS HR_BASE_MES_NUM,
         V.NOME_EVENTO,
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
         COALESCE(NULLIF(TO_CHAR(M.UNIDADE_1800),'0'), CT.COD_UNIDADE) AS UNIDADE_CONTRA
         --M.DATA_MOV AS REFERENCIA
  FROM MOVIMENTOS M
  INNER JOIN VENCIMENTOS V ON V.COD_CONTRATO = M.COD_CONTRATO
  LEFT JOIN CONTRATOS CT ON M.COD_CONTRATO = CT.COD_CONTRATO
  --LEFT JOIN STATUS_AFASTADOS AF ON AF.COD_CONTRATO = M.COD_CONTRATO
  WHERE (NVL(M.HORAS_1800,0)+NVL(M.HORAS_1801,0)+NVL(M.HORAS_1802,0)+NVL(M.HORAS_1803,0)+NVL(M.HORAS_1804,0)) > 0
    --AND AF.STATUS_AFAST IN (0, 6, 7)
)

/* ============================
   === RESULTADO FINAL AQUI ===
   ============================ */
SELECT A.COD_UNIDADE,
       A.DES_UNIDADE,
       A.COD_REDE,
       A.DES_REDE,
       A.COD_CONTRATO,
       --A.DES_PESSOA,
       A.HR_BASE_MES,
       A.HR_BASE_MES_NUM,
       A.NOME_EVENTO,
       TO_CHAR(A.VENCIMENTOS, 'FM999G999G990D00') AS VENCIMENTOS,
       A.UNIDADE_1800,
       A.HORAS_1800,
       A.UNIDADE_1801,
       A.HORAS_1801,
       A.UNIDADE_1802,
       A.HORAS_1802,
       A.UNIDADE_1803,
       A.HORAS_1803,
       A.UNIDADE_1804,
       A.HORAS_1804,
       A.HORAS_MES_1800,
       A.HORAS_MES_1801,
       A.HORAS_MES_1802,
       A.HORAS_MES_1803,
       A.HORAS_MES_1804,
       A.UNIDADE_CONTRA,
       (NVL(A.HORAS_MES_1800, 0) + NVL(A.HORAS_MES_1801, 0) +
       NVL(A.HORAS_MES_1802, 0) + NVL(A.HORAS_MES_1803, 0) +
       NVL(A.HORAS_MES_1803, 0) + NVL(A.HORAS_MES_1804, 0)) AS TOTAL_HORAS,
       TO_CHAR(NVL(ROUND(NVL(TO_NUMBER(A.VENCIMENTOS), 0) *
                         (NVL(A.HORAS_MES_1800, 0) +
                          NVL(A.HORAS_MES_1801, 0) +
                          NVL(A.HORAS_MES_1802, 0) +
                          NVL(A.HORAS_MES_1803, 0) +
                          NVL(A.HORAS_MES_1804, 0)) /
                         NULLIF(TO_NUMBER(A.HR_BASE_MES), 0),
                         2),
                   0),
               'FM999G999G990D00' -- usa os separadores da sessão
               ) AS TOTAL_RATEADO,
       'Referência: ' || D.DTA_INI || ' - ' || D.DTA_FIM || '  |  ' || 'Unidade: ' || :UNIDADE || '  |  ' || 'Rede: ' || :REDE AS PARAMETROS
FROM BASE A
CROSS JOIN DATAS_REF D
WHERE (A.COD_UNIDADE = :UNIDADE OR :UNIDADE = 0)
  AND (A.COD_REDE = :REDE OR :REDE = 0)
ORDER BY A.DES_UNIDADE


/*
FILTROS E PARÂMETROS PARA USAR NO PL/SQL
'Referência: ' || D.DTA_INI || ' - ' || D.DTA_FIM || '  |  ' ||
'Unidade: ' || &UNIDADE || '  |  ' || 'Rede: ' || &REDE AS PARAMETROS
 WHERE (A.COD_UNIDADE = &UNIDADE OR &UNIDADE = 0)
   AND (A.COD_REDE = &REDE OR &REDE = 0)
*/





/*
\* ABAIXO PROCESSO USADO NO ARQUIVO, MAS PODE SERVIR COMO BASE DE RELATÓRIOS TAMBÉM *\
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

\*LAYOUT OFICIAL DO FORMATO DO ARQUIVO txt DE IMPORTAÇÃO CONTÁBIL*\
SELECT
  '001' || LPAD(TRIM(TO_CHAR(NVL(UNIDADE, 0))), 7, '0') || '341101' ||
  RPAD(' ', 34) || 'D3045' || RPAD(' ', 200) ||
  LPAD( TO_CHAR(ROUND(VALOR * 100)) || TO_CHAR(REFERENCIA, 'DDMMYYYY') || '341101', 29, '0') ||
  RPAD(' ', 14) ||
  LPAD(TRIM(TO_CHAR(NVL(UNIDADE_CONTRA, 0))), 7, '0') ||
  RPAD(' ', 20) || '*' AS LINHA_ERP
FROM RESULTADO
ORDER BY TO_NUMBER(TRIM(UNIDADE_CONTRA)), TO_NUMBER(TRIM(UNIDADE));

*/