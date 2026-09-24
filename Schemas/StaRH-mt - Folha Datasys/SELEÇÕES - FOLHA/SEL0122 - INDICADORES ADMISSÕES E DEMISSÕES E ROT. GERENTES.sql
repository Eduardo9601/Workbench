WITH
/* ============================================================
   1) PARÂMETROS
   ============================================================ */
PARAMETROS AS (
    SELECT
        TO_DATE(:DATA_INICIAL, 'DD/MM/YYYY')     AS DATA_INICIAL,
        TO_DATE(:DATA_FINAL,   'DD/MM/YYYY') + 1 AS DATA_FINAL,
        NVL(REPLACE(:UNIDADES, ' ', ''), '0')    AS UNIDADES
    FROM DUAL
),


/* ============================================================
   2) HISTÓRICO COMPLETO DE ORGANOGRAMA

   Diferente da V_DADOS_COLAB_AVT, aqui NÃO pegamos somente
   o último organograma do contrato.
   ============================================================ */
ORG_HIST AS (
    SELECT
        O.COD_CONTRATO,
        O.COD_UNIDADE,
        O.DES_UNIDADE,
        O.COD_REDE,
        O.DES_REDE,
        O.COD_TIPO,
        O.DATA_INI_ORG,
        O.DATA_FIM_ORG

    FROM VH_EST_ORG_CONTRATO_AVT O
         CROSS JOIN PARAMETROS P

    WHERE O.COD_ORG_2 = 8

      /* ============================================
         TIPO
         0 = TODOS
         1 = LOJA
         2 = ADM
         3 = CD
         ============================================ */
      AND (
            NVL(:TIPO, 0) = 0
            OR O.COD_TIPO = :TIPO
          )

      /* ============================================
         REDE
         0 = TODAS
         ============================================ */
      AND (
            NVL(:REDE, 0) = 0
            OR O.COD_REDE = :REDE
          )

      /* ============================================
         UNIDADES

         Exemplos:
         159
         159,529,158
         0 = TODAS
         ============================================ */
      AND (
            P.UNIDADES = '0'

            OR INSTR(
                ',' || P.UNIDADES || ',',
                ',' || TO_CHAR(O.COD_UNIDADE) || ','
            ) > 0
          )
),


/* ============================================================
   3) DIMENSÃO DAS UNIDADES

   Mantém somente a descrição mais recente de cada unidade
   para não termos duas linhas da mesma unidade por alteração
   histórica de descrição/rede.
   ============================================================ */
UNIDADES_DIM AS (
    SELECT
        COD_UNIDADE,
        DES_UNIDADE,
        COD_REDE,
        DES_REDE

    FROM (
        SELECT
            O.COD_UNIDADE,
            O.DES_UNIDADE,
            O.COD_REDE,
            O.DES_REDE,

            ROW_NUMBER() OVER (
                PARTITION BY O.COD_UNIDADE
                ORDER BY
                    O.DATA_INI_ORG DESC,
                    NVL(O.DATA_FIM_ORG, DATE '2999-12-31') DESC
            ) AS RN

        FROM ORG_HIST O
    )

    WHERE RN = 1
),


/* ============================================================
   4) CONTRATOS

   RHFP0300 = origem das datas de admissão/demissão
   ============================================================ */
CONTRATOS AS (
    SELECT
        A.COD_CONTRATO,
        A.DATA_INICIO AS ADMISSAO,
        A.DATA_FIM    AS DEMISSAO

    FROM RHFP0300 A
),


/* ============================================================
   5) ORGANOGRAMA ATUAL

   Define em qual unidade o contrato está HOJE.
   Se houver mais de um registro válido, pega o mais recente.
   ============================================================ */
ORG_ATUAL_RN AS (
    SELECT
        O.*,

        ROW_NUMBER() OVER (
            PARTITION BY O.COD_CONTRATO
            ORDER BY
                O.DATA_INI_ORG DESC,
                NVL(O.DATA_FIM_ORG, DATE '2999-12-31') DESC
        ) AS RN

    FROM ORG_HIST O

    WHERE O.DATA_INI_ORG <= TRUNC(SYSDATE)

      AND NVL(
            O.DATA_FIM_ORG,
            DATE '2999-12-31'
          ) >= TRUNC(SYSDATE)
),

ORG_ATUAL AS (
    SELECT *
    FROM ORG_ATUAL_RN
    WHERE RN = 1
),


/* ============================================================
   6) ATIVOS ATUAIS

   Quantidade de pessoas atualmente ativas em cada unidade.
   ============================================================ */
