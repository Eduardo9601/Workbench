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
   2) CONTRATOS
   ============================================================ */
CONTRATOS AS (
    SELECT
        A.COD_CONTRATO,
        A.COD_FUNC,
        A.DATA_INICIO AS ADMISSAO,
        A.DATA_FIM    AS DEMISSAO
    FROM RHFP0300 A
),


/* ============================================================
   3) HISTÓRICO BRUTO DE ORGANOGRAMA

   IMPORTANTE:
   Ainda NÃO filtramos unidade/rede/empresa.

   Precisamos enxergar a próxima movimentação do contrato
   mesmo que ela tenha sido para outra unidade.
   ============================================================ */
ORG_EVENTOS_BASE AS (
    SELECT DISTINCT
           O.COD_CONTRATO,
           O.COD_ORG_2,
           O.COD_UNIDADE,
           O.DES_UNIDADE,
           O.COD_REDE,
           O.DES_REDE,
           O.COD_TIPO,
           O.DATA_INI_ORG,
           O.DATA_FIM_ORG

    FROM VH_EST_ORG_CONTRATO_AVT O

    WHERE O.DATA_INI_ORG IS NOT NULL
),


/* ============================================================
   4) DESCOBRE A PRÓXIMA MOVIMENTAÇÃO DE ORGANOGRAMA

   Exemplo:

   159 - 01/01/2020
   529 - 01/05/2022

   Mesmo que 159 esteja com fim 2999,
   sabemos que efetivamente terminou quando iniciou 529.
   ============================================================ */
ORG_EVENTOS_SEQ AS (
    SELECT
        O.*,

        LEAD(O.DATA_INI_ORG) OVER (
            PARTITION BY O.COD_CONTRATO
            ORDER BY
                O.DATA_INI_ORG,
                O.COD_UNIDADE
        ) AS PROX_DATA_INI_ORG

    FROM ORG_EVENTOS_BASE O
),


/* ============================================================
   5) ORGANOGRAMA COM FIM EFETIVO
   ============================================================ */
ORG_HIST_COMPLETO AS (
    SELECT
        O.COD_CONTRATO,
        O.COD_ORG_2,
        O.COD_UNIDADE,
        O.DES_UNIDADE,
        O.COD_REDE,
        O.DES_REDE,
        O.COD_TIPO,
        O.DATA_INI_ORG,

        /*
           Estamos trabalhando com DATA_FIM exclusiva.

           Se a próxima movimentação começou em 10/05,
           a anterior vale até antes de 10/05.
        */
        LEAST(
            NVL(O.DATA_FIM_ORG + 1, DATE '3000-01-01'),
            NVL(O.PROX_DATA_INI_ORG, DATE '3000-01-01')
        ) AS DATA_FIM_ORG_EFETIVA

    FROM ORG_EVENTOS_SEQ O
),


/* ============================================================
   6) APLICA OS FILTROS DA CONSULTA

   Só AGORA filtramos empresa/unidade/rede.
   ============================================================ */
ORG_HIST AS (
    SELECT
        O.*

    FROM ORG_HIST_COMPLETO O
         CROSS JOIN PARAMETROS P

    WHERE O.COD_ORG_2 = 8

      /* TIPO */
      AND (
            NVL(:TIPO, 0) = 0
            OR O.COD_TIPO = :TIPO
          )

      /* REDE */
      AND (
            NVL(:REDE, 0) = 0
            OR O.COD_REDE = :REDE
          )

      /* UNIDADES */
      AND (
            P.UNIDADES = '0'

            OR INSTR(
                ',' || P.UNIDADES || ',',
                ',' || TO_CHAR(O.COD_UNIDADE) || ','
            ) > 0
          )
),


/* ============================================================
   7) DIMENSÃO DAS UNIDADES
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
                    O.DATA_INI_ORG DESC
            ) AS RN

        FROM ORG_HIST O
    )

    WHERE RN = 1
),


/* ============================================================
   8) ORGANOGRAMA ATUAL
   ============================================================ */
ORG_ATUAL_RN AS (
    SELECT
        O.*,

        ROW_NUMBER() OVER (
            PARTITION BY O.COD_CONTRATO
            ORDER BY O.DATA_INI_ORG DESC
        ) AS RN

    FROM ORG_HIST O

    WHERE O.DATA_INI_ORG < TRUNC(SYSDATE) + 1

      AND O.DATA_FIM_ORG_EFETIVA > TRUNC(SYSDATE)
),

ORG_ATUAL AS (
    SELECT *
    FROM ORG_ATUAL_RN
    WHERE RN = 1
),


