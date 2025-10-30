/* ==============================================================
   ======= AJUSTANDO NOVA FÓRMULA DO REL DE PRODUTIVIDADE =======
   ==============================================================*/


WITH
PARAMS AS (
/*VERSÃO PARA USAR NO PL/SQL*/
SELECT TO_DATE('&DATA_INICIO', 'DD/MM/YYYY') AS D_INI,
       TO_DATE('&DATA_FIM', 'DD/MM/YYYY') AS D_FIM
  FROM DUAL

  
/*VERSÃO PARA USAR NO SAPINHO E FOLHA*/
/*  SELECT :data_inicio AS D_INI,
           :data_fim AS D_FIM
  FROM DUAL*/
                          
                         

/*VERSÃO PARA INFORMATIVO DE PARÂMETROS*/
/*SELECT :DATA_INICIO AS MONTH_START,
       LAST_DAY(:DATA_FIM) AS MONTH_END,

       --ex: 07/2025  (se for um único mês)  ou  07/2025 - 08/2025 (se cruzar mês)
       CASE
         WHEN TRUNC(:DATA_INICIO, 'MM') = TRUNC(:DATA_FIM, 'MM') THEN
          TO_CHAR(:DATA_INICIO, 'MM/YYYY')
         ELSE
          TO_CHAR(:DATA_INICIO, 'MM/YYYY') || ' - ' ||
          TO_CHAR(:DATA_FIM, 'MM/YYYY')
       END AS MES_ANO,

       --ex: Julho/2025  (único mês)  ou  Julho/2025 - Agosto/2025 (intervalo)
       CASE
         WHEN TRUNC(:DATA_INICIO, 'MM') = TRUNC(:DATA_FIM, 'MM') THEN
          INITCAP(TO_CHAR(:DATA_INICIO,
                          'FMMonth',
                          'NLS_DATE_LANGUAGE=Portuguese')) || '/' ||
          TO_CHAR(:DATA_INICIO, 'YYYY')
         ELSE
          INITCAP(TO_CHAR(:DATA_INICIO,
                          'FMMonth',
                          'NLS_DATE_LANGUAGE=Portuguese')) || '/' ||
          TO_CHAR(:DATA_INICIO, 'YYYY') || ' - ' ||
          INITCAP(TO_CHAR(:DATA_FIM,
                          'FMMonth',
                          'NLS_DATE_LANGUAGE=Portuguese')) || '/' ||
          TO_CHAR(:DATA_FIM, 'YYYY')
       END AS MES_ANO_EXTENSO

  FROM DUAL*/


  
), 

/*CALENDÁRIO MENSAL DINÂMICO A PARTIR DOS PARÂMTROS ACIMA*/
DATAS_REF AS (
  SELECT ADD_MONTHS(P.D_INI, LEVEL - 1) AS DTA_INI,
         LAST_DAY(ADD_MONTHS(P.D_INI, LEVEL - 1)) AS DTA_FIM,
         TO_CHAR(ADD_MONTHS(P.D_INI, LEVEL - 1), 'MM/YYYY') AS MES_ANO,
         INITCAP(TRIM(TO_CHAR(ADD_MONTHS(P.D_INI, LEVEL - 1),
                              'MONTH',
                              'NLS_DATE_LANGUAGE=PORTUGUESE'))) || '/' ||
         TO_CHAR(ADD_MONTHS(P.D_INI, LEVEL - 1), 'YYYY') AS MES_ANO_EXTENSO
    FROM PARAMS P
  CONNECT BY LEVEL <= MONTHS_BETWEEN(P.D_FIM, P.D_INI) + 1
  
  
),


/* 0.0) MAPEIA OS CONTRATOS POR LOJA PARA: TURNOVER, PRODUTIVIDADE E ABSENTEÍSMO */
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
 CROSS JOIN DATAS_REF M
 CROSS JOIN PARAMS P
 WHERE -- CONTRATOS ATIVOS EM QUALQUER DIA DO MÊS
 CT.DATA_ADMISSAO <= M.DTA_FIM
 AND NVL(CT.DATA_DEMISSAO, DATE '2999-12-31') >= M.DTA_INI
