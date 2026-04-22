/*P.L.R GERENTES - PROPORCIONAIS*/

WITH
PARAMS AS (
    SELECT
        TO_DATE('01/01/2025', 'DD/MM/YYYY') AS DT_INI,
        TO_DATE('31/12/2025', 'DD/MM/YYYY') AS DT_FIM,
        TO_DATE('31/12/2025', 'DD/MM/YYYY') AS DT_REF_DEZ
    FROM DUAL
),

/* Unidades com trimestre/prejuízo */
UNIDADES_APR AS (
    SELECT
        ARGUMENTO_1 AS COD_UNIDADE,
        MAX(CASE WHEN COD_VL = 11 THEN 1 ELSE 0 END) AS TRI_1,
        MAX(CASE WHEN COD_VL = 12 THEN 1 ELSE 0 END) AS TRI_2,
        MAX(CASE WHEN COD_VL = 13 THEN 1 ELSE 0 END) AS TRI_3,
        MAX(CASE WHEN COD_VL = 14 THEN 1 ELSE 0 END) AS TRI_4,
        MAX(CASE WHEN COD_VL = 15 THEN 1 ELSE 0 END) AS PREJ
    FROM RHFP1026
    WHERE COD_VL IN (11, 12, 13, 14, 15)
    GROUP BY ARGUMENTO_1
),

/* Só quem teve transição de cargo em 2025 e terminou o ano como gerente */
TRANSICOES AS (
    SELECT /*+ MATERIALIZE */
           DISTINCT V.COD_CONTRATO
    FROM V_DADOS_COLAB_AVT V
    CROSS JOIN PARAMS P
    WHERE V.STATUS = 0
      AND V.COD_TIPO = 1
      AND V.DATA_FIM_ANT BETWEEN P.DT_INI AND P.DT_FIM
      AND V.DES_FUNCAO LIKE '%GERENTE%'
      AND NVL(V.STATUS_AFAST, 'EM ATIVIDADE') NOT IN (
                        'AFASTADO',
                        'ATIVO, SEM RETORNO',
                        'PODERÁ RETORNAR'
                    )
),

/* Dados anteriores */
DADOS_ANT AS (
    SELECT
        V.COD_CONTRATO,
        V.DES_PESSOA,
        V.DATA_ADMISSAO,
        V.DES_FUNCAO_ANT,
        V.DATA_INICIO_ANT,
        V.DATA_FIM_ANT,
        V.COD_UNIDADE_ANT,
        V.DES_UNIDADE_ANT,
        V.DATA_INICIO_ORG_ANT,
        V.DATA_FIM_ORG_ANT,
        CASE
            WHEN V.DATA_FIM_ANT < P.DT_INI THEN 0
            WHEN V.DATA_FIM_ANT > P.DT_FIM THEN 12
            ELSE EXTRACT(MONTH FROM V.DATA_FIM_ANT)
                 - CASE WHEN EXTRACT(DAY FROM V.DATA_FIM_ANT) <= 15 THEN 1 ELSE 0 END
        END AS MESES_ANT
    FROM V_DADOS_COLAB_AVT V
    JOIN TRANSICOES T
      ON T.COD_CONTRATO = V.COD_CONTRATO
    CROSS JOIN PARAMS P
    WHERE V.STATUS = 0
      AND V.COD_TIPO = 1
      AND NVL(V.STATUS_AFAST, 'EM ATIVIDADE') NOT IN (
                        'AFASTADO',
                        'ATIVO, SEM RETORNO',
                        'PODERÁ RETORNAR'
                    )
),