/* ============================================================
   9) ATIVOS ATUAIS
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

    WHERE C.ADMISSAO < TRUNC(SYSDATE) + 1

      AND (
            C.DEMISSAO IS NULL
            OR C.DEMISSAO >= TRUNC(SYSDATE)
          )

    GROUP BY
        O.COD_UNIDADE
),


/* ============================================================
   10) ADMISSÕES

   Descobre em qual unidade o contrato estava na data
   da admissão.
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
       AND C.ADMISSAO <  O.DATA_FIM_ORG_EFETIVA

    CROSS JOIN PARAMETROS P

    WHERE C.ADMISSAO >= P.DATA_INICIAL
      AND C.ADMISSAO <  P.DATA_FINAL
),

ADMITIDOS AS (
    SELECT
        COD_UNIDADE,
        COUNT(DISTINCT COD_CONTRATO) AS QTD_ADMITIDOS

    FROM ADMITIDOS_RN

    WHERE RN = 1

    GROUP BY
        COD_UNIDADE
),


/* ============================================================
   11) DEMISSÕES
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
       AND C.DEMISSAO <  O.DATA_FIM_ORG_EFETIVA

    CROSS JOIN PARAMETROS P

    WHERE C.DEMISSAO IS NOT NULL
      AND C.DEMISSAO >= P.DATA_INICIAL
      AND C.DEMISSAO <  P.DATA_FINAL
),

DEMITIDOS AS (
    SELECT
        COD_UNIDADE,
        COUNT(DISTINCT COD_CONTRATO) AS QTD_DEMITIDOS

    FROM DEMITIDOS_RN

    WHERE RN = 1

    GROUP BY
        COD_UNIDADE
),


/* ============================================================
   12) HISTÓRICO BRUTO DE FUNÇÕES

   IMPORTANTE:
   Aqui buscamos TODAS as funções primeiro.

   Não podemos filtrar GERENTE ainda porque precisamos saber
   quando começou a próxima função, mesmo que não seja gerente.

   A própria V_DADOS_COLAB_AVT usa RHFP0340 como histórico
   da função do contrato.
   ============================================================ */
FUNCAO_EVENTOS_BASE AS (
    SELECT DISTINCT
           F.COD_CONTRATO,
           F.COD_CLH AS COD_FUNCAO,
           CLH.NOME_CLH AS FUNCAO,
           F.DATA_INICIO AS DATA_INICIO_FUNCAO,
           F.DATA_FIM    AS DATA_FIM_FUNCAO

    FROM RHFP0340 F

    INNER JOIN RHFP0500 CLH
        ON CLH.COD_CLH = F.COD_CLH

    WHERE F.DATA_INICIO IS NOT NULL
),


/* ============================================================
   13) DESCOBRE QUANDO COMEÇOU A PRÓXIMA FUNÇÃO
   ============================================================ */
FUNCAO_EVENTOS_SEQ AS (
    SELECT
        F.*,

        LEAD(F.DATA_INICIO_FUNCAO) OVER (
            PARTITION BY F.COD_CONTRATO

            ORDER BY
                F.DATA_INICIO_FUNCAO,
                F.COD_FUNCAO
        ) AS PROX_DATA_INICIO_FUNCAO

    FROM FUNCAO_EVENTOS_BASE F
),


/* ============================================================
   14) FUNÇÃO COM FIM EFETIVO
   ============================================================ */
FUNCOES_HIST AS (
    SELECT
        F.COD_CONTRATO,
        F.COD_FUNCAO,
        F.FUNCAO,
        F.DATA_INICIO_FUNCAO,

        LEAST(
            NVL(
                F.DATA_FIM_FUNCAO + 1,
                DATE '3000-01-01'
            ),

            NVL(
                F.PROX_DATA_INICIO_FUNCAO,
                DATE '3000-01-01'
            )
        ) AS DATA_FIM_FUNCAO_EFETIVA

    FROM FUNCAO_EVENTOS_SEQ F
),


/* ============================================================
   15) SOMENTE FUNÇÕES GERENCIAIS

   Aplicamos o filtro somente DEPOIS de reconstruir o
   histórico corretamente.
   ============================================================ */
FUNCOES_GERENCIAIS AS (
    SELECT
        F.*

    FROM FUNCOES_HIST F

    WHERE UPPER(F.FUNCAO) LIKE '%GERENTE%'
),


/* ============================================================
   16) CRUZA:

       CONTRATO
       +
       FUNÇÃO GERENCIAL
       +
       ORGANOGRAMA

   Esse é o período REAL em que a pessoa foi gerente
   daquela unidade.
   ============================================================ */
