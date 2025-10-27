WITH
/* BLOCO PARA ENTRADA DE PARÂMETROS (DINÂMICO POR PERÍODO) */
PARAMS AS (

/*VERSÃO PARA USAR NO PL/SQL*/
  /*SELECT TO_DATE('&DATA_INICIO', 'DD/MM/YYYY') AS DATA_INICIO,
       TO_DATE('&DATA_FIM', 'DD/MM/YYYY') AS DATA_FIM
  FROM DUAL*/

/*  SELECT --:REFERENCIA AS REFERENCIA
         TO_DATE('&REFERENCIA', 'DD/MM/YYYY') AS REFERENCIA
  FROM DUAL*/


/*VERSÃO PARA USAR NO SAPINHO E DENTRO DA FOLHA*/
SELECT :DATA_INICIO AS DATA_INICIO,
       :DATA_FIM AS DATA_FIM
FROM DUAL

),

CONTRATOS AS (
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
  JOIN VH_EST_ORG_CONTRATO_AVT ORG ON CT.COD_CONTRATO = ORG.COD_CONTRATO
  JOIN VH_HIST_HORAS_COLAB_AVT HR ON CT.COD_CONTRATO = HR.COD_CONTRATO
  JOIN VH_CARGO_CONTRATO_AVT FN ON CT.COD_CONTRATO = FN.COD_CONTRATO
 CROSS JOIN PARAMS P
 WHERE CT.DATA_ADMISSAO <= P.DATA_FIM
  AND NVL(CT.DATA_DEMISSAO, DATE '2999-12-31') >= P.DATA_INICIO

/* CT.DATA_ADMISSAO <= P.DATA_INICIO
 AND NVL(CT.DATA_DEMISSAO, DATE '2999-12-31') >= P.DATA_FIM*/
 --AND P.REFERENCIA BETWEEN CT.DATA_ADMISSAO AND NVL(CT.DATA_DEMISSAO, DATE '2999-12-31')
/*VERSÕES ALTERNATIVAS DE FILTRAR POR DATA
(('31/03/2025' BETWEEN CT.DATA_ADMISSAO AND CT.DATA_DEMISSAO) OR
        (CT.DATA_ADMISSAO <= '31/03/2025' AND CT.DATA_DEMISSAO IS NULL))
AND (CT.DATA_ADMISSAO <= TO_DATE('31/07/2025','DD/MM/YYYY'))
   AND (CT.DATA_DEMISSAO IS NULL OR CT.DATA_DEMISSAO >= TO_DATE('01/07/2025','DD/MM/YYYY'))
AND (CT.DATA_DEMISSAO IS NULL OR
       CT.DATA_DEMISSAO >= '01/07/2025')*/

/* AND P.REFERENCIA BETWEEN ORG.DATA_INI_ORG AND ORG.DATA_FIM_ORG
 AND P.REFERENCIA BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH
 AND P.REFERENCIA BETWEEN HR.DATA_INI_HR AND HR.DATA_FIM_HR*/

  AND ORG.DATA_INI_ORG <= P.DATA_FIM AND ORG.DATA_FIM_ORG >= P.DATA_INICIO
  AND FN.DATA_INI_CLH  <= P.DATA_FIM AND FN.DATA_FIM_CLH  >= P.DATA_INICIO
  AND HR.DATA_INI_HR   <= P.DATA_FIM AND HR.DATA_FIM_HR   >= P.DATA_INICIO
  --AND (ORG.COD_EMP = &EMPRESA OR &EMPRESA = 0)
  AND (ORG.COD_EMP = :EMPRESA OR :EMPRESA = 0)
 --AND ORG.COD_TIPO = 1
 AND ORG.EDICAO_ORG_4 IS NOT NULL
--AND ORG.COD_UNIDADE NOT IN (014, 050, 615, 7586, 7608)
--AND ORG.COD_UNIDADE = 004
 ORDER BY CT.COD_CONTRATO

),

--SELECT * FROM CONTRATOS

