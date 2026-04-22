/*P.L.R GERENTES - INTEGRAL*/

WITH
PARAMS AS (
    SELECT
        TO_DATE('01/01/2025', 'DD/MM/YYYY') AS DT_INI,
        TO_DATE('31/12/2025', 'DD/MM/YYYY') AS DT_FIM,
        TO_DATE('31/12/2025', 'DD/MM/YYYY') AS DT_REF_DEZ
    FROM DUAL
),

/* mesmas lojas que bateram trimestre / prejuízo */
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

/* contratos que já foram para o proporcional */
TRANSICOES AS (
    SELECT /*+ MATERIALIZE */
           DISTINCT V.COD_CONTRATO
    FROM V_DADOS_COLAB_AVT V
    CROSS JOIN PARAMS P
    WHERE V.STATUS = 0
      AND V.COD_TIPO = 1
      AND V.DATA_FIM_ANT BETWEEN P.DT_INI AND P.DT_FIM
      AND NVL(V.STATUS_AFAST, 'EM ATIVIDADE') NOT IN (
                              'AFASTADO',
                              'ATIVO, SEM RETORNO',
                              'PODERÁ RETORNAR'
                          )
      AND V.DES_FUNCAO LIKE '%GERENTE%'
),

/* gerentes integrais = gerente ativo que NÃO está no proporcional */
GER_INT AS (
    SELECT /*+ MATERIALIZE */
           DISTINCT
           V.COD_CONTRATO,
           V.DES_PESSOA,
           V.DATA_ADMISSAO,
           V.DES_FUNCAO,
           V.DATA_INICIO_CLH
    FROM V_DADOS_COLAB_AVT V
    CROSS JOIN PARAMS P
    WHERE V.STATUS = 0
      AND V.COD_TIPO = 1
      AND V.DES_FUNCAO LIKE '%GERENTE%'
      AND V.DATA_INICIO_CLH <= P.DT_FIM
      AND NVL(V.STATUS_AFAST, 'EM ATIVIDADE') NOT IN (
            'AFASTADO',
            'ATIVO, SEM RETORNO',
            'PODERÁ RETORNAR'
      )
      AND V.COD_CONTRATO IN
      /*PASSARAM POR MAIS DE UMA LOJA EM 2025*/
      (383841, 391121, 390323, 302996, 394093, 383898, 391249, 
      393626, 378438, 312878, 380649, 388904, 388566, 388846,
      387631, 387099, 377769, 387316, 380271, 391210, 390686, 
      386740, 364150, 379903, 386675, 387665, 304166, 330558,
      376937, 378581)
      AND NOT EXISTS (
            SELECT 1
            FROM TRANSICOES T
            WHERE T.COD_CONTRATO = V.COD_CONTRATO
      )
),


/* salário de dezembro */
SAL_INT AS (
    SELECT *
    FROM (
        SELECT
            S.COD_CONTRATO,
            S.VALOR_VD AS SAL_INT,
            R.DATA_REFERENCIA AS REF_SAL_INT,
            ROW_NUMBER() OVER (
                PARTITION BY S.COD_CONTRATO
                ORDER BY R.DATA_REFERENCIA DESC
            ) AS RN
        FROM RHFP1006 S
        JOIN RHFP1003 R
          ON R.COD_MESTRE_EVENTO = S.COD_MESTRE_EVENTO
        JOIN GER_INT G
          ON G.COD_CONTRATO = S.COD_CONTRATO
        CROSS JOIN PARAMS P
        WHERE S.COD_VD = 1700
          AND R.COD_EVENTO = 1
          AND R.DATA_REFERENCIA = P.DT_REF_DEZ
    )
    WHERE RN = 1
),

/* períodos de unidade em 2025 */
UNID_INT AS (
    SELECT
        G.COD_CONTRATO,
        G.DES_PESSOA,
        G.DATA_ADMISSAO,
        G.DES_FUNCAO,
        O.COD_UNIDADE,
        O.DES_UNIDADE,
        O.DATA_INI_ORG,
        O.DATA_FIM_ORG,

        GREATEST(O.DATA_INI_ORG, P.DT_INI) AS DT_INI_CALC,
        LEAST(NVL(O.DATA_FIM_ORG, P.DT_FIM), P.DT_FIM) AS DT_FIM_CALC,

        GREATEST(
            0,
            (
                (
                    (EXTRACT(YEAR FROM LEAST(NVL(O.DATA_FIM_ORG, P.DT_FIM), P.DT_FIM))
                     - EXTRACT(YEAR FROM GREATEST(O.DATA_INI_ORG, P.DT_INI))) * 12
                )
                +
                (
                    EXTRACT(MONTH FROM LEAST(NVL(O.DATA_FIM_ORG, P.DT_FIM), P.DT_FIM))
                    - EXTRACT(MONTH FROM GREATEST(O.DATA_INI_ORG, P.DT_INI))
                )
                + 1
                - CASE
                    WHEN EXTRACT(DAY FROM GREATEST(O.DATA_INI_ORG, P.DT_INI)) > 15 THEN 1
                    ELSE 0
                  END
                - CASE
                    WHEN EXTRACT(DAY FROM LEAST(NVL(O.DATA_FIM_ORG, P.DT_FIM), P.DT_FIM)) <= 15 THEN 1
                    ELSE 0
                  END
            )
        ) AS MESES_INT
    FROM VH_EST_ORG_CONTRATO_AVT O
    JOIN GER_INT G
      ON G.COD_CONTRATO = O.COD_CONTRATO
    CROSS JOIN PARAMS P
    WHERE O.DATA_INI_ORG <= P.DT_FIM
      AND NVL(O.DATA_FIM_ORG, P.DT_FIM) >= P.DT_INI
),

