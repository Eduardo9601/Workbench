SELECT A.COD_VD, 
       B.NOME_VD,
       TO_CHAR(SUM(NVL(A.VALOR_VD, 0)), 'FM999G999G990D00') AS "TOTAL_MES",
       '01/04/2024' AS "DE",
       '30/04/2024' AS "ATE"
FROM RHFP1005 A,
     RHFP1000 B
WHERE A.COD_VD = B.COD_VD
  AND A.COD_MESTRE_EVENTO IN (SELECT COD_MESTRE_EVENTO
                               FROM RHFP1003
                              WHERE TO_DATE(DATA_REFERENCIA) BETWEEN
                                    '01/04/2024' AND '30/04/2024'
                                   --'01/10/2022' AND '31/10/2022'
                                AND COD_ORGANOGRAMA = 8
                                AND COD_EVENTO = 9)
GROUP BY A.COD_VD, B.NOME_VD
ORDER BY A.COD_VD ASC;