/* Dados atuais: só os mesmos contratos da transição */
DADOS_ATU AS (
    SELECT
        A.COD_CONTRATO,
        A.DES_PESSOA,
        A.DATA_ADMISSAO,
        A.DES_FUNCAO,
        A.DATA_INICIO_CLH,
        A.DATA_FIM_CLH,
        A.COD_UNIDADE,
        A.DES_UNIDADE,
        A.DATA_INI_ORG,
        A.DATA_FIM_ORG,
        CASE
            WHEN A.DATA_INICIO_CLH > P.DT_FIM THEN 0
            WHEN A.DATA_INICIO_CLH < P.DT_INI THEN 12
            ELSE
                (12 - EXTRACT(MONTH FROM A.DATA_INICIO_CLH))
                + CASE
                    WHEN EXTRACT(DAY FROM A.DATA_INICIO_CLH) <= 15 THEN 1
                    ELSE 0
                  END
        END AS MESES_ATU
    FROM V_DADOS_COLAB_AVT A
    JOIN TRANSICOES T
      ON T.COD_CONTRATO = A.COD_CONTRATO
    CROSS JOIN PARAMS P
    WHERE A.STATUS = 0
      AND A.COD_TIPO = 1
      AND A.DES_FUNCAO LIKE '%GERENTE%'
      AND NVL(A.STATUS_AFAST, 'EM ATIVIDADE') NOT IN (
                              'AFASTADO',
                              'ATIVO, SEM RETORNO',
                              'PODERÁ RETORNAR'
              )
),

/* Salário anterior */
SAL_ANT AS (
    SELECT *
    FROM (
        SELECT
            S.COD_CONTRATO,
            S.VALOR_VD AS SAL_ANT,
            R.DATA_REFERENCIA AS REF_SAL_ANT,
            ROW_NUMBER() OVER (
                PARTITION BY S.COD_CONTRATO
                ORDER BY R.DATA_REFERENCIA DESC
            ) AS RN
        FROM RHFP1006 S
        JOIN RHFP1003 R
          ON R.COD_MESTRE_EVENTO = S.COD_MESTRE_EVENTO
        JOIN DADOS_ANT A
          ON A.COD_CONTRATO = S.COD_CONTRATO
        WHERE S.COD_VD = 1700
          AND R.COD_EVENTO = 1
          AND R.DATA_REFERENCIA <= A.DATA_FIM_ANT
    )
    WHERE RN = 1
),

/* Salário atual - dezembro */
SAL_ATU AS (
    SELECT *
    FROM (
        SELECT
            S.COD_CONTRATO,
            S.VALOR_VD AS SAL_ATU,
            R.DATA_REFERENCIA AS REF_SAL_ATU,
            ROW_NUMBER() OVER (
                PARTITION BY S.COD_CONTRATO
                ORDER BY R.DATA_REFERENCIA DESC
            ) AS RN
        FROM RHFP1006 S
        JOIN RHFP1003 R
          ON R.COD_MESTRE_EVENTO = S.COD_MESTRE_EVENTO
        JOIN DADOS_ATU A
          ON A.COD_CONTRATO = S.COD_CONTRATO
        CROSS JOIN PARAMS P
        WHERE S.COD_VD = 1700
          AND R.COD_EVENTO = 1
          AND R.DATA_REFERENCIA = P.DT_REF_DEZ
    )
    WHERE RN = 1
),

/* Adicionais só do período do cargo anterior */
ADIC AS (
    SELECT
        A.COD_CONTRATO,
        NVL(SUM(B.QTDE_VD), 0)  AS TOT_ADIC,
        NVL(SUM(B.VALOR_VD), 0) AS TOT_ADIC_VAL
    FROM DADOS_ANT A
    JOIN RHFP1006 B
      ON B.COD_CONTRATO = A.COD_CONTRATO
    JOIN RHFP1003 D
      ON D.COD_MESTRE_EVENTO = B.COD_MESTRE_EVENTO
    CROSS JOIN PARAMS P
    WHERE B.COD_MESTRE_EVENTO IN (
              17434,17503,17581,17644,17712,17804,
              17870,17962,18020,18103,18171,18236
          )
      AND B.COD_VD IN (631, 632, 831, 832, 833, 897)
      AND D.DATA_REFERENCIA BETWEEN GREATEST(A.DATA_INICIO_ANT, P.DT_INI)
                                AND LEAST(A.DATA_FIM_ANT, P.DT_FIM)
    GROUP BY A.COD_CONTRATO
),

