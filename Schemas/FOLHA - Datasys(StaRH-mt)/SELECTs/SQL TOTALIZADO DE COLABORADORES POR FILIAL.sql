SELECT DISTINCT C.EDICAO_NIVEL3,
                D.NOME_ORGANOGRAMA,
                COUNT(DISTINCT A.COD_CONTRATO) AS QTD_CONTRATOS,
                SUM(CASE
                      WHEN F.COD_CLH NOT IN
                           (7, 8, 14, 77, 78, 79, 80, 81, 86, 87, 88, 90, 128, 137, 184, 185, 186, 188, 189, 190, 192, 255, 268, 275, 283, 294, 299, 301, 302, 304, 318, 325, 74, 310, 68) THEN
                       1
                      ELSE
                       0
                    END) QTD_COLABORADORES,
                SUM(CASE
                      WHEN F.COD_CLH IN (74, 310) THEN
                       1
                      ELSE
                       0
                    END) QTD_APRENDIZ,
                SUM(CASE
                      WHEN F.COD_CLH IN
                           (7, 8, 14, 77, 78, 79, 80, 81, 86, 87, 88, 90, 128, 137, 184, 185, 186, 188, 189, 190, 192, 255, 268, 275, 283, 294, 299, 301, 302, 304, 318, 325) THEN
                       1
                      ELSE
                       0
                    END) QTD_GERENTES,
                SUM(CASE
                      WHEN F.COD_CLH = 68 THEN
                       1
                      ELSE
                       0
                    END) QTD_SERVENTES,
                SUM(CASE
                      WHEN G.IND_DEFICIENCIA = 'S' THEN
                       1
                      ELSE
                       0
                    END) QTD_PCD,
                SUM(CASE
                      WHEN J.COD_CAUSA_AFAST IS NOT NULL THEN
                       1
                      ELSE
                       0
                    END) QTD_AFASTADOS
  FROM RHFP0310 A,
       RHFP0300 B,
       RHFP0401 C,
       RHFP0400 D,
       RHFP0340 F,
       RHFP0200 G,
       RHFP0306 J
 WHERE B.COD_CONTRATO = A.COD_CONTRATO
   AND B.COD_FUNC = G.COD_FUNC
   AND C.EDICAO_NIVEL3 BETWEEN '004' AND '7999'
   AND (B.DATA_FIM > SYSDATE OR B.DATA_FIM IS NULL)
   AND (A.DATA_FIM > SYSDATE OR A.DATA_FIM IS NULL)
   AND (F.DATA_FIM > SYSDATE OR F.DATA_FIM IS NULL)
   AND B.COD_CONTRATO = J.COD_CONTRATO(+)
   AND J.DATA_INICIO(+) <= SYSDATE
   AND J.DATA_FIM(+) >= SYSDATE
   AND C.COD_ORGANOGRAMA = A.COD_ORGANOGRAMA
   AND D.COD_ORGANOGRAMA = C.COD_ORGANOGRAMA
   AND F.COD_CONTRATO = B.COD_CONTRATO
 GROUP BY C.EDICAO_NIVEL3, D.NOME_ORGANOGRAMA
 ORDER BY 1 ASC