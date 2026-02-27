SELECT CASE
         WHEN GROUPING(C.COD_UNIDADE) = 1 THEN
          NULL
         ELSE
          C.COD_UNIDADE
       END AS COD_UNIDADE,
       
       CASE
         WHEN GROUPING(C.COD_UNIDADE) = 1 AND GROUPING(C.TIPO) = 1 THEN
          'TOTAL CONTRATOS DE TUDO:'
         WHEN GROUPING(C.COD_UNIDADE) = 1 AND C.TIPO = 'LOJA' THEN
          'TOTAL CONTRATOS LOJA:'
         WHEN GROUPING(C.COD_UNIDADE) = 1 AND C.TIPO = 'SETOR' THEN
          'TOTAL CONTRATOS SETOR:'
         WHEN GROUPING(C.COD_UNIDADE) = 1 AND C.TIPO = 'DEPÓSITO' THEN
          'TOTAL CONTRATOS DEPÓSITO:'
         ELSE
          C.DES_UNIDADE
       END AS DES_UNIDADE,
       
       CASE
         WHEN GROUPING(C.COD_UNIDADE) = 1 THEN
          NULL
         ELSE
          C.TIPO
       END AS TIPO,
       
       COUNT(DISTINCT A.COD_CONTRATO) AS QTD_CONTRATOS,
       SUM(CASE
             WHEN F.COD_CLH NOT IN
                  (7, 8, 14, 68, 71, 74, 77, 78, 79, 80, 81, 86, 87, 88, 90, 128, 137, 168, 184, 185, 186, 188, 189, 190, 192, 255, 268, 275, 283, 294, 299, 301, 302, 304, 310, 318, 325) THEN
              1
             ELSE
              0
           END) QTD_COLABORADORES,
       SUM(CASE
             WHEN F.COD_CLH IN (168) THEN
              1
             ELSE
              0
           END) QTD_ESTAGIARIOS,
       SUM(CASE
             WHEN F.COD_CLH IN (71, 74, 310) THEN
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
  FROM V_DADOS_COLAB_AVT        A,
       RHFP0310                 A1,
       RHFP0300                 B,
       V_DADOS_ORGANOGRAMAS_AVT C,
       RHFP0340                 F,
       RHFP0200                 G,
       RHFP0306                 J
 WHERE B.COD_CONTRATO = A.COD_CONTRATO
   AND A1.COD_CONTRATO = A.COD_CONTRATO
   AND B.COD_FUNC = G.COD_FUNC
   AND C.COD_ORGANOGRAMA = A1.COD_ORGANOGRAMA
   AND F.COD_CONTRATO = B.COD_CONTRATO(+)
   AND B.COD_CONTRATO = J.COD_CONTRATO(+)
   AND (A1.DATA_FIM > SYSDATE OR A1.DATA_FIM IS NULL)
   AND (B.DATA_FIM > SYSDATE OR B.DATA_FIM IS NULL)
   AND (F.DATA_FIM > SYSDATE OR F.DATA_FIM IS NULL)
   AND J.DATA_INICIO(+) <= SYSDATE
   AND J.DATA_FIM(+) >= SYSDATE

 GROUP BY GROUPING SETS((C.TIPO, C.COD_UNIDADE, C.DES_UNIDADE),(C.TIPO),())

 ORDER BY CASE
            WHEN C.TIPO = 'LOJA' THEN
             1
            WHEN C.TIPO = 'SETOR' THEN
             2
            WHEN C.TIPO = 'DEPÓSITO' THEN
             3
          END,
          C.COD_UNIDADE ASC;




--=====================================--



SELECT CASE
         WHEN GROUPING(C.COD_UNIDADE) = 1 THEN
          NULL
         ELSE
          C.COD_UNIDADE
       END AS COD_UNIDADE,
       
       CASE
         WHEN GROUPING(C.COD_UNIDADE) = 1 AND GROUPING(C.TIPO) = 1 THEN
          'TOTAL CONTRATOS DE TUDO:'
         WHEN GROUPING(C.COD_UNIDADE) = 1 AND C.TIPO = 'LOJA' THEN
          'TOTAL CONTRATOS LOJA:'
         WHEN GROUPING(C.COD_UNIDADE) = 1 AND C.TIPO = 'SETOR' THEN
          'TOTAL CONTRATOS SETOR:'
         WHEN GROUPING(C.COD_UNIDADE) = 1 AND C.TIPO = 'DEPÓSITO' THEN
          'TOTAL CONTRATOS DEPÓSITO:'
         ELSE
          C.DES_UNIDADE
       END AS DES_UNIDADE,
       
       CASE
         WHEN GROUPING(C.COD_UNIDADE) = 1 THEN
          NULL
         ELSE
          C.TIPO
       END AS TIPO,
       
       COUNT(DISTINCT A.COD_CONTRATO) AS QTD_CONTRATOS,
       SUM(CASE
             WHEN F.COD_CLH NOT IN
                  (7, 8, 14, 68, 71, 74, 77, 78, 79, 80, 81, 86, 87, 88, 90, 128, 137, 168, 184, 185, 186, 188, 189, 190, 192, 255, 268, 275, 283, 294, 299, 301, 302, 304, 310, 318, 325) THEN
              1
             ELSE
              0
           END) QTD_COLABORADORES,
       SUM(CASE
             WHEN F.COD_CLH IN (168) THEN
              1
             ELSE
              0
           END) QTD_ESTAGIARIOS,
       SUM(CASE
             WHEN F.COD_CLH IN (71, 74, 310) THEN
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
  FROM V_DADOS_COLAB_AVT        A,
       V_DADOS_ORGANOGRAMAS_AVT C,
       RHFP0200                 G,
       RHFP0306                 J
 WHERE B.COD_CONTRATO = A.COD_CONTRATO
   AND A1.COD_CONTRATO = A.COD_CONTRATO
   AND B.COD_FUNC = G.COD_FUNC
   AND C.COD_ORGANOGRAMA = A1.COD_ORGANOGRAMA
   AND F.COD_CONTRATO = B.COD_CONTRATO(+)
   AND B.COD_CONTRATO = J.COD_CONTRATO(+)
   AND (A1.DATA_FIM > SYSDATE OR A1.DATA_FIM IS NULL)
   AND (B.DATA_FIM > SYSDATE OR B.DATA_FIM IS NULL)
   AND (F.DATA_FIM > SYSDATE OR F.DATA_FIM IS NULL)
   AND J.DATA_INICIO(+) <= SYSDATE
   AND J.DATA_FIM(+) >= SYSDATE

 GROUP BY GROUPING SETS((C.TIPO, C.COD_UNIDADE, C.DES_UNIDADE),(C.TIPO),())

 ORDER BY CASE
            WHEN C.TIPO = 'LOJA' THEN
             1
            WHEN C.TIPO = 'SETOR' THEN
             2
            WHEN C.TIPO = 'DEPÓSITO' THEN
             3
          END,
          C.COD_UNIDADE ASC;
          
          
 
SELECT * FROM V_DADOS_COLAB_AVT
WHERE COD_EMP = '008' 
AND STATUS = 0 
AND COD_CONTRATO = 393831;


SELECT COD_CONTRATO, COUNT(*) AS QTD_REPETICOES
FROM V_DADOS_COLAB_AVT
WHERE COD_EMP = '008' 
AND STATUS = 0
GROUP BY COD_CONTRATO
HAVING COUNT(*) > 1
ORDER BY QTD_REPETICOES DESC;


SELECT * FROM RHAF1145; 
SELECT * FROM RHAF1119;
    
          
SELECT A.COD_UNIDADE,
       A.DES_UNIDADE,
       COUNT(A.COD_CONTRATO) AS QTD_CONTRATOS,
       SUM(CASE
             WHEN A.COD_FUNCAO NOT IN
                  (7, 8, 14, 68, 71, 74, 77, 78, 79, 80, 81, 86, 87, 88, 90, 128, 137, 168, 184, 185, 186, 188, 189, 190, 192, 255, 268, 275, 283, 294, 299, 301, 302, 304, 310, 318, 325) THEN
              1
             ELSE
              0
           END) QTD_COLABORADORES,
       SUM(CASE
             WHEN A.COD_FUNCAO IN
                  (7, 8, 14, 77, 78, 79, 80, 81, 86, 87, 88, 90, 128, 137, 184, 185, 186, 188, 189, 190, 192, 255, 268, 275, 283, 294, 299, 301, 302, 304, 318, 325) THEN
              1
             ELSE
              0
           END) QTD_GERENTES
  FROM V_DADOS_COLAB_AVT A
   INNER JOIN RHAF1119 B ON A.COD_CONTRATO = B.COD_CONTRATO
   INNER JOIN RHAF1145 C ON B.COD_TURNO = C.COD_TURNO
 WHERE A.COD_EMP = '008'
   AND A.STATUS = 0
   AND A.COD_SETOR_LOJA NOT IN ('001', '013')
   AND C.CARGA_HORARIA = 120
 GROUP BY A.COD_UNIDADE, A.DES_UNIDADE;

























