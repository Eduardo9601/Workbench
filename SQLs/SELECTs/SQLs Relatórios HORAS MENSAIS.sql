/*RELATÓRIO GERAL DE HORAS DAS LOJAS*/

WITH DADOS_UNIDADES AS (

/*RELAÇÃO ABERTA OR LOJA*/
SELECT COD_UNIDADE,
       DES_UNIDADE,
       CASE
           WHEN COD_REDE IS NULL THEN
            0
           ELSE
            TO_NUMBER(COD_REDE)
       END AS COD_REDE,
       CASE
           WHEN DES_REDE IS NULL THEN
            'SEM REDE'
           ELSE
            DES_REDE
       END AS DES_REDE,
       COD_TIPO,
       SUM(CON_ATIVOS) AS QTD_ATIVO,
       SUM(CON_AFAST) AS QTD_AFAST,
       SUM(CON_MATERN) AS QTD_MATERN,
       SUM(IND_PCD) AS QTD_PCD,

       /*QUANTIDADES DE CONTRATOS POR CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, HMT_120, 0)) AS QTD_120_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_150, 0)) AS QTD_150_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_165, 0)) AS QTD_165_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_180, 0)) AS QTD_180_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_195, 0)) AS QTD_195_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_220, 0)) AS QTD_220_ATIVO,

       /*QUANTIDADE DE CADA CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) AS QTD_HORAS_120,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) AS QTD_HORAS_150,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_165, 0)) AS QTD_HORAS_165,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) AS QTD_HORAS_180,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_195, 0)) AS QTD_HORAS_195,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HORAS_220,

       /*TOTALIZADORES*/
       SUM(CON_ATIVOS) + SUM(CON_AFAST) AS QTD_CONT_TOTAL,
       SUM(HMT_120) AS HMT_120_TOTAL,
       SUM(HMT_150) AS HMT_150_TOTAL,
       SUM(HMT_165) AS HMT_165_TOTAL,
       SUM(HMT_180) AS HMT_180_TOTAL,
       SUM(HMT_195) AS HMT_195_TOTAL,
       SUM(HMT_220) AS HMT_220_TOTAL,

       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_165, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_195, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HMT_TOTAL,

       /*QUANTIDADE E PERCENTUAL POR SEXO*/
       SUM(QTD_MASC) AS QTD_MASC,
       ROUND((SUM(QTD_MASC) / COUNT(*) * 100), 2) AS PERC_MASC,
       SUM(QTD_FEM) AS QTD_FEM,
       ROUND((SUM(QTD_FEM) / COUNT(*) * 100), 2) AS PERC_FEM


  FROM (

SELECT DISTINCT A.STATUS,
                A.DESC_STATUS,
                A.COD_CONTRATO,
                A.DES_PESSOA,
                A.DATA_ADMISSAO,
                A.DATA_DEMISSAO,
                C.DES_FUNCAO,
                C.DATA_INI_CLH,
                C.DATA_FIM_CLH,
                --A.COD_VINCULO_EMPREG,
                A.SEXO,
                A.IND_DEFICIENCIA,
                A.COD_DEFICIENCIA,
                A.DES_DEFICIENCIA,

                B.HR_BASE_MES,
                B.DATA_INI_HR,
                B.DATA_FIM_HR,

                D.COD_EMP,
                D.EDICAO_ORG_2 || ' - ' || NOME2 AS EMPRESA,
                D.COD_UNIDADE,
                D.DES_UNIDADE,
                D.DATA_INI_ORG,
                D.DATA_FIM_ORG,
                D.COD_REDE,
                D.DES_REDE,
                --D.COD_REGIAO,
                --D.DES_REGIAO,
                D.COD_TIPO,
                D.DES_TIPO,

                E.COD_AFAST,
                E.DES_AFAST,
                E.DATA_INI_AFAST,
                E.DATA_FIM_AFAST,
                --E.COD_STATUS_AFAST,
                E.STATUS_AFAST,

                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN 1
                    ELSE 0
                END AS IND_PCD,

                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN 1
                    ELSE 0
                END AS HMT_120,
                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_120,

                CASE
                    WHEN B.HR_BASE_MES = 150 THEN 1
                    ELSE 0
                END AS HMT_150,
                CASE
                    WHEN B.HR_BASE_MES = 150 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_150,

                CASE
                    WHEN B.HR_BASE_MES = 165 THEN 1
                    ELSE 0
                END AS HMT_165,
                CASE
                    WHEN B.HR_BASE_MES = 165 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_165,

                CASE
                    WHEN B.HR_BASE_MES = 180 THEN 1
                    ELSE 0
                END AS HMT_180,
                CASE
                    WHEN B.HR_BASE_MES = 180 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_180,

                CASE
                    WHEN B.HR_BASE_MES = 195 THEN 1
                    ELSE 0
                END AS HMT_195,
                CASE
                    WHEN B.HR_BASE_MES = 195 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_195,

                CASE
                    WHEN B.HR_BASE_MES = 220 THEN 1
                    ELSE 0
                END AS HMT_220,
                CASE
                    WHEN B.HR_BASE_MES = 220 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_220,

                CASE
                    WHEN A.COD_STATUS_AFAST IN (0, 6, 7) THEN 1
                    ELSE 0
                END AS CON_ATIVOS,
                CASE
                    WHEN A.COD_STATUS_AFAST NOT IN (0, 6, 7) THEN 1
                    ELSE 0
                END AS CON_AFAST,
                CASE
                    WHEN E.COD_AFAST = 3 THEN 1
                    ELSE 0
                END AS CON_MATERN,

                CASE
                    WHEN A.SEXO = 'M' THEN 1
                    ELSE 0
                END AS QTD_MASC,
                CASE
                    WHEN A.SEXO = 'F' THEN 1
                    ELSE 0
                END AS QTD_FEM

FROM VH_COLAB_PESSOA_AVT A
INNER JOIN VH_HIST_HORAS_COLAB_AVT B ON A.COD_CONTRATO = B.COD_CONTRATO
                                     AND (B.DATA_FIM_HR = '31/12/2999' OR B.DATA_FIM_HR > :DATA_REFERENCIA)
                                     AND (B.DATA_INI_HR  <= :DATA_REFERENCIA)
 LEFT JOIN VH_CARGO_CONTRATO_AVT C ON A.COD_CONTRATO = C.COD_CONTRATO
                                   AND (C.DATA_FIM_CLH = '31/12/2999' OR C.DATA_FIM_CLH > :DATA_REFERENCIA)
                                   AND (C.DATA_INI_CLH <= :DATA_REFERENCIA)
 LEFT JOIN VH_EST_ORG_CONTRATO_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
                                     AND (D.DATA_FIM_ORG = '31/12/2999' OR D.DATA_FIM_ORG > :DATA_REFERENCIA)
                                     AND (D.DATA_INI_ORG  <= :DATA_REFERENCIA)
 LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO = E.COD_CONTRATO
                                       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST > :DATA_REFERENCIA)
                                       AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
WHERE D.COD_EMP = 8
  --AND A.STATUS = 0
  AND D.COD_TIPO = 1
  AND C.COD_FUNCAO NOT IN (68, 71, 74, 75, 310, 409)

  AND (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO > :DATA_REFERENCIA)
  AND (A.DATA_ADMISSAO <= :DATA_REFERENCIA)

)
 GROUP BY COD_UNIDADE, DES_UNIDADE, COD_REDE, DES_REDE, COD_TIPO
 --ORDER BY COD_REDE_LOCAL, COD_UNIDADE

),

