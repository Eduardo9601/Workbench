/* RELAÇÃO ANALÍTICA QUANTITATIVA DO QUADRO DE COLABORADORES
   Ajustado para bater com o REL0112 - Perfil de Colaboradores
   Referência: :DATA_REFERENCIA
*/

WITH
PARAMS AS (
    SELECT
        TRUNC(CAST(:DATA_REFERENCIA AS DATE)) AS DATA_REFERENCIA
    FROM DUAL
),


DIVISOES_ADM AS (
    SELECT '705' AS COD_DIVISAO, 'PRESIDENCIA' AS DES_DIVISAO FROM DUAL UNION ALL
    SELECT '707', 'VICE-PRESIDENCIA' FROM DUAL UNION ALL
    SELECT '720', 'DIRETORIA COMERCIAL' FROM DUAL UNION ALL
    SELECT '730', 'DIRETORIA ADMINISTRATIVA' FROM DUAL UNION ALL
    SELECT '740', 'DIRETORIA TECNOLOGIA DA INFORMAÇÃO' FROM DUAL UNION ALL
    SELECT '750', 'DIRETORIA FINANCEIRA' FROM DUAL UNION ALL
    SELECT '780', 'DIRETORIA RECURSOS HUMANOS' FROM DUAL
),

/* =========================================================
   1. BASE-MÃE IGUAL AO RELATÓRIO DE PERFIS
========================================================= */
DADOS AS (
    SELECT DISTINCT
           V.COD_PESSOA,
           V.COD_CONTRATO,
           V.DES_PESSOA,
           V.DATA_ADMISSAO,
           V.DATA_DEMISSAO,
           V.SEXO,
           NVL(V.COD_AFAST, 0) AS COD_AFAST,
           V.DES_AFAST,
           V.STATUS_AFAST,
           V.COD_EMP,
           V.DES_EMPRESA,
           V.COD_REDE_LOCAL,
           V.DES_REDE_LOCAL
    FROM V_DADOS_COLAB_AVT V
    WHERE V.COD_EMP = 8
),

BASE_CONTRATOS_REF AS (
    SELECT
        D.*,
        P.DATA_REFERENCIA
    FROM DADOS D
    CROSS JOIN PARAMS P
    WHERE TRUNC(D.DATA_ADMISSAO) <= P.DATA_REFERENCIA
      AND (
             D.DATA_DEMISSAO IS NULL
          OR TRUNC(D.DATA_DEMISSAO) >= P.DATA_REFERENCIA
      )
),

BASE_PERFIL AS (
    SELECT *
    FROM (
        SELECT
            B.*,
            ROW_NUMBER() OVER (
                PARTITION BY B.COD_CONTRATO
                ORDER BY
                    NVL(B.DATA_DEMISSAO, DATE '2999-12-31') DESC,
                    B.DATA_ADMISSAO DESC,
                    B.COD_CONTRATO DESC
            ) AS RN_CONTRATO
        FROM BASE_CONTRATOS_REF B
    )
    WHERE RN_CONTRATO = 1
),

