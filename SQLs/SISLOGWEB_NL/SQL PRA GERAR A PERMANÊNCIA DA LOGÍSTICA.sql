/* ==================================================
   ==== SQL PRA GERAR A PERMANÊNCIA DA LAGÍSTICA ====
   ================================================== */

SELECT A.COD_GRUPO,
       A.COD_UNIDADE,
       'CD' AS TIPO,
       CASE
         WHEN NVL(SUM(VLR_ESTOQUE_CD), 0) <> 0 AND
              NVL(SUM(VLR_CUSTO_CD), 0) <> 0 THEN
          ROUND(360 / (NVL(SUM(VLR_CUSTO_CD), 0) /
                (NVL(SUM(VLR_ESTOQUE_CD), 0) / 365.25)),
                0)
         ELSE
          0
       END AS PERMANENCIA
  FROM (SELECT E.DTA_MVTO,
               E.COD_UNIDADE,
               G.COD_GRUPO,
               NVL(E.VLR_CUSTO_CD, 0) AS VLR_CUSTO_CD,
               NVL(TO_NUMBER(TO_CHAR(LAST_DAY(E.DTA_MVTO), 'DD')), 0) *
               (NVL(E.VLR_ESTOQUE_CD, 0) + NVL(E.VLR_CUSTO_CD, 0)) AS VLR_ESTOQUE_CD
          FROM NL.GE_GRUPOS_UNIDADES G
          JOIN NL.ES_0124_CE_ESTMEDIO E ON G.COD_UNIDADE = E.COD_UNIDADE
          JOIN NL.IE_MASCARAS IEM ON IEM.COD_ITEM = E.COD_ITEM
         WHERE G.COD_EMP = 1
           AND G.COD_GRUPO IN (858, 818, 848, 838)
           AND E.DTA_MVTO = DATE '2025-08-01'
           AND IEM.COD_MASCARA = 170
           AND IEM.COD_NIV0 = '1'
           /*AND IEM.COD_COMPLETO BETWEEN '505020205510' AND '505020205510'*/) A
 GROUP BY A.COD_GRUPO, A.COD_UNIDADE