CREATE OR REPLACE VIEW V_UNIDADES_ATIVAS AS
SELECT GU.COD_EMP,
       PSPES.COD_ATIVIDADE,
       TO_CHAR(PJ.NUM_CGC) NUM_CGC,
       SUBSTR(GU.COD_NIVEL2, 2, 3) REDE,
       CASE 
           WHEN GU.COD_NIVEL2 = 810 THEN
            910
           WHEN GU.COD_NIVEL2 = 830 THEN
            930
           WHEN GU.COD_NIVEL2 = 840 THEN
            940
           WHEN GU.COD_NIVEL2 = 850 THEN
            950
           WHEN GU.COD_NIVEL2 = 870 THEN
            970
           ELSE
            999
       END AS COD_GRUPO,           
       MAX(DECODE(GU.COD_UNIDADE,
                  1566,
                  566,
                  3566,
                  566,
                  4566,
                  566,
                  5566,
                  566,
                  1580,
                  580,
                  3580,
                  580,
                  4580,
                  580,
                  5580,
                  580,
                  818,
                  900,
                  838,
                  900,
                  848,
                  900,
                  858,
                  900,
                  878,
                  900,
                  GU.COD_UNIDADE)) COD_UNIDADE,
       PSPES.DES_FANTASIA,
       G1.COD_UF,
       PSPES.COD_CIDADE
 FROM NL.GE_UNIDADES GU
 INNER JOIN NL.PS_PESSOAS PSPES ON PSPES.COD_PESSOA = GU.COD_UNIDADE
 INNER JOIN NL.G1_CIDADES G1 ON G1.COD_CIDADE = PSPES.COD_CIDADE
 INNER JOIN NL.PS_JURIDICAS PJ ON PJ.COD_PESSOA = GU.COD_UNIDADE
 WHERE GU.COD_EMP = 1
   AND GU.COD_UNIDADE < 8000
   AND GU.COD_NIVEL2 IN (810, 830, 840, 850, 870, 900)
   AND PSPES.IND_INATIVO = 0
   AND NVL(PSPES.DTA_AFASTAMENTO, SYSDATE) <= SYSDATE + 15
   AND PJ.NUM_CGC NOT IN (0, 92012467000170)
 GROUP BY GU.COD_EMP,
          PSPES.COD_ATIVIDADE,
          PJ.NUM_CGC,
          SUBSTR(GU.COD_NIVEL2, 2, 3),
          GU.COD_NIVEL2,
          PSPES.DES_FANTASIA,
          G1.COD_UF,
          PSPES.COD_CIDADE