DADOS_REDES AS (

/*RELAÇÃO ABERTA POR REDE*/
SELECT
       CASE
           WHEN COD_REDE IS NULL THEN
            0
           ELSE
            TO_NUMBER(COD_REDE)
       END AS COD_REDE,
       CASE
           WHEN DES_REDE IS NULL THEN
            'SEM REDE'
           ELSE
            DES_REDE
       END AS DES_REDE,
       SUM(CON_ATIVOS) AS QTD_ATIVO,
       SUM(CON_AFAST) AS QTD_AFAST,
       SUM(CON_MATERN) AS QTD_MATERN,
       SUM(IND_PCD) AS QTD_PCD,

       /*QUANTIDADES DE CONTRATOS POR CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, HMT_120, 0)) AS QTD_120_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_150, 0)) AS QTD_150_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_165, 0)) AS QTD_165_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_180, 0)) AS QTD_180_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_195, 0)) AS QTD_195_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_220, 0)) AS QTD_220_ATIVO,

       /*QUANTIDADE DE CADA CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) AS QTD_HORAS_120,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) AS QTD_HORAS_150,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_165, 0)) AS QTD_hORAS_165,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) AS QTD_hORAS_180,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_195, 0)) AS QTD_hORAS_195,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_hORAS_220,

       /*TOTALIZADORES*/
       SUM(CON_ATIVOS) + SUM(CON_AFAST) AS QTD_CONT_TOTAL,
       SUM(HMT_120) AS HMT_120_TOTAL,
       SUM(HMT_150) AS HMT_150_TOTAL,
       SUM(HMT_165) AS HMT_165_TOTAL,
       SUM(HMT_180) AS HMT_180_TOTAL,
       SUM(HMT_195) AS HMT_195_TOTAL,
       SUM(HMT_220) AS HMT_220_TOTAL,

       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_165, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_195, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HMT_TOTAL,

       /*QUANTIDADE E PERCENTUAL POR SEXO*/
       SUM(QTD_MASC) AS QTD_MASC,
       ROUND((SUM(QTD_MASC) / COUNT(*) * 100), 2) AS PERC_MASC,
       SUM(QTD_FEM) AS QTD_FEM,
       ROUND((SUM(QTD_FEM) / COUNT(*) * 100), 2) AS PERC_FEM

  FROM (

SELECT DISTINCT A.STATUS,
                A.DESC_STATUS,
                A.COD_CONTRATO,
                A.DES_PESSOA,
                A.DATA_ADMISSAO,
                A.DATA_DEMISSAO,
                C.DES_FUNCAO,
                C.DATA_INI_CLH,
                C.DATA_FIM_CLH,
                --A.COD_VINCULO_EMPREG,
                A.SEXO,
                A.IND_DEFICIENCIA,
                A.COD_DEFICIENCIA,
                A.DES_DEFICIENCIA,

                B.HR_BASE_MES,
                B.DATA_INI_HR,
                B.DATA_FIM_HR,

                D.COD_EMP,
                D.EDICAO_ORG_2 || ' - ' || NOME2 AS EMPRESA,
                D.COD_UNIDADE,
                D.DES_UNIDADE,
                D.DATA_INI_ORG,
                D.DATA_FIM_ORG,
                D.COD_REDE,
                D.DES_REDE,
                --D.COD_REGIAO,
                --D.DES_REGIAO,
                D.COD_TIPO,
                D.DES_TIPO,

                E.COD_AFAST,
                E.DES_AFAST,
                E.DATA_INI_AFAST,
                E.DATA_FIM_AFAST,
                --E.COD_STATUS_AFAST,
                E.STATUS_AFAST,

                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN 1
                    ELSE 0
                END AS IND_PCD,

                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN 1
                    ELSE 0
                END AS HMT_120,
                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_120,

                CASE
                    WHEN B.HR_BASE_MES = 150 THEN 1
                    ELSE 0
                END AS HMT_150,
                CASE
                    WHEN B.HR_BASE_MES = 150 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_150,

                CASE
                    WHEN B.HR_BASE_MES = 165 THEN 1
                    ELSE 0
                END AS HMT_165,
                CASE
                    WHEN B.HR_BASE_MES = 165 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_165,

                CASE
                    WHEN B.HR_BASE_MES = 180 THEN 1
                    ELSE 0
                END AS HMT_180,
                CASE
                    WHEN B.HR_BASE_MES = 180 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_180,

                CASE
                    WHEN B.HR_BASE_MES = 195 THEN 1
                    ELSE 0
                END AS HMT_195,
                CASE
                    WHEN B.HR_BASE_MES = 195 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_195,

                CASE
                    WHEN B.HR_BASE_MES = 220 THEN 1
                    ELSE 0
                END AS HMT_220,
                CASE
                    WHEN B.HR_BASE_MES = 220 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_220,

                CASE
                    WHEN A.COD_STATUS_AFAST IN (0, 6, 7) THEN 1
                    ELSE 0
                END AS CON_ATIVOS,
                CASE
                    WHEN A.COD_STATUS_AFAST NOT IN (0, 6, 7) THEN 1
                    ELSE 0
                END AS CON_AFAST,
                CASE
                    WHEN E.COD_AFAST = 3 THEN 1
                    ELSE 0
                END AS CON_MATERN,

                CASE
                    WHEN A.SEXO = 'M' THEN 1
                    ELSE 0
                END AS QTD_MASC,
                CASE
                    WHEN A.SEXO = 'F' THEN 1
                    ELSE 0
                END AS QTD_FEM

FROM VH_COLAB_PESSOA_AVT A
INNER JOIN VH_HIST_HORAS_COLAB_AVT B ON A.COD_CONTRATO = B.COD_CONTRATO
                                     AND (B.DATA_FIM_HR = '31/12/2999' OR B.DATA_FIM_HR > :DATA_REFERENCIA)
                                     AND (B.DATA_INI_HR  <= :DATA_REFERENCIA)
 LEFT JOIN VH_CARGO_CONTRATO_AVT C ON A.COD_CONTRATO = C.COD_CONTRATO
                                   AND (C.DATA_FIM_CLH = '31/12/2999' OR C.DATA_FIM_CLH > :DATA_REFERENCIA)
                                   AND (C.DATA_INI_CLH <= :DATA_REFERENCIA)
 LEFT JOIN VH_EST_ORG_CONTRATO_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
                                     AND (D.DATA_FIM_ORG = '31/12/2999' OR D.DATA_FIM_ORG > :DATA_REFERENCIA)
                                     AND (D.DATA_INI_ORG  <= :DATA_REFERENCIA)
 LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO = E.COD_CONTRATO
                                       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST > :DATA_REFERENCIA)
                                       AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
WHERE D.COD_EMP = 8
  --AND A.STATUS = 0
  AND D.COD_TIPO = 1
  AND C.COD_FUNCAO NOT IN (68, 71, 74, 75, 310, 409)

  AND (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO > :DATA_REFERENCIA)
  AND (A.DATA_ADMISSAO <= :DATA_REFERENCIA)

        )
 GROUP BY COD_REDE, DES_REDE
 --ORDER BY COD_REDE_LOCAL

),