/*VERSÕES ALTERNATIVAS DE FILTRAR POR DATA
(('31/03/2025' BETWEEN CT.DATA_ADMISSAO AND CT.DATA_DEMISSAO) OR
        (CT.DATA_ADMISSAO <= '31/03/2025' AND CT.DATA_DEMISSAO IS NULL))
AND (CT.DATA_ADMISSAO <= TO_DATE('31/07/2025','DD/MM/YYYY'))
   AND (CT.DATA_DEMISSAO IS NULL OR CT.DATA_DEMISSAO >= TO_DATE('01/07/2025','DD/MM/YYYY'))
AND (CT.DATA_DEMISSAO IS NULL OR
       CT.DATA_DEMISSAO >= '01/07/2025')*/

 AND P.D_FIM BETWEEN ORG.DATA_INI_ORG AND ORG.DATA_FIM_ORG
 AND P.D_FIM BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH
 AND P.D_FIM BETWEEN HR.DATA_INI_HR AND HR.DATA_FIM_HR
 AND ORG.COD_EMP = 8
--AND ORG.COD_TIPO = 1
 AND ORG.EDICAO_ORG_4 IS NOT NULL
--AND ORG.COD_UNIDADE NOT IN (014, 050, 615, 7586, 7608)
--AND ORG.COD_UNIDADE = 004
 ORDER BY CT.COD_CONTRATO
),

STATUS_AFASTADOS AS (
SELECT DISTINCT
       ORG.COD_EMP,
       CT.COD_CONTRATO,
       ORG.COD_ORGANOGRAMA,
       ORG.COD_UNIDADE,
       NVL(AF.COD_CAUSA_AFAST,0) AS STATUS_AFAST,
       AF.DATA_INICIO AS DATA_INI_AFAST,
       AF.DATA_FIM AS DATA_FIM_AFAST
  FROM RHFP0306 AF,
       RHFP0300 CT,
       VH_EST_ORG_CONTRATO_AVT ORG,
       VH_CARGO_CONTRATO_AVT FN,
       DATAS_REF M,
       PARAMS P
 WHERE CT.COD_CONTRATO = AF.COD_CONTRATO(+)
   AND CT.COD_CONTRATO = ORG.COD_CONTRATO(+)
   AND CT.COD_CONTRATO = FN.COD_CONTRATO(+)
   AND CT.DATA_INICIO <= M.DTA_FIM
   AND NVL(CT.DATA_FIM, DATE '2999-12-31') >= M.DTA_INI
  /* AND (CT.DATA_INICIO <= '31/03/2025')
   AND (CT.DATA_INICIO IS NULL OR CT.DATA_FIM >= '01/01/2025')*/
   AND P.D_FIM BETWEEN AF.DATA_INICIO(+) AND AF.DATA_FIM(+)
   AND P.D_FIM BETWEEN ORG.DATA_INI_ORG(+) AND ORG.DATA_FIM_ORG(+)
   AND P.D_FIM BETWEEN AF.DATA_INICIO(+) AND NVL(AF.DATA_FIM(+), DATE '2999-12-31')
   AND ORG.COD_EMP = 8
   --AND ORG.COD_UNIDADE NOT IN (014, 050, 615, 7586, 7608)
   --AND ORG.COD_TIPO = 1
   --AND ORG.COD_UNIDADE NOT IN (014, 050, 615, 7586, 7608) --657 essa ainda irá inaugurar em agosto

),


