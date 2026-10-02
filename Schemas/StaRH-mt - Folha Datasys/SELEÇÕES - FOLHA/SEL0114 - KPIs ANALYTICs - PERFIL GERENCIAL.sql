/*RELAÇÃO DE PERFIS SOMENTE CARGOS GERENCIAIS*/

WITH
/*PARAMS AS (
    SELECT
        :REFERENCIA AS REFERENCIA,
        NVL(TO_NUMBER(:REDE_EMPRESA), 0) AS REDE_EMPRESA
    FROM DUAL
),*/

PARAMS AS (
    SELECT
        /*NVL(CAST(:REFERENCIA AS DATE), TRUNC(SYSDATE)) AS REFERENCIA,*/
        :REFERENCIA AS REFERENCIA,

        CASE
            WHEN TO_CHAR(:REDE_EMPRESA) IS NULL THEN '8'
            ELSE TRIM(TO_CHAR(:REDE_EMPRESA))
        END AS REDE_EMPRESA
    FROM DUAL
),

LOCAL_INFO AS (
    SELECT
        CASE
            WHEN P.REDE_EMPRESA = '8' THEN '8'
            ELSE P.REDE_EMPRESA
        END AS REDE_LOCAL,

        CASE P.REDE_EMPRESA
            WHEN '8'  THEN 'GRAZZIOTIN SA'
            WHEN '10' THEN 'GRAZZIOTIN'
            WHEN '30' THEN 'PORMENOS'
            WHEN '40' THEN 'FRANCO GIORGI'
            WHEN '50' THEN 'TOTTAL'
            WHEN '70' THEN 'GZT STORE'
            ELSE 'REDE NÃO MAPEADA'
        END AS DES_LOCAL
    FROM PARAMS P
),

DADOS AS (
    SELECT DISTINCT
           COD_PESSOA,
           COD_CONTRATO,
           DES_PESSOA,
           DATA_NASCIMENTO,
           DATA_ADMISSAO AS ADMISSAO,
           DATA_DEMISSAO,
           COD_TIPO_ADMISSAO,
           DES_TIPO_ADMISSAO,
           SEXO,
           COD_EST_CIVIL,
           DES_EST_CIVIL,
           IND_DEFICIENCIA,
           COD_INSTRUCAO,
           DES_INSTRUCAO,
           COD_PAIS,
           COD_PAIS_NASCTO,
           COD_NACIONALIDADE,
           DES_NACIONALIDADE,
           COD_RACA_COR,
           DES_RACA_COR,
           NVL(COD_AFAST, 0) AS COD_AFAST,
           DES_AFAST,
           COD_STATUS_AFAST,
           TRIM(UPPER(STATUS_AFAST)) AS STATUS_AFAST,
           COD_ORGANOGRAMA,
           COD_UNIDADE,
           DES_UNIDADE,
           COD_REDE_LOCAL,
           DES_REDE_LOCAL,
           COD_EMP,
           DES_EMPRESA,
           COD_UF
    FROM V_DADOS_COLAB_AVT
    WHERE COD_EMP = 8
),

BASE_CONTRATOS_REF AS (
    SELECT
           D.*,
           P.REFERENCIA,

           TRUNC(MONTHS_BETWEEN(P.REFERENCIA, D.DATA_NASCIMENTO) / 12) AS IDADE_REF,

           FLOOR(MONTHS_BETWEEN(P.REFERENCIA, D.ADMISSAO)) AS TEMPO_MESES_EMPRESA
    FROM DADOS D
    CROSS JOIN PARAMS P
    WHERE TRUNC(D.ADMISSAO) <= P.REFERENCIA
      AND (
             D.DATA_DEMISSAO IS NULL
          OR TRUNC(D.DATA_DEMISSAO) >= P.REFERENCIA
      )
      AND (
             P.REDE_EMPRESA = '8'
          OR TRIM(TO_CHAR(D.COD_REDE_LOCAL)) = P.REDE_EMPRESA
      )
),

BASE AS (
    SELECT *
    FROM (
        SELECT
               B.*,
               ROW_NUMBER() OVER (
                   PARTITION BY B.COD_CONTRATO
                   ORDER BY
                       NVL(B.DATA_DEMISSAO, DATE '2999-12-31') DESC,
                       B.ADMISSAO DESC,
                       B.COD_CONTRATO DESC
               ) AS RN_CONTRATO
        FROM BASE_CONTRATOS_REF B
    )
    WHERE RN_CONTRATO = 1
),


