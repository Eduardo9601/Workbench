WITH
/* ==========================================================
   1. PARÂMETROS DO PERÍODO

   Altere somente estas duas datas.
   DATA_FINAL é considerada inclusiva.
   ========================================================== */
PARAMETROS AS (
    SELECT
        :DATA_INICIO AS DATA_INICIAL,
        :DATA_FIM AS DATA_FINAL
    FROM DUAL
),

/* ==========================================================
   2. CÁLCULOS EXISTENTES NO PERÍODO

   Busca os COD_MESTRE_EVENTO dinamicamente pela RHFP1003.
   ========================================================== */
MESTRES_PERIODO AS (
    SELECT
        B.COD_MESTRE_EVENTO,

        MIN(B.DATA_INI_MOV) AS DATA_INI_MOV,

        MAX(
            NVL(
                B.DATA_FIM_MOV,
                B.DATA_INI_MOV
            )
        ) AS DATA_FIM_MOV,

        TO_CHAR(
            MIN(B.DATA_INI_MOV),
            'MM/YYYY'
        ) AS COMPETENCIA

    FROM RHFP1003 B

    CROSS JOIN PARAMETROS P

    WHERE B.COD_ORGANOGRAMA = 8
      AND B.DATA_INI_MOV IS NOT NULL

      /* O período do cálculo inicia antes do fim informado */
      AND B.DATA_INI_MOV < P.DATA_FINAL + 1

      /* O período do cálculo termina após o início informado */
      AND NVL(
              B.DATA_FIM_MOV,
              B.DATA_INI_MOV
          ) >= P.DATA_INICIAL

      /* Evento de folha mensal */
      AND B.COD_EVENTO = 1

    GROUP BY
        B.COD_MESTRE_EVENTO
),

/* ==========================================================
   3. LÍQUIDO DO COLABORADOR

   Uma linha por:
   - cálculo;
   - competência;
   - contrato.
   ========================================================== */
LIQUIDOS AS (
    SELECT
        A.COD_MESTRE_EVENTO,
        M.COMPETENCIA,
        A.COD_CONTRATO,
        SUM(A.VALOR_VD) AS VALOR_LIQUIDO

    FROM RHFP1006 A

    INNER JOIN MESTRES_PERIODO M
        ON M.COD_MESTRE_EVENTO = A.COD_MESTRE_EVENTO

    WHERE A.COD_VD = 1003
      AND A.VALOR_VD <> 0

      /* Use somente para testar um colaborador */
      -- AND A.COD_CONTRATO = 389622

    GROUP BY
        A.COD_MESTRE_EVENTO,
        M.COMPETENCIA,
        A.COD_CONTRATO
),

/* ==========================================================
   4. MAPA DOS COLABORADORES ALOCADOS NO NÍVEL 4

   COD_DEPARTAMENTO deve ser o código do nível 5
   em que o colaborador será agrupado.
   ========================================================== */
MAPA_EXCECOES AS (
    SELECT
        297305 AS COD_CONTRATO,
        '780'  AS COD_DEPARTAMENTO
    FROM DUAL

    UNION ALL

    SELECT
        377199 AS COD_CONTRATO,
        '740'  AS COD_DEPARTAMENTO
    FROM DUAL

    UNION ALL

    SELECT
        299685 AS COD_CONTRATO,
        '705'  AS COD_DEPARTAMENTO
    FROM DUAL
),

/* ==========================================================
   5. DEPARTAMENTOS DO NÍVEL 5

   Recupera a descrição oficial do departamento.
   ========================================================== */
DEPARTAMENTOS_NIVEL_5 AS (
    SELECT
        TRIM(
            CAST(C.EDICAO_DEPART AS VARCHAR2(50))
        ) AS COD_DEPARTAMENTO,

        MAX(C.DES_DEPART) AS DES_DEPARTAMENTO

    FROM V_DADOS_COLAB_AVT C

    WHERE C.EDICAO_DEPART IS NOT NULL

    GROUP BY
        TRIM(
            CAST(C.EDICAO_DEPART AS VARCHAR2(50))
        )
),

/* ==========================================================
   6. NORMALIZAÇÃO DA UNIDADE/DEPARTAMENTO

   Prioridade:
   1. Colaboradores do mapa de exceções;
   2. Tipo 2: Administração por departamento;
   3. Tipo 3: Logística por divisão;
   4. Demais unidades normalmente.
   ========================================================== */