/* Regras APR - ANTERIOR */
APR_ANT AS (
    SELECT
        A.COD_CONTRATO,
        A.COD_UNIDADE_ANT,
        U.TRI_1,
        U.TRI_2,
        U.TRI_3,
        U.TRI_4,
        U.PREJ,

        GREATEST(0, LEAST(NVL(A.DATA_FIM_ORG_ANT, A.DATA_FIM_ANT), TO_DATE('31/03/2025','DD/MM/YYYY'))
                    - GREATEST(A.DATA_INICIO_ORG_ANT, TO_DATE('01/01/2025','DD/MM/YYYY')) + 1) AS D_TRI_1,
        GREATEST(0, LEAST(NVL(A.DATA_FIM_ORG_ANT, A.DATA_FIM_ANT), TO_DATE('30/06/2025','DD/MM/YYYY'))
                    - GREATEST(A.DATA_INICIO_ORG_ANT, TO_DATE('01/04/2025','DD/MM/YYYY')) + 1) AS D_TRI_2,
        GREATEST(0, LEAST(NVL(A.DATA_FIM_ORG_ANT, A.DATA_FIM_ANT), TO_DATE('30/09/2025','DD/MM/YYYY'))
                    - GREATEST(A.DATA_INICIO_ORG_ANT, TO_DATE('01/07/2025','DD/MM/YYYY')) + 1) AS D_TRI_3,
        GREATEST(0, LEAST(NVL(A.DATA_FIM_ORG_ANT, A.DATA_FIM_ANT), TO_DATE('31/12/2025','DD/MM/YYYY'))
                    - GREATEST(A.DATA_INICIO_ORG_ANT, TO_DATE('01/10/2025','DD/MM/YYYY')) + 1) AS D_TRI_4,

        GREATEST(0,
            LEAST(NVL(A.DATA_FIM_ORG_ANT, A.DATA_FIM_ANT), P.DT_FIM)
            - GREATEST(A.DATA_INICIO_ORG_ANT, P.DT_INI) + 1
        ) AS D_UNID_ANT
    FROM DADOS_ANT A
    CROSS JOIN PARAMS P
    LEFT JOIN UNIDADES_APR U
      ON U.COD_UNIDADE = A.COD_UNIDADE_ANT
),

APR_ANT_FAT AS (
    SELECT
        A.COD_CONTRATO,
        NVL(A.TRI_1,0) AS TRI_1,
        NVL(A.TRI_2,0) AS TRI_2,
        NVL(A.TRI_3,0) AS TRI_3,
        NVL(A.TRI_4,0) AS TRI_4,
        NVL(A.PREJ,0)  AS PREJ,
        A.D_TRI_1,
        A.D_TRI_2,
        A.D_TRI_3,
        A.D_TRI_4,
        A.D_UNID_ANT,

        CASE WHEN A.COD_UNIDADE_ANT IS NOT NULL AND NVL(A.TRI_1,0)=1 AND A.D_TRI_1 >= 75 THEN 1 ELSE 0 END AS G_TRI_1,
        CASE WHEN A.COD_UNIDADE_ANT IS NOT NULL AND NVL(A.TRI_2,0)=1 AND A.D_TRI_2 >= 75 THEN 1 ELSE 0 END AS G_TRI_2,
        CASE WHEN A.COD_UNIDADE_ANT IS NOT NULL AND NVL(A.TRI_3,0)=1 AND A.D_TRI_3 >= 75 THEN 1 ELSE 0 END AS G_TRI_3,
        CASE WHEN A.COD_UNIDADE_ANT IS NOT NULL AND NVL(A.TRI_4,0)=1 AND A.D_TRI_4 >= 75 THEN 1 ELSE 0 END AS G_TRI_4,

        1
        + 0.25 * (
            CASE WHEN A.COD_UNIDADE_ANT IS NOT NULL AND NVL(A.TRI_1,0)=1 AND A.D_TRI_1 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN A.COD_UNIDADE_ANT IS NOT NULL AND NVL(A.TRI_2,0)=1 AND A.D_TRI_2 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN A.COD_UNIDADE_ANT IS NOT NULL AND NVL(A.TRI_3,0)=1 AND A.D_TRI_3 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN A.COD_UNIDADE_ANT IS NOT NULL AND NVL(A.TRI_4,0)=1 AND A.D_TRI_4 >= 75 THEN 1 ELSE 0 END
        ) AS FAT_TRI_ANT,

        CASE
            WHEN A.COD_UNIDADE_ANT IS NOT NULL
             AND NVL(A.PREJ,0)=1
             AND A.D_UNID_ANT >= 75
            THEN 0.50
            ELSE 1
        END AS FAT_PREJ_ANT
    FROM APR_ANT A
),

