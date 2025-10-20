CREATE OR REPLACE VIEW V_ORGANOGRAMA_PORTAL AS
SELECT T.NOME, T.CODIGO, T.CODIGO_PAI

  FROM (SELECT 'GRAZZIOTIN SA' NOME, '001' CODIGO, '' CODIGO_PAI
          FROM DUAL
        UNION ALL
        SELECT 'COLIGADAS' NOME, '003' CODIGO, '001' CODIGO_PAI
          FROM DUAL
        UNION ALL
        SELECT 'GRAZZIOTIN FINANCIADORA SA FINANCIADOR' NOME,
               '000' CODIGO,
               '003' CODIGO_PAI
          FROM DUAL
        UNION ALL
        SELECT 'CENTRO SHOPPING EMP E PARTIC LTDA CENTRO SHOPPING' NOME,
               '276' CODIGO,
               '003' CODIGO_PAI
          FROM DUAL
        UNION ALL
        SELECT 'FLORESTA GRAZZIOTIN LTDA' NOME,
               '006' CODIGO,
               '003' CODIGO_PAI
          FROM DUAL
        UNION ALL
        SELECT 'VR GRAZZIOTIN S A ADM.E PART. VR' NOME,
               '010' CODIGO,
               '003' CODIGO_PAI
          FROM DUAL
        UNION ALL
        SELECT 'GRATO AGROPECUARIA LTDA GRATO' NOME,
               '011' CODIGO,
               '003' CODIGO_PAI
          FROM DUAL
        UNION ALL
        SELECT 'CAULESPAR ADM E PARTIC LTDA' NOME,
               '012' CODIGO,
               '003' CODIGO_PAI
          FROM DUAL
        UNION ALL
        SELECT DECODE(ORG_CUSTO_CTB.EDICAO_NIVEL3,
                      '1',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                             '811',
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             813,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             815,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             'GRAZZIOTIN'),
                      '2',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                             '851',
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             853,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             855,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             'TOTTAL'),
                      '3',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                             831,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             833,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             835,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             'PORMENOS'),
                      '4',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                             841,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             843,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             845,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             'FRANCO GIORGI'),
                      '7',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                             '871',
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             873,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             875,
                             ORGANOGRAMA.NOME_ORGANOGRAMA,
                             'CIA LOJAS HIBRIDAS'),

                      ORGANOGRAMA.NOME_ORGANOGRAMA) NOME,
               DECODE(ORG_EMP.COD_NIVEL2,
                      282,
                      '000',
                      DECODE(ORG_CUSTO_CTB.EDICAO_NIVEL3,
                             '1',
                             DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '811',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '813',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '815',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '910'),
                             '2',
                             DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '851',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '853',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '855',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '950'),
                             '3',
                             DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '831',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '833',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '835',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '930'),
                             '4',
                             DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '841',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '843',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '845',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '940'),
                             '7',
                             DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '871',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '873',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '875',
                                    ORG_CUSTO_CTB.CUSTO_CONTABIL,
                                    '970'),

                             ORG_CUSTO_CTB.CUSTO_CONTABIL)) CODIGO
               --,'001' CODIGO_PAI
              ,
               DECODE(ORG_CUSTO_CTB.EDICAO_NIVEL3,
                      '1',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL, '813', '910', '811'),
                      '2',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL, '853', '950', '851'),
                      '3',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL, '833', '930', '831'),
                      '4',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL, '843', '940', '841'),
                      '7',
                      DECODE(ORG_CUSTO_CTB.CUSTO_CONTABIL, '873', '970', '720'),
                      ORG_EMP.EDICAO_NIVEL4) CODIGO_PAI

          FROM RHFP0300 FP03,
               RHFP0310 CONTR_ORGANOGRAMA,
               RHFP0400 ORGANOGRAMA,
               RHFP0401 ORG_EMP,
               RHFP0402 ORG_CUSTO_CTB,
               RHFP0340 CONTRFUNC
         WHERE FP03.COD_CONTRATO = CONTRFUNC.COD_CONTRATO
           AND FP03.COD_CONTRATO = CONTR_ORGANOGRAMA.COD_CONTRATO
           AND CONTR_ORGANOGRAMA.COD_ORGANOGRAMA =
               ORGANOGRAMA.COD_ORGANOGRAMA
           AND ORGANOGRAMA.COD_ORGANOGRAMA = ORG_EMP.COD_ORGANOGRAMA
           AND ORGANOGRAMA.COD_CUSTO_CONTABIL =
               ORG_CUSTO_CTB.COD_CUSTO_CONTABIL(+)
           AND CONTR_ORGANOGRAMA.DATA_FIM > SYSDATE
           AND ORG_EMP.COD_NIVEL2 IN (8, 282 /*,276*/
               )
           AND FP03.DATA_FIM IS NULL
           AND CONTRFUNC.DATA_FIM > SYSDATE
           AND NOT FP03.COD_CONTRATO = 283479
           AND ORG_EMP.DATA_FIM > SYSDATE
           AND ORG_CUSTO_CTB.CUSTO_CONTABIL IS NOT NULL
         GROUP BY ORGANOGRAMA.NOME_ORGANOGRAMA,
                  ORG_CUSTO_CTB.EDICAO_NIVEL3,
                  ORGANOGRAMA.NOME_ORGANOGRAMA,
                  ORG_CUSTO_CTB.CUSTO_CONTABIL,
                  ORG_EMP.COD_NIVEL2,
                  ORG_EMP.EDICAO_NIVEL4

        ) T
 GROUP BY T.NOME, T.CODIGO, T.CODIGO_PAI
 ORDER BY T.CODIGO