CARGO_REF AS (
    SELECT
        X.COD_CONTRATO,
        X.COD_CLH AS COD_FUNCAO,
        F.NOME_CLH AS DES_FUNCAO,
        X.DATA_INICIO AS DATA_INICIO_CARGO,
        X.DATA_FIM AS DATA_FIM_CARGO
    FROM (
        SELECT
            A.*,
            ROW_NUMBER() OVER (
                PARTITION BY A.COD_CONTRATO
                ORDER BY
                    A.DATA_INICIO DESC,
                    NVL(A.DATA_FIM, DATE '2999-12-31') DESC
            ) AS RN
        FROM RHFP0340 A
        CROSS JOIN PARAMS P
        WHERE TRUNC(A.DATA_INICIO) <= P.REFERENCIA
          AND NVL(TRUNC(A.DATA_FIM), DATE '2999-12-31') >= P.REFERENCIA
    ) X
    INNER JOIN RHFP0500 F
        ON F.COD_CLH = X.COD_CLH
    WHERE X.RN = 1
),

BASE_GERENCIAL AS (
    SELECT
        B.*,
        TRIM(UPPER(TO_CHAR(B.COD_UF))) AS COD_UF_RESIDENCIA,
        C.COD_FUNCAO,
        C.DES_FUNCAO,
        C.DATA_INICIO_CARGO,
        C.DATA_FIM_CARGO,
        FLOOR(MONTHS_BETWEEN(B.REFERENCIA, C.DATA_INICIO_CARGO)) AS TEMPO_MESES_CARGO
    FROM BASE B
    INNER JOIN CARGO_REF C
      ON C.COD_CONTRATO = B.COD_CONTRATO
    WHERE (
          UPPER(C.DES_FUNCAO) LIKE '%GERENTE%'
       OR UPPER(C.DES_FUNCAO) LIKE '%COMPRADOR%'
       OR UPPER(C.DES_FUNCAO) LIKE '%SUPERVISOR%'
       OR REGEXP_LIKE(
              UPPER(C.DES_FUNCAO),
              '(^|[^[:alpha:]])DIRETOR(A)?([^[:alpha:]]|$)'
          )
      )
      AND UPPER(C.DES_FUNCAO) NOT LIKE '%ASSESSOR DE DIRETORIA%'
      AND UPPER(C.DES_FUNCAO) NOT LIKE '%ASSISTENTE DA DIRETORIA%'
),