DADOS_LOJAS_GERAL AS (

/*RELAÇÃO TOTAL LOJAS*/
SELECT
       COD_TIPO,
       'LOJAS' AS DES_TIPO,
       SUM(CON_ATIVOS) AS QTD_ATIVO,
       SUM(CON_AFAST) AS QTD_AFAST,
       SUM(CON_MATERN) AS QTD_MATERN,
       SUM(IND_PCD) AS QTD_PCD,

       /*QUANTIDADES DE CONTRATOS POR CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, HMT_120, 0)) AS QTD_120_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_150, 0)) AS QTD_150_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_165, 0)) AS QTD_165_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_180, 0)) AS QTD_180_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_195, 0)) AS QTD_195_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_220, 0)) AS QTD_220_ATIVO,

       /*QUANTIDADE DE CADA CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) AS QTD_HORAS_120,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) AS QTD_HORAS_150,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_165, 0)) AS QTD_hORAS_165,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) AS QTD_hORAS_180,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_195, 0)) AS QTD_hORAS_195,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_hORAS_220,

       /*TOTALIZADORES*/
       SUM(CON_ATIVOS) + SUM(CON_AFAST) AS QTD_CONT_TOTAL,
       SUM(HMT_120) AS HMT_120_TOTAL,
       SUM(HMT_150) AS HMT_150_TOTAL,
       SUM(HMT_165) AS HMT_165_TOTAL,
       SUM(HMT_180) AS HMT_180_TOTAL,
       SUM(HMT_195) AS HMT_195_TOTAL,
       SUM(HMT_220) AS HMT_220_TOTAL,

       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_165, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_195, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HMT_TOTAL,

       /*QUANTIDADE E PERCENTUAL POR SEXO*/
       SUM(QTD_MASC) AS QTD_MASC,
       ROUND((SUM(QTD_MASC) / COUNT(*) * 100), 2) AS PERC_MASC,
       SUM(QTD_FEM) AS QTD_FEM,
       ROUND((SUM(QTD_FEM) / COUNT(*) * 100), 2) AS PERC_FEM

  FROM (

SELECT DISTINCT A.STATUS,
                A.DESC_STATUS,
                A.COD_CONTRATO,
                A.DES_PESSOA,
                A.DATA_ADMISSAO,
                A.DATA_DEMISSAO,
                C.DES_FUNCAO,
                C.DATA_INI_CLH,
                C.DATA_FIM_CLH,
                --A.COD_VINCULO_EMPREG,
                A.SEXO,
                A.IND_DEFICIENCIA,
                A.COD_DEFICIENCIA,
                A.DES_DEFICIENCIA,

                B.HR_BASE_MES,
                B.DATA_INI_HR,
                B.DATA_FIM_HR,

                D.COD_EMP,
                D.EDICAO_ORG_2 || ' - ' || NOME2 AS EMPRESA,
                D.COD_UNIDADE,
                D.DES_UNIDADE,
                D.DATA_INI_ORG,
                D.DATA_FIM_ORG,
                D.COD_REDE,
                D.DES_REDE,
                --D.COD_REGIAO,
                --D.DES_REGIAO,
                D.COD_TIPO,
                D.DES_TIPO,

                E.COD_AFAST,
                E.DES_AFAST,
                E.DATA_INI_AFAST,
                E.DATA_FIM_AFAST,
                --E.COD_STATUS_AFAST,
                E.STATUS_AFAST,

                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN 1
                    ELSE 0
                END AS IND_PCD,

                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN 1
                    ELSE 0
                END AS HMT_120,
                CASE
                    WHEN B.HR_BASE_MES = 120 AND A.IND_DEFICIENCIA = 'S' THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_120,

                CASE
                    WHEN B.HR_BASE_MES = 150 THEN 1
                    ELSE 0
                END AS HMT_150,
                CASE
                    WHEN B.HR_BASE_MES = 150 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_150,

                CASE
                    WHEN B.HR_BASE_MES = 165 THEN 1
                    ELSE 0
                END AS HMT_165,
                CASE
                    WHEN B.HR_BASE_MES = 165 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_165,

                CASE
                    WHEN B.HR_BASE_MES = 180 THEN 1
                    ELSE 0
                END AS HMT_180,
                CASE
                    WHEN B.HR_BASE_MES = 180 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_180,

                CASE
                    WHEN B.HR_BASE_MES = 195 THEN 1
                    ELSE 0
                END AS HMT_195,
                CASE
                    WHEN B.HR_BASE_MES = 195 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_195,

                CASE
                    WHEN B.HR_BASE_MES = 220 THEN 1
                    ELSE 0
                END AS HMT_220,
                CASE
                    WHEN B.HR_BASE_MES = 220 THEN TO_NUMBER(B.HR_BASE_MES)
                    ELSE 0
                END AS QTD_HMT_220,

                CASE
                    WHEN A.COD_STATUS_AFAST IN (0, 6, 7) THEN 1
                    ELSE 0
                END AS CON_ATIVOS,
                CASE
                    WHEN A.COD_STATUS_AFAST NOT IN (0, 6, 7) THEN 1
                    ELSE 0
                END AS CON_AFAST,
                CASE
                    WHEN E.COD_AFAST = 3 THEN 1
                    ELSE 0
                END AS CON_MATERN,

                CASE
                    WHEN A.SEXO = 'M' THEN 1
                    ELSE 0
                END AS QTD_MASC,
                CASE
                    WHEN A.SEXO = 'F' THEN 1
                    ELSE 0
                END AS QTD_FEM

FROM VH_COLAB_PESSOA_AVT A
INNER JOIN VH_HIST_HORAS_COLAB_AVT B ON A.COD_CONTRATO = B.COD_CONTRATO
                                     AND (B.DATA_FIM_HR = '31/12/2999' OR B.DATA_FIM_HR > :DATA_REFERENCIA)
                                     AND (B.DATA_INI_HR  <= :DATA_REFERENCIA)
 LEFT JOIN VH_CARGO_CONTRATO_AVT C ON A.COD_CONTRATO = C.COD_CONTRATO
                                   AND (C.DATA_FIM_CLH = '31/12/2999' OR C.DATA_FIM_CLH > :DATA_REFERENCIA)
                                   AND (C.DATA_INI_CLH <= :DATA_REFERENCIA)
 LEFT JOIN VH_EST_ORG_CONTRATO_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
                                     AND (D.DATA_FIM_ORG = '31/12/2999' OR D.DATA_FIM_ORG > :DATA_REFERENCIA)
                                     AND (D.DATA_INI_ORG  <= :DATA_REFERENCIA)
 LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO = E.COD_CONTRATO
                                       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST > :DATA_REFERENCIA)
                                       AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
WHERE D.COD_EMP = 8
  --AND A.STATUS = 0
  AND D.COD_TIPO = 1
  AND C.COD_FUNCAO NOT IN (68, 71, 74, 75, 310, 409)

  AND (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO > :DATA_REFERENCIA)
  AND (A.DATA_ADMISSAO <= :DATA_REFERENCIA)

        )
 GROUP BY COD_TIPO, DES_TIPO

)

