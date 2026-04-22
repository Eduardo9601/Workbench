SELECT LAST_DAY(MES) AS DTA_MOVIMENTO,
       COD_UNIDADE,
       REGIAO,
       REDE,
       VLR_PREVENTIVA,
       SUM(CASE
             WHEN VLR_PREVENTIVA > 0 THEN 1
             ELSE 0
           END) OVER (PARTITION BY COD_UNIDADE) AS QTD_MESES,
           cod_grupo_lcto
  FROM (
        SELECT MES,
               COD_UNIDADE,
               MAX(REGIAO) AS REGIAO,
               MAX(REDE) AS REDE,
               SUM(VLR_PREV_MES) AS VLR_PREVENTIVA, cod_grupo_lcto
          FROM (
                SELECT TRUNC(A.DTA_MOVIMENTO, 'MM') AS MES,
                       A.COD_UNIDADE,
                       CASE
                         WHEN TO_CHAR(A.COD_GRUPO_UNI) LIKE '%8%' THEN
                          A.COD_GRUPO_UNI
                       END AS REGIAO,
                       CASE
                         WHEN TO_CHAR(A.COD_QUEBRA_UNI) NOT LIKE '%8%' THEN
                          A.COD_QUEBRA_UNI
                       END AS REDE,
                       NVL(A.VLR_PREVENTIVO, 0) AS VLR_PREV_MES, a.cod_grupo_lcto
                  FROM NL.ES_0124_CR_PROJECAO@NLGRZ A
                 WHERE A.DTA_MOVIMENTO >= '01/01/2025'
                   AND A.DTA_MOVIMENTO <= '31/12/2025'
                   AND A.COD_QUEBRA_LCTO = 1
                   AND A.COD_UNIDADE <> 0
                   AND A.COD_UNIDADE = 568--IN(19,34,205,371,392,461,554,555,567,568,615,7038,7046,7059,7268,7415,7637)
               ) X
         WHERE REGIAO IS NOT NULL
           AND REDE IS NOT NULL
         GROUP BY MES, COD_UNIDADE, cod_grupo_lcto
       )
 ORDER BY COD_UNIDADE, MES;