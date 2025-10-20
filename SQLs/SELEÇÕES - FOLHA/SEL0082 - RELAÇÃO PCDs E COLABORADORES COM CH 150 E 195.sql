WITH
PCDs AS (
SELECT COD_CONTRATO,
       DES_PESSOA,
       DES_FUNCAO,
       DES_UNIDADE,
       DES_REDE_LOCAL,
       HR_BASE_MES,
       CASE
           WHEN IND_DEFICIENCIA = 'S' THEN
            IND_DEFICIENCIA
           WHEN IND_DEFICIENCIA = 'N' THEN
            IND_DEFICIENCIA
           ELSE 
            NULL
       END "DEFICIENCIA?",
       CASE
           WHEN IND_DEFICIENCIA = 'S' THEN
            DES_DEFICIENCIA
           WHEN IND_DEFICIENCIA = 'N' THEN
            NULL
           ELSE 
            NULL
       END "QUAL?",
       CASE
           WHEN IND_DEFICIENCIA = 'S' THEN 
            TO_CHAR(HOR_1_ENT || ' - ' || HOR_1_SAI || ' - ' || HOR_2_ENT || ' - ' || HOR_2_SAI)
           ELSE
            NULL
       END AS HORARIO_SEM,
       CASE
           WHEN IND_DEFICIENCIA = 'S' THEN 
            TO_CHAR(HOR_3_ENT || ' - ' || HOR_3_SAI || ' - ' || HOR_4_ENT || ' - ' || HOR_4_SAI) 
           ELSE 
            NULL
       END AS HORARIO_SAB
FROM V_DADOS_COLAB_AVT
WHERE STATUS = 0
AND COD_TIPO = 1
AND IND_DEFICIENCIA  = 'S'

),

COLABS_150_195 AS (
SELECT COD_CONTRATO,
       DES_PESSOA,
       DES_FUNCAO,
       DES_UNIDADE,
       DES_REDE_LOCAL,
       HR_BASE_MES, 
       CASE
           WHEN IND_DEFICIENCIA = 'S' THEN
            IND_DEFICIENCIA
           WHEN IND_DEFICIENCIA = 'N' THEN
            IND_DEFICIENCIA
           ELSE 
            NULL
       END "DEFICIENCIA?",
       CASE
           WHEN IND_DEFICIENCIA = 'S' THEN
            DES_DEFICIENCIA
           WHEN IND_DEFICIENCIA = 'N' THEN
            NULL
           ELSE 
            NULL
       END "QUAL?",     
       CASE
           WHEN HR_BASE_MES = 150 THEN 
            TO_CHAR(HOR_1_ENT || ' - ' || HOR_1_SAI || ' - ' || HOR_2_ENT || ' - ' || HOR_2_SAI) 
           ELSE
            NULL
       END AS HORARIO_SEM,
       CASE
           WHEN HR_BASE_MES = 195 THEN 
            TO_CHAR(HOR_3_ENT || ' - ' || HOR_3_SAI || ' - ' || HOR_4_ENT || ' - ' || HOR_4_SAI) 
           ELSE 
            NULL
       END AS HORARIO_SAB
FROM V_DADOS_COLAB_AVT
WHERE STATUS = 0
AND COD_TIPO = 1
AND HR_BASE_MES IN (150, 195)

)

SELECT * FROM PCDs

UNION ALL

SELECT NULL AS COD_CONTRATO,
       NULL AS DES_PESSOA,
       NULL AS DES_FUNCAO,
       'Colaboradores cargas horarias 150h e 195h' AS DES_UNIDADE,
       NULL AS DES_REDE_LOCAL,
       NULL AS HR_BASE_MES,
       NULL AS "DEFICIENCIA?",
       NULL AS "QUAL?",
       NULL AS HORARIO_SEM,
       NULL AS HORARIO_SAB
  FROM DUAL

UNION ALL

SELECT * FROM COLABS_150_195