/* =========================================================
   2. ORGANOGRAMA VIGENTE NA REFERÊNCIA
   Usado para detalhar setor/divisão da administração.
========================================================= */
ORG_REF AS (
    SELECT *
    FROM (
        SELECT
            H.COD_CONTRATO,

            H.DATA_INICIO AS DATA_INI_ORG,
            H.DATA_FIM    AS DATA_FIM_ORG,
            H.COD_ORGANOGRAMA,

            A.COD_ORG_2 AS COD_EMP,
            A.EDICAO_ORG_2 AS EDICAO_EMP,
            A.NOME2 AS DES_EMP,

            A.EDICAO_ORG AS COD_UNIDADE,
            A.NOME_ORGANOGRAMA_B AS DES_UNIDADE,

            A.DATA_INICIO,
            A.DATA_FIM,

            A.COD_ORG_1,
            A.EDICAO_ORG_1,
            A.NOME1,

            A.COD_ORG_2,
            A.EDICAO_ORG_2,
            A.NOME2,

            A.COD_ORG_3,
            A.EDICAO_ORG_3,
            A.NOME3,

            A.COD_ORG_4,
            A.EDICAO_ORG_4,
            A.NOME4,

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
                PARTITION BY H.COD_CONTRATO
                ORDER BY
                    /* 1º: histórico do contrato vigente na referência */
                    CASE
                        WHEN P.DATA_REFERENCIA BETWEEN TRUNC(H.DATA_INICIO)
                                                  AND NVL(TRUNC(H.DATA_FIM), DATE '2999-12-31')
                        THEN 0
                        ELSE 1
                    END,

                    /* 2º: estrutura do organograma vigente na referência */
                    CASE
                        WHEN P.DATA_REFERENCIA BETWEEN TRUNC(A.DATA_INICIO)
                                                  AND NVL(TRUNC(A.DATA_FIM), DATE '2999-12-31')
                        THEN 0
                        ELSE 1
                    END,

                    /* 3º: prioriza quem possui uma diretoria oficial em qualquer nível */
                    CASE
                        WHEN '705' IN (
                                TO_CHAR(A.EDICAO_ORG_1), TO_CHAR(A.EDICAO_ORG_2),
                                TO_CHAR(A.EDICAO_ORG_3), TO_CHAR(A.EDICAO_ORG_4),
                                TO_CHAR(A.EDICAO_ORG_5), TO_CHAR(A.EDICAO_ORG_6),
                                TO_CHAR(A.EDICAO_ORG_7), TO_CHAR(A.EDICAO_ORG_8)
                             )
                          OR '707' IN (
                                TO_CHAR(A.EDICAO_ORG_1), TO_CHAR(A.EDICAO_ORG_2),
                                TO_CHAR(A.EDICAO_ORG_3), TO_CHAR(A.EDICAO_ORG_4),
                                TO_CHAR(A.EDICAO_ORG_5), TO_CHAR(A.EDICAO_ORG_6),
                                TO_CHAR(A.EDICAO_ORG_7), TO_CHAR(A.EDICAO_ORG_8)
                             )
                          OR '720' IN (
                                TO_CHAR(A.EDICAO_ORG_1), TO_CHAR(A.EDICAO_ORG_2),
                                TO_CHAR(A.EDICAO_ORG_3), TO_CHAR(A.EDICAO_ORG_4),
                                TO_CHAR(A.EDICAO_ORG_5), TO_CHAR(A.EDICAO_ORG_6),
                                TO_CHAR(A.EDICAO_ORG_7), TO_CHAR(A.EDICAO_ORG_8)
                             )
                          OR '730' IN (
                                TO_CHAR(A.EDICAO_ORG_1), TO_CHAR(A.EDICAO_ORG_2),
                                TO_CHAR(A.EDICAO_ORG_3), TO_CHAR(A.EDICAO_ORG_4),
                                TO_CHAR(A.EDICAO_ORG_5), TO_CHAR(A.EDICAO_ORG_6),
                                TO_CHAR(A.EDICAO_ORG_7), TO_CHAR(A.EDICAO_ORG_8)
                             )
                          OR '740' IN (
                                TO_CHAR(A.EDICAO_ORG_1), TO_CHAR(A.EDICAO_ORG_2),
                                TO_CHAR(A.EDICAO_ORG_3), TO_CHAR(A.EDICAO_ORG_4),
                                TO_CHAR(A.EDICAO_ORG_5), TO_CHAR(A.EDICAO_ORG_6),
                                TO_CHAR(A.EDICAO_ORG_7), TO_CHAR(A.EDICAO_ORG_8)
                             )
                          OR '750' IN (
                                TO_CHAR(A.EDICAO_ORG_1), TO_CHAR(A.EDICAO_ORG_2),
                                TO_CHAR(A.EDICAO_ORG_3), TO_CHAR(A.EDICAO_ORG_4),
                                TO_CHAR(A.EDICAO_ORG_5), TO_CHAR(A.EDICAO_ORG_6),
                                TO_CHAR(A.EDICAO_ORG_7), TO_CHAR(A.EDICAO_ORG_8)
                             )
                          OR '780' IN (
                                TO_CHAR(A.EDICAO_ORG_1), TO_CHAR(A.EDICAO_ORG_2),
                                TO_CHAR(A.EDICAO_ORG_3), TO_CHAR(A.EDICAO_ORG_4),
                                TO_CHAR(A.EDICAO_ORG_5), TO_CHAR(A.EDICAO_ORG_6),
                                TO_CHAR(A.EDICAO_ORG_7), TO_CHAR(A.EDICAO_ORG_8)
                             )
                        THEN 0
                        ELSE 1
                    END,

                    H.DATA_INICIO DESC,
                    A.DATA_INICIO DESC,
                    NVL(H.DATA_FIM, DATE '2999-12-31') DESC,
                    NVL(A.DATA_FIM, DATE '2999-12-31') DESC
            ) AS RN_ORG

        FROM RHFP0310 H
        INNER JOIN V_EST_ORG_ALTER_AVT A
            ON A.COD_ORGANOGRAMA = H.COD_ORGANOGRAMA
        CROSS JOIN PARAMS P
        WHERE A.COD_ORG_2 = 8
          AND TRUNC(H.DATA_INICIO) <= P.DATA_REFERENCIA
          AND TRUNC(A.DATA_INICIO) <= P.DATA_REFERENCIA
    )
    WHERE RN_ORG = 1
),