/* Regras APR - ATUAL */
APR_ATU AS (
    SELECT
        A.COD_CONTRATO,
        A.COD_UNIDADE,
        U.TRI_1,
        U.TRI_2,
        U.TRI_3,
        U.TRI_4,
        U.PREJ,

        GREATEST(0, LEAST(NVL(A.DATA_FIM_ORG, P.DT_FIM), TO_DATE('31/03/2025','DD/MM/YYYY'))
                    - GREATEST(A.DATA_INI_ORG, TO_DATE('01/01/2025','DD/MM/YYYY')) + 1) AS D_TRI_1,
        GREATEST(0, LEAST(NVL(A.DATA_FIM_ORG, P.DT_FIM), TO_DATE('30/06/2025','DD/MM/YYYY'))
                    - GREATEST(A.DATA_INI_ORG, TO_DATE('01/04/2025','DD/MM/YYYY')) + 1) AS D_TRI_2,
        GREATEST(0, LEAST(NVL(A.DATA_FIM_ORG, P.DT_FIM), TO_DATE('30/09/2025','DD/MM/YYYY'))
                    - GREATEST(A.DATA_INI_ORG, TO_DATE('01/07/2025','DD/MM/YYYY')) + 1) AS D_TRI_3,
        GREATEST(0, LEAST(NVL(A.DATA_FIM_ORG, P.DT_FIM), TO_DATE('31/12/2025','DD/MM/YYYY'))
                    - GREATEST(A.DATA_INI_ORG, TO_DATE('01/10/2025','DD/MM/YYYY')) + 1) AS D_TRI_4,

        GREATEST(0,
            LEAST(NVL(A.DATA_FIM_ORG, P.DT_FIM), P.DT_FIM)
            - GREATEST(A.DATA_INI_ORG, P.DT_INI) + 1
        ) AS D_UNID_ATU
    FROM DADOS_ATU A
    CROSS JOIN PARAMS P
    LEFT JOIN UNIDADES_APR U
      ON U.COD_UNIDADE = A.COD_UNIDADE
),