/*==== MAPEIA TODOS OS COLABORADORES MAS TAMBÉM COM INFO DE AFASTAMENTO ====*/
STATUS_AFASTADOS AS (
SELECT DISTINCT ORG.COD_EMP,
                CT.COD_CONTRATO,
                ORG.COD_ORGANOGRAMA,
                ORG.COD_UNIDADE,
                NVL(AF.COD_CAUSA_AFAST, 0) AS STATUS_AFAST,
                DES.NOME_CAUSA_AFAST AS DES_AFAST,
                AF.DATA_INICIO AS DATA_INI_AFAST,
                AF.DATA_FIM AS DATA_FIM_AFAST
  FROM RHFP0306                AF,
       RHFP0300                CT,
       VH_EST_ORG_CONTRATO_AVT ORG,
       VH_CARGO_CONTRATO_AVT   FN,
       RHFP0100                DES,
       PARAMS                  P
 WHERE CT.COD_CONTRATO = AF.COD_CONTRATO(+)
   AND CT.COD_CONTRATO = ORG.COD_CONTRATO(+)
   AND CT.COD_CONTRATO = FN.COD_CONTRATO(+)
   AND AF.COD_CAUSA_AFAST = DES.COD_CAUSA_AFAST(+)
   AND P.DATA_FIM BETWEEN CT.DATA_INICIO AND NVL(CT.DATA_FIM, DATE '2999-12-31')
   /*AND CT.DATA_INICIO <= M.DTA_FIM
   AND NVL(CT.DATA_FIM, DATE '2999-12-31') >= M.DTA_INI*/
      /* AND (CT.DATA_INICIO <= '31/03/2025')
         AND (CT.DATA_INICIO IS NULL OR CT.DATA_FIM >= '01/01/2025')*/
   AND P.DATA_FIM BETWEEN AF.DATA_INICIO(+) AND AF.DATA_FIM(+)
   AND P.DATA_FIM BETWEEN ORG.DATA_INI_ORG(+) AND ORG.DATA_FIM_ORG(+)
   AND P.DATA_FIM BETWEEN AF.DATA_INICIO AND NVL(AF.DATA_FIM, DATE '2999-12-31')
   --AND (ORG.COD_EMP = &EMPRESA OR &EMPRESA = 0)
   AND (ORG.COD_EMP = :EMPRESA OR :EMPRESA = 0)
   --AND ORG.COD_TIPO = 1
--AND ORG.COD_UNIDADE NOT IN (014, 050, 615, 7586, 7608)

),

