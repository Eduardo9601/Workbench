SELECT DISTINCT VDC.COD_CONTRATO || ' - ' || VDC.DES_PESSOA AS DES_PESSOA,
                VDC.DATA_ADMISSAO,
                VDC.DES_EMPRESA || ' ->  ' || VDC.DES_UNIDADE AS DES_LOCAL,
                VDC.DES_TIPO,
                VDC.COD_REDE_LOCAL AS REDE,
                VDC.DES_FUNCAO,
                'Início: ' || TO_CHAR(VDC.DATA_INICIO_CLH, 'DD/MM/YYYY') ||
                '  Fim: ' || TO_CHAR(VDC.DATA_FIM_CLH, 'DD/MM/YYYY') AS DATA_CARGO,
                'Início: ' || TO_CHAR(VDC.DATA_INICIO_ORG, 'DD/MM/YYYY') ||
                '  Fim: ' || TO_CHAR(VDC.DATA_FIM_ORG, 'DD/MM/YYYY') AS DATA_ORG,
                
                --STATUS DE AFASTAMENTO ATUAL
                CASE
                  WHEN VDC.COD_AFAST IS NULL OR VDC.DES_AFAST IS NULL THEN
                   'Em Atividade'
                  ELSE
                   VDC.COD_AFAST || ' - ' || VDC.DES_AFAST
                END AS DES_AFAST,
                
                CASE
                  WHEN VDC.DATA_INI_AFAST IS NOT NULL AND
                       VDC.DATA_FIM_AFAST IS NOT NULL THEN
                   'De ' || TO_CHAR(VDC.DATA_INI_AFAST, 'DD/MM/YYYY') ||
                   '  até ' || TO_CHAR(VDC.DATA_FIM_AFAST, 'DD/MM/YYYY')
                  ELSE
                   NULL
                END AS AFASTAMENTO,
                
                --STATUS DE AFASTAMENTO ANTERIOR
                CASE
                  WHEN VAC.COD_CAUSA_AFAST_ANT IS NULL OR
                       VAC.NOME_CAUSA_AFAST_ANT IS NULL THEN
                   'Em Atividade'
                  ELSE
                   'Esteve afastado(a) por:' || VAC.COD_CAUSA_AFAST_ANT ||
                   ' - ' || VAC.NOME_CAUSA_AFAST_ANT
                END AS DES_AFAST_ANT,
                
                CASE
                  WHEN VAC.DATA_INICIO_ANT IS NOT NULL AND
                       VAC.DATA_FIM_ANT IS NOT NULL THEN
                   'De ' || TO_CHAR(VAC.DATA_INICIO_ANT, 'DD/MM/YYYY') ||
                   '  até ' || TO_CHAR(VAC.DATA_FIM_ANT, 'DD/MM/YYYY')
                  ELSE
                   NULL
                END AS AFASTAMENTO_ANT,
                
                '/=========/' AS ESPACO_1,
                
                CASE
                  WHEN VCC.DATA_FIM_ANT IS NULL AND
                       VCC.DATA_INICIO_ANT IS NULL THEN
                   NULL
                  WHEN VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT BETWEEN '01/04/2024' AND
                       '30/04/2024' OR
                       VCC.DATA_FIM_ANT =
                       TO_DATE('01/04/2024', 'DD/MM/YYYY') - 1 THEN
                   VCC.COD_CLH_ANT || ' - ' || VCC.NOME_CLH_ANT
                  ELSE
                   NULL
                END AS DES_CLH_ANT,
                
                CASE
                  WHEN VCC.DATA_FIM_ANT IS NULL AND
                       VCC.DATA_INICIO_ANT IS NULL THEN
                   NULL
                  WHEN VCC.DATA_FIM_ANT IS NULL OR
                       VCC.DATA_FIM_ANT BETWEEN '01/04/2024' AND
                       '30/04/2024' OR
                       VCC.DATA_FIM_ANT =
                       TO_DATE('01/04/2024', 'DD/MM/YYYY') - 1 THEN
                   'De ' || TO_CHAR(VCC.DATA_INICIO_ANT, 'DD/MM/YYYY') ||
                   '  até ' || TO_CHAR(VCC.DATA_FIM_ANT, 'DD/MM/YYYY')
                  ELSE
                   NULL
                END AS DATA_CLH_ANT,
                
                '/=========/' AS ESPACO_2,
                
                CASE
                  WHEN VOC.DATA_FIM_ORG_ANT IS NULL AND
                       VOC.DATA_INICIO_ORG_ANT IS NULL THEN
                   NULL
                  WHEN VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT BETWEEN '01/04/2024' AND
                       '30/04/2024' OR
                       VOC.DATA_FIM_ORG_ANT =
                       TO_DATE('01/04/2024', 'DD/MM/YYYY') - 1 THEN
                   VOC.EDICAO_ORG_ANT || ' - ' || VOC.NOME_ORGANOGRAMA_ANT
                  ELSE
                   NULL
                END AS DES_ORG_ANT,
                
                CASE
                  WHEN VOC.DATA_FIM_ORG_ANT IS NULL AND
                       VOC.DATA_INICIO_ORG_ANT IS NULL THEN
                   NULL
                  WHEN VOC.DATA_FIM_ORG_ANT IS NULL OR
                       VOC.DATA_FIM_ORG_ANT BETWEEN '01/04/2024' AND
                       '30/04/2024' OR
                       VOC.DATA_FIM_ORG_ANT =
                       TO_DATE('01/04/2024', 'DD/MM/YYYY') - 1 THEN
                   'De ' || TO_CHAR(VOC.DATA_INICIO_ORG_ANT, 'DD/MM/YYYY') ||
                   '  até ' ||
                   COALESCE(TO_CHAR(VOC.DATA_FIM_ORG_ANT, 'DD/MM/YYYY'),
                            'Atual')
                  ELSE
                   NULL
                END AS DATA_ORG_ANT,
                
                
                'Período: De ' || TO_CHAR(TO_DATE(:DATA_INICIO, 'DD/MM/YYYY'), 'DD/MM/YYYY') ||
                ' até ' || TO_CHAR(TO_DATE(:DATA_FIM, 'DD/MM/YYYY'), 'DD/MM/YYYY') AS PERIODO_RELATORIO

                
                
                
                'Período: De ' ||
                TO_CHAR(TO_DATE('01/04/2024', 'DD/MM/YYYY'), 'DD/MM/YYYY') ||
                ' até ' ||
                TO_CHAR(TO_DATE('30/04/2024', 'DD/MM/YYYY'), 'DD/MM/YYYY') AS PERIODO_RELATORIO

  FROM V_DADOS_COLAB_AVT VDC
  LEFT JOIN V_CARGO_CONTRATO_AVT VCC ON VDC.COD_CONTRATO = VCC.COD_CONTRATO
  LEFT JOIN V_ORGANOGRAMA_CONTRATO_AVT VOC ON VDC.COD_CONTRATO =
                                              VOC.COD_CONTRATO
  LEFT JOIN V_AFAST_COLAB_AVT VAC ON VDC.COD_CONTRATO = VAC.COD_CONTRATO
 WHERE VDC.STATUS = 0
   AND (VDC.DES_FUNCAO LIKE '%AUDITOR%' OR
       VDC.DES_FUNCAO LIKE '%COMPRADOR%' OR
       VDC.DES_FUNCAO LIKE '%GERENTE%' OR
       VDC.DES_FUNCAO LIKE '%SUPERVISOR%' OR
       VDC.DES_FUNCAO LIKE '%DIRETOR%')
   AND VDC.DES_FUNCAO NOT LIKE '%TRAINEE%'
   AND VDC.DES_FUNCAO NOT LIKE '%ASSESSOR%'
   AND VDC.DATA_INICIO_CLH <= '30/04/2024'
   AND VDC.DATA_INICIO_ORG <= '30/04/2024'
   AND (VDC.COD_AFAST != 21 OR VDC.COD_AFAST IS NULL)
--AND VDC.COD_CONTRATO = :CONTRATO
 ORDER BY CASE VDC.DES_TIPO -- Aqui você especifica a ordenação personalizada
            WHEN 'LOJA' THEN
             1
            WHEN 'COLIGADA' THEN
             2
            WHEN 'SETOR' THEN
             3
            WHEN 'DEPÓSITO' THEN
             4
            ELSE
             5
          END,
          CASE VDC.COD_REDE_LOCAL -- Aqui você especifica a ordenação personalizada
            WHEN 10 THEN
             1
            WHEN 30 THEN
             2
            WHEN 40 THEN
             3
            WHEN 50 THEN
             4
            WHEN 70 THEN
             5
            ELSE
             6
          END,
          DES_LOCAL ASC,
          DES_PESSOA ASC