APR_ATU_FAT AS (
    SELECT
        A.COD_CONTRATO,
        NVL(A.TRI_1,0) AS TRI_1,
        NVL(A.TRI_2,0) AS TRI_2,
        NVL(A.TRI_3,0) AS TRI_3,
        NVL(A.TRI_4,0) AS TRI_4,
        NVL(A.PREJ,0)  AS PREJ,
        A.D_TRI_1,
        A.D_TRI_2,
        A.D_TRI_3,
        A.D_TRI_4,
        A.D_UNID_ATU,

        CASE WHEN A.COD_UNIDADE IS NOT NULL AND NVL(A.TRI_1,0)=1 AND A.D_TRI_1 >= 75 THEN 1 ELSE 0 END AS G_TRI_1,
        CASE WHEN A.COD_UNIDADE IS NOT NULL AND NVL(A.TRI_2,0)=1 AND A.D_TRI_2 >= 75 THEN 1 ELSE 0 END AS G_TRI_2,
        CASE WHEN A.COD_UNIDADE IS NOT NULL AND NVL(A.TRI_3,0)=1 AND A.D_TRI_3 >= 75 THEN 1 ELSE 0 END AS G_TRI_3,
        CASE WHEN A.COD_UNIDADE IS NOT NULL AND NVL(A.TRI_4,0)=1 AND A.D_TRI_4 >= 75 THEN 1 ELSE 0 END AS G_TRI_4,

        1
        + 0.25 * (
            CASE WHEN A.COD_UNIDADE IS NOT NULL AND NVL(A.TRI_1,0)=1 AND A.D_TRI_1 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN A.COD_UNIDADE IS NOT NULL AND NVL(A.TRI_2,0)=1 AND A.D_TRI_2 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN A.COD_UNIDADE IS NOT NULL AND NVL(A.TRI_3,0)=1 AND A.D_TRI_3 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN A.COD_UNIDADE IS NOT NULL AND NVL(A.TRI_4,0)=1 AND A.D_TRI_4 >= 75 THEN 1 ELSE 0 END
        ) AS FAT_TRI_ATU,

        CASE
            WHEN A.COD_UNIDADE IS NOT NULL
             AND NVL(A.PREJ,0)=1
             AND A.D_UNID_ATU >= 75
            THEN 0.50
            ELSE 1
        END AS FAT_PREJ_ATU
    FROM APR_ATU A
),

