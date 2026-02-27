SELECT DISTINCT CT.STATUS,
                CT.COD_CONTRATO,
                CT.DES_PESSOA,
                CT.DATA_NASCIMENTO,
                CT.DATA_ADMISSAO,
                CT.DATA_DEMISSAO,
                FN.COD_FUNCAO,
                FN.DES_FUNCAO,
                FN.DATA_INI_CLH,
                FN.DATA_FIM_CLH,
                HR.HR_BASE_MES,
                HR.DATA_INI_HR,
                HR.DATA_FIM_HR,
                CT.IND_DEFICIENCIA,
                CT.SEXO,
                ORG.COD_EMP,
                ORG.EDICAO_EMP,
                ORG.DES_EMP,
                ORG.COD_ORGANOGRAMA,
                ORG.COD_UNIDADE,
                ORG.DES_UNIDADE,
                ORG.DATA_INI_ORG,
                ORG.DATA_FIM_ORG,
                CASE
                  WHEN ORG.COD_TIPO = 2 THEN
                   ORG.EDICAO_ORG_3
                  WHEN ORG.COD_TIPO = 3 THEN
                   ORG.EDICAO_ORG_3
                  ELSE
                   ORG.COD_UNIDADE
                END AS COD_FILIAL,
                CASE
                  WHEN ORG.COD_TIPO = 2 THEN
                   ORG.NOME3
                  WHEN ORG.COD_TIPO = 3 THEN
                   ORG.NOME3
                  ELSE
                   ORG.DES_UNIDADE
                END AS DES_FILIAL,
                CASE
                  WHEN ORG.COD_TIPO = 2 THEN
                   ORG.EDICAO_ORG_4
                  WHEN ORG.COD_TIPO = 3 THEN
                   ORG.EDICAO_ORG_4
                  ELSE
                   ORG.COD_UNIDADE
                END AS COD_DIVISAO,
                CASE
                  WHEN ORG.COD_TIPO = 2 THEN
                   ORG.NOME4
                  WHEN ORG.COD_TIPO = 3 THEN
                   ORG.NOME4
                  ELSE
                   ORG.DES_UNIDADE
                END AS DES_DIVISAO,
                ORG.COD_REDE,
                ORG.DES_REDE,
                ORG.COD_TIPO,
                ORG.DES_TIPO
  FROM V_DADOS_CONTRATO_AVT CT
  JOIN VH_EST_ORG_CONTRATO_AVT ORG
    ON CT.COD_CONTRATO = ORG.COD_CONTRATO
  JOIN VH_HIST_HORAS_COLAB_AVT HR
    ON CT.COD_CONTRATO = HR.COD_CONTRATO
  JOIN VH_CARGO_CONTRATO_AVT FN
    ON CT.COD_CONTRATO = FN.COD_CONTRATO
 WHERE CT.DATA_DEMISSAO IS NULL
   AND SYSDATE BETWEEN ORG.DATA_INI_ORG AND ORG.DATA_FIM_ORG
   AND SYSDATE BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH
   AND SYSDATE BETWEEN HR.DATA_INI_HR AND HR.DATA_FIM_HR
   AND CT.STATUS = 0
   AND ORG.COD_TIPO = 1
   AND ORG.COD_REDE = 30
   AND ORG.COD_EMP = 8
   AND CT.COD_CONTRATO NOT IN (394234)
   AND ORG.EDICAO_ORG_4 IS NOT NULL
 ORDER BY CT.COD_CONTRATO