ADM_DIVISAO_REF AS (
    SELECT *
    FROM (
        SELECT
            O.COD_CONTRATO,

            CASE
                WHEN '705' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN '705'

                WHEN '707' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN '707'

                WHEN '720' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN '720'

                WHEN '730' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN '730'

                WHEN '740' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN '740'

                WHEN '750' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN '750'

                WHEN '780' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN '780'
            END AS COD_DIVISAO_ADM,

            CASE
                WHEN '705' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN 'PRESIDENCIA'

                WHEN '707' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN 'VICE-PRESIDENCIA'

                WHEN '720' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN 'DIRETORIA COMERCIAL'

                WHEN '730' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN 'DIRETORIA ADMINISTRATIVA'

                WHEN '740' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN 'DIRETORIA TECNOLOGIA DA INFORMAÇÃO'

                WHEN '750' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN 'DIRETORIA FINANCEIRA'

                WHEN '780' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                ) THEN 'DIRETORIA RECURSOS HUMANOS'
            END AS DES_DIVISAO_ADM,

            ROW_NUMBER() OVER (
                PARTITION BY O.COD_CONTRATO
                ORDER BY
                    CASE
                        WHEN P.DATA_REFERENCIA BETWEEN TRUNC(O.DATA_INI_ORG)
                                                  AND NVL(TRUNC(O.DATA_FIM_ORG), DATE '2999-12-31')
                         AND P.DATA_REFERENCIA BETWEEN TRUNC(O.DATA_INICIO)
                                                  AND NVL(TRUNC(O.DATA_FIM), DATE '2999-12-31')
                        THEN 0
                        ELSE 1
                    END,

                    O.DATA_INICIO DESC,
                    O.DATA_INI_ORG DESC,
                    NVL(O.DATA_FIM, DATE '2999-12-31') DESC,
                    NVL(O.DATA_FIM_ORG, DATE '2999-12-31') DESC
            ) AS RN_DIV

        FROM VH_EST_ORG_CONTRATO_AVT O
        CROSS JOIN PARAMS P
        WHERE O.COD_EMP = 8
          AND TRUNC(O.DATA_INICIO) <= P.DATA_REFERENCIA
          AND TRUNC(O.DATA_INI_ORG) <= P.DATA_REFERENCIA

          AND (
                '705' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                )
             OR '707' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                )
             OR '720' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                )
             OR '730' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                )
             OR '740' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                )
             OR '750' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                )
             OR '780' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2), TO_CHAR(O.EDICAO_ORG_3),
                    TO_CHAR(O.EDICAO_ORG_4), TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6)
                )
          )
    )
    WHERE RN_DIV = 1
),

/* =========================================================
   3. CARGO/FUNÇÃO VIGENTE NA REFERÊNCIA
   LEFT JOIN para não excluir colaborador da base.
========================================================= */
CARGO_REF AS (
    SELECT *
    FROM (
        SELECT
            F.COD_CONTRATO,
            F.COD_FUNCAO,
            F.DES_FUNCAO,
            ROW_NUMBER() OVER (
                PARTITION BY F.COD_CONTRATO
                ORDER BY
                    F.DATA_INI_CLH DESC,
                    NVL(F.DATA_FIM_CLH, DATE '2999-12-31') DESC
            ) AS RN_CARGO
        FROM VH_CARGO_CONTRATO_AVT F
        CROSS JOIN PARAMS P
        WHERE P.DATA_REFERENCIA BETWEEN TRUNC(F.DATA_INI_CLH)
                                    AND NVL(TRUNC(F.DATA_FIM_CLH), DATE '2999-12-31')
    )
    WHERE RN_CARGO = 1
),

