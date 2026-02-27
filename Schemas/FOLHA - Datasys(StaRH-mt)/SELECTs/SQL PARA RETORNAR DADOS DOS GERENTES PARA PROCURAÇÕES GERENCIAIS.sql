--SQL PARA RETORNAR DADOS DOS GERENTES PARA PROCURAÇÕES GERENCIAIS

----VERSÃO COM DATA DE REFERENCIA FIXA

SELECT DISTINCT VDC.COD_UNIDADE,
                VDC.DES_UNIDADE,
                VDC.COD_EMP,
                VDC.COD_CONTRATO,
                VDC.DES_PESSOA,
                VDC.DATA_ADMISSAO,
                VDC.DATA_DEMISSAO,
                VDC.COD_FUNCAO,
                VDC.DES_FUNCAO,
                VDC.DATA_INICIO_CLH,
                VDC.DATA_FIM_CLH,
                VDC.DATA_INICIO_ORG,
                VDC.DATA_FIM_ORG,
                VDC.COD_AFAST,
                VDC.DES_AFAST,
                VDC.DATA_INI_AFAST,
                VDC.DATA_FIM_AFAST,
                VDC.STATUS_AFAST,
                '/=========/' AS ESPACO_1,
                CASE
                  WHEN VCC.DATA_INICIO_ANT <= '31/10/2023' AND
                       (VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT >= '31/10/2023') THEN
                   VCC.COD_CLH_ANT
                  ELSE
                   NULL
                END AS COD_CLH_ANT,
                CASE
                  WHEN VCC.DATA_INICIO_ANT <= '31/10/2023' AND
                       (VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT >= '31/10/2023') THEN
                   VCC.NOME_CLH_ANT
                  ELSE
                   NULL
                END AS NOME_CLH_ANT,
                CASE
                  WHEN VCC.DATA_INICIO_ANT <= '31/10/2023' AND
                       (VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT >= '31/10/2023') THEN
                   VCC.DATA_INICIO_ANT
                  ELSE
                   NULL
                END AS DATA_INICIO_CLH_ANT,
                CASE
                  WHEN VCC.DATA_INICIO_ANT <= '31/10/2023' AND
                       (VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT >= '31/10/2023') THEN
                   VCC.DATA_FIM_ANT
                  ELSE
                   NULL
                END AS DATA_FIM_CLH_ANT,
                '/=========/' AS ESPACO_2,
                CASE
                  WHEN VOC.DATA_INICIO_ORG_ANT <= '31/10/2023' AND
                       (VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT >= '31/10/2023') THEN
                   VOC.EDICAO_ORG_ANT
                  ELSE
                   NULL
                END AS EDICAO_ORG_ANT,
                CASE
                  WHEN VOC.DATA_INICIO_ORG_ANT <= '31/10/2023' AND
                       (VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT >= '31/10/2023') THEN
                   VOC.NOME_ORGANOGRAMA_ANT
                  ELSE
                   NULL
                END AS NOME_ORGANOGRAMA_ANT,
                CASE
                  WHEN VOC.DATA_INICIO_ORG_ANT <= '31/10/2023' AND
                       (VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT >= '31/10/2023') THEN
                   VOC.DATA_INICIO_ORG_ANT
                  ELSE
                   NULL
                END AS DATA_INICIO_ORG_ANT,
                CASE
                  WHEN VOC.DATA_INICIO_ORG_ANT <= '31/10/2023' AND
                       (VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT >= '31/10/2023') THEN
                   VOC.DATA_FIM_ORG_ANT
                  ELSE
                   NULL
                END AS DATA_FIM_ORG_ANT
  FROM V_DADOS_COLAB_AVT VDC
  LEFT JOIN V_CARGO_CONTRATO_AVT VCC ON VDC.COD_CONTRATO = VCC.COD_CONTRATO
  LEFT JOIN V_ORGANOGRAMA_CONTRATO_AVT VOC ON VDC.COD_CONTRATO =
                                              VOC.COD_CONTRATO
 WHERE VDC.STATUS = 0
   AND (VDC.DES_FUNCAO LIKE '%AUDITOR%' OR
       VDC.DES_FUNCAO LIKE '%COMPRADOR%' OR
       VDC.DES_FUNCAO LIKE '%GERENTE%' OR
       VDC.DES_FUNCAO LIKE '%SUPERVISOR%' OR
       VDC.DES_FUNCAO LIKE '%DIRETOR%')
 ORDER BY VDC.COD_UNIDADE ASC, VDC.COD_EMP ASC, VDC.COD_CONTRATO ASC






