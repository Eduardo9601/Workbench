--==SELECT PARA O RELATÓRIO DE CONFERENCIAS GERENCIAIS PARA PROCURAÇÕES GERENCIAIS


SELECT DISTINCT VDC.COD_CONTRATO || ' - ' || VDC.DES_PESSOA AS DES_PESSOA,
                VDC.DATA_ADMISSAO,
                VDC.DES_EMPRESA || ' ->  ' || VDC.DES_UNIDADE AS DES_LOCAL,
                VDC.DES_FUNCAO,
                'Início: ' || TO_CHAR(VDC.DATA_INICIO_CLH, 'DD/MM/YYYY') || '  Fim: ' || TO_CHAR(VDC.DATA_FIM_CLH, 'DD/MM/YYYY') AS DATA_CARGO,
                'Início: ' || TO_CHAR(VDC.DATA_INICIO_ORG, 'DD/MM/YYYY') || '  Fim: ' || TO_CHAR(VDC.DATA_FIM_ORG, 'DD/MM/YYYY') AS DATA_ORG,
                
                CASE
                  WHEN VDC.COD_AFAST IS NULL OR VDC.DES_AFAST IS NULL THEN
                   'Em Atividade'
                ELSE
                 VDC.COD_AFAST || ' - ' || VDC.DES_AFAST
                END AS DES_AFAST,

                CASE
                  WHEN VDC.DATA_INI_AFAST IS NOT NULL AND VDC.DATA_FIM_AFAST IS NOT NULL THEN
                   'De ' || TO_CHAR(VDC.DATA_INI_AFAST, 'DD/MM/YYYY') || '  até ' || TO_CHAR(VDC.DATA_FIM_AFAST, 'DD/MM/YYYY')
                  ELSE
                   NULL
                END AS AFASTAMENTO,
                
                '/=========/' AS ESPACO_1,

                CASE
                  WHEN VCC.DATA_FIM_ANT IS NULL AND VCC.DATA_INICIO_ANT IS NULL THEN
                   NULL
                  WHEN VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT BETWEEN :DATA_INICIO AND :DATA_FIM THEN
                   VCC.COD_CLH_ANT || ' - ' || VCC.NOME_CLH_ANT
                  ELSE
                   NULL
                END AS DES_CLH_ANT,
                
                CASE
                  WHEN VCC.DATA_FIM_ANT IS NULL AND VCC.DATA_INICIO_ANT IS NULL THEN
                   NULL
                  WHEN VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT BETWEEN :DATA_INICIO AND :DATA_FIM THEN
                   'De ' || TO_CHAR(VCC.DATA_INICIO_ANT, 'DD/MM/YYYY') || '  até ' || TO_CHAR(VCC.DATA_FIM_ANT, 'DD/MM/YYYY')
                  ELSE
                   NULL
                END AS DATA_CLH_ANT,

                '/=========/' AS ESPACO_2,
                
                CASE
                  WHEN VOC.DATA_FIM_ORG_ANT IS NULL AND VOC.DATA_INICIO_ORG_ANT IS NULL THEN
                   NULL
                  WHEN VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT BETWEEN :DATA_INICIO AND :DATA_FIM THEN
                   VOC.EDICAO_ORG_ANT || ' - ' || VOC.NOME_ORGANOGRAMA_ANT
                  ELSE
                   NULL
                END AS DES_ORG_ANT,
                
                CASE
                  WHEN VOC.DATA_FIM_ORG_ANT IS NULL AND VOC.DATA_INICIO_ORG_ANT IS NULL THEN
                   NULL
                  WHEN VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT BETWEEN :DATA_INICIO AND :DATA_FIM THEN
                   'De ' || TO_CHAR(VOC.DATA_INICIO_ORG_ANT, 'DD/MM/YYYY') || '  até ' || COALESCE(TO_CHAR(VOC.DATA_FIM_ORG_ANT, 'DD/MM/YYYY'), 'Atual')
                  ELSE
                   NULL
                END AS DATA_ORG_ANT
  FROM V_DADOS_COLAB_AVT VDC
  LEFT JOIN V_CARGO_CONTRATO_AVT VCC ON VDC.COD_CONTRATO =
VCC.COD_CONTRATO
  LEFT JOIN V_ORGANOGRAMA_CONTRATO_AVT VOC ON VDC.COD_CONTRATO =
                                              VOC.COD_CONTRATO
 WHERE VDC.STATUS = 0
   AND (VDC.DES_FUNCAO LIKE '%AUDITOR%' OR
       VDC.DES_FUNCAO LIKE '%COMPRADOR%' OR
       VDC.DES_FUNCAO LIKE '%GERENTE%' OR
       VDC.DES_FUNCAO LIKE '%SUPERVISOR%' OR
       VDC.DES_FUNCAO LIKE '%DIRETOR%')

  AND VDC.DATA_INICIO_CLH <= :DATA_REFERENCIA
  AND VDC.DATA_INICIO_ORG <= :DATA_REFERENCIA

 ORDER BY DES_LOCAL ASC, DES_PESSOA ASC