/* =========================================================
   4. BASE FINAL DO RELATÓRIO
========================================================= */
BASE_REL AS (
    SELECT
        B.COD_PESSOA,
        B.COD_CONTRATO,
        B.DES_PESSOA,
        B.DATA_ADMISSAO,
        B.DATA_DEMISSAO,
        B.SEXO,
        B.COD_AFAST,
        B.DES_AFAST,
        B.STATUS_AFAST,

        B.COD_EMP,
        LPAD(B.COD_EMP, 3, '0') AS EDICAO_EMP,
        B.DES_EMPRESA AS DES_EMP,

        /* Local oficial conforme relatório de Perfis */
        B.COD_REDE_LOCAL AS COD_REDE_PERFIL,
        B.DES_REDE_LOCAL AS DES_REDE_PERFIL,

        /* Dados históricos de organograma */
        O.COD_UNIDADE,
        O.DES_UNIDADE,
        O.COD_REDE AS COD_REDE_ORG,
        O.DES_REDE AS DES_REDE_ORG,
        O.COD_TIPO,
        O.DES_TIPO,
        O.EDICAO_ORG_3,
        O.NOME3,
        O.EDICAO_ORG_4,
        O.NOME4,

        CASE
            WHEN B.COD_REDE_LOCAL = 1
             AND '705' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN '705'

            WHEN B.COD_REDE_LOCAL = 1
             AND '707' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN '707'

            WHEN B.COD_REDE_LOCAL = 1
             AND '720' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN '720'

            WHEN B.COD_REDE_LOCAL = 1
             AND '730' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN '730'

            WHEN B.COD_REDE_LOCAL = 1
             AND '740' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN '740'

            WHEN B.COD_REDE_LOCAL = 1
             AND '750' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN '750'

            WHEN B.COD_REDE_LOCAL = 1
             AND '780' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN '780'

            ELSE NULL
        END AS COD_DIVISAO_AJUSTADO,

        CASE
            WHEN B.COD_REDE_LOCAL = 1
             AND '705' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN 'PRESIDENCIA'

            WHEN B.COD_REDE_LOCAL = 1
             AND '707' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN 'VICE-PRESIDENCIA'

            WHEN B.COD_REDE_LOCAL = 1
             AND '720' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN 'DIRETORIA COMERCIAL'

            WHEN B.COD_REDE_LOCAL = 1
             AND '730' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN 'DIRETORIA ADMINISTRATIVA'

            WHEN B.COD_REDE_LOCAL = 1
             AND '740' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN 'DIRETORIA TECNOLOGIA DA INFORMAÇÃO'

            WHEN B.COD_REDE_LOCAL = 1
             AND '750' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN 'DIRETORIA FINANCEIRA'

            WHEN B.COD_REDE_LOCAL = 1
             AND '780' IN (
                    TO_CHAR(O.EDICAO_ORG_1), TO_CHAR(O.EDICAO_ORG_2),
                    TO_CHAR(O.EDICAO_ORG_3), TO_CHAR(O.EDICAO_ORG_4),
                    TO_CHAR(O.EDICAO_ORG_5), TO_CHAR(O.EDICAO_ORG_6),
                    TO_CHAR(O.EDICAO_ORG_7), TO_CHAR(O.EDICAO_ORG_8)
                 )
                THEN 'DIRETORIA RECURSOS HUMANOS'

            ELSE NULL
        END AS DES_DIVISAO_AJUSTADO,

        C.COD_FUNCAO,
        C.DES_FUNCAO,
        UPPER(NVL(C.DES_FUNCAO, '')) AS DES_FUNCAO_UPPER,

        /* =================================================
           Categoria funcional única e fechada.
           Essa regra garante que as categorias somam o total.
        ================================================= */
        CASE
            WHEN NVL(B.COD_AFAST, 0) NOT IN (0, 7)
                THEN 'AFASTADO'

            WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%ESTAGI%'
                THEN 'ESTAGIARIO'

            WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%APRENDIZ%'
                THEN 'APRENDIZ'

            WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%SERVENTE%'
                THEN 'SERVENTE'

            ELSE 'COLABORADOR'
        END AS CATEGORIA_FUNCIONAL

FROM BASE_PERFIL B
LEFT JOIN ORG_REF O
    ON O.COD_CONTRATO = B.COD_CONTRATO
LEFT JOIN ADM_DIVISAO_REF AD
    ON AD.COD_CONTRATO = B.COD_CONTRATO
LEFT JOIN CARGO_REF C
    ON C.COD_CONTRATO = B.COD_CONTRATO
),