SELECT UNI.COD_UNIDADE,
       UNI.DES_UNIDADE,
       UNI.QTD_ATIVO AS QTD_ATIVO_LJ,
       UNI.QTD_AFAST AS QTD_AFAST_LJ,
       UNI.QTD_MATERN AS QTD_MATER_LJ,
       UNI.QTD_PCD AS QTD_PCD_LJ,
       'Referência: ' || TO_CHAR(:DATA_REFERENCIA, 'DD/MM/YYYY') AS REFERENCIA,

       /*QUANTIDADE DE CONTRATOS ATIVOS POR CARGA HORÁRIA*/
       UNI.QTD_120_ATIVO AS QTD_120_ATIVO_LJ,
       UNI.QTD_150_ATIVO AS QTD_150_ATIVO_LJ,
       UNI.QTD_165_ATIVO AS QTD_165_ATIVO_LJ,
       UNI.QTD_180_ATIVO AS QTD_180_ATIVO_LJ,
       UNI.QTD_195_ATIVO AS QTD_195_ATIVO_LJ,
       UNI.QTD_220_ATIVO AS QTD_220_ATIVO_LJ,

       UNI.QTD_HORAS_120 AS QTD_HORAS_120_LJ,
       UNI.QTD_HORAS_150 AS QTD_HORAS_150_LJ,
       UNI.QTD_HORAS_165 AS QTD_HORAS_165_LJ,
       UNI.QTD_HORAS_180 AS QTD_HORAS_180_LJ,
       UNI.QTD_HORAS_195 AS QTD_HORAS_195_LJ,
       UNI.QTD_HORAS_220 AS QTD_HORAS_220_LJ,

       UNI.QTD_HMT_TOTAL AS QTD_HMT_TOTAL_LJ,

       /*QUANTIDADE TOTAL  DE CONTRATOS POR CARGA HORÁRIA*/
       UNI.HMT_120_TOTAL AS HMT_120_TOTAL_LJ,
       UNI.HMT_150_TOTAL AS HMT_150_TOTAL_LJ,
       UNI.HMT_165_TOTAL AS HMT_165_TOTAL_LJ,
       UNI.HMT_180_TOTAL AS HMT_180_TOTAL_LJ,
       UNI.HMT_195_TOTAL AS HMT_195_TOTAL_LJ,
       UNI.HMT_220_TOTAL AS HMT_220_TOTAL_LJ,

       UNI.QTD_CONT_TOTAL AS QTD_CONT_TOTAL_LJ,

       UNI.QTD_MASC AS QTD_MASC_LJ,
       UNI.PERC_MASC AS PERC_MASC_LJ,
       UNI.QTD_FEM AS QTD_FEM_LJ,
       UNI.PERC_FEM AS PERC_FEM_LJ,

       /*REDES*/
       COALESCE(RE.COD_REDE || ' - ' || RE.DES_REDE, 'SEM REDE') AS REDE,
       --RE.COD_REDE_LOCAL || ' - ' || RE.DES_REDE_LOCAL AS REDE,
       RE.QTD_ATIVO AS QTD_ATIVO_RD,
       RE.QTD_AFAST AS QTD_AFAST_RD,
       RE.QTD_MATERN AS QTD_MATER_RD,
       RE.QTD_PCD AS QTD_PCD_RD,

       /*QUANTIDADE DE CONTRATOS ATIVOS POR CARGA HORÁRIA*/
       RE.QTD_120_ATIVO AS QTD_120_ATIVO_RD,
       RE.QTD_150_ATIVO AS QTD_150_ATIVO_RD,
       RE.QTD_165_ATIVO AS QTD_165_ATIVO_RD,
       RE.QTD_180_ATIVO AS QTD_180_ATIVO_RD,
       RE.QTD_195_ATIVO AS QTD_195_ATIVO_RD,
       RE.QTD_220_ATIVO AS QTD_220_ATIVO_RD,

       RE.QTD_HORAS_120 AS QTD_HORAS_120_RD,
       RE.QTD_HORAS_150 AS QTD_HORAS_150_RD,
       RE.QTD_HORAS_165 AS QTD_HORAS_165_RD,
       RE.QTD_HORAS_180 AS QTD_HORAS_180_RD,
       RE.QTD_HORAS_195 AS QTD_HORAS_195_RD,
       RE.QTD_HORAS_220 AS QTD_HORAS_220_RD,

       RE.QTD_HMT_TOTAL AS QTD_HMT_TOTAL_RD,

       /*QUANTIDADE TOTAL  DE CONTRATOS POR CARGA HORÁRIA*/
       RE.HMT_120_TOTAL AS HMT_120_TOTAL_RD,
       RE.HMT_150_TOTAL AS HMT_150_TOTAL_RD,
       RE.HMT_165_TOTAL AS HMT_165_TOTAL_RD,
       RE.HMT_180_TOTAL AS HMT_180_TOTAL_RD,
       RE.HMT_195_TOTAL AS HMT_195_TOTAL_RD,
       RE.HMT_220_TOTAL AS HMT_220_TOTAL_RD,


       RE.QTD_CONT_TOTAL AS QTD_CONT_TOTAL_RD,

       RE.QTD_MASC AS QTD_MASC_RD,
       RE.PERC_MASC AS PERC_MASC_RD,
       RE.QTD_FEM AS QTD_FEM_RD,
       RE.PERC_FEM AS PERC_FEM_RD,

       /*GERAL LOJAS*/
       COALESCE(LG.COD_TIPO || ' - ' || LG.DES_TIPO, 'SEM REDE') AS LOJAS,
       LG.QTD_ATIVO AS QTD_ATIVO_LJG,
       LG.QTD_AFAST AS QTD_AFAST_LJG,
       LG.QTD_MATERN AS QTD_MATER_LJG,
       LG.QTD_PCD AS QTD_PCD_LJG,

       /*QUANTIDADE DE CONTRATOS ATIVOS POR CARGA HORÁRIA*/
       LG.QTD_120_ATIVO AS QTD_120_ATIVO_LJG,
       LG.QTD_150_ATIVO AS QTD_150_ATIVO_LJG,
       LG.QTD_165_ATIVO AS QTD_165_ATIVO_LJG,
       LG.QTD_180_ATIVO AS QTD_180_ATIVO_LJG,
       LG.QTD_195_ATIVO AS QTD_195_ATIVO_LJG,
       LG.QTD_220_ATIVO AS QTD_220_ATIVO_LJG,

       LG.QTD_HORAS_120 AS QTD_HORAS_120_LJG,
       LG.QTD_HORAS_150 AS QTD_HORAS_150_LJG,
       LG.QTD_HORAS_165 AS QTD_HORAS_165_LJG,
       LG.QTD_HORAS_180 AS QTD_HORAS_180_LJG,
       LG.QTD_HORAS_195 AS QTD_HORAS_195_LJG,
       LG.QTD_HORAS_220 AS QTD_HORAS_220_LJG,

       LG.QTD_HMT_TOTAL AS QTD_HMT_TOTAL_LJG,

       /*QUANTIDADE TOTAL  DE CONTRATOS POR CARGA HORÁRIA*/
       LG.HMT_120_TOTAL AS HMT_120_TOTAL_LJG,
       LG.HMT_150_TOTAL AS HMT_150_TOTAL_LJG,
       LG.HMT_165_TOTAL AS HMT_165_TOTAL_LJG,
       LG.HMT_180_TOTAL AS HMT_180_TOTAL_LJG,
       LG.HMT_195_TOTAL AS HMT_195_TOTAL_LJG,
       LG.HMT_220_TOTAL AS HMT_220_TOTAL_LJG,


       LG.QTD_CONT_TOTAL AS QTD_CONT_TOTAL_LJG,

       LG.QTD_MASC AS QTD_MASC_LJG,
       LG.PERC_MASC AS PERC_MASC_LJG,
       LG.QTD_FEM AS QTD_FEM_LJG,
       LG.PERC_FEM AS PERC_FEM_LJG

FROM DADOS_UNIDADES UNI
JOIN DADOS_REDES RE ON UNI.COD_REDE = RE.COD_REDE
JOIN DADOS_LOJAS_GERAL LG ON UNI.COD_TIPO = LG.COD_TIPO
ORDER BY RE.COD_REDE, UNI.COD_UNIDADE




/*===========================================================================*/



/*RELATÓRIO GERAL DE HORAS ADM/CD*/