APR_INT AS (
    SELECT
        U.COD_CONTRATO,
        U.DES_PESSOA,
        U.DATA_ADMISSAO,
        U.DES_FUNCAO,
        U.COD_UNIDADE,
        U.DES_UNIDADE,
        U.DATA_INI_ORG,
        U.DATA_FIM_ORG,
        U.DT_INI_CALC,
        U.DT_FIM_CALC,
        U.MESES_INT,

        A.TRI_1,
        A.TRI_2,
        A.TRI_3,
        A.TRI_4,
        A.PREJ,

        GREATEST(0, U.DT_FIM_CALC - U.DT_INI_CALC + 1) AS D_UNID_INT,

        GREATEST(0,
            LEAST(U.DT_FIM_CALC, TO_DATE('31/03/2025','DD/MM/YYYY'))
            - GREATEST(U.DT_INI_CALC, TO_DATE('01/01/2025','DD/MM/YYYY')) + 1
        ) AS D_TRI_1,

        GREATEST(0,
            LEAST(U.DT_FIM_CALC, TO_DATE('30/06/2025','DD/MM/YYYY'))
            - GREATEST(U.DT_INI_CALC, TO_DATE('01/04/2025','DD/MM/YYYY')) + 1
        ) AS D_TRI_2,

        GREATEST(0,
            LEAST(U.DT_FIM_CALC, TO_DATE('30/09/2025','DD/MM/YYYY'))
            - GREATEST(U.DT_INI_CALC, TO_DATE('01/07/2025','DD/MM/YYYY')) + 1
        ) AS D_TRI_3,

        GREATEST(0,
            LEAST(U.DT_FIM_CALC, TO_DATE('31/12/2025','DD/MM/YYYY'))
            - GREATEST(U.DT_INI_CALC, TO_DATE('01/10/2025','DD/MM/YYYY')) + 1
        ) AS D_TRI_4
    FROM UNID_INT U
    LEFT JOIN UNIDADES_APR A
      ON A.COD_UNIDADE = U.COD_UNIDADE
),

APR_INT_FAT AS (
    SELECT
        A.*,

        CASE WHEN NVL(A.TRI_1,0)=1 AND A.D_TRI_1 >= 75 THEN 1 ELSE 0 END AS G_TRI_1,
        CASE WHEN NVL(A.TRI_2,0)=1 AND A.D_TRI_2 >= 75 THEN 1 ELSE 0 END AS G_TRI_2,
        CASE WHEN NVL(A.TRI_3,0)=1 AND A.D_TRI_3 >= 75 THEN 1 ELSE 0 END AS G_TRI_3,
        CASE WHEN NVL(A.TRI_4,0)=1 AND A.D_TRI_4 >= 75 THEN 1 ELSE 0 END AS G_TRI_4,

        1
        + 0.25 * (
            CASE WHEN NVL(A.TRI_1,0)=1 AND A.D_TRI_1 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN NVL(A.TRI_2,0)=1 AND A.D_TRI_2 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN NVL(A.TRI_3,0)=1 AND A.D_TRI_3 >= 75 THEN 1 ELSE 0 END
          + CASE WHEN NVL(A.TRI_4,0)=1 AND A.D_TRI_4 >= 75 THEN 1 ELSE 0 END
        ) AS FAT_TRI_INT,

        CASE
            WHEN NVL(A.PREJ,0)=1
             AND A.D_UNID_INT >= 75
            THEN 0.50
            ELSE 1
        END AS FAT_PREJ_INT
    FROM APR_INT A
),


NOTAS_PLR AS (
    SELECT
        DECODE(COD_UNIDADE,
            7022, 22,
            7047, 47,
            7059, 59,
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
            7643, 643,
            COD_UNIDADE
        ) AS COD_UNIDADE,
        TOTAL_PTS
    FROM GRZ_KPI_NOTAS_PLR_2025_TB
    WHERE ANO = 2025
),

