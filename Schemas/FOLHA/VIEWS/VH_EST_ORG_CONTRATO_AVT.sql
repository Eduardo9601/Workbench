CREATE OR REPLACE VIEW VH_EST_ORG_CONTRATO_AVT AS
SELECT DISTINCT
       B.COD_CONTRATO,
       PF.NOME_PESSOA,
       /* ORGANOGRAMA PRINCIPAL DO CONTRATO */
       B.DATA_INICIO AS DATA_INI_ORG,
       B.DATA_FIM AS DATA_FIM_ORG,
       A.COD_ORG_2 AS COD_EMP,
       A.EDICAO_ORG_2 AS EDICAO_EMP,
       A.NOME2 AS DES_EMP,
       A.EDICAO_ORG AS COD_UNIDADE,
       A.NOME_ORGANOGRAMA_B AS DES_UNIDADE,
       A.DATA_INICIO,
       A.DATA_FIM,
       A.COD_UF,
       A.COD_ORGANOGRAMA,
       A.NOME_ORGANOGRAMA,
       A.NOME_ORGANOGRAMA_A,
       A.COD_NIVEL_ORG,
       A.COD_ORGANOGRAMA_SUB,
       A.EDICAO,
       A.COD_CUSTO_CONTABIL,
       A.CUSTO_CONTABIL,
       A.NOME_CUSTO_CONTABIL,
       /* SEQUENCIA DOS NÍVEIS DO ORGANOGRAMA DO CONTRATO */
       CASE
           WHEN A.COD_ORG_1 =  A.COD_ORG_1 THEN
            A.COD_NIVEL_ORG
           ELSE
            NULL
       END AS NIVEL_ORG_1,
       A.COD_ORG_1,
       A.EDICAO_ORG_1,
       A.NOME1,
       A.COD_ORG_2,
       A.EDICAO_ORG_2,
       A.NOME2,
       A.COD_ORG_3,
       A.EDICAO_ORG_3,
       A.NOME3,
       CASE
           WHEN A.EDICAO_ORG_4 NOT IN ('811', '831', '841', '851', '871') THEN
            A.COD_ORG_4
           ELSE
            NULL
       END AS COD_ORG_4,
       CASE
           WHEN A.EDICAO_ORG_4 NOT IN ('811', '831', '841', '851', '871') THEN
            A.EDICAO_ORG_4
           ELSE
            NULL
       END AS EDICAO_ORG_4,
       CASE
           WHEN A.EDICAO_ORG_4 NOT IN ('811', '831', '841', '851', '871') THEN
            A.NOME4
           ELSE
            NULL
       END AS NOME4,
       A.COD_ORG_5,
       A.EDICAO_ORG_5,
       A.NOME5,
       A.COD_ORG_6,
       A.EDICAO_ORG_6,
       A.NOME6,
       A.COD_ORG_7,
       A.EDICAO_ORG_7,
       A.NOME7,
       A.COD_ORG_8,
       A.EDICAO_ORG_8,
       A.NOME8,
       A.COD_REDE,
       A.DES_REDE,
       --A.COD_REGIAO,
       --A.DES_REGIAO,
       /* OTIMIZAÇÃO DO CASE */
       CASE
           WHEN A.COD_ORG_2 = 8 THEN
               CASE
                   WHEN A.COD_ORG_3 = 9 THEN 2
                   WHEN A.COD_ORG_3 = 21 THEN 3
                   ELSE 1
               END
           ELSE 4
       END AS COD_TIPO,
       CASE
           WHEN A.COD_ORG_2 = 8 THEN
               CASE
                   WHEN A.COD_ORG_3 = 9 THEN 'SETOR'
                   WHEN A.COD_ORG_3 = 21 THEN 'DEPÓSITO'
                   ELSE 'LOJA'
               END
           ELSE 'COLIGADA'
       END AS DES_TIPO
FROM V_EST_ORG_ALTER_AVT A
INNER JOIN RHFP0310 B ON A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA
INNER JOIN RHFP0300 C ON B.COD_CONTRATO = C.COD_CONTRATO
INNER JOIN PESSOA_FISICA PF ON C.COD_FUNC = PF.COD_PESSOA
--LEFT JOIN V_INFO_FILIAL_CONT_AVT UFF ON A.COD_ORG_3 = UFF.COD_FILIAL
--WHERE B.COD_CONTRATO = 389622
;