WITH DADOS_UNIDADES AS (

/*RELAÇÃO ABERTA POR SETOR*/
SELECT COD_EMP,
       COD_TIPO,
       COD_UNIDADE,
       DES_UNIDADE,
       CASE
           WHEN COD_REDE IS NULL THEN
            0
           ELSE
            TO_NUMBER(COD_REDE)
       END AS COD_REDE,
       CASE
           WHEN DES_REDE IS NULL THEN
            'SEM REDE'
           ELSE
            DES_REDE
       END AS DES_REDE,
       SUM(CON_ATIVOS) AS QTD_ATIVO,
       SUM(CON_AFAST) AS QTD_AFAST,
       SUM(CON_MATERN) AS QTD_MATERN,
       SUM(IND_PCD) AS QTD_PCD,

       /*QUANTIDADES DE CONTRATOS POR CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, HMT_100, 0)) AS QTD_100_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_120, 0)) AS QTD_120_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_125, 0)) AS QTD_125_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_150, 0)) AS QTD_150_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_180, 0)) AS QTD_180_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_220, 0)) AS QTD_220_ATIVO,

       /*QUANTIDADE DE CADA CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_100, 0)) AS QTD_HORAS_100,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) AS QTD_HORAS_120,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_125, 0)) AS QTD_HORAS_125,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) AS QTD_HORAS_150,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) AS QTD_HORAS_180,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HORAS_220,

       /*TOTALIZADORES*/
       SUM(CON_ATIVOS) + SUM(CON_AFAST) AS QTD_CONT_TOTAL,
       SUM(HMT_100) AS HMT_100_TOTAL,
       SUM(HMT_120) AS HMT_120_TOTAL,
       SUM(HMT_125) AS HMT_125_TOTAL,
       SUM(HMT_150) AS HMT_150_TOTAL,
       SUM(HMT_180) AS HMT_180_TOTAL,
       SUM(HMT_220) AS HMT_220_TOTAL,

       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_100, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_125, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HMT_TOTAL,

       /*QUANTIDADE E PERCENTUAL POR SEXO*/
       SUM(QTD_MASC) AS QTD_MASC,
       ROUND((SUM(QTD_MASC) / COUNT(*) * 100), 2) AS PERC_MASC,
       SUM(QTD_FEM) AS QTD_FEM,
       ROUND((SUM(QTD_FEM) / COUNT(*) * 100), 2) AS PERC_FEM


  FROM (

        SELECT DISTINCT A.STATUS,
                A.DESC_STATUS,
                A.COD_CONTRATO,
                A.DES_PESSOA,
                A.DATA_ADMISSAO,
                A.DATA_DEMISSAO,
                C.DES_FUNCAO,
                C.DATA_INI_CLH,
                C.DATA_FIM_CLH,
                --A.COD_VINCULO_EMPREG,
                A.SEXO,
                A.IND_DEFICIENCIA,
                A.COD_DEFICIENCIA,
                A.DES_DEFICIENCIA,

                B.HR_BASE_MES,
                B.DATA_INI_HR,
                B.DATA_FIM_HR,

                D.COD_EMP,
                D.EDICAO_ORG_2 || ' - ' || NOME2 AS EMPRESA,
                D.COD_UNIDADE,
                D.DES_UNIDADE,
                D.DATA_INI_ORG,
                D.DATA_FIM_ORG,
                D.COD_REDE,
                D.DES_REDE,
                --D.COD_REGIAO,
                --D.DES_REGIAO,
                D.COD_TIPO,
                D.DES_TIPO,

                E.COD_AFAST,
                E.DES_AFAST,
                E.DATA_INI_AFAST,
                E.DATA_FIM_AFAST,
                --E.COD_STATUS_AFAST,
                E.STATUS_AFAST,

                         CASE
                           WHEN A.IND_DEFICIENCIA = 'S' THEN
                            1
                           ELSE
                            0
                         END AS IND_PCD,

                         CASE
                           WHEN B.HR_BASE_MES = 100 THEN
                            1
                           ELSE
                            0
                         END AS HMT_100,
                         CASE
                           WHEN B.HR_BASE_MES = 100 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_100,

                         CASE
                           WHEN B.HR_BASE_MES = 120 THEN
                            1
                           ELSE
                            0
                         END AS HMT_120,
                         CASE
                           WHEN B.HR_BASE_MES = 120 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_120,

                         CASE
                           WHEN B.HR_BASE_MES = 125 THEN
                            1
                           ELSE
                            0
                         END AS HMT_125,
                         CASE
                           WHEN B.HR_BASE_MES = 125 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_125,

                         CASE
                           WHEN B.HR_BASE_MES = 150 THEN
                            1
                           ELSE
                            0
                         END AS HMT_150,
                         CASE
                           WHEN B.HR_BASE_MES = 150 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_150,

                         CASE
                           WHEN B.HR_BASE_MES = 180 THEN
                            1
                           ELSE
                            0
                         END AS HMT_180,
                         CASE
                           WHEN B.HR_BASE_MES = 180  THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_180,

                         CASE
                           WHEN B.HR_BASE_MES = 220 THEN
                            1
                           ELSE
                            0
                         END AS HMT_220,
                         CASE
                           WHEN B.HR_BASE_MES = 220 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_220,

                         CASE
                           WHEN A.COD_STATUS_AFAST IN (0, 6, 7) THEN
                            1
                           ELSE
                            0
                         END AS CON_ATIVOS,
                         CASE
                           WHEN A.COD_STATUS_AFAST NOT IN (0, 6, 7) THEN
                            1
                           ELSE
                            0
                         END AS CON_AFAST,
                         CASE
                           WHEN A.COD_AFAST = 3 THEN
                            1
                           ELSE
                            0
                         END AS CON_MATERN,

                         CASE
                           WHEN A.SEXO = 'M' THEN
                            1
                           ELSE
                            0
                         END AS QTD_MASC,
                         CASE
                           WHEN A.SEXO = 'F' THEN
                            1
                           ELSE
                            0
                         END AS QTD_FEM

FROM VH_COLAB_PESSOA_AVT A
INNER JOIN VH_HIST_HORAS_COLAB_AVT B ON A.COD_CONTRATO = B.COD_CONTRATO
                                     AND (B.DATA_FIM_HR = '31/12/2999' OR B.DATA_FIM_HR > :DATA_REFERENCIA)
                                     AND (B.DATA_INI_HR  <= :DATA_REFERENCIA)
 LEFT JOIN VH_CARGO_CONTRATO_AVT C ON A.COD_CONTRATO = C.COD_CONTRATO
                                   AND (C.DATA_FIM_CLH = '31/12/2999' OR C.DATA_FIM_CLH > :DATA_REFERENCIA)
                                   AND (C.DATA_INI_CLH <= :DATA_REFERENCIA)
 LEFT JOIN VH_EST_ORG_CONTRATO_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
                                     AND (D.DATA_FIM_ORG = '31/12/2999' OR D.DATA_FIM_ORG > :DATA_REFERENCIA)
                                     AND (D.DATA_INI_ORG  <= :DATA_REFERENCIA)
 LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO = E.COD_CONTRATO
                                       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST > :DATA_REFERENCIA)
                                       AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
WHERE D.COD_EMP = 8
  --AND A.STATUS = 0
  AND D.COD_TIPO IN (2,3)
  AND C.COD_FUNCAO NOT IN (68, 71, 74, 75, 310, 409)

  AND (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO > :DATA_REFERENCIA)
  AND (A.DATA_ADMISSAO <= :DATA_REFERENCIA)

        )
 GROUP BY COD_TIPO, COD_UNIDADE, DES_UNIDADE, COD_REDE, DES_REDE, COD_EMP
 --ORDER BY COD_REDE_LOCAL, COD_UNIDADE

),