/* Final anterior */
FINAL_ANT AS (
    SELECT
        A.*,
        S.SAL_ANT,
        S.REF_SAL_ANT,
        NVL(C.TOT_ADIC,0)     AS TOT_ADIC,
        NVL(C.TOT_ADIC_VAL,0) AS TOT_ADIC_VAL,

        F.TRI_1,
        F.TRI_2,
        F.TRI_3,
        F.TRI_4,
        F.PREJ,
        F.FAT_TRI_ANT,
        F.FAT_PREJ_ANT,

        /* salário base proporcional */
        ROUND(
            NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
        , 2) AS SAL_PROP_ANT_BAS,

        /* só multiplica por 2 se no anterior já era gerente e não houve prejuízo */
        ROUND(
            CASE
                WHEN F.FAT_PREJ_ANT = 0.50 THEN
                    NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
                WHEN A.DES_FUNCAO_ANT LIKE '%GERENTE%' THEN
                    (NVL(S.SAL_ANT,0) * 2) / 12 * NVL(A.MESES_ANT,0)
                ELSE
                    NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
            END
        , 2) AS SAL_PROP_ANT_GER,

        /* valor base ajustado anterior */
        ROUND(
            CASE
                WHEN F.FAT_PREJ_ANT = 0.50 THEN
                    NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
                WHEN A.DES_FUNCAO_ANT LIKE '%GERENTE%' THEN
                    (NVL(S.SAL_ANT,0) * 2) / 12 * NVL(A.MESES_ANT,0)
                ELSE
                    NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
            END
        , 2) AS SAL_PROP_ANT_AJ,

        /* trimestre só se não houve prejuízo */
        ROUND(
            CASE
                WHEN F.FAT_TRI_ANT > 1
                 AND F.FAT_PREJ_ANT = 1 THEN
                    (
                        CASE
                            WHEN A.DES_FUNCAO_ANT LIKE '%GERENTE%' THEN
                                ((NVL(S.SAL_ANT,0) * 2) / 12 * NVL(A.MESES_ANT,0))
                            ELSE
                                (NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0))
                        END
                    ) * (F.FAT_TRI_ANT - 1)
                ELSE
                    0
            END
        , 2) AS VLR_TRIMESTRE_ANT,

        ROUND(NVL(C.TOT_ADIC,0) / 2, 2) AS PERC_DESC_ADIC,

        /* desconto dos adicionais */
        ROUND(
            (
                CASE
                    WHEN F.FAT_PREJ_ANT = 0.50 THEN
                        NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
                    WHEN A.DES_FUNCAO_ANT LIKE '%GERENTE%' THEN
                        (NVL(S.SAL_ANT,0) * 2) / 12 * NVL(A.MESES_ANT,0)
                    ELSE
                        NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
                END
            ) * ((NVL(C.TOT_ADIC,0) / 2) / 100)
        , 2) AS VLR_DESC_ADIC,

        /* valor final líquido do anterior */
        ROUND(
            (
                CASE
                    WHEN F.FAT_PREJ_ANT = 0.50 THEN
                        NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
                    WHEN A.DES_FUNCAO_ANT LIKE '%GERENTE%' THEN
                        (NVL(S.SAL_ANT,0) * 2) / 12 * NVL(A.MESES_ANT,0)
                    ELSE
                        NVL(S.SAL_ANT,0) / 12 * NVL(A.MESES_ANT,0)
                END
            ) * (1 - ((NVL(C.TOT_ADIC,0) / 2) / 100))
        , 2) AS VLR_FIM_SAL_ANT

    FROM DADOS_ANT A
    JOIN SAL_ANT S
      ON S.COD_CONTRATO = A.COD_CONTRATO
    LEFT JOIN ADIC C
      ON C.COD_CONTRATO = A.COD_CONTRATO
    LEFT JOIN APR_ANT_FAT F
      ON F.COD_CONTRATO = A.COD_CONTRATO
),
/* Final atual */
FINAL_ATU AS (
    SELECT
        A.*,
        S.SAL_ATU,
        S.REF_SAL_ATU,

        F.TRI_1,
        F.TRI_2,
        F.TRI_3,
        F.TRI_4,
        F.PREJ,
        F.FAT_TRI_ATU,
        F.FAT_PREJ_ATU,

        /* salário base proporcional atual */
        ROUND(
            NVL(S.SAL_ATU,0) / 12 * NVL(A.MESES_ATU,0)
        , 2) AS SAL_PROP_ATU_BAS,

        /* no atual é gerente, então só usa x2 se não houve prejuízo */
        ROUND(
            CASE
                WHEN F.FAT_PREJ_ATU = 0.50 THEN
                    NVL(S.SAL_ATU,0) / 12 * NVL(A.MESES_ATU,0)
                ELSE
                    (NVL(S.SAL_ATU,0) * 2) / 12 * NVL(A.MESES_ATU,0)
            END
        , 2) AS SAL_PROP_ATU_GER,

        /* valor base ajustado atual */
        ROUND(
            CASE
                WHEN F.FAT_PREJ_ATU = 0.50 THEN
                    NVL(S.SAL_ATU,0) / 12 * NVL(A.MESES_ATU,0)
                ELSE
                    (NVL(S.SAL_ATU,0) * 2) / 12 * NVL(A.MESES_ATU,0)
            END
        , 2) AS SAL_PROP_ATU_AJ,

        /* trimestre só se não houve prejuízo */
        ROUND(
            CASE
                WHEN F.FAT_TRI_ATU > 1
                 AND F.FAT_PREJ_ATU = 1 THEN
                    (
                        (NVL(S.SAL_ATU,0) * 2) / 12 * NVL(A.MESES_ATU,0)
                    ) * (F.FAT_TRI_ATU - 1)
                ELSE
                    0
            END
        , 2) AS VLR_TRIMESTRE_ATU,

        /* valor final líquido atual */
        ROUND(
            CASE
                WHEN F.FAT_PREJ_ATU = 0.50 THEN
                    NVL(S.SAL_ATU,0) / 12 * NVL(A.MESES_ATU,0)
                ELSE
                    (NVL(S.SAL_ATU,0) * 2) / 12 * NVL(A.MESES_ATU,0)
            END
        , 2) AS VLR_FIM_SAL_ATU

    FROM DADOS_ATU A
    JOIN SAL_ATU S
      ON S.COD_CONTRATO = A.COD_CONTRATO
    LEFT JOIN APR_ATU_FAT F
      ON F.COD_CONTRATO = A.COD_CONTRATO
),

