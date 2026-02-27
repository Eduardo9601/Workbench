CREATE OR REPLACE VIEW VH_HORAS_MES_AVT AS
WITH HORAS_MES AS (
SELECT A.COD_CONTRATO,
       B.DES_PESSOA,
       B.COD_UNIDADE,
       B.DES_UNIDADE,

       /* m�s/ano da compet�ncia */
       TRUNC(A.DATA_OCORRENCIA, 'MM') AS COMPETENCIA, --formato de data é DD/MM/YYYY ex: 01/02/2026
       LAST_DAY(A.DATA_OCORRENCIA) AS COMPETENCIA_FIM, --formato de data é DD/MM/YYYY ex: 28/02/2026
       TO_CHAR(TRUNC(A.DATA_OCORRENCIA, 'MM'), 'MM/YYYY') AS MES,  --formato de data é MM/YYYY ex: 02/2026

       /* totais mensais (decimais em horas) */
       SUM(CASE
             WHEN A.COD_OCORRENCIA = 2 THEN
              A.NUM_HORAS
             ELSE
              0
           END) AS TOTAL_HORAS,

       SUM(CASE
             WHEN UPPER(C.NOME_OCORRENCIA) LIKE '%FALTA%' THEN
              A.NUM_HORAS
             ELSE
              0
           END) AS TOTAL_FALTAS,

       SUM(CASE
             WHEN (UPPER(C.NOME_OCORRENCIA) LIKE '%ATRASO%' OR
                  UPPER(C.NOME_OCORRENCIA) LIKE '%ACOMPANHAMENTO%') AND
                  C.COD_VD IS NOT NULL THEN
              A.NUM_HORAS
             ELSE
              0
           END) AS TOTAL_ATRASOS,

       SUM(CASE
             WHEN UPPER(C.NOME_OCORRENCIA) LIKE '%FALTAS A COMPENSAR%' AND
                  C.COD_VD IS NOT NULL THEN
              A.NUM_HORAS
             ELSE
              0
           END) AS TOTAL_COMPENSAR,

       SUM(CASE
             WHEN UPPER(C.NOME_OCORRENCIA) LIKE '%EXTRAS%' AND
                  C.COD_VD IS NOT NULL THEN
              A.NUM_HORAS
             ELSE
              0
           END) AS TOTAL_EXTRAS,

       SUM(CASE
             WHEN UPPER(C.NOME_OCORRENCIA) LIKE '%FERIAS%' THEN
              A.NUM_HORAS
             ELSE
              0
           END) AS TOTAL_FERIAS
  FROM RHAF1123 A
  JOIN V_DADOS_PESSOA B ON B.COD_CONTRATO = A.COD_CONTRATO
  JOIN RHAF1129 C ON C.COD_OCORRENCIA = A.COD_OCORRENCIA
 WHERE A.DATA_OCORRENCIA >= DATE '2020-01-01'
   AND A.DATA_OCORRENCIA <= (SELECT NVL(MAX(X.DATA_OCORRENCIA), TRUNC(SYSDATE)-1)
                             FROM RHAF1123 X 
                             WHERE X.COD_CONTRATO = A.COD_CONTRATO
                             AND X.COD_OCORRENCIA = 2)-- < TRUNC(SYSDATE) + 1
   --AND A.COD_CONTRATO = 389622
 GROUP BY TRUNC(A.DATA_OCORRENCIA, 'MM'),
          LAST_DAY(A.DATA_OCORRENCIA),
          A.COD_CONTRATO,
          B.DES_PESSOA,
          B.COD_UNIDADE,
          B.DES_UNIDADE

)

SELECT COD_CONTRATO,
    DES_PESSOA,
    COD_UNIDADE,
    DES_UNIDADE,
    COMPETENCIA,
    COMPETENCIA_FIM,
    MES,
       CASE
         WHEN TOTAL_HORAS < 0 THEN
          '-' || TRUNC(ABS(TOTAL_HORAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(TOTAL_HORAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(TOTAL_HORAS) || ':' || LPAD(ROUND(MOD(TOTAL_HORAS, 1) * 60), 2, '0')
       END AS HORAS,

       CASE
         WHEN TOTAL_FALTAS < 0 THEN
          '-' || TRUNC(ABS(TOTAL_FALTAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(TOTAL_FALTAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(TOTAL_FALTAS) || ':' || LPAD(ROUND(MOD(TOTAL_FALTAS, 1) * 60), 2, '0')
       END AS FALTAS,

       CASE
         WHEN TOTAL_COMPENSAR < 0 THEN
          '-' || TRUNC(ABS(TOTAL_COMPENSAR)) || ':' ||
          LPAD(ROUND(MOD(ABS(TOTAL_COMPENSAR), 1) * 60), 2, '0')
         ELSE
          TRUNC(TOTAL_COMPENSAR) || ':' || LPAD(ROUND(MOD(TOTAL_COMPENSAR, 1) * 60), 2, '0')
       END AS COMPENSAR,

       CASE
         WHEN TOTAL_ATRASOS < 0 THEN
          '-' || TRUNC(ABS(TOTAL_ATRASOS)) || ':' ||
          LPAD(ROUND(MOD(ABS(TOTAL_ATRASOS), 1) * 60), 2, '0')
         ELSE
          TRUNC(TOTAL_ATRASOS) || ':' || LPAD(ROUND(MOD(TOTAL_ATRASOS, 1) * 60), 2, '0')
       END AS ATRASOS,

       CASE
         WHEN TOTAL_EXTRAS < 0 THEN
          '-' || TRUNC(ABS(TOTAL_EXTRAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(TOTAL_EXTRAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(TOTAL_EXTRAS) || ':' || LPAD(ROUND(MOD(TOTAL_EXTRAS, 1) * 60), 2, '0')
       END AS EXTRAS,

       CASE
         WHEN TOTAL_FERIAS < 0 THEN
          '-' || TRUNC(ABS(TOTAL_FERIAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(TOTAL_FERIAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(TOTAL_FERIAS) || ':' || LPAD(ROUND(MOD(TOTAL_FERIAS, 1) * 60), 2, '0')
       END AS FERIAS
FROM HORAS_MES
;