GERENCIA_SEGMENTOS_RAW AS (
    SELECT
        O.COD_CONTRATO,
        O.COD_UNIDADE,

        F.COD_FUNCAO,
        F.FUNCAO,

        GREATEST(
            O.DATA_INI_ORG,
            F.DATA_INICIO_FUNCAO,
            C.ADMISSAO
        ) AS DATA_INICIO_GERENCIA,

        LEAST(
            O.DATA_FIM_ORG_EFETIVA,
            F.DATA_FIM_FUNCAO_EFETIVA,
            NVL(C.DEMISSAO + 1, DATE '3000-01-01')
        ) AS DATA_FIM_GERENCIA

    FROM ORG_HIST O

    INNER JOIN FUNCOES_GERENCIAIS F
        ON F.COD_CONTRATO = O.COD_CONTRATO

    INNER JOIN CONTRATOS C
        ON C.COD_CONTRATO = O.COD_CONTRATO
),


/* ============================================================
   17) ELIMINA INTERVALOS SEM INTERSEÇÃO
   ============================================================ */
GERENCIA_SEGMENTOS AS (
    SELECT *
    FROM GERENCIA_SEGMENTOS_RAW

    WHERE DATA_INICIO_GERENCIA < DATA_FIM_GERENCIA
),


/* ============================================================
   18) JUNTA SEGMENTOS CONSECUTIVOS DA MESMA PESSOA/UNIDADE
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

    FROM GERENCIA_SEGMENTOS G
),


GERENCIA_MARCADA AS (
    SELECT
        G.*,

        CASE
            WHEN G.MAIOR_FIM_ANTERIOR IS NULL
            THEN 1

            WHEN G.DATA_INICIO_GERENCIA >
                 G.MAIOR_FIM_ANTERIOR
            THEN 1

            ELSE 0
        END AS NOVO_GRUPO

    FROM GERENCIA_ORDENADA G
),


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
   19) PERÍODOS REAIS DE GERÊNCIA
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
   20) SEQUÊNCIA DOS GERENTES POR UNIDADE
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
        ) AS GERENTE_ANTERIOR

    FROM GERENCIA_PERIODOS G
),


/* ============================================================
   21) INDICADORES DA GERÊNCIA
   ============================================================ */
GERENCIA_INDICADORES AS (
    SELECT
        G.COD_UNIDADE,

        /* ====================================================
           QUANTOS GERENTES REALMENTE EXISTIRAM NA UNIDADE
           DURANTE O PERÍODO INFORMADO
           ==================================================== */
        COUNT(
            DISTINCT CASE

                WHEN G.DATA_INICIO_GERENCIA < P.DATA_FINAL

                 AND G.DATA_FIM_GERENCIA > P.DATA_INICIAL

                THEN G.COD_CONTRATO

            END
        ) AS QTD_GERENTES_PERIODO,


        /* ====================================================
           QUANTOS COMEÇARAM COMO GERENTE DA UNIDADE
           DENTRO DO PERÍODO
           ==================================================== */
        COUNT(
            DISTINCT CASE

                WHEN G.DATA_INICIO_GERENCIA >= P.DATA_INICIAL
                 AND G.DATA_INICIO_GERENCIA <  P.DATA_FINAL

                THEN G.COD_CONTRATO

            END
        ) AS GERENTES_QUE_ASSUMIRAM,


        /* ====================================================
           QUANTOS DEIXARAM A GERÊNCIA DA UNIDADE
           DENTRO DO PERÍODO
           ==================================================== */
        COUNT(
            DISTINCT CASE

                WHEN G.DATA_FIM_GERENCIA > P.DATA_INICIAL
                 AND G.DATA_FIM_GERENCIA <= P.DATA_FINAL
                 AND G.DATA_FIM_GERENCIA < DATE '3000-01-01'

                THEN G.COD_CONTRATO

            END
        ) AS GERENTES_QUE_SAIRAM,


        /* ====================================================
           TROCAS DE GERENTE

           Só conta quando um NOVO gerente iniciou
           durante o período e havia outro antes dele.
           ==================================================== */
        SUM(
            CASE
                WHEN G.DATA_INICIO_GERENCIA >= P.DATA_INICIAL
                 AND G.DATA_INICIO_GERENCIA <  P.DATA_FINAL

                 AND G.GERENTE_ANTERIOR IS NOT NULL

                 AND G.GERENTE_ANTERIOR <>
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
   22) RESULTADO FINAL
   ============================================================ */
SELECT
       U.COD_UNIDADE,
       U.DES_UNIDADE,
       U.COD_REDE,
       U.DES_REDE,

       NVL(A.ATIVOS_ATUAIS, 0)
           AS ATIVOS_ATUAIS,

       NVL(AD.QTD_ADMITIDOS, 0)
           AS QTD_ADMITIDOS,

       NVL(DE.QTD_DEMITIDOS, 0)
           AS QTD_DEMITIDOS,

       NVL(AD.QTD_ADMITIDOS, 0)
       -
       NVL(DE.QTD_DEMITIDOS, 0)
           AS SALDO_PERIODO,

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