DADOS_REDES AS (

/*RELAÇÃO ABERTA POR REDE*/
SELECT
       CASE
           WHEN COD_REDE IS NULL THEN
            0
           ELSE
            TO_NUMBER(COD_REDE)
       END AS COD_REDE,
       CASE
           WHEN DES_REDE IS NULL THEN
            'SEM REDE'
           ELSE
            DES_REDE
       END AS DES_REDE,
       SUM(CON_ATIVOS) AS QTD_ATIVO,
       SUM(CON_AFAST) AS QTD_AFAST,
       SUM(CON_MATERN) AS QTD_MATERN,
       SUM(IND_PCD) AS QTD_PCD,

       /*QUANTIDADES DE CONTRATOS POR CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, HMT_100, 0)) AS QTD_100_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_120, 0)) AS QTD_120_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_125, 0)) AS QTD_125_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_150, 0)) AS QTD_150_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_180, 0)) AS QTD_180_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_220, 0)) AS QTD_220_ATIVO,

       /*QUANTIDADE DE CADA CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_100, 0)) AS QTD_HORAS_100,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) AS QTD_HORAS_120,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_125, 0)) AS QTD_HORAS_125,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) AS QTD_HORAS_150,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) AS QTD_HORAS_180,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HORAS_220,

       /*TOTALIZADORES*/
       SUM(CON_ATIVOS) + SUM(CON_AFAST) AS QTD_CONT_TOTAL,
       SUM(HMT_100) AS HMT_100_TOTAL,
       SUM(HMT_120) AS HMT_120_TOTAL,
       SUM(HMT_125) AS HMT_125_TOTAL,
       SUM(HMT_150) AS HMT_150_TOTAL,
       SUM(HMT_180) AS HMT_180_TOTAL,
       SUM(HMT_220) AS HMT_220_TOTAL,

       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_100, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_125, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HMT_TOTAL,

       /*QUANTIDADE E PERCENTUAL POR SEXO*/
       SUM(QTD_MASC) AS QTD_MASC,
       ROUND((SUM(QTD_MASC) / COUNT(*) * 100), 2) AS PERC_MASC,
       SUM(QTD_FEM) AS QTD_FEM,
       ROUND((SUM(QTD_FEM) / COUNT(*) * 100), 2) AS PERC_FEM

  FROM (

        SELECT DISTINCT A.STATUS,
                A.DESC_STATUS,
                A.COD_CONTRATO,
                A.DES_PESSOA,
                A.DATA_ADMISSAO,
                A.DATA_DEMISSAO,
                C.DES_FUNCAO,
                C.DATA_INI_CLH,
                C.DATA_FIM_CLH,
                --A.COD_VINCULO_EMPREG,
                A.SEXO,
                A.IND_DEFICIENCIA,
                A.COD_DEFICIENCIA,
                A.DES_DEFICIENCIA,

                B.HR_BASE_MES,
                B.DATA_INI_HR,
                B.DATA_FIM_HR,

                D.COD_EMP,
                D.EDICAO_ORG_2 || ' - ' || NOME2 AS EMPRESA,
                D.COD_UNIDADE,
                D.DES_UNIDADE,
                D.DATA_INI_ORG,
                D.DATA_FIM_ORG,
                D.COD_REDE,
                D.DES_REDE,
                --D.COD_REGIAO,
                --D.DES_REGIAO,
                D.COD_TIPO,
                D.DES_TIPO,

                E.COD_AFAST,
                E.DES_AFAST,
                E.DATA_INI_AFAST,
                E.DATA_FIM_AFAST,
                --E.COD_STATUS_AFAST,
                E.STATUS_AFAST,

                         CASE
                           WHEN A.IND_DEFICIENCIA = 'S' THEN
                            1
                           ELSE
                            0
                         END AS IND_PCD,

                         CASE
                           WHEN B.HR_BASE_MES = 100 THEN
                            1
                           ELSE
                            0
                         END AS HMT_100,
                         CASE
                           WHEN B.HR_BASE_MES = 100 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_100,

                         CASE
                           WHEN B.HR_BASE_MES = 120 THEN
                            1
                           ELSE
                            0
                         END AS HMT_120,
                         CASE
                           WHEN B.HR_BASE_MES = 120 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_120,

                         CASE
                           WHEN B.HR_BASE_MES = 125 THEN
                            1
                           ELSE
                            0
                         END AS HMT_125,
                         CASE
                           WHEN B.HR_BASE_MES = 125 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_125,

                         CASE
                           WHEN B.HR_BASE_MES = 150 THEN
                            1
                           ELSE
                            0
                         END AS HMT_150,
                         CASE
                           WHEN B.HR_BASE_MES = 150 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_150,

                         CASE
                           WHEN B.HR_BASE_MES = 180 THEN
                            1
                           ELSE
                            0
                         END AS HMT_180,
                         CASE
                           WHEN B.HR_BASE_MES = 180  THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_180,

                         CASE
                           WHEN B.HR_BASE_MES = 220 THEN
                            1
                           ELSE
                            0
                         END AS HMT_220,
                         CASE
                           WHEN B.HR_BASE_MES = 220 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_220,

                         CASE
                           WHEN A.COD_STATUS_AFAST IN (0, 6, 7) THEN
                            1
                           ELSE
                            0
                         END AS CON_ATIVOS,
                         CASE
                           WHEN A.COD_STATUS_AFAST NOT IN (0, 6, 7) THEN
                            1
                           ELSE
                            0
                         END AS CON_AFAST,
                         CASE
                           WHEN A.COD_AFAST = 3 THEN
                            1
                           ELSE
                            0
                         END AS CON_MATERN,

                         CASE
                           WHEN A.SEXO = 'M' THEN
                            1
                           ELSE
                            0
                         END AS QTD_MASC,
                         CASE
                           WHEN A.SEXO = 'F' THEN
                            1
                           ELSE
                            0
                         END AS QTD_FEM

FROM VH_COLAB_PESSOA_AVT A
INNER JOIN VH_HIST_HORAS_COLAB_AVT B ON A.COD_CONTRATO = B.COD_CONTRATO
                                     AND (B.DATA_FIM_HR = '31/12/2999' OR B.DATA_FIM_HR > :DATA_REFERENCIA)
                                     AND (B.DATA_INI_HR  <= :DATA_REFERENCIA)
 LEFT JOIN VH_CARGO_CONTRATO_AVT C ON A.COD_CONTRATO = C.COD_CONTRATO
                                   AND (C.DATA_FIM_CLH = '31/12/2999' OR C.DATA_FIM_CLH > :DATA_REFERENCIA)
                                   AND (C.DATA_INI_CLH <= :DATA_REFERENCIA)
 LEFT JOIN VH_EST_ORG_CONTRATO_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
                                     AND (D.DATA_FIM_ORG = '31/12/2999' OR D.DATA_FIM_ORG > :DATA_REFERENCIA)
                                     AND (D.DATA_INI_ORG  <= :DATA_REFERENCIA)
 LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO = E.COD_CONTRATO
                                       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST > :DATA_REFERENCIA)
                                       AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
WHERE D.COD_EMP = 8
  --AND A.STATUS = 0
  AND D.COD_TIPO IN (2,3)
  AND C.COD_FUNCAO NOT IN (68, 71, 74, 75, 310, 409)

  AND (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO > :DATA_REFERENCIA)
  AND (A.DATA_ADMISSAO <= :DATA_REFERENCIA)

        )
 GROUP BY COD_REDE, DES_REDE
 --ORDER BY COD_REDE_LOCAL

),