/* =========================================================
   5. AGRUPAMENTOS DO RELATÓRIO
   Todos nascem da mesma BASE_REL.
========================================================= */
LINHAS_AGRUPAMENTO AS (
    /* Administração por divisão oficial */
    SELECT
        'ADM' AS BLOCO,
        COD_DIVISAO_AJUSTADO AS COD_LOCAL,
        DES_DIVISAO_AJUSTADO AS DES_LOCAL,
        B.*
    FROM BASE_REL B
    WHERE B.COD_REDE_PERFIL = 1
      AND B.COD_DIVISAO_AJUSTADO IN ('705', '707', '720', '730', '740', '750', '780')

    UNION ALL

    /* Logística */
    SELECT
        'CD' AS BLOCO,
        TO_CHAR(COD_REDE_PERFIL) AS COD_LOCAL,
        DES_REDE_PERFIL AS DES_LOCAL,
        B.*
    FROM BASE_REL B
    WHERE B.COD_REDE_PERFIL = 13

    UNION ALL

    /* Administração total */
    SELECT
        'ADM_TOT' AS BLOCO,
        TO_CHAR(COD_REDE_PERFIL) AS COD_LOCAL,
        DES_REDE_PERFIL AS DES_LOCAL,
        B.*
    FROM BASE_REL B
    WHERE B.COD_REDE_PERFIL = 1

    UNION ALL

    /* Administração + Logística */
    SELECT
        'ADM_CD' AS BLOCO,
        '001/013' AS COD_LOCAL,
        'ADMINISTRAÇÃO/LOGÍSTICA' AS DES_LOCAL,
        B.*
    FROM BASE_REL B
    WHERE B.COD_REDE_PERFIL IN (1, 13)

    UNION ALL

    /* Redes separadas */
    SELECT
        'REDES' AS BLOCO,
        TO_CHAR(COD_REDE_PERFIL) AS COD_LOCAL,
        DES_REDE_PERFIL AS DES_LOCAL,
        B.*
    FROM BASE_REL B
    WHERE B.COD_REDE_PERFIL IN (10, 30, 40, 50, 70)

    UNION ALL

    /* Total lojas */
    SELECT
        'LOJAS' AS BLOCO,
        '1' AS COD_LOCAL,
        'LOJAS' AS DES_LOCAL,
        B.*
    FROM BASE_REL B
    WHERE B.COD_REDE_PERFIL IN (10, 30, 40, 50, 70)

    UNION ALL

    /* Total empresa */
    SELECT
        'EMP' AS BLOCO,
        EDICAO_EMP AS COD_LOCAL,
        DES_EMP AS DES_LOCAL,
        B.*
    FROM BASE_REL B
    WHERE B.COD_EMP = 8
),

/* =========================================================
   6. MÉTRICAS
   Categorias fechadas: soma sempre bate com TOT_COLAB.
========================================================= */
METRICAS_BASE AS (
    SELECT
        BLOCO,
        COD_LOCAL,
        DES_LOCAL,

        COUNT(DISTINCT CASE
            WHEN CATEGORIA_FUNCIONAL = 'COLABORADOR'
            THEN COD_CONTRATO
        END) AS QTD_COLABS,

        COUNT(DISTINCT CASE
            WHEN CATEGORIA_FUNCIONAL = 'ESTAGIARIO'
            THEN COD_CONTRATO
        END) AS QTD_ESTAG,

        COUNT(DISTINCT CASE
            WHEN CATEGORIA_FUNCIONAL = 'APRENDIZ'
            THEN COD_CONTRATO
        END) AS QTD_APRE,

        COUNT(DISTINCT CASE
            WHEN CATEGORIA_FUNCIONAL = 'SERVENTE'
            THEN COD_CONTRATO
        END) AS QTD_SERV,

        COUNT(DISTINCT CASE
            WHEN CATEGORIA_FUNCIONAL = 'AFASTADO'
            THEN COD_CONTRATO
        END) AS QTD_AFAST,

        COUNT(DISTINCT CASE
            WHEN SEXO = 'F'
            THEN COD_CONTRATO
        END) AS QTD_COLAB_FEM,

        COUNT(DISTINCT CASE
            WHEN SEXO = 'M'
            THEN COD_CONTRATO
        END) AS QTD_COLAB_MASC,

        COUNT(DISTINCT COD_CONTRATO) AS TOT_COLAB

    FROM LINHAS_AGRUPAMENTO
    GROUP BY
        BLOCO,
        COD_LOCAL,
        DES_LOCAL
),