ATIVOS AS (
    SELECT
        O.COD_UNIDADE,

        COUNT(
            DISTINCT C.COD_CONTRATO
        ) AS ATIVOS_ATUAIS

    FROM CONTRATOS C

    INNER JOIN ORG_ATUAL O
        ON O.COD_CONTRATO = C.COD_CONTRATO

    WHERE C.ADMISSAO <= TRUNC(SYSDATE)

      AND (
            C.DEMISSAO IS NULL
            OR C.DEMISSAO >= TRUNC(SYSDATE)
          )

    GROUP BY
        O.COD_UNIDADE
),


/* ============================================================
   7) IDENTIFICA A UNIDADE EM QUE O COLABORADOR FOI ADMITIDO

   Isso evita usar a unidade ATUAL para uma admissão histórica.
   ============================================================ */
ADMITIDOS_RN AS (
    SELECT
        C.COD_CONTRATO,
        O.COD_UNIDADE,
        C.ADMISSAO,

        ROW_NUMBER() OVER (
            PARTITION BY C.COD_CONTRATO
            ORDER BY O.DATA_INI_ORG DESC
        ) AS RN

    FROM CONTRATOS C

    INNER JOIN ORG_HIST O
        ON O.COD_CONTRATO = C.COD_CONTRATO

       AND C.ADMISSAO >= O.DATA_INI_ORG

       AND C.ADMISSAO <= NVL(
            O.DATA_FIM_ORG,
            DATE '2999-12-31'
       )

    CROSS JOIN PARAMETROS P

    WHERE C.ADMISSAO >= P.DATA_INICIAL
      AND C.ADMISSAO <  P.DATA_FINAL
),

ADMITIDOS AS (
    SELECT
        COD_UNIDADE,

        COUNT(
            DISTINCT COD_CONTRATO
        ) AS QTD_ADMITIDOS

    FROM ADMITIDOS_RN

    WHERE RN = 1

    GROUP BY
        COD_UNIDADE
),


/* ============================================================
   8) IDENTIFICA A UNIDADE EM QUE O COLABORADOR FOI DEMITIDO

   Mesma lógica: usa a unidade existente na data da demissão.
   ============================================================ */
DEMITIDOS_RN AS (
    SELECT
        C.COD_CONTRATO,
        O.COD_UNIDADE,
        C.DEMISSAO,

        ROW_NUMBER() OVER (
            PARTITION BY C.COD_CONTRATO
            ORDER BY O.DATA_INI_ORG DESC
        ) AS RN

    FROM CONTRATOS C

    INNER JOIN ORG_HIST O
        ON O.COD_CONTRATO = C.COD_CONTRATO

       AND C.DEMISSAO >= O.DATA_INI_ORG

       AND C.DEMISSAO <= NVL(
            O.DATA_FIM_ORG,
            DATE '2999-12-31'
       )

    CROSS JOIN PARAMETROS P

    WHERE C.DEMISSAO IS NOT NULL
      AND C.DEMISSAO >= P.DATA_INICIAL
      AND C.DEMISSAO <  P.DATA_FINAL
),

DEMITIDOS AS (
    SELECT
        COD_UNIDADE,

        COUNT(
            DISTINCT COD_CONTRATO
        ) AS QTD_DEMITIDOS

    FROM DEMITIDOS_RN

    WHERE RN = 1

    GROUP BY
        COD_UNIDADE
),


/* ============================================================
   9) HISTÓRICO DE FUNÇÕES GERENCIAIS

   RHFP0340 = histórico de função por contrato
   RHFP0500 = descrição da função
   ============================================================ */
FUNCOES_GERENCIAIS AS (
    SELECT
        F.COD_CONTRATO,
        F.COD_CLH AS COD_FUNCAO,
        CLH.NOME_CLH AS FUNCAO,

        F.DATA_INICIO AS DATA_INICIO_FUNCAO,

        NVL(
            F.DATA_FIM,
            DATE '2999-12-31'
        ) AS DATA_FIM_FUNCAO

    FROM RHFP0340 F

    INNER JOIN RHFP0500 CLH
        ON CLH.COD_CLH = F.COD_CLH

    WHERE UPPER(CLH.NOME_CLH) LIKE '%GERENTE%'
),


/* ============================================================
   10) CRUZA FUNÇÃO DE GERENTE COM ORGANOGRAMA

   Só considera o período em que as duas condições existiam
   simultaneamente:

   - estava na função GERENTE
   - estava naquela UNIDADE
   ============================================================ */
