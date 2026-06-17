CREATE OR REPLACE VIEW VH_EST_ORG_CONTRATO_AVT AS
WITH BASE AS (
    SELECT
           B.ROWID AS RID_RHFP0310,

           B.COD_CONTRATO,
           PF.NOME_PESSOA,

           /* ORGANOGRAMA PRINCIPAL DO CONTRATO */
           B.DATA_INICIO AS DATA_INI_ORG,
           B.DATA_FIM    AS DATA_FIM_ORG,
           
           B.COD_NIVEL2 AS EMP_310,
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

           /* NÍVEL DO ORGANOGRAMA ALOCADO */
           A.COD_NIVEL_ORG AS NIVEL_ORG_1,

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

           CASE
               WHEN A.COD_ORG_2 = 8 THEN
                   CASE
                       WHEN A.COD_ORG_3 = 9  THEN 2
                       WHEN A.COD_ORG_3 = 21 THEN 3
                       ELSE 1
                   END
               ELSE 4
           END AS COD_TIPO,

           CASE
               WHEN A.COD_ORG_2 = 8 THEN
                   CASE
                       WHEN A.COD_ORG_3 = 9  THEN 'SETOR'
                       WHEN A.COD_ORG_3 = 21 THEN 'DEPÓSITO'
                       ELSE 'LOJA'
                   END
               ELSE 'COLIGADA'
           END AS DES_TIPO,

           ROW_NUMBER() OVER (
               PARTITION BY B.ROWID
               ORDER BY
                   /* 1º: estrutura cuja vigência contém a DATA_INICIO da RHFP0310 */
                   CASE
                       WHEN B.DATA_INICIO BETWEEN A.DATA_INICIO
                                             AND NVL(A.DATA_FIM, DATE '2999-12-31')
                       THEN 0
                       ELSE 1
                   END,

                   /* 2º: se tiver mais de uma, pega a mais recente */
                   A.DATA_INICIO DESC,

                   /* 3º: critério de desempate */
                   NVL(A.DATA_FIM, DATE '2999-12-31') DESC,

                   /* 4º: último desempate técnico */
                   A.COD_ORGANOGRAMA_SUB DESC
           ) AS RN

    FROM RHFP0310 B

    LEFT JOIN V_EST_ORG_ALTER_AVT A
           ON A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA

    LEFT JOIN RHFP0300 C
           ON C.COD_CONTRATO = B.COD_CONTRATO

    LEFT JOIN PESSOA_FISICA PF
           ON PF.COD_PESSOA = C.COD_FUNC
)

SELECT
       COD_CONTRATO,
       NOME_PESSOA,

       DATA_INI_ORG,
       DATA_FIM_ORG,
       
       EMP_310,
       COD_EMP,
       EDICAO_EMP,
       DES_EMP,

       COD_UNIDADE,
       DES_UNIDADE,

       DATA_INICIO,
       DATA_FIM,
       COD_UF,

       COD_ORGANOGRAMA,
       NOME_ORGANOGRAMA,
       NOME_ORGANOGRAMA_A,
       COD_NIVEL_ORG,
       COD_ORGANOGRAMA_SUB,
       EDICAO,

       COD_CUSTO_CONTABIL,
       CUSTO_CONTABIL,
       NOME_CUSTO_CONTABIL,

       NIVEL_ORG_1,

       COD_ORG_1,
       EDICAO_ORG_1,
       NOME1,

       COD_ORG_2,
       EDICAO_ORG_2,
       NOME2,

       COD_ORG_3,
       EDICAO_ORG_3,
       NOME3,

       COD_ORG_4,
       EDICAO_ORG_4,
       NOME4,

       COD_ORG_5,
       EDICAO_ORG_5,
       NOME5,

       COD_ORG_6,
       EDICAO_ORG_6,
       NOME6,

       COD_ORG_7,
       EDICAO_ORG_7,
       NOME7,

       COD_ORG_8,
       EDICAO_ORG_8,
       NOME8,

       COD_REDE,
       DES_REDE,

       COD_TIPO,
       DES_TIPO

FROM BASE
WHERE RN = 1;