NOTAS_PLR AS (
    SELECT
        COD_UNIDADE,
        TOTAL_PTS
    FROM GRZ_KPI_NOTAS_PLR_2025_TB
    WHERE ANO = 2025
),

SELECT_FINAL AS (
SELECT
    COALESCE(A.COD_CONTRATO, U.COD_CONTRATO) AS COD_CONTRATO,
    COALESCE(A.DES_PESSOA, U.DES_PESSOA)     AS DES_PESSOA,
    COALESCE(A.DATA_ADMISSAO, U.DATA_ADMISSAO) AS DATA_ADMISSAO,

    /* ===== BLOCO ANTERIOR ===== */
    A.DES_FUNCAO_ANT      AS FUNCAO_ANTERIOR,
    A.DATA_INICIO_ANT || ' - ' || A.DATA_FIM_ANT AS PERIODO_FUNCAO_ANTERIOR,
    A.DES_UNIDADE_ANT     AS UNIDADE_ANTERIOR,
    A.DATA_INICIO_ORG_ANT || ' - ' || A.DATA_FIM_ORG_ANT AS PERIODO_UNIDADE_ANTERIOR,
    A.MESES_ANT           AS MESES_FUNCAO_ANTERIOR,
    A.SAL_ANT             AS SALARIO_ANTERIOR,
    A.REF_SAL_ANT         AS REF_SALARIO_ANTERIOR,
    A.TOT_ADIC            AS TOTAL_ADICIONAIS,
    A.TOT_ADIC_VAL        AS VLR_TOTAL_ADICIONAIS ,
    A.TRI_1               AS TRI_1_ANTERIOR,
    A.TRI_2               AS TRI_2_ANTERIOR,
    A.TRI_3               AS TRI_3_ANTERIOR,
    A.TRI_4               AS TRI_4_ANTERIOR,
    A.PREJ                AS PREJUIZO_ANTERIOR,
    --A.FAT_TRI_ANT         AS ANT_FAT_TRI,
    --A.FAT_PREJ_ANT        AS ANT_FAT_PREJ,
    A.SAL_PROP_ANT_BAS    AS SAL_BASE_PROPOR_ANTERIOR,
    A.SAL_PROP_ANT_GER    AS SAL_PROP_SE_FOR_GERENTE_ANT,
    A.SAL_PROP_ANT_AJ     AS SAL_PROPORCIONAL_AJ_ANTERIOR,
    A.VLR_TRIMESTRE_ANT   AS VLR_TRIMESTRE_ANTERIOR,
    A.PERC_DESC_ADIC      AS PERC_DESCONTO_ADICIONAIS,
    A.VLR_DESC_ADIC       AS VLR_DESCONTO_ADICIONAIS,
    A.VLR_FIM_SAL_ANT     AS VLR_FINAL_ANTERIOR,

    /* ===== BLOCO ATUAL ===== */
    U.DES_FUNCAO          AS FUNCAO_ATUAL,
    U.DATA_INICIO_CLH || ' - ' || U.DATA_FIM_CLH AS PERIODO_FUNCAO_ATUAL,
    U.DES_UNIDADE         AS UNIDADE_ATUAL,
    U.DATA_INI_ORG || ' - ' || U.DATA_FIM_ORG AS PERIODO_UNIDADE_ATUAL,
    U.MESES_ATU           AS MESES_FUNCAO_ATUAL,
    U.SAL_ATU             AS SALARIO_BASE_DEZEMBRO,
    U.REF_SAL_ATU         AS REF_SALARIO_DEZEMBRO,
    U.TRI_1               AS TRI_1_ATUAL,
    U.TRI_2               AS TRI_2_ATUAL,
    U.TRI_3               AS TRI_3_ATUAL,
    U.TRI_4               AS TRI_4_ATUAL,
    U.PREJ                AS PREJUIZO_ATUAL,
    --U.FAT_TRI_ATU         AS ATU_FAT_TRI,
    --U.FAT_PREJ_ATU        AS ATU_FAT_PREJ,
    U.SAL_PROP_ATU_BAS    AS SAL_BASE_PROPOR_ATUAL,
    U.SAL_PROP_ATU_GER    AS ATU_SAL_PROP_GERENTE,
    U.SAL_PROP_ATU_AJ     AS SAL_PROPORCIONAL_AJ_ATUAL,
    U.VLR_TRIMESTRE_ATU   AS VLR_TRIMESTRE_ATUAL,
    U.VLR_FIM_SAL_ATU     AS VLR_FINAL_ATUAL,

    /* ===== FECHAMENTO ===== */
    NVL(A.VLR_FIM_SAL_ANT, 0) AS GERAL_VLR_FINAL_ANTERIOR,
    NVL(U.VLR_FIM_SAL_ATU, 0) AS GERAL_VLR_FINAL_ATUAL,

    ROUND(
        CASE
            WHEN A.DES_FUNCAO_ANT LIKE '%GERENTE%' THEN
                NVL(A.VLR_FIM_SAL_ANT, 0) + NVL(U.VLR_FIM_SAL_ATU, 0)
            ELSE
                NVL(U.VLR_FIM_SAL_ATU, 0)
        END
    , 2) AS VLR_BASE_NOTA,

    ROUND(
        NVL(A.VLR_FIM_SAL_ANT, 0) + NVL(U.VLR_FIM_SAL_ATU, 0)
    , 2) AS VLR_FINAL_PARCIAL,

    ROUND(
        NVL(A.VLR_TRIMESTRE_ANT, 0) + NVL(U.VLR_TRIMESTRE_ATU, 0)
    , 2) AS VLR_TOTAL_TRIMESTRE,

    N.TOTAL_PTS AS NOTA,

    ROUND(
        CASE
            WHEN A.DES_FUNCAO_ANT LIKE '%GERENTE%' THEN
                (
                    (NVL(A.VLR_FIM_SAL_ANT, 0) + NVL(U.VLR_FIM_SAL_ATU, 0))
                    * (NVL(N.TOTAL_PTS, 0) / 100)
                )
                + NVL(A.VLR_TRIMESTRE_ANT, 0)
                + NVL(U.VLR_TRIMESTRE_ATU, 0)
            ELSE
                NVL(A.VLR_FIM_SAL_ANT, 0)
                +
                (
                    NVL(U.VLR_FIM_SAL_ATU, 0)
                    * (NVL(N.TOTAL_PTS, 0) / 100)
                )
                + NVL(A.VLR_TRIMESTRE_ANT, 0)
                + NVL(U.VLR_TRIMESTRE_ATU, 0)
        END
    , 2) AS VLR_FINAL_PLR

FROM FINAL_ANT A
FULL OUTER JOIN FINAL_ATU U
    ON A.COD_CONTRATO = U.COD_CONTRATO
LEFT JOIN NOTAS_PLR N
    ON N.COD_UNIDADE = U.COD_UNIDADE
ORDER BY COALESCE(A.DES_PESSOA, U.DES_PESSOA)
)

SELECT 
       /*colunas apenas para exportação das notas*/
       DISTINCT
       COD_CONTRATO,
       '30/04/2026' AS DATA_REFERENCIA,
       1146 AS COD_VD,
       NOTA
       /*colunas apenas para exportação dos valores*/
       /*DISTINCT
       COD_CONTRATO,
       '30/04/2026' AS DATA_REFERENCIA,
       219 AS COD_VD,
       VLR_FINAL_PLR*/
FROM SELECT_FINAL
