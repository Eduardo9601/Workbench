CREATE OR REPLACE VIEW V_DADOS_COLAB_AVT AS
SELECT DISTINCT /*DADOS DO CONTRATO*/
                CASE
                  WHEN CT.DATA_FIM IS NOT NULL AND
                       CT.DATA_FIM < TRUNC(SYSDATE) THEN
                   1
                  ELSE
                   0
                END AS STATUS,
                CASE
                  WHEN CT.DATA_FIM IS NOT NULL AND
                       CT.DATA_FIM < TRUNC(SYSDATE) THEN
                   'INATIVO'
                  WHEN CT.DATA_INICIO <= TRUNC(SYSDATE) THEN
                   'ATIVO'
                  WHEN CT.DATA_INICIO > TRUNC(SYSDATE) THEN
                   'ADMISSAO_FUTURA'
                END AS DESC_STATUS,
                PF.COD_PESSOA,
                CT.COD_CONTRATO,
                CASE
                  WHEN CT.DATA_INICIO > TRUNC(SYSDATE) THEN
                   NULL
                  ELSE
                   INITCAP(PF.NOME_PESSOA)
                END AS DES_PESSOA,
                CT.DATA_INICIO AS DATA_ADMISSAO,
                CT.DATA_FIM AS DATA_DEMISSAO,
                CT.COD_CAUSA_DEMISSAO AS COD_DEMISSAO,
                DEM.NOME_CAUSA_DEMISSAO AS DES_DEMISSAO,
                FUNC.COD_CLH AS COD_FUNCAO,
                FUNC.COD_CLH || ' - ' || FUNC.NOME_CLH AS DES_FUNCAO,
                CT_FUNC.DATA_INICIO AS DATA_INICIO_CLH,
                CT_FUNC.DATA_FIM AS DATA_FIM_CLH,
                CT.COD_VINCULO_EMPREG,
                CT_TUR.COD_TURNO,
                TURNO.NOME_TURNO AS DES_TURNO,
                HR.QTD_HORBAS_MES AS HR_BASE_MES,
                HR.QTD_HORBAS_SEM AS HR_BASE_SEM,
                HR.QTD_HORBAS_DIA AS HR_BASE_DIA,
                HR.DATA_INICIO AS DATA_INICIO_HR,
                HR.DATA_FIM AS DATA_FIM_HR,

                /*DADOS DO ORGANOGRAMA DO CONTRATO*/
                ORG.COD_ORGANOGRAMA,
                ORG.EDICAO_ORG AS COD_UNIDADE,
                ORG.EDICAO_ORG || ' - ' || ORG.NOME_ORGANOGRAMA AS DES_UNIDADE,
                ORG.DATA_INICIO AS DATA_INICIO_ORG,
                ORG.DATA_FIM AS DATA_FIM_ORG,
                RESP.IND_RESP_UNI AS IND_RESP_UNI,
                VO.COD_REDE AS COD_REDE_LOCAL,
                VO.DES_REDE AS DES_REDE_LOCAL,
                VO.COD_REGIAO,
                VO.DES_REGIAO,

                ----NÍVEIS DO ORGANOGRAMA DO CONTRATO
                ORG.COD_ORG_1    AS COD_GRUPO_EMP,
                ORG.EDICAO_ORG_1 AS EDICAO_GRUPO_EMP,
                ORG.NOME1        AS DES_GRUPO_EMP,
                --===
                ORG.COD_ORG_2    AS COD_EMP,
                ORG.EDICAO_ORG_2 AS EDICAO_EMP,
                ORG.NOME2        AS DES_EMPRESA,
                --===
                ORG.COD_ORG_3    AS COD_ORG_FILIAL,
                ORG.EDICAO_ORG_3 AS EDICAO_FILIAL,
                ORG.NOME3        AS DES_FILIAL,
                --===
                ORG.COD_ORG_4    AS COD_ORG_DIVISAO,
                ORG.EDICAO_ORG_4 AS EDICAO_DIVISAO,
                ORG.NOME4        AS DES_DIVISAO,
                --===
                ORG.COD_ORG_5    AS COD_ORG_DEPART,
                ORG.EDICAO_ORG_5 AS EDICAO_DEPART,
                ORG.NOME5        AS DES_DEPART,
                --===
                ORG.COD_ORG_6    AS COD_ORG_SETOR,
                ORG.EDICAO_ORG_6 AS EDICAO_SETOR,
                ORG.NOME6        AS DES_SETOR,
                --===
                ORG.COD_ORG_7    AS COD_ORG_SECAO,
                ORG.EDICAO_ORG_7 AS EDICAO_SECAO,
                ORG.NOME7        AS DES_SECAO,
                --===
                ORG.COD_ORG_8    AS COD_ORG_UNI,
                ORG.EDICAO_ORG_8 AS EDICAO_UNI,
                ORG.NOME8        AS DES_UNI,

                CASE
                  WHEN LOT_CONT.COD_LOTACAO IS NOT NULL THEN
                   LOT_CONT.COD_LOTACAO
                  ELSE
                   NULL
                END AS COD_LOTACAO,

                VO.COD_TIPO,
                VO.DES_TIPO,

                /*DADOS PESSOAIS DO CONTRATO*/
                FP02.DATA_NASCIMENTO,
                FP02.SEXO,
                FP02.COD_ESTADO_CIVIL AS COD_EST_CIVIL,
                EC.NOME_ESTADO_CIVIL AS DES_EST_CIVIL,
                PF.EMAIL AS DES_EMAIL,
                PF.DDD_FONE_CEL AS COD_DDD,
                PF.FONE_CEL,
                PF.CPF,
                FP02.NRO_IDENTIDADE,
                PJ.NOME_PESSOA || '/' || FP02.COD_UF_IDENTIDADE AS EMISSOR,
                FP02.NRO_PIS_PASEP,
                FP02.COD_NACIONALIDADE,
                NAC.NOME_NACIONALIDADE || '(a)' AS NACIONALIDADE,
                FP02.COD_NACIONALIDADE || ' - ' || NAC.NOME_NACIONALIDADE || '(a)' AS DES_NACIONALIDADE,
                PF.CEP AS COD_CEP,
                PF.TIPO_LOGRA,
                PF.COD_LOGRA,
                PF.NOME_LOGRA AS DES_LOGRA,
                PF.COD_BAIRRO,
                PF.NOME_BAIRRO AS DES_BAIRRO,
                PF.COD_MUNIC AS COD_CIDADE,
                PF.NOME_MUNIC AS DES_CIDADE,
                PF.COD_UF,

                /*DADOS DE AFASTAMENTOS DO CONTRATO*/
                AFAST.COD_CAUSA_AFAST AS COD_AFAST,
                AFAST.NOME_CAUSA_AFAST AS DES_AFAST,
                AFAST.DATA_INICIO AS DATA_INI_AFAST,
                AFAST.DATA_FIM AS DATA_FIM_AFAST,
                CASE
                  WHEN (CT.DATA_FIM IS NOT NULL AND
                       CT.DATA_FIM < TRUNC(SYSDATE)) THEN
                   'INATIVO'
                  WHEN AFAST.COD_CAUSA_AFAST <> 0 AND
                       AFAST.COD_CAUSA_AFAST <> 4 AND
                       AFAST.DATA_FIM = '31/12/2999' THEN
                   'AFASTADO'
                  WHEN AFAST.COD_CAUSA_AFAST = 7 THEN
                   'EM FÉRIAS'
                  WHEN AFAST.COD_CAUSA_AFAST IN (3, 6) THEN
                   'AFASTADO TEMP'
                  WHEN AFAST.COD_CAUSA_AFAST = 4 AND
                       AFAST.DATA_FIM = '31/12/2999' THEN
                   'PODERÁ RETORNAR'
                  ELSE
                   'EM ATIVIDADE'
                END AS STATUS_AFAST,

                /*DADOS DE CARGO E ORGANOGRAMAS ANTERIORES DO CONTRATO - O ÚLTIMO ANTES DO ATUAL*/
                'DADOS ANTERIORES DO CONTRATO =>' AS ESPACO,
                CC.COD_CLH_ANT AS COD_FUNCAO_ANT,
                CC.DES_CLH_ANT AS DES_FUNCAO_ANT,
                CC.DATA_INICIO_ANT,
                CC.DATA_FIM_ANT,
                CO.EDICAO_ORG_ANT AS COD_UNIDADE_ANT,
                CO.DES_ORGANOGRAMA_ANT AS DES_UNIDADE_ANT,
                CO.DATA_INICIO_ORG_ANT,
                CO.DATA_FIM_ORG_ANT

  FROM RHFP0300 CT
 INNER JOIN RHFP0200 FP02 ON CT.COD_FUNC = FP02.COD_FUNC
  LEFT JOIN PESSOA_JURIDICA PJ ON FP02.COD_ORG_IDENTIDADE = PJ.COD_PESSOA
  LEFT JOIN RHFP0104 EC ON FP02.COD_ESTADO_CIVIL = EC.COD_ESTADO_CIVIL
  LEFT JOIN RHFP0107 NAC ON FP02.COD_NACIONALIDADE = NAC.COD_NACIONALIDADE
 INNER JOIN PESSOA_FISICA PF ON CT.COD_FUNC = PF.COD_PESSOA
 INNER JOIN RHFP0340 CT_FUNC ON CT.COD_CONTRATO = CT_FUNC.COD_CONTRATO
                            AND TRUNC(SYSDATE) BETWEEN CT_FUNC.DATA_INICIO AND
                                NVL(CT_FUNC.DATA_FIM, '31/12/2999')
                                
 --DADOS DO ORGANOGRAMA DO CONTRATO                               
 INNER JOIN VH_EST_ORG_CONTRATO_AVT ORG ON CT.COD_CONTRATO =
                                           ORG.COD_CONTRATO
                                       AND TRUNC(SYSDATE) BETWEEN
                                           ORG.DATA_INICIO AND
                                           NVL(ORG.DATA_FIM, '31/12/2999')                                     
  LEFT JOIN V_ORGANOGRAMAS_AVT VO ON ORG.COD_ORGANOGRAMA = VO.COD_ORGANOGRAMA
  
 INNER JOIN RHFP0500 FUNC ON CT_FUNC.COD_CLH = FUNC.COD_CLH
  LEFT JOIN RHFP0309 LOT_CONT ON CT.COD_CONTRATO = LOT_CONT.COD_CONTRATO
  
 --DADOS DO TURNO E HORÁRIOS DO CONTRATO 
 INNER JOIN RHAF1119 CT_TUR ON CT.COD_CONTRATO = CT_TUR.COD_CONTRATO
                           AND TRUNC(SYSDATE) BETWEEN CT_TUR.DATA_INICIO AND
                               CT_TUR.DATA_FIM
 INNER JOIN RHAF1145 TURNO ON CT_TUR.COD_TURNO = TURNO.COD_TURNO
 INNER JOIN V_HORAS_COLAB_AVT HR ON CT.COD_CONTRATO = HR.COD_CONTRATO
  LEFT JOIN V_SUPERIOR_IMEDIATO_AVT RESP ON CT.COD_CONTRATO =
                                            RESP.COD_CONTRATO
                                            
  LEFT JOIN V_AFAST_COLAB_AVT AFAST ON CT.COD_CONTRATO = AFAST.COD_CONTRATO
  LEFT JOIN RHFP0102 DEM ON CT.COD_CAUSA_DEMISSAO = DEM.COD_CAUSA_DEMISSAO
  
  --DADOS ANTERIORES DO CONTRATO
  LEFT JOIN V_CARGO_CONTRATO_AVT CC ON CT.COD_CONTRATO = CC.COD_CONTRATO
  LEFT JOIN V_ORGANOGRAMA_CONTRATO_AVT CO ON CT.COD_CONTRATO =
                                             CO.COD_CONTRATO

 WHERE (CT.DATA_FIM IS NULL AND TRUNC(SYSDATE) BETWEEN CT.DATA_INICIO AND
       NVL(CT.DATA_FIM, '31/12/2999') OR
       CT.DATA_FIM >= TRUNC(SYSDATE) - 365)

 ORDER BY STATUS ASC, DATA_ADMISSAO, DESC_STATUS DESC
