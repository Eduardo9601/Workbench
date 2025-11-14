CREATE OR REPLACE VIEW VH_HORAS_DIA_AVT AS
WITH DIA AS (
  SELECT A.COD_CONTRATO,
         B.DES_PESSOA,
         B.COD_UNIDADE,
         B.DES_UNIDADE,
         TRUNC(A.DATA_OCORRENCIA) AS DATA_DIA,

         /* Dia da semana (texto) e número ISO (segunda=1) */
         TO_CHAR(TRUNC(A.DATA_OCORRENCIA),
                 'FMDAY',
                 'NLS_DATE_LANGUAGE=Portuguese') AS DIA_SEMANA,
         TO_CHAR(TRUNC(A.DATA_OCORRENCIA),
                 'FMDY',
                 'NLS_DATE_LANGUAGE=Portuguese') AS DIA_SEMANA_ABREV,
         --TRUNC(A.DATA_OCORRENCIA) - TRUNC(A.DATA_OCORRENCIA, 'IW') + 1 AS DIA_SEMANA_NUM,

         /* buckets por dia */
         SUM(CASE
               WHEN A.COD_OCORRENCIA = 2 THEN
                A.NUM_HORAS
               ELSE
                0
             END) AS HORAS,
         SUM(CASE
               WHEN UPPER(C.NOME_OCORRENCIA) LIKE '%FALTA%' THEN
                A.NUM_HORAS
               ELSE
                0
             END) AS FALTAS,

         SUM(CASE
               WHEN (UPPER(C.NOME_OCORRENCIA) LIKE '%ATRASO%' OR
                    UPPER(C.NOME_OCORRENCIA) LIKE '%ACOMPANHAMENTO%') AND
                    C.COD_VD IS NOT NULL THEN
                A.NUM_HORAS
               ELSE
                0
             END) AS ATRASOS,

         SUM(CASE
               WHEN UPPER(C.NOME_OCORRENCIA) LIKE '%FALTAS A COMPENSAR%' AND
                    C.COD_VD IS NOT NULL THEN
                A.NUM_HORAS
               ELSE
                0
             END) AS COMPENSAR,

         SUM(CASE
               WHEN UPPER(C.NOME_OCORRENCIA) LIKE '%EXTRAS%' AND
                    C.COD_VD IS NOT NULL THEN
                A.NUM_HORAS
               ELSE
                0
             END) AS EXTRAS,
         SUM(CASE
               WHEN UPPER(C.NOME_OCORRENCIA) LIKE '%FERIAS%' THEN
                A.NUM_HORAS
               ELSE
                0
             END) AS FERIAS
    FROM RHAF1123 A
    JOIN V_DADOS_PESSOA B ON B.COD_CONTRATO = A.COD_CONTRATO
    JOIN RHAF1129 C ON C.COD_OCORRENCIA = A.COD_OCORRENCIA
   WHERE A.DATA_OCORRENCIA >= DATE '2020-01-01'
     AND A.DATA_OCORRENCIA < TRUNC(SYSDATE) + 1
     --AND A.COD_CONTRATO = 389622
   GROUP BY A.COD_CONTRATO,
            B.DES_PESSOA,
            B.COD_UNIDADE,
            B.DES_UNIDADE,
            TRUNC(A.DATA_OCORRENCIA)
)

SELECT COD_CONTRATO,
       DES_PESSOA,
       COD_UNIDADE,
       DES_UNIDADE,
       DATA_DIA AS COMPETENCIA,
       DIA_SEMANA,
       DIA_SEMANA_ABREV,
       --DIA_SEMANA_NUM,

       /* formatações HH:MM (mesma lógica que você já usa) */
       HORAS AS NUM_HORAS,
       CASE
         WHEN HORAS < 0 THEN
          '-' || TRUNC(ABS(HORAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(HORAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(HORAS) || ':' || LPAD(ROUND(MOD(HORAS, 1) * 60), 2, '0')
       END AS HORAS,

       FALTAS AS NUM_FALTAS,
       CASE
         WHEN FALTAS < 0 THEN
          '-' || TRUNC(ABS(FALTAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(FALTAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(FALTAS) || ':' || LPAD(ROUND(MOD(FALTAS, 1) * 60), 2, '0')
       END AS FALTAS,

       COMPENSAR AS NUM_COMPENSAR,
       CASE
         WHEN COMPENSAR < 0 THEN
          '-' || TRUNC(ABS(COMPENSAR)) || ':' ||
          LPAD(ROUND(MOD(ABS(COMPENSAR), 1) * 60), 2, '0')
         ELSE
          TRUNC(COMPENSAR) || ':' || LPAD(ROUND(MOD(COMPENSAR, 1) * 60), 2, '0')
       END AS COMPENSAR,

       ATRASOS AS NUM_ATRASOS,
       CASE
         WHEN ATRASOS < 0 THEN
          '-' || TRUNC(ABS(ATRASOS)) || ':' ||
          LPAD(ROUND(MOD(ABS(ATRASOS), 1) * 60), 2, '0')
         ELSE
          TRUNC(ATRASOS) || ':' || LPAD(ROUND(MOD(ATRASOS, 1) * 60), 2, '0')
       END AS ATRASOS,

       EXTRAS AS NUM_EXTRAS,
       CASE
         WHEN EXTRAS < 0 THEN
          '-' || TRUNC(ABS(EXTRAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(EXTRAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(EXTRAS) || ':' || LPAD(ROUND(MOD(EXTRAS, 1) * 60), 2, '0')
       END AS EXTRAS,

       FERIAS AS NUM_FERIAS,
       CASE
         WHEN FERIAS < 0 THEN
          '-' || TRUNC(ABS(FERIAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(FERIAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(FERIAS) || ':' || LPAD(ROUND(MOD(FERIAS, 1) * 60), 2, '0')
       END AS FERIAS
       /*CASE
         WHEN TOTAL_ATRASOS < 0 THEN
          '-' || TRUNC(ABS(TOTAL_ATRASOS)) || ':' ||
          LPAD(ROUND(MOD(ABS(TOTAL_ATRASOS), 1) * 60), 2, '0')
         ELSE
          TRUNC(TOTAL_ATRASOS) || ':' ||
          LPAD(ROUND(MOD(TOTAL_ATRASOS, 1) * 60), 2, '0')
       END AS TOTAL_ATRASOS,
       CASE
         WHEN TOTAL_EXTRAS < 0 THEN
          '-' || TRUNC(ABS(TOTAL_EXTRAS)) || ':' ||
          LPAD(ROUND(MOD(ABS(TOTAL_EXTRAS), 1) * 60), 2, '0')
         ELSE
          TRUNC(TOTAL_EXTRAS) || ':' ||
          LPAD(ROUND(MOD(TOTAL_EXTRAS, 1) * 60), 2, '0')
       END AS TOTAL_EXTRAS*/
  FROM DIA
 ORDER BY COMPETENCIA, DES_PESSOA