-----VERSÃO COM CAMPO DATA DE REFERENCIA

SELECT DISTINCT VDC.COD_UNIDADE,
                VDC.DES_UNIDADE,
                VDC.COD_EMP,
                VDC.COD_CONTRATO,
                VDC.DES_PESSOA,
                VDC.DATA_ADMISSAO,
                VDC.DATA_DEMISSAO,
                VDC.COD_FUNCAO,
                VDC.DES_FUNCAO,
                VDC.DATA_INICIO_CLH,
                VDC.DATA_FIM_CLH,
                VDC.DATA_INICIO_ORG,
                VDC.DATA_FIM_ORG,
                VDC.COD_AFAST,
                VDC.DES_AFAST,
                VDC.DATA_INI_AFAST,
                VDC.DATA_FIM_AFAST,
                VDC.STATUS_AFAST,
                '/=========/' AS ESPACO_1,
                CASE
                  WHEN VCC.DATA_INICIO_ANT <= :DATA_REFERENCIA AND
                       (VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT >= :DATA_REFERENCIA) THEN
                   VCC.COD_CLH_ANT
                  ELSE
                   NULL
                END AS COD_CLH_ANT,
                CASE
                  WHEN VCC.DATA_INICIO_ANT <= :DATA_REFERENCIA AND
                       (VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT >= :DATA_REFERENCIA) THEN
                   VCC.NOME_CLH_ANT
                  ELSE
                   NULL
                END AS NOME_CLH_ANT,
                CASE
                  WHEN VCC.DATA_INICIO_ANT <= :DATA_REFERENCIA AND
                       (VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT >= :DATA_REFERENCIA) THEN
                   VCC.DATA_INICIO_ANT
                  ELSE
                   NULL
                END AS DATA_INICIO_CLH_ANT,
                CASE
                  WHEN VCC.DATA_INICIO_ANT <= :DATA_REFERENCIA AND
                       (VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT >= :DATA_REFERENCIA) THEN
                   VCC.DATA_FIM_ANT
                  ELSE
                   NULL
                END AS DATA_FIM_CLH_ANT,
                '/=========/' AS ESPACO_2,
                CASE
                  WHEN VOC.DATA_INICIO_ORG_ANT <= :DATA_REFERENCIA AND
                       (VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT >= :DATA_REFERENCIA) THEN
                   VOC.EDICAO_ORG_ANT
                  ELSE
                   NULL
                END AS EDICAO_ORG_ANT,
                CASE
                  WHEN VOC.DATA_INICIO_ORG_ANT <= :DATA_REFERENCIA AND
                       (VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT >= :DATA_REFERENCIA) THEN
                   VOC.NOME_ORGANOGRAMA_ANT
                  ELSE
                   NULL
                END AS NOME_ORGANOGRAMA_ANT,
                CASE
                  WHEN VOC.DATA_INICIO_ORG_ANT <= :DATA_REFERENCIA AND
                       (VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT >= :DATA_REFERENCIA) THEN
                   VOC.DATA_INICIO_ORG_ANT
                  ELSE
                   NULL
                END AS DATA_INICIO_ORG_ANT,
                CASE
                  WHEN VOC.DATA_INICIO_ORG_ANT <= :DATA_REFERENCIA AND
                       (VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT >= :DATA_REFERENCIA) THEN
                   VOC.DATA_FIM_ORG_ANT
                  ELSE
                   NULL
                END AS DATA_FIM_ORG_ANT
  FROM V_DADOS_COLAB_AVT VDC
  LEFT JOIN V_CARGO_CONTRATO_AVT VCC ON VDC.COD_CONTRATO = VCC.COD_CONTRATO
  LEFT JOIN V_ORGANOGRAMA_CONTRATO_AVT VOC ON VDC.COD_CONTRATO =
                                              VOC.COD_CONTRATO
 WHERE VDC.STATUS = 0
   AND (VDC.DES_FUNCAO LIKE '%AUDITOR%' OR
       VDC.DES_FUNCAO LIKE '%COMPRADOR%' OR
       VDC.DES_FUNCAO LIKE '%GERENTE%' OR
       VDC.DES_FUNCAO LIKE '%SUPERVISOR%' OR
       VDC.DES_FUNCAO LIKE '%DIRETOR%')
 ORDER BY VDC.COD_UNIDADE ASC, VDC.COD_EMP ASC, VDC.COD_CONTRATO ASC