GERENCIA_SEGMENTOS_RAW AS (
    SELECT
        O.COD_CONTRATO,
        O.COD_UNIDADE,

        GREATEST(
            O.DATA_INI_ORG,
            F.DATA_INICIO_FUNCAO
        ) AS DATA_INICIO_GERENCIA,

        LEAST(
            NVL(
                O.DATA_FIM_ORG,
                DATE '2999-12-31'
            ),
            F.DATA_FIM_FUNCAO
        ) AS DATA_FIM_GERENCIA

    FROM ORG_HIST O

    INNER JOIN FUNCOES_GERENCIAIS F
        ON F.COD_CONTRATO = O.COD_CONTRATO

       /* Existe interseção entre os períodos */
       AND F.DATA_INICIO_FUNCAO <= NVL(
            O.DATA_FIM_ORG,
            DATE '2999-12-31'
       )

       AND O.DATA_INI_ORG <= F.DATA_FIM_FUNCAO
),


/* ============================================================
   11) PREPARA JUNÇÃO DOS SEGMENTOS

   Um mesmo gerente pode possuir vários registros consecutivos
   para a mesma unidade por alterações administrativas.

   Não queremos interpretar isso como várias trocas.
   ============================================================ */
GERENCIA_ORDENADA AS (
    SELECT
        G.*,

        MAX(G.DATA_FIM_GERENCIA) OVER (
            PARTITION BY
                G.COD_CONTRATO,
                G.COD_UNIDADE

            ORDER BY
                G.DATA_INICIO_GERENCIA,
                G.DATA_FIM_GERENCIA

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND 1 PRECEDING
        ) AS MAIOR_FIM_ANTERIOR

    FROM GERENCIA_SEGMENTOS_RAW G
),


/* ============================================================
   12) MARCA UM NOVO PERÍODO REAL DE GERÊNCIA
   ============================================================ */
GERENCIA_MARCADA AS (
    SELECT
        G.*,

        CASE
            WHEN G.MAIOR_FIM_ANTERIOR IS NULL
            THEN 1

            WHEN G.DATA_INICIO_GERENCIA >
                 G.MAIOR_FIM_ANTERIOR + 1
            THEN 1

            ELSE 0
        END AS NOVO_GRUPO

    FROM GERENCIA_ORDENADA G
),


/* ============================================================
   13) AGRUPA PERÍODOS CONSECUTIVOS
   ============================================================ */
GERENCIA_GRUPOS AS (
    SELECT
        G.*,

        SUM(G.NOVO_GRUPO) OVER (
            PARTITION BY
                G.COD_CONTRATO,
                G.COD_UNIDADE

            ORDER BY
                G.DATA_INICIO_GERENCIA,
                G.DATA_FIM_GERENCIA

            ROWS UNBOUNDED PRECEDING
        ) AS GRUPO_GERENCIA

    FROM GERENCIA_MARCADA G
),


/* ============================================================
   14) PERÍODOS REAIS DE GERÊNCIA

   Aqui chegamos em algo como:

   contrato | unidade | início | fim

   representando de fato por quanto tempo aquela pessoa
   foi gerente daquela unidade.
   ============================================================ */
GERENCIA_PERIODOS AS (
    SELECT
        COD_CONTRATO,
        COD_UNIDADE,
        GRUPO_GERENCIA,

        MIN(DATA_INICIO_GERENCIA)
            AS DATA_INICIO_GERENCIA,

        MAX(DATA_FIM_GERENCIA)
            AS DATA_FIM_GERENCIA

    FROM GERENCIA_GRUPOS

    GROUP BY
        COD_CONTRATO,
        COD_UNIDADE,
        GRUPO_GERENCIA
),


/* ============================================================
   15) SEQUÊNCIA DE GERENTES DA UNIDADE

   Descobre quem foi o gerente anterior daquela unidade.
   ============================================================ */
GERENCIA_SEQUENCIA AS (
    SELECT
        G.*,

        LAG(G.COD_CONTRATO) OVER (
            PARTITION BY G.COD_UNIDADE

            ORDER BY
                G.DATA_INICIO_GERENCIA,
                G.DATA_FIM_GERENCIA,
                G.COD_CONTRATO
        ) AS COD_GERENTE_ANTERIOR

    FROM GERENCIA_PERIODOS G
),


/* ============================================================
   16) INDICADORES GERENCIAIS
   ============================================================ */