METRICAS AS (
    SELECT
        BLOCO,
        COD_LOCAL,
        DES_LOCAL,
        QTD_COLABS,
        QTD_ESTAG,
        QTD_APRE,
        QTD_SERV,
        QTD_AFAST,
        QTD_COLAB_FEM,
        ROUND(QTD_COLAB_FEM * 100 / NULLIF(TOT_COLAB, 0), 2) AS PERC_FEM,
        QTD_COLAB_MASC,
        ROUND(QTD_COLAB_MASC * 100 / NULLIF(TOT_COLAB, 0), 2) AS PERC_MASC,
        TOT_COLAB,

        /* Validadores internos para conferência */
        TOT_COLAB
        - (
              QTD_COLABS
            + QTD_ESTAG
            + QTD_APRE
            + QTD_SERV
            + QTD_AFAST
          ) AS DIF_CLASSIFICACAO,

        TOT_COLAB
        - (
              QTD_COLAB_FEM
            + QTD_COLAB_MASC
          ) AS DIF_SEXO

    FROM METRICAS_BASE
),

/* =========================================================
   7. NUMERAÇÃO DOS BLOCOS PARA RELATÓRIO LADO A LADO
========================================================= */
ADM_NUM AS (
    SELECT ROW_NUMBER() OVER (ORDER BY COD_LOCAL) AS RN, M.*
    FROM METRICAS M
    WHERE BLOCO = 'ADM'
),

CD_NUM AS (
    SELECT ROW_NUMBER() OVER (ORDER BY COD_LOCAL) AS RN, M.*
    FROM METRICAS M
    WHERE BLOCO = 'CD'
),

ADM_TOT_NUM AS (
    SELECT ROW_NUMBER() OVER (ORDER BY COD_LOCAL) AS RN, M.*
    FROM METRICAS M
    WHERE BLOCO = 'ADM_TOT'
),

ADM_CD_NUM AS (
    SELECT ROW_NUMBER() OVER (ORDER BY COD_LOCAL) AS RN, M.*
    FROM METRICAS M
    WHERE BLOCO = 'ADM_CD'
),

REDES_NUM AS (
    SELECT ROW_NUMBER() OVER (ORDER BY TO_NUMBER(COD_LOCAL)) AS RN, M.*
    FROM METRICAS M
    WHERE BLOCO = 'REDES'
      AND COD_LOCAL IN ('10', '30', '40', '50', '70')
),

TOT_LOJAS_NUM AS (
    SELECT ROW_NUMBER() OVER (ORDER BY COD_LOCAL) AS RN, M.*
    FROM METRICAS M
    WHERE BLOCO = 'LOJAS'
),

EMP_NUM AS (
    SELECT ROW_NUMBER() OVER (ORDER BY COD_LOCAL) AS RN, M.*
    FROM METRICAS M
    WHERE BLOCO = 'EMP'
),

RN_LIST AS (
    SELECT RN FROM ADM_NUM
    UNION
    SELECT RN FROM CD_NUM
    UNION
    SELECT RN FROM ADM_TOT_NUM
    UNION
    SELECT RN FROM ADM_CD_NUM
    UNION
    SELECT RN FROM REDES_NUM
    UNION
    SELECT RN FROM TOT_LOJAS_NUM
    UNION
    SELECT RN FROM EMP_NUM
)



