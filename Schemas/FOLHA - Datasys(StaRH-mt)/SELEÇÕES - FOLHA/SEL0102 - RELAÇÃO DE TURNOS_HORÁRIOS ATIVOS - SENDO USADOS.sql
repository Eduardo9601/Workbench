SELECT *
FROM (
    SELECT DISTINCT 
           1 AS ORDEM,
           '' AS COD_TURNO,
           '' AS DES_TURNO,
           '' AS HR_BASE_MES,
           '' AS HR_BASE_SEM,
           '' AS HR_BASE_DIA,
           '' AS HORA_ENTRADA_1,
           '' AS HORA_SAIDA_1,
           '' AS HORA_ENTRADA_2,
           '' AS HORA_SAIDA_2,
           '' AS HOR_ENTRADA_3,
           '' AS HORA_SAIDA_3,
           '' AS HOR_ENTRADA_4,
           '' AS HORA_SAIDA_4,
           'Momento da Exportação: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') AS DATA_HORA_EXPORT
    FROM dual


    UNION ALL

    SELECT DISTINCT 
           2 AS ORDEM,
           TO_CHAR(COD_TURNO) AS COD_TURNO,
           TO_CHAR(DES_TURNO) AS DES_TURNO,
           TO_CHAR(HR_BASE_MES) AS HR_BASE_MES,
           TO_CHAR(HR_BASE_SEM) AS HR_BASE_SEM,
           TO_CHAR(HR_BASE_DIA) AS HR_BASE_DIA,
           TO_CHAR(HOR_1_ENT) AS HORA_ENTRADA_1,
           TO_CHAR(HOR_1_SAI) AS HORA_SAIDA_1,
           TO_CHAR(HOR_2_ENT) AS HORA_ENTRADA_2,
           TO_CHAR(HOR_2_SAI) AS HORA_SAIDA_2,
           TO_CHAR(HOR_3_ENT) AS HOR_ENTRADA_3,
           TO_CHAR(HOR_3_SAI) AS HORA_SAIDA_3,
           TO_CHAR(HOR_4_ENT) AS HOR_ENTRADA_4,
           TO_CHAR(HOR_4_SAI) AS HORA_SAIDA_4,
           TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') AS DATA_HORA_EXPORT
    FROM V_DADOS_COLAB_AVT
    WHERE STATUS = 0
) t
ORDER BY
    t.ORDEM,
    CASE 
      WHEN REGEXP_LIKE(t.COD_TURNO, '^[0-9]+$') THEN TO_NUMBER(t.COD_TURNO)
      ELSE NULL
    END,
    t.COD_TURNO;