DADOS_ADM_CD AS (

/*RELAÇÃO GERAL DO ADM + CD*/
SELECT
       COD_EMP,
       NOME2 AS DES_EMPRESA,
       SUM(CON_ATIVOS) AS QTD_ATIVO,
       SUM(CON_AFAST) AS QTD_AFAST,
       SUM(CON_MATERN) AS QTD_MATERN,
       SUM(IND_PCD) AS QTD_PCD,

       /*QUANTIDADES DE CONTRATOS POR CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, HMT_100, 0)) AS QTD_100_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_120, 0)) AS QTD_120_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_125, 0)) AS QTD_125_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_150, 0)) AS QTD_150_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_180, 0)) AS QTD_180_ATIVO,
       SUM(DECODE(CON_ATIVOS, 1, HMT_220, 0)) AS QTD_220_ATIVO,

       /*QUANTIDADE DE CADA CARGA HORÁRIA*/
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_100, 0)) AS QTD_HORAS_100,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) AS QTD_HORAS_120,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_125, 0)) AS QTD_HORAS_125,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) AS QTD_HORAS_150,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) AS QTD_HORAS_180,
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HORAS_220,

       /*TOTALIZADORES*/
       SUM(CON_ATIVOS) + SUM(CON_AFAST) AS QTD_CONT_TOTAL,
       SUM(HMT_100) AS HMT_100_TOTAL,
       SUM(HMT_120) AS HMT_120_TOTAL,
       SUM(HMT_125) AS HMT_125_TOTAL,
       SUM(HMT_150) AS HMT_150_TOTAL,
       SUM(HMT_180) AS HMT_180_TOTAL,
       SUM(HMT_220) AS HMT_220_TOTAL,

       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_100, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_120, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_125, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_150, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_180, 0)) +
       SUM(DECODE(CON_ATIVOS, 1, QTD_HMT_220, 0)) AS QTD_HMT_TOTAL,

       /*QUANTIDADE E PERCENTUAL POR SEXO*/
       SUM(QTD_MASC) AS QTD_MASC,
       ROUND((SUM(QTD_MASC) / COUNT(*) * 100), 2) AS PERC_MASC,
       SUM(QTD_FEM) AS QTD_FEM,
       ROUND((SUM(QTD_FEM) / COUNT(*) * 100), 2) AS PERC_FEM

  FROM (

        SELECT DISTINCT A.STATUS,
                A.DESC_STATUS,
                A.COD_CONTRATO,
                A.DES_PESSOA,
                A.DATA_ADMISSAO,
                A.DATA_DEMISSAO,
                C.DES_FUNCAO,
                C.DATA_INI_CLH,
                C.DATA_FIM_CLH,
                --A.COD_VINCULO_EMPREG,
                A.SEXO,
                A.IND_DEFICIENCIA,
                A.COD_DEFICIENCIA,
                A.DES_DEFICIENCIA,

                B.HR_BASE_MES,
                B.DATA_INI_HR,
                B.DATA_FIM_HR,

                D.COD_EMP,
                D.NOME2,
                D.EDICAO_ORG_2 || ' - ' || NOME2 AS EMPRESA,
                D.COD_UNIDADE,
                D.DES_UNIDADE,
                D.DATA_INI_ORG,
                D.DATA_FIM_ORG,
                D.COD_REDE,
                D.DES_REDE,
                --D.COD_REGIAO,
                --D.DES_REGIAO,
                D.COD_TIPO,
                D.DES_TIPO,

                E.COD_AFAST,
                E.DES_AFAST,
                E.DATA_INI_AFAST,
                E.DATA_FIM_AFAST,
                --E.COD_STATUS_AFAST,
                E.STATUS_AFAST,

                         CASE
                           WHEN A.IND_DEFICIENCIA = 'S' THEN
                            1
                           ELSE
                            0
                         END AS IND_PCD,

                         CASE
                           WHEN B.HR_BASE_MES = 100 THEN
                            1
                           ELSE
                            0
                         END AS HMT_100,
                         CASE
                           WHEN B.HR_BASE_MES = 100 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_100,

                         CASE
                           WHEN B.HR_BASE_MES = 120 THEN
                            1
                           ELSE
                            0
                         END AS HMT_120,
                         CASE
                           WHEN B.HR_BASE_MES = 120 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_120,

                         CASE
                           WHEN B.HR_BASE_MES = 125 THEN
                            1
                           ELSE
                            0
                         END AS HMT_125,
                         CASE
                           WHEN B.HR_BASE_MES = 125 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_125,

                         CASE
                           WHEN B.HR_BASE_MES = 150 THEN
                            1
                           ELSE
                            0
                         END AS HMT_150,
                         CASE
                           WHEN B.HR_BASE_MES = 150 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_150,

                         CASE
                           WHEN B.HR_BASE_MES = 180 THEN
                            1
                           ELSE
                            0
                         END AS HMT_180,
                         CASE
                           WHEN B.HR_BASE_MES = 180  THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_180,

                         CASE
                           WHEN B.HR_BASE_MES = 220 THEN
                            1
                           ELSE
                            0
                         END AS HMT_220,
                         CASE
                           WHEN B.HR_BASE_MES = 220 THEN
                            TO_NUMBER(B.HR_BASE_MES)
                           ELSE
                            0
                         END AS QTD_HMT_220,

                         CASE
                           WHEN A.COD_STATUS_AFAST IN (0, 6, 7) THEN
                            1
                           ELSE
                            0
                         END AS CON_ATIVOS,
                         CASE
                           WHEN A.COD_STATUS_AFAST NOT IN (0, 6, 7) THEN
                            1
                           ELSE
                            0
                         END AS CON_AFAST,
                         CASE
                           WHEN A.COD_AFAST = 3 THEN
                            1
                           ELSE
                            0
                         END AS CON_MATERN,

                         CASE
                           WHEN A.SEXO = 'M' THEN
                            1
                           ELSE
                            0
                         END AS QTD_MASC,
                         CASE
                           WHEN A.SEXO = 'F' THEN
                            1
                           ELSE
                            0
                         END AS QTD_FEM

FROM VH_COLAB_PESSOA_AVT A
INNER JOIN VH_HIST_HORAS_COLAB_AVT B ON A.COD_CONTRATO = B.COD_CONTRATO
                                     AND (B.DATA_FIM_HR = '31/12/2999' OR B.DATA_FIM_HR > :DATA_REFERENCIA)
                                     AND (B.DATA_INI_HR  <= :DATA_REFERENCIA)
 LEFT JOIN VH_CARGO_CONTRATO_AVT C ON A.COD_CONTRATO = C.COD_CONTRATO
                                   AND (C.DATA_FIM_CLH = '31/12/2999' OR C.DATA_FIM_CLH > :DATA_REFERENCIA)
                                   AND (C.DATA_INI_CLH <= :DATA_REFERENCIA)
 LEFT JOIN VH_EST_ORG_CONTRATO_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
                                     AND (D.DATA_FIM_ORG = '31/12/2999' OR D.DATA_FIM_ORG > :DATA_REFERENCIA)
                                     AND (D.DATA_INI_ORG  <= :DATA_REFERENCIA)
 LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO = E.COD_CONTRATO
                                       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST > :DATA_REFERENCIA)
                                       AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
WHERE D.COD_EMP = 8
  --AND A.STATUS = 0
  AND D.COD_TIPO NOT IN (1)
  AND C.COD_FUNCAO NOT IN (68, 71, 74, 75, 310, 409)

  AND (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO > :DATA_REFERENCIA)
  AND (A.DATA_ADMISSAO <= :DATA_REFERENCIA)

        )
 GROUP BY COD_EMP, NOME2
 --ORDER BY COD_REDE_LOCAL

)