/* =========================================================
   8. RESULTADO FINAL
========================================================= */
SELECT
    'ADMINISTRAÇÃO' AS DES_ADM,
    CASE
        WHEN ADM.COD_LOCAL IS NOT NULL AND ADM.DES_LOCAL IS NOT NULL THEN ADM.COD_LOCAL || ' - ' || ADM.DES_LOCAL
        WHEN ADM.COD_LOCAL IS NOT NULL THEN ADM.COD_LOCAL
        WHEN ADM.DES_LOCAL IS NOT NULL THEN ADM.DES_LOCAL
        ELSE NULL
    END AS ADM_LOCAL,
    ADM.QTD_COLABS AS ADM_COLABS,
    ADM.QTD_ESTAG AS ADM_ESTAG,
    ADM.QTD_APRE  AS ADM_APRE,
    ADM.QTD_SERV  AS ADM_SERV,
    ADM.QTD_AFAST AS ADM_AFAST,
    ADM.QTD_COLAB_FEM AS ADM_FEM,
    ADM.PERC_FEM AS ADM_PERC_FEM,
    ADM.QTD_COLAB_MASC AS ADM_MASC,
    ADM.PERC_MASC AS ADM_PERC_MASC,
    ADM.TOT_COLAB AS ADM_TOTAL,
    ADM.DIF_CLASSIFICACAO AS ADM_DIF_CLASSIFICACAO,
    ADM.DIF_SEXO AS ADM_DIF_SEXO,

    'LOGÍSTICA' AS DES_CD,
    CASE
        WHEN CD.COD_LOCAL IS NOT NULL AND CD.DES_LOCAL IS NOT NULL THEN CD.COD_LOCAL || ' - ' || CD.DES_LOCAL
        WHEN CD.COD_LOCAL IS NOT NULL THEN CD.COD_LOCAL
        WHEN CD.DES_LOCAL IS NOT NULL THEN CD.DES_LOCAL
        ELSE NULL
    END AS CD_LOCAL,
    CD.QTD_COLABS AS CD_COLABS,
    CD.QTD_ESTAG AS CD_ESTAG,
    CD.QTD_APRE  AS CD_APRE,
    CD.QTD_SERV  AS CD_SERV,
    CD.QTD_AFAST AS CD_AFAST,
    CD.QTD_COLAB_FEM AS CD_FEM,
    CD.PERC_FEM AS CD_PERC_FEM,
    CD.QTD_COLAB_MASC AS CD_MASC,
    CD.PERC_MASC AS CD_PERC_MASC,
    CD.TOT_COLAB AS CD_TOTAL,
    CD.DIF_CLASSIFICACAO AS CD_DIF_CLASSIFICACAO,
    CD.DIF_SEXO AS CD_DIF_SEXO,

    'ADMINISTRAÇÃO TOTAL' AS DES_ADM_TOT,
    CASE
        WHEN ATT.COD_LOCAL IS NOT NULL AND ATT.DES_LOCAL IS NOT NULL THEN ATT.COD_LOCAL || ' - ' || ATT.DES_LOCAL
        WHEN ATT.COD_LOCAL IS NOT NULL THEN ATT.COD_LOCAL
        WHEN ATT.DES_LOCAL IS NOT NULL THEN ATT.DES_LOCAL
        ELSE NULL
    END AS ADM_TOT_LOCAL,
    ATT.QTD_COLABS AS ADM_TOT_COLABS,
    ATT.QTD_ESTAG AS ADM_TOT_ESTAG,
    ATT.QTD_APRE  AS ADM_TOT_APRE,
    ATT.QTD_SERV  AS ADM_TOT_SERV,
    ATT.QTD_AFAST AS ADM_TOT_AFAST,
    ATT.QTD_COLAB_FEM AS ADM_TOT_FEM,
    ATT.PERC_FEM AS ADM_TOT_PERC_FEM,
    ATT.QTD_COLAB_MASC AS ADM_TOT_MASC,
    ATT.PERC_MASC AS ADM_TOT_PERC_MASC,
    ATT.TOT_COLAB AS ADM_TOT_TOTAL,
    ATT.DIF_CLASSIFICACAO AS ADM_TOT_DIF_CLASSIFICACAO,
    ATT.DIF_SEXO AS ADM_TOT_DIF_SEXO,

    'ADMINISTRAÇÃO/LOGÍSTICA' AS DES_ADM_CD,
    CASE
        WHEN AC.COD_LOCAL IS NOT NULL AND AC.DES_LOCAL IS NOT NULL THEN AC.COD_LOCAL || ' - ' || AC.DES_LOCAL
        WHEN AC.COD_LOCAL IS NOT NULL THEN AC.COD_LOCAL
        WHEN AC.DES_LOCAL IS NOT NULL THEN AC.DES_LOCAL
        ELSE NULL
    END AS ADM_CD_LOCAL,
    AC.QTD_COLABS AS ADM_CD_COLABS,
    AC.QTD_ESTAG AS ADM_CD_ESTAG,
    AC.QTD_APRE  AS ADM_CD_APRE,
    AC.QTD_SERV  AS ADM_CD_SERV,
    AC.QTD_AFAST AS ADM_CD_AFAST,
    AC.QTD_COLAB_FEM AS ADM_CD_FEM,
    AC.PERC_FEM AS ADM_CD_PERC_FEM,
    AC.QTD_COLAB_MASC AS ADM_CD_MASC,
    AC.PERC_MASC AS ADM_CD_PERC_MASC,
    AC.TOT_COLAB AS ADM_CD_TOTAL,
    AC.DIF_CLASSIFICACAO AS ADM_CD_DIF_CLASSIFICACAO,
    AC.DIF_SEXO AS ADM_CD_DIF_SEXO,

    'REDES' AS DES_REDE,
    CASE
        WHEN REDE.COD_LOCAL IS NOT NULL AND REDE.DES_LOCAL IS NOT NULL THEN REDE.COD_LOCAL || ' - ' || REDE.DES_LOCAL
        WHEN REDE.COD_LOCAL IS NOT NULL THEN REDE.COD_LOCAL
        WHEN REDE.DES_LOCAL IS NOT NULL THEN REDE.DES_LOCAL
        ELSE NULL
    END AS REDE_LOCAL,
    REDE.QTD_COLABS AS REDE_COLABS,
    REDE.QTD_ESTAG AS REDE_ESTAG,
    REDE.QTD_APRE  AS REDE_APRE,
    REDE.QTD_SERV  AS REDE_SERV,
    REDE.QTD_AFAST AS REDE_AFAST,
    REDE.QTD_COLAB_FEM AS REDE_FEM,
    REDE.PERC_FEM AS REDE_PERC_FEM,
    REDE.QTD_COLAB_MASC AS REDE_MASC,
    REDE.PERC_MASC AS REDE_PERC_MASC,
    REDE.TOT_COLAB AS REDE_TOTAL,
    REDE.DIF_CLASSIFICACAO AS REDE_DIF_CLASSIFICACAO,
    REDE.DIF_SEXO AS REDE_DIF_SEXO,

    'LOJAS' AS DES_LOJAS,
    CASE
        WHEN LOJAS.COD_LOCAL IS NOT NULL AND LOJAS.DES_LOCAL IS NOT NULL THEN LOJAS.COD_LOCAL || ' - ' || LOJAS.DES_LOCAL
        WHEN LOJAS.COD_LOCAL IS NOT NULL THEN LOJAS.COD_LOCAL
        WHEN LOJAS.DES_LOCAL IS NOT NULL THEN LOJAS.DES_LOCAL
        ELSE NULL
    END AS LOJAS_LOCAL,
    LOJAS.QTD_COLABS AS LOJAS_COLABS,
    LOJAS.QTD_ESTAG AS LOJAS_ESTAG,
    LOJAS.QTD_APRE  AS LOJAS_APRE,
    LOJAS.QTD_SERV  AS LOJAS_SERV,
    LOJAS.QTD_AFAST AS LOJAS_AFAST,
    LOJAS.QTD_COLAB_FEM AS LOJAS_FEM,
    LOJAS.PERC_FEM AS LOJAS_PERC_FEM,
    LOJAS.QTD_COLAB_MASC AS LOJAS_MASC,
    LOJAS.PERC_MASC AS LOJAS_PERC_MASC,
    LOJAS.TOT_COLAB AS LOJAS_TOTAL,
    LOJAS.DIF_CLASSIFICACAO AS LOJAS_DIF_CLASSIFICACAO,
    LOJAS.DIF_SEXO AS LOJAS_DIF_SEXO,

    'EMPRESA' AS DES_EMP,
    CASE
        WHEN EMP.COD_LOCAL IS NOT NULL AND EMP.DES_LOCAL IS NOT NULL THEN EMP.COD_LOCAL || ' - ' || EMP.DES_LOCAL
        WHEN EMP.COD_LOCAL IS NOT NULL THEN EMP.COD_LOCAL
        WHEN EMP.DES_LOCAL IS NOT NULL THEN EMP.DES_LOCAL
        ELSE NULL
    END AS EMP_LOCAL,
    EMP.QTD_COLABS AS EMP_COLABS,
    EMP.QTD_ESTAG AS EMP_ESTAG,
    EMP.QTD_APRE  AS EMP_APRE,
    EMP.QTD_SERV  AS EMP_SERV,
    EMP.QTD_AFAST AS EMP_AFAST,
    EMP.QTD_COLAB_FEM AS EMP_FEM,
    EMP.PERC_FEM AS EMP_PERC_FEM,
    EMP.QTD_COLAB_MASC AS EMP_MASC,
    EMP.PERC_MASC AS EMP_PERC_MASC,
    EMP.TOT_COLAB AS EMP_TOTAL,
    EMP.DIF_CLASSIFICACAO AS EMP_DIF_CLASSIFICACAO,
    EMP.DIF_SEXO AS EMP_DIF_SEXO,

    TO_CHAR((SELECT DATA_REFERENCIA FROM PARAMS), 'DD/MM/YYYY') AS REFERENCIA

FROM RN_LIST R
LEFT JOIN ADM_NUM ADM
    ON ADM.RN = R.RN
LEFT JOIN CD_NUM CD
    ON CD.RN = R.RN
LEFT JOIN ADM_TOT_NUM ATT
    ON ATT.RN = R.RN
LEFT JOIN ADM_CD_NUM AC
    ON AC.RN = R.RN
LEFT JOIN REDES_NUM REDE
    ON REDE.RN = R.RN
LEFT JOIN TOT_LOJAS_NUM LOJAS
    ON LOJAS.RN = R.RN
LEFT JOIN EMP_NUM EMP
    ON EMP.RN = R.RN
ORDER BY R.RN



