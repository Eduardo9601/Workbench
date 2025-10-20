--comando para mostrar valores distintos de EDICAO_NIVEL6, seus comprimentos e uma representação em dump do valor (para identificar possíveis caracteres não imprimíveis ou outros valores problemáticos)

SELECT DISTINCT A.EDICAO_NIVEL6, LENGTH(A.EDICAO_NIVEL6) AS LENGTH, DUMP(A.EDICAO_NIVEL6) AS DUMP_VALUE
FROM RHFP0401 A
WHERE A.COD_NIVEL3 IN (9, 21)
ORDER BY LENGTH(A.EDICAO_NIVEL6) ASC;
