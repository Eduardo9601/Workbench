--SQL PARA CALCULAR FALTAS E ATRASOS DOS COLABORADORES

WITH OCORRENCIAS AS (
    SELECT B.COD_CONTRATO, 
        B.DES_PESSOA, 
        SUM(DECODE(cod_ocorrencia, 203, num_horas, 0)) AS "Extras Diurnas 60% ( Geral )",
        SUM(DECODE(cod_ocorrencia, 205, num_horas, 0)) AS "Atrasos Diurno ( Geral )", 
        SUM(DECODE(cod_ocorrencia, 205, num_horas, 0)) AS "Atrasos Diurno ( Geral )", 
        SUM(DECODE(cod_ocorrencia, 203, num_horas, 0)) - SUM(DECODE(cod_ocorrencia, 205, num_horas, 0))  AS  total, 
        SUM(DECODE(cod_ocorrencia, 1034, num_horas, 0)) AS banco_Horas
    FROM RHAF1123 a
    INNER JOIN V_DADOS_PESSOA B ON B.COD_CONTRATO = A.COD_CONTRATO AND B.COD_UNIDADE = '769'
    WHERE A.DATA_OCORRENCIA BETWEEN  TO_DATE('01/02/2024', 'DD/MM/YYYY') AND  TO_DATE('29/02/2024', 'DD/MM/YYYY')
    AND A.cod_ocorrencia IN (203,205, 1034)
    GROUP BY B.COD_CONTRATO, B.DES_PESSOA
) 
SELECT 
    COD_CONTRATO, 
    DES_PESSOA, 
    CASE 
        WHEN banco_Horas < 0 THEN '-' || TRUNC(ABS(banco_Horas)) || ':' || LPAD(ROUND(MOD(ABS(banco_Horas), 1) * 60), 2, '0')
        ELSE TRUNC(banco_Horas) || ':' || LPAD(ROUND(MOD(banco_Horas, 1) * 60), 2, '0')
    END AS "BCO FALTAS ( Geral )", 
    CASE 
        WHEN total < 0 THEN '-' || TRUNC(ABS(total)) || ':' || LPAD(ROUND(MOD(ABS(total), 1) * 60), 2, '0')
        ELSE TRUNC(total) || ':' || LPAD(ROUND(MOD(total, 1) * 60), 2, '0')
    END AS compensar
FROM 
    OCORRENCIAS
   GROUP BY COD_CONTRATO, 
            DES_PESSOA, 
            total, 
            banco_Horas
    ORDER BY DES_PESSOA