GERENCIA_INDICADORES AS (
    SELECT
        G.COD_UNIDADE,


        /* ====================================================
           QUANTOS GERENTES DIFERENTES PASSARAM PELA UNIDADE
           DURANTE O PERÍODO ESCOLHIDO

           Inclui quem já era gerente antes da DATA_INICIAL,
           desde que tenha permanecido no período.
           ==================================================== */
        COUNT(
            DISTINCT CASE
                WHEN G.DATA_INICIO_GERENCIA < P.DATA_FINAL

                 AND G.DATA_FIM_GERENCIA >= P.DATA_INICIAL

                THEN G.COD_CONTRATO
            END
        ) AS QTD_GERENTES_PERIODO,


        /* ====================================================
           GERENTES QUE COMEÇARAM NA UNIDADE DURANTE O PERÍODO
           ==================================================== */
        COUNT(
            DISTINCT CASE
                WHEN G.DATA_INICIO_GERENCIA >= P.DATA_INICIAL

                 AND G.DATA_INICIO_GERENCIA < P.DATA_FINAL

                THEN G.COD_CONTRATO
            END
        ) AS GERENTES_QUE_ASSUMIRAM,


        /* ====================================================
           GERENTES QUE ENCERRARAM A PASSAGEM PELA UNIDADE
           DURANTE O PERÍODO
           ==================================================== */
        COUNT(
            DISTINCT CASE
                WHEN G.DATA_FIM_GERENCIA >= P.DATA_INICIAL

                 AND G.DATA_FIM_GERENCIA < P.DATA_FINAL

                 AND G.DATA_FIM_GERENCIA <
                     DATE '2999-12-31'

                THEN G.COD_CONTRATO
            END
        ) AS GERENTES_QUE_SAIRAM,


        /* ====================================================
           TROCAS REAIS DE GERENTE

           Conta quando começa um gerente diferente do
           gerente anterior da unidade.

           Exemplo:
             João   -> Maria  = 1 troca
             Maria  -> Carlos = 1 troca

           3 gerentes = 2 trocas.
           ==================================================== */
        SUM(
            CASE
                WHEN G.DATA_INICIO_GERENCIA >= P.DATA_INICIAL

                 AND G.DATA_INICIO_GERENCIA < P.DATA_FINAL

                 AND G.COD_GERENTE_ANTERIOR IS NOT NULL

                 AND G.COD_GERENTE_ANTERIOR <>
                     G.COD_CONTRATO

                THEN 1

                ELSE 0
            END
        ) AS ROTATIVIDADE_GERENTES

    FROM GERENCIA_SEQUENCIA G
         CROSS JOIN PARAMETROS P

    GROUP BY
        G.COD_UNIDADE
)


/* ============================================================
   17) RESULTADO FINAL
   ============================================================ */
SELECT
       U.COD_UNIDADE,
       U.DES_UNIDADE,
       U.COD_REDE,
       U.DES_REDE,

       /* QUADRO ATUAL */
       NVL(A.ATIVOS_ATUAIS, 0)
           AS ATIVOS_ATUAIS,

       /* MOVIMENTAÇÃO RH */
       NVL(AD.QTD_ADMITIDOS, 0)
           AS QTD_ADMITIDOS,

       NVL(DE.QTD_DEMITIDOS, 0)
           AS QTD_DEMITIDOS,

       /* SALDO DO PERÍODO */
       NVL(AD.QTD_ADMITIDOS, 0)
       -
       NVL(DE.QTD_DEMITIDOS, 0)
           AS SALDO_PERIODO,

       /* HISTÓRICO GERENCIAL */
       NVL(G.QTD_GERENTES_PERIODO, 0)
           AS QTD_GERENTES_PERIODO,

       NVL(G.GERENTES_QUE_ASSUMIRAM, 0)
           AS GERENTES_QUE_ASSUMIRAM,

       NVL(G.GERENTES_QUE_SAIRAM, 0)
           AS GERENTES_QUE_SAIRAM,

       NVL(G.ROTATIVIDADE_GERENTES, 0)
           AS ROTATIVIDADE_GERENTES

FROM UNIDADES_DIM U

LEFT JOIN ATIVOS A
       ON A.COD_UNIDADE = U.COD_UNIDADE

LEFT JOIN ADMITIDOS AD
       ON AD.COD_UNIDADE = U.COD_UNIDADE

LEFT JOIN DEMITIDOS DE
       ON DE.COD_UNIDADE = U.COD_UNIDADE

LEFT JOIN GERENCIA_INDICADORES G
       ON G.COD_UNIDADE = U.COD_UNIDADE

ORDER BY
       U.COD_REDE,
       U.COD_UNIDADE;