SELECT UNI.COD_TIPO,
       UNI.COD_UNIDADE,
       UNI.DES_UNIDADE,
       UNI.QTD_ATIVO AS QTD_ATIVO_LJ,
       UNI.QTD_AFAST AS QTD_AFAST_LJ,
       UNI.QTD_MATERN AS QTD_MATER_LJ,
       UNI.QTD_PCD AS QTD_PCD_LJ,
       'Referência: ' || TO_CHAR(:DATA_REFERENCIA, 'DD/MM/YYYY') AS REFERENCIA,

       /*QUANTIDADE DE CONTRATOS ATIVOS POR CARGA HORÁRIA*/
       UNI.QTD_100_ATIVO AS QTD_100_ATIVO_LJ,
       UNI.QTD_120_ATIVO AS QTD_120_ATIVO_LJ,
       UNI.QTD_125_ATIVO AS QTD_125_ATIVO_LJ,
       UNI.QTD_150_ATIVO AS QTD_150_ATIVO_LJ,
       UNI.QTD_180_ATIVO AS QTD_180_ATIVO_LJ,
       UNI.QTD_220_ATIVO AS QTD_220_ATIVO_LJ,

       UNI.QTD_HORAS_100 AS QTD_HORAS_100_LJ,
       UNI.QTD_HORAS_120 AS QTD_HORAS_120_LJ,
       UNI.QTD_HORAS_125 AS QTD_HORAS_125_LJ,
       UNI.QTD_HORAS_150 AS QTD_HORAS_150_LJ,
       UNI.QTD_HORAS_180 AS QTD_HORAS_180_LJ,
       UNI.QTD_HORAS_220 AS QTD_HORAS_220_LJ,

       UNI.QTD_HMT_TOTAL AS QTD_HMT_TOTAL_LJ,

       /*QUANTIDADE TOTAL  DE CONTRATOS POR CARGA HORÁRIA*/
       UNI.HMT_100_TOTAL AS HMT_100_TOTAL_LJ,
       UNI.HMT_120_TOTAL AS HMT_120_TOTAL_LJ,
       UNI.HMT_125_TOTAL AS HMT_125_TOTAL_LJ,
       UNI.HMT_150_TOTAL AS HMT_150_TOTAL_LJ,
       UNI.HMT_180_TOTAL AS HMT_180_TOTAL_LJ,
       UNI.HMT_220_TOTAL AS HMT_220_TOTAL_LJ,

       UNI.QTD_CONT_TOTAL AS QTD_CONT_TOTAL_LJ,

       UNI.QTD_MASC AS QTD_MASC_LJ,
       UNI.PERC_MASC AS PERC_MASC_LJ,
       UNI.QTD_FEM AS QTD_FEM_LJ,
       UNI.PERC_FEM AS PERC_FEM_LJ,

       /*REDES*/
       COALESCE(RE.COD_REDE || ' - ' || RE.DES_REDE, 'SEM REDE') AS REDE,
       --RE.COD_REDE_LOCAL || ' - ' || RE.DES_REDE_LOCAL AS REDE,
       RE.QTD_ATIVO AS QTD_ATIVO_RD,
       RE.QTD_AFAST AS QTD_AFAST_RD,
       RE.QTD_MATERN AS QTD_MATER_RD,
       RE.QTD_PCD AS QTD_PCD_RD,

       /*QUANTIDADE DE CONTRATOS ATIVOS POR CARGA HORÁRIA*/
       RE.QTD_100_ATIVO AS QTD_100_ATIVO_RD,
       RE.QTD_120_ATIVO AS QTD_120_ATIVO_RD,
       RE.QTD_125_ATIVO AS QTD_125_ATIVO_RD,
       RE.QTD_150_ATIVO AS QTD_150_ATIVO_RD,
       RE.QTD_180_ATIVO AS QTD_180_ATIVO_RD,
       RE.QTD_220_ATIVO AS QTD_220_ATIVO_RD,

       RE.QTD_HORAS_100 AS QTD_HORAS_100_RD,
       RE.QTD_HORAS_120 AS QTD_HORAS_120_RD,
       RE.QTD_HORAS_125 AS QTD_HORAS_125_RD,
       RE.QTD_HORAS_150 AS QTD_HORAS_150_RD,
       RE.QTD_HORAS_180 AS QTD_HORAS_180_RD,
       RE.QTD_HORAS_220 AS QTD_HORAS_220_RD,

       RE.QTD_HMT_TOTAL AS QTD_HMT_TOTAL_RD,

       /*QUANTIDADE TOTAL  DE CONTRATOS POR CARGA HORÁRIA*/
       RE.HMT_100_TOTAL AS HMT_100_TOTAL_RD,
       RE.HMT_120_TOTAL AS HMT_120_TOTAL_RD,
       RE.HMT_125_TOTAL AS HMT_125_TOTAL_RD,
       RE.HMT_150_TOTAL AS HMT_150_TOTAL_RD,
       RE.HMT_180_TOTAL AS HMT_180_TOTAL_RD,
       RE.HMT_220_TOTAL AS HMT_220_TOTAL_RD,


       RE.QTD_CONT_TOTAL AS QTD_CONT_TOTAL_RD,

       RE.QTD_MASC AS QTD_MASC_RD,
       RE.PERC_MASC AS PERC_MASC_RD,
       RE.QTD_FEM AS QTD_FEM_RD,
       RE.PERC_FEM AS PERC_FEM_RD,
       
       /*ADM + CD*/
       COALESCE(AC.COD_EMP || ' - ' || AC.DES_EMPRESA, 'SEM REDE') AS REDE,
       --RE.COD_REDE_LOCAL || ' - ' || RE.DES_REDE_LOCAL AS REDE,
       AC.QTD_ATIVO AS QTD_ATIVO_ST,
       AC.QTD_AFAST AS QTD_AFAST_ST,
       AC.QTD_MATERN AS QTD_MATER_ST,
       AC.QTD_PCD AS QTD_PCD_ST,

       /*QUANTIDADE DE CONTRATOS ATIVOS POR CARGA HORÁRIA*/
       AC.QTD_100_ATIVO AS QTD_100_ATIVO_ST,
       AC.QTD_120_ATIVO AS QTD_120_ATIVO_ST,
       AC.QTD_125_ATIVO AS QTD_125_ATIVO_ST,
       AC.QTD_150_ATIVO AS QTD_150_ATIVO_ST,
       AC.QTD_180_ATIVO AS QTD_180_ATIVO_ST,
       AC.QTD_220_ATIVO AS QTD_220_ATIVO_ST,

       AC.QTD_HORAS_100 AS QTD_HORAS_100_ST,
       AC.QTD_HORAS_120 AS QTD_HORAS_120_ST,
       AC.QTD_HORAS_125 AS QTD_HORAS_125_ST,
       AC.QTD_HORAS_150 AS QTD_HORAS_150_ST,
       AC.QTD_HORAS_180 AS QTD_HORAS_180_ST,
       AC.QTD_HORAS_220 AS QTD_HORAS_220_ST,

       AC.QTD_HMT_TOTAL AS QTD_HMT_TOTAL_ST,

       /*QUANTIDADE TOTAL  DE CONTRATOS POR CARGA HORÁRIA*/
       AC.HMT_100_TOTAL AS HMT_100_TOTAL_ST,
       AC.HMT_120_TOTAL AS HMT_120_TOTAL_ST,
       AC.HMT_125_TOTAL AS HMT_125_TOTAL_ST,
       AC.HMT_150_TOTAL AS HMT_150_TOTAL_ST,
       AC.HMT_180_TOTAL AS HMT_180_TOTAL_ST,
       AC.HMT_220_TOTAL AS HMT_220_TOTAL_ST,


       AC.QTD_CONT_TOTAL AS QTD_CONT_TOTAL_ST,

       AC.QTD_MASC AS QTD_MASC_ST,
       AC.PERC_MASC AS PERC_MASC_ST,
       AC.QTD_FEM AS QTD_FEM_ST,
       AC.PERC_FEM AS PERC_FEM_ST

FROM DADOS_UNIDADES UNI
JOIN DADOS_REDES RE ON UNI.COD_REDE = RE.COD_REDE
JOIN DADOS_ADM_CD AC ON UNI.COD_EMP = AC.COD_EMP
ORDER BY
  CASE
    -- TIPO 2 - Unidades normais (exceto regiões) aparecem primeiro
    WHEN UNI.COD_TIPO = 2 AND UNI.COD_UNIDADE NOT IN (871, 907) AND UNI.COD_UNIDADE NOT BETWEEN 8701 AND 8717 THEN 1
    -- TIPO 2 - Unidades 871 e 907 aparecem logo depois
    WHEN UNI.COD_TIPO = 2 AND UNI.COD_UNIDADE IN (871, 907) THEN 2
    -- TIPO 2 - Regiões (8701 a 8717) aparecem por último dentro do TIPO 2
    WHEN UNI.COD_TIPO = 2 AND UNI.COD_UNIDADE BETWEEN 8701 AND 8717 THEN 3
    -- TIPO 3 sempre vem depois de todo o TIPO 2
    WHEN UNI.COD_TIPO = 3 THEN 4
    -- Outros tipos seguem a ordem padrão (se existirem)
    ELSE 5
  END,
  UNI.COD_TIPO,  -- Mantém a organização geral por tipo
  UNI.COD_UNIDADE -- Ordena dentro do mesmo tipo
