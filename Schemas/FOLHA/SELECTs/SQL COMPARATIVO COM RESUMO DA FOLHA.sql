SELECT A.COD_VD, B.NOME_VD, SUM(NVL(A.VALOR_VD,0)) "TOTAL_MES"
FROM RHFP1006 A,
     RHFP1000 B
WHERE A.COD_VD IN (1, 2, 3, 5, 7, 8, 10,
                   13, 19, 28, 29, 37, 38,
                   43, 158, 184, 185, 187,
                   323, 325, 326, 327, 328,
                   329, 330)
  AND A.COD_VD = B.COD_VD
  AND COD_MESTRE_EVENTO IN (SELECT COD_MESTRE_EVENTO FROM RHFP1003
                            WHERE TO_DATE(DATA_REFERENCIA) BETWEEN :DATA_INICIAL AND :DATA_FINAL
                            --'01/10/2022' AND '31/10/2022'
                            AND COD_ORGANOGRAMA = :ORGANOGRAMA
                            AND COD_EVENTO IN (1, 17, 19, 26))
GROUP BY A.COD_VD, B.NOME_VD
ORDER BY A.COD_VD ASC