--SQL QUE MAPEIA O CONTRATO DE EM CADA CARGO - LOTAÇÃOES


SELECT DISTINCT VDC.COD_UNIDADE AS COD_UNIDADE,
                VDC.DES_UNIDADE AS DES_UNIDADE,
                VDC.COD_ORGANOGRAMA AS COD_ORGANOGRAMA,
                VDC.COD_REDE_LOCAL AS COD_REDE_LOCAL,
                VDC.DES_REDE_LOCAL AS DES_REDE_LOCAL,
                VDC.COD_FUNCAO,
                CASE
                  WHEN VDC.COD_FUNCAO IN
                       (77, 78, 79, 80, 81, 86, 87, 88, 89, 90, 184, 185, 186, 188, 189, 190, 192, 294, 318) THEN
                   VDC.COD_CONTRATO
                  ELSE
                   NULL
                END AS GERENTES,
                CASE
                  WHEN VDC.COD_FUNCAO IN (121, 305, 122) THEN
                   VDC.COD_CONTRATO
                  ELSE
                   NULL
                END AS ORIENT_VENDA,
                CASE
                  WHEN VDC.COD_FUNCAO = 206 THEN
                   VDC.COD_CONTRATO
                  ELSE
                   NULL
                END AS AUXI_LOJA,
                CASE
                  WHEN VDC.COD_FUNCAO = 120 THEN
                   VDC.COD_CONTRATO
                  ELSE
                   NULL
                END AS VEND_MODA_MASC,
                CASE
                  WHEN VDC.COD_FUNCAO = 102 THEN
                   VDC.COD_CONTRATO
                  ELSE
                   NULL
                END AS CAIXA_GERAL,
                CASE
                  WHEN VDC.COD_FUNCAO = 74 THEN
                   VDC.COD_CONTRATO
                  ELSE
                   NULL
                END AS APRENDIZ,
                CASE
                  WHEN VDC.COD_FUNCAO = 68 THEN
                   VDC.COD_CONTRATO
                  ELSE
                   NULL
                END AS SERVENTE
  FROM V_DADOS_COLAB_AVT VDC
 WHERE VDC.COD_EMP = '008'
   AND VDC.STATUS = 0
   AND VDC.STATUS_AFAST IN ('EM ATIVIDADE', 'AFASTADO TEMP')
   AND VDC.TIPO = 'LOJA'
   AND (VDC.COD_FUNCAO = 68 OR
       VDC.COD_FUNCAO IN
       (77, 78, 79, 80, 81, 86, 87, 88, 89, 90, 184, 185, 186, 188, 189, 190, 192, 294, 318) OR
       VDC.COD_FUNCAO IN (121, 305, 122) OR VDC.COD_FUNCAO = 206 OR
       VDC.COD_FUNCAO = 120 OR VDC.COD_FUNCAO = 102 OR VDC.COD_FUNCAO = 74)
 ORDER BY VDC.COD_UNIDADE ASC