DADOS_COLABORADORES AS (
    SELECT DISTINCT
        C.COD_CONTRATO,
        C.DES_PESSOA,

        /* Empresa do colaborador */
        C.COD_EMP,
        C.DES_EMPRESA,

        /* Código normalizado da unidade/departamento */
        CASE
            /* Colaboradores alocados no nível 4 */
            WHEN E.COD_CONTRATO IS NOT NULL THEN
                TRIM(
                    CAST(
                        E.COD_DEPARTAMENTO AS VARCHAR2(50)
                    )
                )

            /* Administração */
            WHEN C.COD_TIPO = 2 THEN
                COALESCE(
                    TRIM(
                        CAST(
                            C.EDICAO_DEPART AS VARCHAR2(50)
                        )
                    ),
                    TRIM(
                        CAST(
                            C.COD_UNIDADE AS VARCHAR2(50)
                        )
                    )
                )

            /* Logística */
            WHEN C.COD_TIPO = 3 THEN
                COALESCE(
                    TRIM(
                        CAST(
                            C.EDICAO_DIVISAO AS VARCHAR2(50)
                        )
                    ),
                    TRIM(
                        CAST(
                            C.COD_UNIDADE AS VARCHAR2(50)
                        )
                    )
                )

            /* Demais tipos */
            ELSE
                TRIM(
                    CAST(
                        C.COD_UNIDADE AS VARCHAR2(50)
                    )
                )
        END AS COD_UNIDADE,

        /* Descrição normalizada da unidade/departamento */
        CASE
            /* Colaboradores alocados no nível 4 */
            WHEN E.COD_CONTRATO IS NOT NULL THEN
                COALESCE(
                    D5.DES_DEPARTAMENTO,
                    C.DES_UNIDADE
                )

            /* Administração */
            WHEN C.COD_TIPO = 2 THEN
                COALESCE(
                    C.DES_DEPART,
                    C.DES_UNIDADE
                )

            /* Logística */
            WHEN C.COD_TIPO = 3 THEN
                COALESCE(
                    C.DES_DIVISAO,
                    C.DES_UNIDADE
                )

            /* Demais tipos */
            ELSE
                C.DES_UNIDADE
        END AS DES_UNIDADE

    FROM V_DADOS_COLAB_AVT C

    LEFT JOIN MAPA_EXCECOES E
        ON E.COD_CONTRATO = C.COD_CONTRATO

    LEFT JOIN DEPARTAMENTOS_NIVEL_5 D5
        ON D5.COD_DEPARTAMENTO =
           TRIM(
               CAST(
                   E.COD_DEPARTAMENTO AS VARCHAR2(50)
               )
           )
),

/* ==========================================================
   7. RELAÇÃO INDIVIDUAL

   Uma linha por colaborador, cálculo e competência.
   ========================================================== */
COLABORADORES AS (
    SELECT DISTINCT
        L.COD_MESTRE_EVENTO,
        L.COMPETENCIA,

        D.COD_EMP,
        D.DES_EMPRESA,

        D.COD_UNIDADE,
        D.DES_UNIDADE,

        L.COD_CONTRATO,
        D.DES_PESSOA,
        L.VALOR_LIQUIDO

    FROM LIQUIDOS L

    LEFT JOIN DADOS_COLABORADORES D
        ON D.COD_CONTRATO = L.COD_CONTRATO
),

/* ==========================================================
   8. TOTALIZAÇÃO POR UNIDADE

   Separada por:
   - cálculo;
   - competência;
   - empresa;
   - unidade/departamento.
   ========================================================== */
UNIDADES AS (
    SELECT
        C.COD_MESTRE_EVENTO,
        C.COMPETENCIA,
        C.COD_EMP,
        C.COD_UNIDADE,

        MAX(C.DES_UNIDADE) AS DES_UNIDADE,

        COUNT(
            DISTINCT C.COD_CONTRATO
        ) AS QTD_COLABORADORES_UNIDADE,

        SUM(
            C.VALOR_LIQUIDO
        ) AS TOTAL_LIQUIDO_UNIDADE

    FROM COLABORADORES C

    GROUP BY
        C.COD_MESTRE_EVENTO,
        C.COMPETENCIA,
        C.COD_EMP,
        C.COD_UNIDADE
),

/* ==========================================================
   9. TOTALIZAÇÃO POR EMPRESA

   Retorna:
   - quantidade total de contratos;
   - total geral do líquido da empresa.

   Separado por cálculo e competência.
   ========================================================== */
EMPRESAS AS (
    SELECT
        C.COD_MESTRE_EVENTO,
        C.COMPETENCIA,
        C.COD_EMP,

        MAX(C.DES_EMPRESA) AS DES_EMP,

        COUNT(
            DISTINCT C.COD_CONTRATO
        ) AS QTD_CONTRATOS_EMPRESA,

        SUM(
            C.VALOR_LIQUIDO
        ) AS TOTAL_LIQUIDO_EMPRESA

    FROM COLABORADORES C

    GROUP BY
        C.COD_MESTRE_EVENTO,
        C.COMPETENCIA,
        C.COD_EMP
)

/* ==========================================================
   10. RESULTADO FINAL

   Uma linha por colaborador, contendo:
   - empresa;
   - unidade/departamento;
   - líquido individual;
   - total da unidade;
   - total geral da empresa.
   ========================================================== */
SELECT
    C.COD_MESTRE_EVENTO,
    C.COMPETENCIA,

    /* Empresa */
    C.COD_EMP,
    E.DES_EMP,

    /* Unidade/departamento */
    C.COD_UNIDADE,
    U.DES_UNIDADE,

    /* Colaborador */
    C.COD_CONTRATO,
    C.DES_PESSOA,

    TO_CHAR(
        C.VALOR_LIQUIDO,
        'FM999G999G999G990D00',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS VALOR_LIQUIDO,

    /* Totais da unidade */
    U.QTD_COLABORADORES_UNIDADE,

    TO_CHAR(
        U.TOTAL_LIQUIDO_UNIDADE,
        'FM999G999G999G990D00',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS TOTAL_LIQUIDO_UNIDADE,

    /* Totais gerais da empresa */
    E.QTD_CONTRATOS_EMPRESA,

    TO_CHAR(
        E.TOTAL_LIQUIDO_EMPRESA,
        'FM999G999G999G990D00',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS TOTAL_LIQUIDO_EMPRESA

FROM COLABORADORES C

LEFT JOIN UNIDADES U
    ON U.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
   AND U.COMPETENCIA       = C.COMPETENCIA
   AND U.COD_EMP           = C.COD_EMP
   AND U.COD_UNIDADE       = C.COD_UNIDADE

LEFT JOIN EMPRESAS E
    ON E.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
   AND E.COMPETENCIA       = C.COMPETENCIA
   AND E.COD_EMP           = C.COD_EMP

ORDER BY
    C.COD_EMP,
    C.COD_UNIDADE,
    C.DES_PESSOA,
    C.COD_CONTRATO;