FINAL_INT_DET AS (
    SELECT
        A.COD_CONTRATO,
        A.DES_PESSOA,
        A.DATA_ADMISSAO,
        A.DES_FUNCAO,
        A.COD_UNIDADE,
        A.DES_UNIDADE,
        A.DATA_INI_ORG,
        A.DATA_FIM_ORG,
        A.DT_INI_CALC,
        A.DT_FIM_CALC,
        A.MESES_INT,

        S.SAL_INT,
        S.REF_SAL_INT,

        A.TRI_1,
        A.TRI_2,
        A.TRI_3,
        A.TRI_4,
        A.PREJ,
        A.FAT_TRI_INT,
        A.FAT_PREJ_INT,

        ROUND(
            NVL(S.SAL_INT,0)
        , 2) AS SALARIO_BASE,

        ROUND(
            NVL(S.SAL_INT,0) * 2
        , 2) AS BASE_SOBRE_2,

        /* base final antes da nota:
           com prejuízo = 1 salário
           sem prejuízo = 2 salários */
        ROUND(
            CASE
                WHEN A.FAT_PREJ_INT = 0.50 THEN
                    NVL(S.SAL_INT,0)
                ELSE
                    NVL(S.SAL_INT,0) * 2
            END
        , 2) AS TOTAL_COM_OU_SEM_PREJ,

        /* trimestre só entra se não houve prejuízo */
        ROUND(
            CASE
                WHEN A.FAT_TRI_INT > 1
                 AND A.FAT_PREJ_INT = 1 THEN
                    (NVL(S.SAL_INT,0) * 2) * (A.FAT_TRI_INT - 1)
                ELSE
                    0
            END
        , 2) AS VLR_TRIMESTRE,

        /* valor parcial com nota, sem trimestre */
        ROUND(
            CASE
                WHEN A.FAT_PREJ_INT = 0.50 THEN
                    NVL(S.SAL_INT,0) * (NVL(N.TOTAL_PTS,0) / 100)
                ELSE
                    (NVL(S.SAL_INT,0) * 2) * (NVL(N.TOTAL_PTS,0) / 100)
            END
        , 2) AS VLR_FINAL_SEM_NOTA,

        N.TOTAL_PTS AS NOTA,

        /* valor final da PLR */
        ROUND(
            CASE
                WHEN A.FAT_PREJ_INT = 0.50 THEN
                    NVL(S.SAL_INT,0) * (NVL(N.TOTAL_PTS,0) / 100)
                WHEN A.FAT_TRI_INT > 1 THEN
                    ((NVL(S.SAL_INT,0) * 2) * (NVL(N.TOTAL_PTS,0) / 100))
                    + ((NVL(S.SAL_INT,0) * 2) * (A.FAT_TRI_INT - 1))
                ELSE
                    (NVL(S.SAL_INT,0) * 2) * (NVL(N.TOTAL_PTS,0) / 100)
            END
        , 2) AS VLR_FINAL_PLR

    FROM APR_INT_FAT A
    JOIN SAL_INT S
      ON S.COD_CONTRATO = A.COD_CONTRATO
    LEFT JOIN NOTAS_PLR N
      ON N.COD_UNIDADE =
         DECODE(A.COD_UNIDADE,
            7022, 22,
            7047, 47,
            7059, 59,
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
            7643, 643,
            A.COD_UNIDADE
         )
),

FINAL_INT_RES AS (
    SELECT
        COD_CONTRATO,
        MAX(DES_PESSOA)     AS DES_PESSOA,
        MAX(DATA_ADMISSAO)  AS DATA_ADMISSAO,
        MAX(DES_FUNCAO)     AS DES_FUNCAO,
        MAX(SAL_INT)        AS SAL_INT,
        MAX(REF_SAL_INT)    AS REF_SAL_INT,
        ROUND(SUM(VLR_FINAL_SEM_NOTA), 2) AS VLR_TOTAL_INT
    FROM FINAL_INT_DET
    GROUP BY COD_CONTRATO
)

SELECT *
        /*colunas para exportar notas*/
        /*DISTINCT
        COD_CONTRATO,
        '30/04/2026' AS DATA_REFERENCIA,
        1146 AS COD_VD,
        NOTA*/
       /*colunas apenas pra exportação dos valores*/
       /*DISTINCT
       COD_CONTRATO,
       '30/04/2026' AS DATA_REFERENCIA,
       219 AS COD_VD,
       VLR_FINAL_PLR*/
FROM FINAL_INT_DET
WHERE VLR_FINAL_PLR <> 0
ORDER BY COD_UNIDADE, DES_PESSOA, DT_INI_CALC;