VENDAS AS (
SELECT GE.COD_QUEBRA REGIAO,
       DECODE(A.COD_UNIDADE,
              7022, 22,
              7047, 47,
              7065, 65,
              7138, 138,
              7140, 140,
              7183, 183,
              7244, 244,
              7353, 353,
              7386, 386,
              7412, 412,
              7430, 430,
              7442, 442,
              7461, 461,
              7466, 466,
              7491, 491,
              7543, 543,
              7555, 555,
              7570, 570,
              7577, 653,
              7587, 587,
              7588, 588,
              7592, 592,
              7597, 597,
              7601, 601,
              7602, 608,
              7620, 620,
              7500, 651,
              7051, 652,
              7066, 654,
              A.COD_UNIDADE) COD_UNIDADE,
       GE.COD_GRUPO,
       MIN(D.DES_FANTASIA) DES_FANTASIA, -- USA MIN PARA "UNIFICAR"
       MIN(D.DTA_CADASTRO) DTA_CADASTRO, -- IDEM
       MIN(A.DTA_EMISSAO) DTA_ATUALIZACAO,
       SUM(OPER.VLR_OPERACAO) VALOR_VENDA_LOJA,
       SUM(CASE
             WHEN TO_CHAR(A.DTA_EMISSAO, 'D') = 1 THEN
              NVL(OPER.VLR_OPERACAO, 0)
             ELSE
              0
           END) VDA_DOMINGO
  FROM NL.NS_NOTAS@NLGRZ A
  JOIN NL.NS_NOTAS_OPERACOES@NLGRZ OPER ON A.NUM_SEQ = OPER.NUM_SEQ
                                       AND A.COD_MAQUINA = OPER.COD_MAQUINA
  JOIN NL.GE_GRUPOS_UNIDADES@NLGRZ GE ON A.COD_UNIDADE = GE.COD_UNIDADE
  JOIN NL.PS_PESSOAS@NLGRZ D ON A.COD_UNIDADE = D.COD_PESSOA
  CROSS JOIN DATAS_REF M
 WHERE A.DTA_EMISSAO BETWEEN M.DTA_INI AND M.DTA_FIM
   AND GE.COD_GRUPO = 999
   AND GE.COD_EMP = 1
   --AND (A.COD_UNIDADE = :UNIDADE OR :UNIDADE = 0)
      --AND A.COD_UNIDADE >= 0
      --AND A.COD_UNIDADE <= 999
   AND A.IND_STATUS = 1
   AND A.TIP_NOTA = 4
   AND D.IND_INATIVO = 0
 GROUP BY GE.COD_QUEBRA,
          DECODE(A.COD_UNIDADE,
                 7022, 22,
                 7047, 47,
                 7065, 65,
                 7138, 138,
                 7140, 140,
                 7183, 183,
                 7244, 244,
                 7353, 353,
                 7386, 386,
                 7412, 412,
                 7430, 430,
                 7442, 442,
                 7461, 461,
                 7466, 466,
                 7491, 491,
                 7543, 543,
                 7555, 555,
                 7570, 570,
                 7577, 653,
                 7587, 587,
                 7588, 588,
                 7592, 592,
                 7597, 597,
                 7601, 601,
                 7602, 608,
                 7620, 620,
                 7500, 651,
                 7051, 652,
                 7066, 654,
                 A.COD_UNIDADE),
          GE.COD_GRUPO
 ORDER BY GE.COD_QUEBRA, COD_UNIDADE, DES_FANTASIA

),

TOTAL_HORAS AS (
SELECT A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.COD_TIPO,
       SUM(CASE
             WHEN A.IND_DEFICIENCIA = 'S' THEN
              0
             ELSE
              TO_NUMBER(A.HR_BASE_MES)
           END) AS TOTAL_HRS
  FROM CONTRATOS A
  LEFT JOIN STATUS_AFASTADOS B ON A.COD_CONTRATO = B.COD_CONTRATO
 CROSS JOIN DATAS_REF M
 CROSS JOIN PARAMS P
 WHERE NVL(B.STATUS_AFAST, 0) IN (0, 6, 7, 107)
   AND A.COD_FUNCAO NOT IN (74, 75, 310, 409, 68)
      --AND A.COD_TIPO = 1
   AND A.DATA_ADMISSAO <= LAST_DAY(M.DTA_FIM)
   AND (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO >= M.DTA_FIM)
   AND P.D_FIM BETWEEN A.DATA_INI_ORG AND A.DATA_FIM_ORG
   AND P.D_FIM BETWEEN A.DATA_INI_CLH AND A.DATA_FIM_CLH
   AND P.D_FIM BETWEEN A.DATA_INI_HR AND A.DATA_FIM_HR
 GROUP BY A.COD_ORGANOGRAMA, A.COD_UNIDADE, A.COD_TIPO
),


PRODUTIVIDADE AS (
SELECT A.COD_UNIDADE,       
       MIN(A.DES_FANTASIA) AS DES_FANTASIA,
       TT.COD_TIPO,
       A.VALOR_VENDA_LOJA,
       TT.TOTAL_HRS,
       TRUNC(A.VALOR_VENDA_LOJA / NULLIF(TT.TOTAL_HRS, 0)) AS PRODUTIVIDADE       
  FROM VENDAS A
  LEFT JOIN TOTAL_HORAS TT ON A.COD_UNIDADE = TT.COD_UNIDADE
 GROUP BY A.COD_UNIDADE, A.VALOR_VENDA_LOJA, TT.TOTAL_HRS, TT.COD_TIPO
 ORDER BY A.COD_UNIDADE
 
)


SELECT * FROM PRODUTIVIDADE
