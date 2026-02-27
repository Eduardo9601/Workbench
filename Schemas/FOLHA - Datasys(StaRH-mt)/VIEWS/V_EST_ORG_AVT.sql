CREATE OR REPLACE VIEW V_EST_ORG_AVT AS
SELECT DISTINCT CASE
                  WHEN A.DATA_FIM = '31/12/2999' THEN
                   0
                  ELSE
                   1
                END AS STATUS_ORG,
                CASE
                  WHEN A.DATA_FIM = '31/12/2999' THEN
                   'ATIVO'
                  ELSE
                   'INATIVO'
                END AS DES_STATUS_ORG,
                A.COD_ORGANOGRAMA,
                PJ1.COD_PESSOA,
                B.NOME_ORGANOGRAMA,
                A.COD_ORGANOGRAMA || ' - ' || B.NOME_ORGANOGRAMA AS NOME_ORGANOGRAMA_A,
                A.EDICAO_ORG || ' - ' || B.NOME_ORGANOGRAMA AS NOME_ORGANOGRAMA_B,
                A.DATA_INICIO,
                A.DATA_FIM,
                B.COD_NIVEL_ORG,
                D.NOME_NIVEL_ORG,
                A.COD_ORGANOGRAMA_SUB,
                A.EDICAO_ORG,
                SUBSTR(RHYF0002(B.COD_ORGANOGRAMA,
                                B.COD_NIVEL_ORG,
                                TRUNC(SYSDATE)),
                       1,
                       80) AS EDICAO,
                A.COD_NIVEL1 AS COD1,
                A.COD_NIVEL2 AS COD2,
                A.COD_NIVEL3 AS COD3,
                A.COD_NIVEL4 AS COD4,
                A.COD_NIVEL5 AS COD5,
                A.COD_NIVEL6 AS COD6,
                A.COD_NIVEL7 AS COD7,
                A.COD_NIVEL8 AS COD8,
                A.EDICAO_NIVEL1 AS EDI1,
                A.EDICAO_NIVEL2 AS EDI2,
                A.EDICAO_NIVEL3 AS EDI3,
                A.EDICAO_NIVEL4 AS EDI4,
                A.EDICAO_NIVEL5 AS EDI5,
                A.EDICAO_NIVEL6 AS EDI6,
                A.EDICAO_NIVEL7 AS EDI7,
                A.EDICAO_NIVEL8 AS EDI8,
                A.COD_NIVEL1 AS COD_ORG_1,
                A.EDICAO_NIVEL1 AS EDICAO_ORG_1,
                B1.NOME_ORGANOGRAMA AS NOME1,
                A.COD_NIVEL2 AS COD_ORG_2,
                A.EDICAO_NIVEL2 AS EDICAO_ORG_2,
                B2.NOME_ORGANOGRAMA AS NOME2,
                A.COD_NIVEL3 AS COD_ORG_3,
                A.EDICAO_NIVEL3 AS EDICAO_ORG_3,
                B3.NOME_ORGANOGRAMA AS NOME3,
                A.COD_NIVEL4 AS COD_ORG_4,
                A.EDICAO_NIVEL4 AS EDICAO_ORG_4,
                B4.NOME_ORGANOGRAMA AS NOME4,
                A.COD_NIVEL5 AS COD_ORG_5,
                A.EDICAO_NIVEL5 AS EDICAO_ORG_5,
                B5.NOME_ORGANOGRAMA AS NOME5,
                A.COD_NIVEL6 AS COD_ORG_6,
                A.EDICAO_NIVEL6 AS EDICAO_ORG_6,
                B6.NOME_ORGANOGRAMA AS NOME6,
                A.COD_NIVEL7 AS COD_ORG_7,
                A.EDICAO_NIVEL7 AS EDICAO_ORG_7,
                B7.NOME_ORGANOGRAMA AS NOME7,
                A.COD_NIVEL8 AS COD_ORG_8,
                A.EDICAO_NIVEL8 AS EDICAO_ORG_8,
                B8.NOME_ORGANOGRAMA AS NOME8,
                C.COD_CUSTO_CONTABIL,
                C.CUSTO_CONTABIL,
                C.NOME_CUSTO_CONTABIL,
                C.COD_NIVEL_CONTABIL,
                C.COD_CUSTO_SUB,
                C.EDICAO_NIVEL3,
                CASE
                /* Se COD_CUSTO_SUB=50, força ADM (independe do resto) */
                  WHEN NVL(C.COD_CUSTO_SUB, -1) = 50 THEN
                   '001'

                /* ADM/CD */
                  WHEN A.EDICAO_NIVEL3 = '001' AND A.COD_NIVEL3 = 9 AND
                       A.EDICAO_ORG IN ('580', '581', '585', '811', '815', '831', '835', '841', '845', '851', '855', '871', '907') THEN
                   '001'
                  WHEN A.EDICAO_NIVEL3 = '013' AND A.COD_NIVEL3 = 21 THEN
                   '013'

                /* LOJAS/REDES (usa fallback: C.EDICAO_NIVEL3 se existir, senão A.EDICAO_NIVEL3) */
                  WHEN C.EDICAO_NIVEL3 = '1' AND
                       A.COD_ORGANOGRAMA <> 1 AND
                       A.EDICAO_ORG NOT IN ('811', '815', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   '10'

                  WHEN C.EDICAO_NIVEL3 = '3' AND
                       A.EDICAO_ORG NOT IN ('831', '835', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   '30'

                  WHEN C.EDICAO_NIVEL3 = '4' AND
                       A.EDICAO_ORG NOT IN ('841', '845', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   '40'

                  WHEN C.EDICAO_NIVEL3 = '2' AND
                       A.EDICAO_ORG NOT IN ('851', '855', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   '50'

                  WHEN C.EDICAO_NIVEL3 = '7' AND
                       A.EDICAO_ORG NOT IN ('871', '907') AND B.COD_NIVEL_ORG = 5 THEN
                   '70'

                /* EXTINTAS */
                  WHEN C.EDICAO_NIVEL3 = '5' AND
                       A.EDICAO_ORG NOT IN ('580', '581', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   '20'

                  WHEN C.EDICAO_NIVEL3 = '6' AND
                       A.EDICAO_ORG NOT IN ('585', '907') AND B.COD_NIVEL_ORG = 5 THEN
                   '60'

                  ELSE
                   NULL
                END AS COD_REDE,

                CASE
                  WHEN NVL(C.COD_CUSTO_SUB, -1) = 50 THEN
                   'ADMINISTRAÇÃO'

                  WHEN A.EDICAO_NIVEL3 = '001' AND A.COD_NIVEL3 = 9 AND
                       A.EDICAO_ORG IN ('580', '581', '585', '811', '815', '831', '835', '841', '845', '851', '855', '871', '907') THEN
                   'ADMINISTRAÇÃO'
                  WHEN A.EDICAO_NIVEL3 = '013' AND A.COD_NIVEL3 = 21 THEN
                   'LOGÍSTICA'

                  WHEN C.EDICAO_NIVEL3 = '1' AND
                       A.COD_ORGANOGRAMA <> 1 AND
                       A.EDICAO_ORG NOT IN ('811', '815', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'GRAZZIOTIN'

                  WHEN C.EDICAO_NIVEL3 = '3' AND
                       A.EDICAO_ORG NOT IN ('831', '835', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'PORMENOS'

                  WHEN C.EDICAO_NIVEL3 = '4' AND
                       A.EDICAO_ORG NOT IN ('841', '845', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'FRANCO GIORGI'

                  WHEN C.EDICAO_NIVEL3 = '2' AND
                       A.EDICAO_ORG NOT IN ('851', '855', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'TOTTAL'

                  WHEN C.EDICAO_NIVEL3 = '7' AND
                       A.EDICAO_ORG NOT IN ('871', '907') AND B.COD_NIVEL_ORG = 5 THEN
                   'GZT STORE'

                  WHEN C.EDICAO_NIVEL3 = '5' AND
                       A.EDICAO_ORG NOT IN ('580', '581', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'ARRAZZO'

                  WHEN C.EDICAO_NIVEL3 = '6' AND
                       A.EDICAO_ORG NOT IN ('585', '907') AND B.COD_NIVEL_ORG = 5 THEN
                   'VIA RAQUELLE'

                  ELSE
                   NULL
                END AS DES_REDE,

                CASE
                  WHEN NVL(C.COD_CUSTO_SUB, -1) = 50 THEN
                   'ADM'

                  WHEN A.EDICAO_NIVEL3 = '001' AND A.COD_NIVEL3 = 9 AND
                       A.EDICAO_ORG IN ('580', '581', '585', '811', '815', '831', '835', '841', '845', '851', '855', '871', '907') THEN
                   'ADM'
                  WHEN A.EDICAO_NIVEL3 = '013' AND A.COD_NIVEL3 = 21 THEN
                   'CD'

                  WHEN C.EDICAO_NIVEL3 = '1' AND
                       A.COD_ORGANOGRAMA <> 1 AND
                       A.EDICAO_ORG NOT IN ('811', '815', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'GRZ'

                  WHEN C.EDICAO_NIVEL3 = '3' AND
                       A.EDICAO_ORG NOT IN ('831', '835', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'PRM'

                  WHEN C.EDICAO_NIVEL3 = '4' AND
                       A.EDICAO_ORG NOT IN ('841', '845', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'FRG'

                  WHEN C.EDICAO_NIVEL3 = '2' AND
                       A.EDICAO_ORG NOT IN ('851', '855', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'TOT'

                  WHEN C.EDICAO_NIVEL3 = '7' AND
                       A.EDICAO_ORG NOT IN ('871', '907') AND B.COD_NIVEL_ORG = 5 THEN
                   'GZT'

                  WHEN C.EDICAO_NIVEL3 = '5' AND
                       A.EDICAO_ORG NOT IN ('580', '581', '907') AND
                       B.COD_NIVEL_ORG = 5 THEN
                   'ARZ'

                  WHEN C.EDICAO_NIVEL3 = '6' AND
                       A.EDICAO_ORG NOT IN ('585', '907') AND B.COD_NIVEL_ORG = 5 THEN
                   'VIA'

                /* COLIGADAS */
                  WHEN A.COD_NIVEL2 = 4 THEN
                   'MDT'
                  WHEN A.COD_NIVEL2 = 276 THEN
                   'SHP'
                  WHEN A.COD_NIVEL2 = 282 THEN
                   'FIN'
                  WHEN A.COD_NIVEL2 = 1629 THEN
                   'FLO'

                  ELSE
                   NULL
                END AS SIGLA_REDE,

                --C1.COD_REGIAO,
                --C1.DES_REGIAO,
                PJ1.TIP_LOGRA,
                PJ1.NOME_LOGRA AS LOGRADOURO,
                PJ1.NUMERO,
                PJ1.COMPLEMENTO,
                PJ1.COD_BAIRRO,
                PJ1.NOME_BAIRRO AS BAIRRO,
                PJ1.COD_MUNIC,
                PJ1.COD_MUN_FED AS COD_IBGE,
                PJ1.NOME_MUNIC AS CIDADE,
                PJ1.COD_UF,
                PJ1.CEP,
                PJ1.CGC AS CNPJ,
                PJ1.EMAIL,
                PJ1.DDD,
                PJ1.FONE,
                PJ1.FONE_ALTER,
                PJ1.FANTASIA,
                PJ1.INSC_MUNIC,
                PJ1.INSC_EST,
                PJ1.COD_ATIV,
                PJ1.COD_NATURE,
                PJ1.CNAE2,
                PJ1.ESTABELECIMENTO,
                PJ1.CATEGORIA,
                ES1.COD_FPAS,
                ES1.COD_CEI,
                ES1.COD_EMPRESA_CAIXA,
                ES1.INDICE_SAT,
                ES1.COD_TERCEIROS,
                ES1.DATA_BASE,
                ES1.COD_GPS,
                ES1.PERC_FILANTROPIA,
                ES1.COD_RESPONSAVEL,
                ES1.IND_PARTICIPA_PAT,
                ES1.IND_SINDICATO,
                ES1.INDICE_FAP,
                ES1.COD_NATUREZA,
                ES1.IND_CALC_INSS_EMP,
                ES1.COD_CLA_TRIB,
                ES1.IND_COOPERATIVA,
                ES1.TIPO_CONTROLE_PONTO,
                ES1.IND_DES_FOLHA,
                ES1.IND_CONSTR,
                ES1.IND_ENT_ED,
                ES1.IND_ETT,
                ES1.IND_SIT_PJ,
                ES1.CONT_APR,
                ES1.CONT_ENT_ED,
                ES1.CONT_PCD,
                ES1.TP_LOTACAO,
                ES1.REG_PT,
                ES1.COD_PESSOA_ENT_ED,
                ES1.COD_TERCS_SUSP,
                ES1.COD_TERC_SUSP1,
                ES1.NR_PROC_JUD_T1,
                ES1.NRO_CERT_ASS,
                ES1.DTEMI_CERT_ASS,
                ES1.DTVAL_CERT_ASS,
                ES1.NRO_CERT_ENV,
                ES1.DTEMI_CERT_ENV,
                ES1.DTVAL_CERT_ENV,
                ES1.IND_MES_ESOCIAL,
                ES1.BH_COMP_INI,
                ES1.IND_OPC_CP,
                ES1.IND_CLH_ESOCIAL,
                ES1.IND_OPT_REG_ELETRON,
                ES1.IND_CERTIF_USUARIO,
                ES1.IND_ENV_RAT,
                ES1.IND_ENV_FAP,
                ES1.IND_PIS_COF,
                ES1.DATA_INI_ATIVIDADES,
                ES1.DATA_FIM_ATIVIDADES,
                CASE
                  WHEN A.COD_NIVEL1 = 1 AND A.COD_ORGANOGRAMA = 1 THEN
                   0
                  WHEN A.COD_NIVEL2 = 8 AND A.COD_ORGANOGRAMA = 8 THEN
                   8
                  WHEN A.COD_NIVEL2 = 8 AND A.COD_NIVEL3 = 9 THEN
                   2
                  WHEN A.COD_NIVEL2 = 8 AND A.COD_NIVEL3 = 21 THEN
                   3
                  WHEN A.COD_NIVEL2 <> 8 THEN
                   4
                  ELSE
                   1
                END AS COD_TIPO,
                CASE
                  WHEN A.COD_NIVEL1 = 1 AND A.COD_ORGANOGRAMA = 1 THEN
                   'GRUPO EMP'
                  WHEN A.COD_NIVEL2 = 8 AND A.COD_ORGANOGRAMA = 8 THEN
                   'GRZ SA'
                  WHEN A.COD_NIVEL2 = 8 AND A.COD_NIVEL3 = 9 THEN
                   'ADM'
                  WHEN A.COD_NIVEL2 = 8 AND A.COD_NIVEL3 = 21 THEN
                   'DEPÓSITO'
                  WHEN A.COD_NIVEL2 <> 8 THEN
                   'COLIGADA'
                  ELSE
                   'LOJA'
                END AS DES_TIPO,
                0 AS IND_SEL
  FROM RHFP0401        A,
       RHFP0400        B1,
       RHFP0400        B2,
       RHFP0400        B3,
       RHFP0400        B4,
       RHFP0400        B5,
       RHFP0400        B6,
       RHFP0400        B7,
       RHFP0400        B8,
       RHFP0400        B,
       RHFP0402        C,
       RHFP0117        D,
       PESSOA_JURIDICA PJ1,
       JURIDICA        JU,
       RHFP0430        ES1
       --RHFP0458        ES2,
       --RHFP0488        ES3
--V_ORGANOGRAMAS_AVT C1
 WHERE A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA
   AND A.COD_NIVEL1 = B1.COD_ORGANOGRAMA(+)
   AND A.COD_NIVEL2 = B2.COD_ORGANOGRAMA(+)
   AND A.COD_NIVEL3 = B3.COD_ORGANOGRAMA(+)
   AND A.COD_NIVEL4 = B4.COD_ORGANOGRAMA(+)
   AND A.COD_NIVEL5 = B5.COD_ORGANOGRAMA(+)
   AND A.COD_NIVEL6 = B6.COD_ORGANOGRAMA(+)
   AND A.COD_NIVEL7 = B7.COD_ORGANOGRAMA(+)
   AND A.COD_NIVEL8 = B8.COD_ORGANOGRAMA(+)
   AND B.COD_CUSTO_CONTABIL = C.COD_CUSTO_CONTABIL(+)
   AND B.COD_NIVEL_ORG = D.COD_NIVEL_ORG(+)
   AND B.COD_PESSOA = PJ1.COD_PESSOA(+)
   AND B.COD_PESSOA = JU.COD_PESSOA(+)
   AND B.COD_ORGANOGRAMA = ES1.COD_ESTABELECIMENTO(+)
--AND A.COD_ORGANOGRAMA = C1.COD_ORGANOGRAMA(+)
--AND TRUNC(SYSDATE) BETWEEN A.DATA_INICIO AND A.DATA_FIM
  --AND A.EDICAO_ORG = '002'
 ORDER BY A.COD_ORGANOGRAMA ASC
;
