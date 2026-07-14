-- VALIDAR COM O CONSULTA DADOS INVETARIO LOJA - CONTABILIDADE

WITH 
GRUPOS AS (
SELECT CASE
           WHEN COD_UNIDADE IN (818, 838, 848, 858, 878) THEN
             COD_UNIDADE
           WHEN COD_NIVEL2 IN (810, 830, 840, 850, 870) THEN
             COD_NIVEL2
           ELSE
             NULL
       END AS GRUPO_UNIDADE
FROM NL.GE_UNIDADES

)

BASE AS (
    SELECT CED.DTA_LANCAMENTO,
           CED.COD_UNIDADE,
           GE.DES_NOME,
           GE.COD_NIVEL2 AS REDE_UNIDADE,
           /*CASE
              -- 1º: Verifica se é um CD. Se for, assume o código do CD e ignora o resto.
              WHEN GE.COD_UNIDADE IN (818, 838, 848, 858, 878) THEN
                GE.COD_UNIDADE
              -- 2º: Se não for CD, verifica se é uma Rede de Lojas.
              WHEN GE.COD_NIVEL2 IN (810, 830, 840, 850, 870) THEN 
                GE.COD_NIVEL2
              ELSE
                999
           END AS GRUPO_UNIDADES,*/
                
           CASE
             WHEN CED.NUM_DOCUMENTO < 9999999999 THEN
              'AJUSTE'
             ELSE
              'INVENTÁRIO'
           END AS TIPO_LANCAMENTO,
           CED.COD_ITEM,
           IEM.COD_NIV1 AS REDE_ITEM,
           IEM.COD_NIV2 AS SETOR,
           IEM.COD_NIV3 AS GRUPO,
           IEM.COD_NIV4 AS SUBGRUPO,
           IEM.COD_EDITADO,
           IEI.DES_ITEM,
           
           -- CÁLCULOS DE QUANTIDADE (CE_DIARIOS)
           SUM(CASE
                 WHEN CED.COD_OPER = 20 THEN
                  CED.QTD_LANCAMENTO
                 ELSE
                  -CED.QTD_LANCAMENTO
               END) AS QTD_LANCAMENTO,
           
           -- QUANTIDADES DO INVENTÁRIO (IN_WEB_INVENTARIOS)
           NVL(IWI.QTD_ESTOQUE, 0) AS QTD_ESTOQUE,
           NVL(IWI.QTD_RES_SAIDA, 0) AS QTD_RES_SAIDA,
           NVL(IWI.QTD_CONTADA, 0) AS QTD_CONTADA,
           
           -- CÁLCULOS DE VALOR MÉDIO (CE_DIARIOS)
           ROUND(CASE
                   WHEN CED.COD_OPER = 20 THEN
                    SUM(CED.VLR_MEDIO_EMP) / NULLIF(SUM(CED.QTD_LANCAMENTO), 0)
                   ELSE
                    - (SUM(CED.VLR_MEDIO_EMP) / NULLIF(SUM(CED.QTD_LANCAMENTO), 0))
                 END,
                 4) AS VLR_MEDIO_EMP_UNI,
           ROUND(CASE
                   WHEN CED.COD_OPER = 20 THEN
                    SUM(CED.VLR_MEDIO_EMP)
                   ELSE
                    -SUM(CED.VLR_MEDIO_EMP)
                 END,
                 4) AS VLR_MEDIO_EMP
    
      FROM NL.CE_DIARIOS CED
      JOIN NL.IE_MASCARAS IEM
        ON IEM.COD_ITEM = CED.COD_ITEM
       AND IEM.COD_MASCARA = 170
      JOIN NL.IE_ITENS IEI
        ON IEI.COD_ITEM = CED.COD_ITEM
      JOIN NL.GE_UNIDADES GE
        ON GE.COD_UNIDADE = CED.COD_UNIDADE
      /*JOIN NL.GE_GRUPOS_UNIDADES GU
        ON GU.COD_UNIDADE = CED.COD_UNIDADE*/
      JOIN NL.PS_PESSOAS PSP
        ON PSP.COD_PESSOA = CED.COD_UNIDADE
      JOIN NL.G1_CIDADES G1C
        ON G1C.COD_CIDADE = PSP.COD_CIDADE
      LEFT JOIN NL.IN_WEB_INVENTARIOS IWI
        ON IWI.COD_EMP = CED.COD_EMP
       AND IWI.COD_UNIDADE = CED.COD_UNIDADE
       AND IWI.COD_ITEM = CED.COD_ITEM
       AND IWI.DTA_INVENTARIO = CED.DTA_LANCAMENTO
       AND ((NVL(IWI.QTD_CONTADA, 0) + NVL(IWI.QTD_RES_SAIDA, 0)) <> 0 OR
           NVL(IWI.QTD_ESTOQUE, 0) <> 0)
      --CROSS JOIN PERIODOS P
     WHERE CED.COD_EMP = 1
       AND CED.COD_OPER IN (20, 22, 23, 24)
       AND CED.DTA_LANCAMENTO >= TO_DATE('01/04/2026', 'DD/MM/YYYY')
       AND CED.DTA_LANCAMENTO <= TO_DATE('30/06/2026', 'DD/MM/YYYY')
       AND IEM.COD_NIV0 = 1
       --AND IEM.COD_NIV2  = '10'
       --AND GE.COD_NIVEL2 = 810 --AQUI O USUÁRIO NO SELECT FINAL IRÁ INFORMAR OS GRUPOS: 810, 830, 840, 850 E 870 = REDE DAS LOJAS
       --AND CED.COD_UNIDADE = 900
       AND GE.COD_UNIDADE IN (818, 838, 848, 858, 878) --JÁ AQUI É OS GRUPOS DO CENTRO DE DISTRIBUIÇÃO
    
     GROUP BY CED.DTA_LANCAMENTO,
              TO_CHAR(CED.DTA_LANCAMENTO, 'YYYY'),
              CED.COD_UNIDADE,
              GE.DES_NOME,
              GE.COD_NIVEL2,
              /*CASE
                -- 1º: Verifica se é um CD. Se for, assume o código do CD e ignora o resto.
                WHEN GE.COD_UNIDADE IN (818, 838, 848, 858, 878) THEN
                  GE.COD_UNIDADE
                -- 2º: Se não for CD, verifica se é uma Rede de Lojas.
                WHEN GE.COD_NIVEL2 IN (810, 830, 840, 850, 870) THEN 
                  GE.COD_NIVEL2
                ELSE
                  999
              END,*/
              G1C.DES_CIDADE,
              CASE
                WHEN CED.NUM_DOCUMENTO < 9999999999 THEN
                 'AJUSTE'
                ELSE
                 'INVENTÁRIO'
              END,
              CED.COD_LOCAL,
              CED.COD_ITEM,
              IEM.COD_NIV1,
              IEM.COD_NIV2,
              IEM.COD_NIV3,
              IEM.COD_NIV4,
              IEM.COD_EDITADO,
              IEI.DES_ITEM,
              NVL(IWI.QTD_ESTOQUE, 0),
              NVL(IWI.QTD_RES_SAIDA, 0),
              NVL(IWI.QTD_CONTADA, 0),
              CED.COD_OPER
),