RELACAO_GERAL AS (
    SELECT
        MAX(L.REDE_LOCAL) AS REDE_LOCAL,
        MAX(L.DES_LOCAL) AS DES_LOCAL,
        TO_CHAR(MAX(P.REFERENCIA), 'DD/MM/YYYY') AS DATA_REFERENCIA,

        /* =========================
           FAIXA ETÁRIA
        ========================= */
        NVL(SUM(CASE WHEN B.IDADE_REF <= 18 THEN 1 ELSE 0 END), 0) AS FAIXA_ATE_18_ANOS,
        NVL(SUM(CASE WHEN B.IDADE_REF > 18 AND B.IDADE_REF <= 21 THEN 1 ELSE 0 END), 0) AS FAIXA_18_A_21_ANOS,
        NVL(SUM(CASE WHEN B.IDADE_REF > 21 AND B.IDADE_REF <= 25 THEN 1 ELSE 0 END), 0) AS FAIXA_21_A_25_ANOS,
        NVL(SUM(CASE WHEN B.IDADE_REF > 25 AND B.IDADE_REF <= 30 THEN 1 ELSE 0 END), 0) AS FAIXA_25_A_30_ANOS,
        NVL(SUM(CASE WHEN B.IDADE_REF > 30 AND B.IDADE_REF <= 40 THEN 1 ELSE 0 END), 0) AS FAIXA_30_A_40_ANOS,
        NVL(SUM(CASE WHEN B.IDADE_REF > 40 AND B.IDADE_REF <= 50 THEN 1 ELSE 0 END), 0) AS FAIXA_40_A_50_ANOS,
        NVL(SUM(CASE WHEN B.IDADE_REF > 50 THEN 1 ELSE 0 END), 0) AS FAIXA_ACIMA_50_ANOS,
        NVL(SUM(CASE WHEN B.IDADE_REF IS NULL THEN 1 ELSE 0 END), 0) AS FAIXA_SEM_DATA_NASCIMENTO,

        /* =========================
           SEXO
        ========================= */
        NVL(SUM(CASE WHEN UPPER(B.SEXO) IN ('M', 'MASCULINO') THEN 1 ELSE 0 END), 0) AS SEXO_MASCULINO,
        NVL(SUM(CASE WHEN UPPER(B.SEXO) IN ('F', 'FEMININO') THEN 1 ELSE 0 END), 0) AS SEXO_FEMININO,

        /* =========================
           ESTADO CIVIL
        ========================= */
        NVL(SUM(CASE WHEN UPPER(B.DES_EST_CIVIL) LIKE 'SOLTEIR%' THEN 1 ELSE 0 END), 0) AS EST_CIVIL_SOLTEIRO,
        NVL(SUM(CASE WHEN UPPER(B.DES_EST_CIVIL) LIKE 'CASAD%' THEN 1 ELSE 0 END), 0) AS EST_CIVIL_CASADO,
        NVL(SUM(CASE WHEN UPPER(B.DES_EST_CIVIL) LIKE 'SEPARAD%' THEN 1 ELSE 0 END), 0) AS EST_CIVIL_SEPARADO,
        NVL(SUM(CASE WHEN UPPER(B.DES_EST_CIVIL) LIKE 'DIVORCIAD%' THEN 1 ELSE 0 END), 0) AS EST_CIVIL_DIVORCIADO,
        NVL(SUM(CASE WHEN UPPER(B.DES_EST_CIVIL) LIKE 'VIÚV%'
                   OR UPPER(B.DES_EST_CIVIL) LIKE 'VIUV%' THEN 1 ELSE 0 END), 0) AS EST_CIVIL_VIUVO,
        NVL(SUM(CASE WHEN UPPER(B.DES_EST_CIVIL) LIKE 'UNIÃO ESTÁVEL%'
                   OR UPPER(B.DES_EST_CIVIL) LIKE 'UNIAO ESTAVEL%' THEN 1 ELSE 0 END), 0) AS EST_CIVIL_UNIAO_ESTAVEL,

        /* =========================
           ESCOLARIDADE
        ========================= */
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 1 THEN 1 ELSE 0 END), 0) AS ESC_FUNDAMENTAL_INCOMPLETO,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 2 THEN 1 ELSE 0 END), 0) AS ESC_FUNDAMENTAL_COMPLETO,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 3 THEN 1 ELSE 0 END), 0) AS ESC_MEDIO_INCOMPLETO,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 4 THEN 1 ELSE 0 END), 0) AS ESC_MEDIO_COMPLETO,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 5 THEN 1 ELSE 0 END), 0) AS ESC_SUPERIOR_INCOMPLETO,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 6 THEN 1 ELSE 0 END), 0) AS ESC_SUPERIOR_COMPLETO,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 7 THEN 1 ELSE 0 END), 0) AS ESC_POS_GRAD_INCOMPLETA,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 8 THEN 1 ELSE 0 END), 0) AS ESC_POS_GRAD_COMPLETA,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 9 THEN 1 ELSE 0 END), 0) AS ESC_MESTRADO_INCOMPLETO,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 10 THEN 1 ELSE 0 END), 0) AS ESC_MESTRADO_COMPLETO,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 11 THEN 1 ELSE 0 END), 0) AS ESC_INSTRUCAO_11,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 12 THEN 1 ELSE 0 END), 0) AS ESC_INSTRUCAO_12,
        NVL(SUM(CASE WHEN B.COD_INSTRUCAO = 13 THEN 1 ELSE 0 END), 0) AS ESC_INSTRUCAO_13,
        NVL(SUM(CASE
                    WHEN B.COD_INSTRUCAO IS NULL
                      OR B.COD_INSTRUCAO NOT BETWEEN 1 AND 13
                    THEN 1 ELSE 0
                END), 0) AS ESC_INSTRUCAO_NAO_MAPEADA,

        /* =========================
           TEMPO DE EMPRESA
        ========================= */

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA < 12
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_ABAIXO_1_ANO,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA >= 12
                     AND B.TEMPO_MESES_EMPRESA < 24
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_1_A_2_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA >= 24
                     AND B.TEMPO_MESES_EMPRESA < 60
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_2_A_5_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA >= 60
                     AND B.TEMPO_MESES_EMPRESA < 120
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_5_A_10_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA >= 120
                     AND B.TEMPO_MESES_EMPRESA < 240
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_10_A_20_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA >= 240
                     AND B.TEMPO_MESES_EMPRESA < 360
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_20_A_30_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA >= 360
                     AND B.TEMPO_MESES_EMPRESA < 480
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_30_A_40_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA >= 480
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_ACIMA_40_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_EMPRESA IS NULL
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_EMPRESA_SEM_DATA,

        /* =========================
           TEMPO NO CARGO GERENCIAL
        ========================= */
        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_CARGO < 60
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_CARGO_ATE_5_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_CARGO >= 60
                     AND B.TEMPO_MESES_CARGO < 120
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_CARGO_5_A_10_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_CARGO >= 120
                     AND B.TEMPO_MESES_CARGO < 180
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_CARGO_10_A_15_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_CARGO >= 180
                     AND B.TEMPO_MESES_CARGO < 240
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_CARGO_15_A_20_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_CARGO >= 240
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_CARGO_ACIMA_20_ANOS,

        NVL(SUM(CASE
                    WHEN B.TEMPO_MESES_CARGO IS NULL
                    THEN 1 ELSE 0
                END), 0) AS TEMPO_CARGO_SEM_DATA,

        /* =========================
           EMPREGOS
        ========================= */
        NVL(SUM(CASE WHEN B.COD_TIPO_ADMISSAO = 1 THEN 1 ELSE 0 END), 0) AS PRIMEIRO_EMPREGO,
        NVL(SUM(CASE WHEN B.COD_TIPO_ADMISSAO <> 1 OR B.COD_TIPO_ADMISSAO IS NULL THEN 1 ELSE 0 END), 0) AS EMPREGOS_ANTERIORES,

        /* =========================
           RAÇA / COR
        ========================= */
        NVL(SUM(CASE WHEN B.COD_RACA_COR = 1 THEN 1 ELSE 0 END), 0) AS RACA_INDIGENA,
        NVL(SUM(CASE WHEN B.COD_RACA_COR = 2 THEN 1 ELSE 0 END), 0) AS RACA_BRANCA,
        NVL(SUM(CASE WHEN B.COD_RACA_COR = 4 THEN 1 ELSE 0 END), 0) AS RACA_PRETA,
        NVL(SUM(CASE WHEN B.COD_RACA_COR = 6 THEN 1 ELSE 0 END), 0) AS RACA_AMARELA,
        NVL(SUM(CASE WHEN B.COD_RACA_COR = 8 THEN 1 ELSE 0 END), 0) AS RACA_PARDA,
        NVL(SUM(CASE WHEN B.COD_RACA_COR = 9 THEN 1 ELSE 0 END), 0) AS RACA_NAO_INFORMADO,
        NVL(SUM(CASE
                    WHEN B.COD_RACA_COR IS NULL
                      OR B.COD_RACA_COR NOT IN (1, 2, 4, 6, 8, 9)
                    THEN 1 ELSE 0
                END), 0) AS RACA_NAO_MAPEADA,

        /* =========================
           NACIONALIDADE - RESUMO
        ========================= */
        NVL(SUM(CASE WHEN B.COD_NACIONALIDADE = 10 THEN 1 ELSE 0 END), 0) AS NAC_BRASILEIRO,
        NVL(SUM(CASE WHEN B.COD_NACIONALIDADE = 20 THEN 1 ELSE 0 END), 0) AS NAC_NATURALIZADO_BRASILEIRO,
        NVL(SUM(CASE WHEN B.COD_NACIONALIDADE IS NOT NULL
                       AND B.COD_NACIONALIDADE NOT IN (10, 20)
                     THEN 1 ELSE 0 END), 0) AS NAC_ESTRANGEIRO,
        NVL(SUM(CASE WHEN B.COD_NACIONALIDADE IS NULL THEN 1 ELSE 0 END), 0) AS NAC_NAO_INFORMADA,

        /* =========================
           COLABORADORES POR ESTADO
           Baseado na UF residencial do colaborador
        ========================= */

        NVL(SUM(CASE
            WHEN B.COD_UF_RESIDENCIA = 'RS'
            THEN 1 ELSE 0
        END), 0) AS UF_RS,

        NVL(SUM(CASE
            WHEN B.COD_UF_RESIDENCIA = 'SC'
            THEN 1 ELSE 0
        END), 0) AS UF_SC,

        NVL(SUM(CASE
            WHEN B.COD_UF_RESIDENCIA = 'PR'
            THEN 1 ELSE 0
        END), 0) AS UF_PR,

        NVL(SUM(CASE
            WHEN B.COD_UF_RESIDENCIA IS NULL
              OR B.COD_UF_RESIDENCIA NOT IN ('RS', 'SC', 'PR')
            THEN 1 ELSE 0
        END), 0) AS UF_NAO_MAPEADA,
        
        /* =========================
           AFASTADOS POR ESTADO
           Baseado na UF residencial do colaborador
           Mesma regra do TOTAL_AFASTADOS
        ========================= */

        NVL(SUM(CASE
            WHEN B.COD_UF_RESIDENCIA = 'RS'
             AND B.COD_AFAST NOT IN (0, 7)
            THEN 1 ELSE 0
        END), 0) AS UF_RS_AFASTADOS,

        NVL(SUM(CASE
            WHEN B.COD_UF_RESIDENCIA = 'SC'
             AND B.COD_AFAST NOT IN (0, 7)
            THEN 1 ELSE 0
        END), 0) AS UF_SC_AFASTADOS,

        NVL(SUM(CASE
            WHEN B.COD_UF_RESIDENCIA = 'PR'
             AND B.COD_AFAST NOT IN (0, 7)
            THEN 1 ELSE 0
        END), 0) AS UF_PR_AFASTADOS,

        NVL(SUM(CASE
            WHEN (
                    B.COD_UF_RESIDENCIA IS NULL
                 OR B.COD_UF_RESIDENCIA NOT IN ('RS', 'SC', 'PR')
                 )
             AND B.COD_AFAST NOT IN (0, 7)
            THEN 1 ELSE 0
        END), 0) AS UF_NAO_MAPEADA_AFASTADOS,

        /* =========================
           TOTAIS
        ========================= */
        COUNT(B.COD_CONTRATO) AS TOTAL_FUNCIONARIOS,
        COUNT(B.COD_CONTRATO) AS TOTAL_GERENCIAIS,

        NVL(SUM(CASE WHEN B.COD_AFAST = 0 THEN 1 ELSE 0 END), 0) AS TOTAL_TRABALHANDO,
        NVL(SUM(CASE WHEN B.COD_AFAST = 7 THEN 1 ELSE 0 END), 0) AS TOTAL_EM_FERIAS,
        NVL(SUM(CASE WHEN B.COD_AFAST NOT IN (0, 7) THEN 1 ELSE 0 END), 0) AS TOTAL_AFASTADOS

    FROM LOCAL_INFO L
    CROSS JOIN PARAMS P
    LEFT JOIN BASE_GERENCIAL B
        ON 1 = 1
)

SELECT R.*,
       ROUND((R.SEXO_MASCULINO / NULLIF(R.TOTAL_FUNCIONARIOS, 0)) * 100, 1) AS PCT_SEXO_MASCULINO,
       ROUND((R.SEXO_FEMININO / NULLIF(R.TOTAL_FUNCIONARIOS, 0)) * 100, 1) AS PCT_SEXO_FEMININO,
       ROUND((R.TOTAL_TRABALHANDO / NULLIF(R.TOTAL_FUNCIONARIOS, 0)) * 100, 1) AS PCT_TRABALHANDO,
       ROUND((R.TOTAL_EM_FERIAS / NULLIF(R.TOTAL_FUNCIONARIOS, 0)) * 100, 1) AS PCT_EM_FERIAS,
       ROUND((R.TOTAL_AFASTADOS / NULLIF(R.TOTAL_FUNCIONARIOS, 0)) * 100, 1) AS PCT_AFASTADOS
FROM RELACAO_GERAL R