VALORES_ECONSIGNADO AS (
SELECT D.COD_ORGANOGRAMA AS EMPRESA,
       A.COD_CONTRATO,
       A.DATA_REFERENCIA AS REFERENCIA,
       A.COD_EVENTO,
       C.NOME_EVENTO AS DES_EVENTO,
       A.COD_VD,
       B.NOME_VD AS DES_VD,
       A.QTDE_VD,
       A.VALOR_VD,
       A.COD_MESTRE_EVENTO AS COD_MESTRE,
       D.NOME_MESTRE_EVENTO AS DES_MESTRE,
       D.DATA_PAGAMENTO AS PAGAMENTO,
       D.DATA_INI_MOV || ' - ' || D.DATA_FIM_MOV AS PERIODO,
       D.DATA_PROCESSO AS PROCESSAMENTO,
       D.DATA_INCORPORACAO AS INCORPORACAO,
       D.DATA_APROPRIACAO AS APROPRIACAO,
       D.SITUACAO_PROCESSO AS STATUS,
       CASE
           WHEN D.SITUACAO_PROCESSO = 'A' THEN
            'ABERTO'
           WHEN D.SITUACAO_PROCESSO = 'C' THEN
            'CALCULADO'
           WHEN D.SITUACAO_PROCESSO = 'I' THEN
            'INCORPORADO'
           ELSE
            NULL
       END AS DES_STATUS
FROM RHFP1005 A
JOIN RHFP1000 B ON A.COD_VD = B.COD_VD
JOIN RHFP1002 C ON A.COD_EVENTO = C.COD_EVENTO
JOIN RHFP1003 D ON A.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
CROSS JOIN PARAMS P
WHERE (D.COD_ORGANOGRAMA = :EMPRESA OR :EMPRESA = 0)
   --(D.COD_ORGANOGRAMA = &EMPRESA OR &EMPRESA = 0)
AND A.DATA_REFERENCIA BETWEEN P.DATA_INICIO AND P.DATA_FIM
--AND A.DATA_REFERENCIA BETWEEN '&DATA_INICIO' AND '&DATA_FIM'
AND A.COD_VD IN (4075, 4076, 4081, 4082, 4084, 4085, 4086, 4087, 4088, 4089, 4090,
4091, 4092, 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104)
/*AND (&VD = '0' OR A.COD_VD IN
    (SELECT * FROM TABLE(SPLIT_CONTRACTS(&VD ))))*/
/*AND (:UNIDADE = '0' OR  B.COD_UNIDADE IN
    (SELECT * FROM TABLE(SPLIT_CONTRACTS(:UNIDADE ))))*/

ORDER BY A.COD_EVENTO, A.COD_VD, A.COD_CONTRATO

)
SELECT X.EMPRESA,
       X.COLABORADOR,
       X.DES_UNIDADE,
       X.DES_REDE,
       X.REFERENCIA,
       /* 4075 */
       x.COD_4075,
       x.NOME_4075,
       TO_CHAR(x.VALOR_4075, 'FM999G999G990D00') AS VALOR_4075,

       /* 4096 */
       x.COD_4096,
       x.NOME_4096,
       TO_CHAR(x.VALOR_4096, 'FM999G999G990D00') AS VALOR_4096,

       /* 4097 */
       x.COD_4097,
       x.NOME_4097,
       TO_CHAR(x.VALOR_4097, 'FM999G999G990D00') AS VALOR_4097,

       /* 4098 */
       x.COD_4098,
       x.NOME_4098,
       TO_CHAR(x.VALOR_4098, 'FM999G999G990D00') AS VALOR_4098,

       /* 4099 */
       x.COD_4099,
       x.NOME_4099,
       TO_CHAR(x.VALOR_4099, 'FM999G999G990D00') AS VALOR_4099,

       /* 4100 */
       x.COD_4100,
       x.NOME_4100,
       TO_CHAR(x.VALOR_4100, 'FM999G999G990D00') AS VALOR_4100,

       /* 4101 */
       x.COD_4101,
       x.NOME_4101,
       TO_CHAR(x.VALOR_4101, 'FM999G999G990D00') AS VALOR_4101,

       /* 4102 */
       x.COD_4102,
       x.NOME_4102,
       TO_CHAR(x.VALOR_4102, 'FM999G999G990D00') AS VALOR_4102,

       /* 4103 */
       x.COD_4103,
       x.NOME_4103,
       TO_CHAR(x.VALOR_4103, 'FM999G999G990D00') AS VALOR_4103,

       /* 4104 */
       x.COD_4104,
       x.NOME_4104,
       TO_CHAR(x.VALOR_4104, 'FM999G999G990D00') AS VALOR_4104,

       /* totais formatados */
       TO_CHAR(x.TOTAL, 'FM999G999G990D00') AS TOTAL,

       X.EVENTO,
       X.MESTRE,
       X.PAGAMENTO,
       X.PERIODO,
       X.PROCESSAMENTO,
       X.INCORPORACAO,
       X.APROPRIACAO,
       X.STATUS,
       X.DES_STATUS,

       TO_CHAR(SUM(x.TOTAL) OVER(), 'FM999G999G990D00') AS TOTAL_GERAL
  FROM (
        SELECT EMPRESA,
               COLABORADOR,
               DES_UNIDADE,
               DES_REDE,
               REFERENCIA,

               /* 4075 */
               V4075_COD AS COD_4075,
               V4075_NOME AS NOME_4075,
               NVL(V4075_VALOR, 0) AS VALOR_4075,

               /* 4096 */
               V4096_COD AS COD_4096,
               V4096_NOME AS NOME_4096,
               NVL(V4096_VALOR, 0) AS VALOR_4096,

               /* 4097 */
               V4097_COD AS COD_4097,
               V4097_NOME AS NOME_4097,
               NVL(V4097_VALOR, 0) AS VALOR_4097,

               /* 4098 */
               V4098_COD AS COD_4098,
               V4098_NOME AS NOME_4098,
               NVL(V4098_VALOR, 0) AS VALOR_4098,

               /* 4099 */
               V4099_COD AS COD_4099,
               V4099_NOME AS NOME_4099,
               NVL(V4099_VALOR, 0) AS VALOR_4099,

               /* 4100 */
               V4100_COD AS COD_4100,
               V4100_NOME AS NOME_4100,
               NVL(V4100_VALOR, 0) AS VALOR_4100,

               /* 4101 */
               V4101_COD AS COD_4101,
               V4101_NOME AS NOME_4101,
               NVL(V4101_VALOR, 0) AS VALOR_4101,

               /* 4102 */
               V4102_COD AS COD_4102,
               V4102_NOME AS NOME_4102,
               NVL(V4102_VALOR, 0) AS VALOR_4102,

               /* 4103 */
               V4103_COD AS COD_4103,
               V4103_NOME AS NOME_4103,
               NVL(V4103_VALOR, 0) AS VALOR_4103,

               /* 4104 */
               V4104_COD AS COD_4104,
               V4104_NOME AS NOME_4104,
               NVL(V4104_VALOR, 0) AS VALOR_4104,

               /* total por linha (opcional) */
               NVL(V4075_VALOR, 0) + NVL(V4096_VALOR, 0) +
               NVL(V4097_VALOR, 0) + NVL(V4098_VALOR, 0) +
               NVL(V4099_VALOR, 0) + NVL(V4100_VALOR, 0) +
               NVL(V4101_VALOR, 0) + NVL(V4102_VALOR, 0) +
               NVL(V4103_VALOR, 0) + NVL(V4104_VALOR, 0) AS TOTAL,

               /* metadados do evento */
               EVENTO,
               MESTRE,
               PAGAMENTO,
               PERIODO,
               PROCESSAMENTO,
               INCORPORACAO,
               APROPRIACAO,
               STATUS,
               DES_STATUS

          FROM (SELECT VE.EMPRESA || ' - ' || CT.DES_EMP AS EMPRESA,
                        CT.COD_CONTRATO || ' - ' || CT.DES_PESSOA AS COLABORADOR,
                        CT.DES_UNIDADE,
                        CT.DES_REDE,
                        VE.REFERENCIA,
                        VE.COD_VD,
                        VE.COD_VD AS COD_VD_MEDIDA,
                        NVL(VE.VALOR_VD, 0) AS VALOR_VD,
                        VE.DES_VD AS NOME_VD, -- <- vem de RHFP1000.NOME_VD no seu CTE

                        VE.COD_EVENTO || ' - ' || VE.DES_EVENTO AS EVENTO,
                        VE.COD_MESTRE || ' - ' || VE.DES_MESTRE AS MESTRE,
                        VE.PAGAMENTO,
                        VE.PERIODO,
                        VE.PROCESSAMENTO,
                        VE.INCORPORACAO,
                        VE.APROPRIACAO,
                        VE.STATUS,
                        VE.DES_STATUS
                   FROM VALORES_ECONSIGNADO VE
                   LEFT JOIN CONTRATOS CT ON CT.COD_CONTRATO = VE.COD_CONTRATO
                  WHERE VE.COD_VD IN
                        (4075, 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104)
                        )
                         PIVOT(SUM(VALOR_VD) AS VALOR,
                               MAX(NOME_VD) AS NOME,
                               MAX(COD_VD_MEDIDA)
                               AS COD FOR COD_VD IN (4075 AS V4075, 4096 AS V4096,
                                                     4097 AS V4097, 4098 AS V4098,
                                                     4099 AS V4099, 4100 AS V4100,
                                                     4101 AS V4101, 4102 AS V4102,
                                                     4103 AS V4103, 4104 AS V4104))) X
 ORDER BY X.DES_UNIDADE, X.COLABORADOR, X.REFERENCIA