CALC AS (
    SELECT B.*, (B.QTD_CONTADA - B.QTD_ESTOQUE) AS QTD_DIVERG FROM BASE B

)

SELECT C.DTA_LANCAMENTO,
       C.COD_UNIDADE,
       C.DES_NOME,
       C.REDE_UNIDADE,
       --C.GRUPO_UNIDADES,
       C.TIPO_LANCAMENTO,
       C.COD_ITEM,
       C.REDE_ITEM,
       C.SETOR,
       C.GRUPO,
       C.SUBGRUPO,
       C.COD_EDITADO,
       C.DES_ITEM,
       C.QTD_LANCAMENTO,
       C.QTD_ESTOQUE,
       C.QTD_RES_SAIDA,
       C.QTD_CONTADA,
       C.VLR_MEDIO_EMP_UNI,
       C.VLR_MEDIO_EMP,
       
       -- DIVERGÊNCIA (QUANTIDADE)
       C.QTD_DIVERG,
       
       -- FALTA E SOBRA (QUANTIDADE) SEGUINDO O SINAL
       CASE
         WHEN C.QTD_DIVERG < 0 THEN
          C.QTD_DIVERG
         ELSE
          0
       END AS EST_FALTA,
       CASE
         WHEN C.QTD_DIVERG > 0 THEN
          C.QTD_DIVERG
         ELSE
          0
       END AS EST_SOBRA,
       
       -- DIVERGÊNCIA (VALOR) (MANTÉM SINAL)
       C.VLR_MEDIO_EMP AS VLR_DIVERG,
       
       -- NEGATIVOS EM FALTA, POSITIVOS EM SOBRA
       CASE
         WHEN C.VLR_MEDIO_EMP < 0 THEN
          C.VLR_MEDIO_EMP
         ELSE
          0
       END AS VLR_FALTA,
       CASE
         WHEN C.VLR_MEDIO_EMP > 0 THEN
          C.VLR_MEDIO_EMP
         ELSE
          0
       END AS VLR_SOBRA

  FROM CALC C