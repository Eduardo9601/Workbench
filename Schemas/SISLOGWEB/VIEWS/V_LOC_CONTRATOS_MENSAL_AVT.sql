CREATE OR REPLACE VIEW V_LOC_CONTRATOS_MENSAL_AVT AS
WITH

/* =========================================================
   COMPETÊNCIAS DISPONÍVEIS PARA CONSULTA
========================================================= */
PERIODOS AS
(
    SELECT
        ADD_MONTHS(DATE '2000-01-01', LEVEL - 1) AS COMPETENCIA_REF,

        EXTRACT
        (
            YEAR
            FROM ADD_MONTHS(DATE '2000-01-01', LEVEL - 1)
        ) AS ANO_REF,

        EXTRACT
        (
            MONTH
            FROM ADD_MONTHS(DATE '2000-01-01', LEVEL - 1)
        ) AS MES_REF,

        TO_NUMBER
        (
            TO_CHAR
            (
                ADD_MONTHS(DATE '2000-01-01', LEVEL - 1),
                'YYYYMM'
            )
        ) AS ANOMES_REF

    FROM DUAL

    CONNECT BY LEVEL <=
        MONTHS_BETWEEN
        (
            DATE '2999-12-01',
            DATE '2000-01-01'
        ) + 1
),

/* =========================================================
   BASE APENAS COM CONTRATOS VIGENTES
========================================================= */
BASE_CONTRATOS AS
(
    SELECT
        A.COD_UNIDADE,

        CASE
            WHEN A.COD_UNIDADE = 630 THEN
                'FOTOVOLTAICAS'
            ELSE
                V.DES_FANTASIA
        END AS DES_UNIDADE,

        V.REDE,
        A.COD_CONTRATO,
        A.IND_INATIVO,
        A.DTA_INICIO,
        A.DTA_TERMINO,

        B.VAL_FIXO,
        B.VAL_ANTIGO_ALUGUEL,
        B.VAL_NOVO_ALUGUEL,
        B.DTA_ALTERACAO,

        B.VAL_DIFERENCA,
        B.DTA_VALIDADE_DIF,

        B.VAL_DESCTO,
        B.DTA_DESCTO_INI,
        B.DTA_DESCTO_FIM

    FROM GRAZZ.GRZ_LOC_CONTRATOS A

    JOIN GRAZZ.GRZ_LOC_CONTR_VALORES B
      ON B.COD_CONTRATO = A.COD_CONTRATO

    LEFT JOIN SISLOGWEB.V_UNIDADES_ATIVAS V
      ON V.COD_UNIDADE = A.COD_UNIDADE

    WHERE A.COD_EMPRESA = 1
      AND A.IND_INATIVO = 0
      AND B.IND_INATIVO = 0
      AND B.COD_VALOR = 1
),

/* =========================================================
   VERIFICA REAJUSTE CONFORME A COMPETÊNCIA
========================================================= */
REAJUSTE AS
(
    SELECT
        P.COMPETENCIA_REF,
        B.COD_UNIDADE,
        B.COD_CONTRATO,
        B.DTA_ALTERACAO

    FROM PERIODOS P

    JOIN BASE_CONTRATOS B
      ON B.DTA_ALTERACAO >= P.COMPETENCIA_REF
),

/* =========================================================
   LOJAS QUE POSSUEM DESCONTOS VIGENTES NA COMPETÊNCIA

   O desconto somente será considerado quando:
   - já tiver iniciado na competência consultada;
   - ainda não tiver terminado na competência consultada.
========================================================= */
DESCONTOS AS
(
    SELECT
        P.COMPETENCIA_REF,
        B.COD_UNIDADE,
        B.COD_CONTRATO,
        B.VAL_DESCTO,
        B.DTA_DESCTO_INI,
        B.DTA_DESCTO_FIM,

        LAST_DAY
        (
            ADD_MONTHS(B.DTA_DESCTO_FIM, -1)
        ) AS DESCONTO_ATE

    FROM PERIODOS P

    JOIN BASE_CONTRATOS B
      ON P.COMPETENCIA_REF >= TRUNC(B.DTA_DESCTO_INI, 'MM')
     AND P.COMPETENCIA_REF <  TRUNC(B.DTA_DESCTO_FIM, 'MM')
),

/* =========================================================
   LOJAS QUE POSSUEM DIFERENÇAS
========================================================= */
DIFERENCAS AS
(
    SELECT
        P.COMPETENCIA_REF,
        B.COD_UNIDADE,
        B.COD_CONTRATO,
        B.VAL_DIFERENCA,

        LAST_DAY
        (
            ADD_MONTHS(B.DTA_VALIDADE_DIF, -1)
        ) AS VALIDADE_DIF

    FROM PERIODOS P

    JOIN BASE_CONTRATOS B
      ON B.DTA_VALIDADE_DIF >= P.COMPETENCIA_REF
),

/* =========================================================
   LOJAS QUE POSSUEM EMPRÉSTIMOS

   Busca o último mês disponível somente dentro do ano da
   competência informada, de janeiro até o mês solicitado.
========================================================= */
LOJAS_EMPRESTIMOS AS
(
    SELECT
        P.COMPETENCIA_REF,
        A.COD_UNIDADE,
        A.COD_CONTRATO,

        SUM
        (
            NVL(A.VLR_ADIANTAMENTO, 0)
        ) AS VLR_EMPRESTIMO,

        CAST(NULL AS DATE) AS EMPRESTIMO_ATE

    FROM PERIODOS P

    JOIN GRAZZ.GRZ_LOC_MVTO A
      ON
      (
          A.ANO_REFERENCIA * 100
          + A.MES_REFERENCIA
      ) =
      (
          SELECT
              MAX
              (
                  SUB.ANO_REFERENCIA * 100
                  + SUB.MES_REFERENCIA
              )

          FROM GRAZZ.GRZ_LOC_MVTO SUB

          WHERE SUB.COD_UNIDADE = A.COD_UNIDADE
            AND SUB.COD_CONTRATO = A.COD_CONTRATO
            AND SUB.VLR_ADIANTAMENTO <> 0

            AND
            (
                SUB.ANO_REFERENCIA * 100
                + SUB.MES_REFERENCIA
            )
            BETWEEN
                TO_NUMBER
                (
                    TO_CHAR(P.COMPETENCIA_REF, 'YYYY') || '01'
                )
            AND
                TO_NUMBER
                (
                    TO_CHAR(P.COMPETENCIA_REF, 'YYYYMM')
                )
      )

    JOIN GRAZZ.GRZ_LOC_ADIANTAMENTOS B
      ON B.COD_PESSOA = A.COD_PESSOA
     AND B.COD_CONTRATO = A.COD_CONTRATO

    WHERE A.VLR_ADIANTAMENTO <> 0

    GROUP BY
        P.COMPETENCIA_REF,
        A.COD_UNIDADE,
        A.COD_CONTRATO
),

/* =========================================================
   RETENÇÃO DA UNIDADE 284

   Busca o último mês disponível até a competência.
   A data RETENCAO_ATE permanece fixa em agosto/2032.
========================================================= */
LOJAS_RETENCAO AS
(
    SELECT
        P.COMPETENCIA_REF,
        A.COD_UNIDADE,

        SUM
        (
            NVL(A.VLR_ADIANTAMENTO, 0)
        ) AS VLR_RETENCAO,

        LAST_DAY
        (
            TO_DATE('08/2032', 'MM/YYYY')
        ) AS RETENCAO_ATE

    FROM PERIODOS P

    JOIN GRAZZ.GRZ_LOC_MVTO A
      ON
      (
          A.ANO_REFERENCIA * 100
          + A.MES_REFERENCIA
      ) =
      (
          SELECT
              MAX
              (
                  SUB.ANO_REFERENCIA * 100
                  + SUB.MES_REFERENCIA
              )

          FROM GRAZZ.GRZ_LOC_MVTO SUB

          WHERE SUB.COD_UNIDADE = A.COD_UNIDADE
            AND SUB.VLR_ADIANTAMENTO <> 0

            AND
            (
                SUB.ANO_REFERENCIA * 100
                + SUB.MES_REFERENCIA
            )
            <= TO_NUMBER
               (
                   TO_CHAR(P.COMPETENCIA_REF, 'YYYYMM')
               )
      )

    WHERE A.VLR_ADIANTAMENTO <> 0
      AND A.COD_UNIDADE = 284

    GROUP BY
        P.COMPETENCIA_REF,
        A.COD_UNIDADE
),

/* =========================================================
   UNIDADES QUE DEVEM SER AGREGADAS EM UMA ÚNICA LINHA
========================================================= */
UNIDADES_AGREGADAS AS
(
    SELECT 22 AS COD_UNIDADE
    FROM DUAL

    UNION ALL

    SELECT 125
    FROM DUAL

    UNION ALL

    SELECT 337
    FROM DUAL

    UNION ALL

    SELECT 356
    FROM DUAL
),

/* =========================================================
   AGREGAÇÃO POR COMPETÊNCIA, UNIDADE E CONTRATO
========================================================= */
CONTRATOS AS
(
    SELECT
        P.COMPETENCIA_REF,

        B.COD_UNIDADE AS UNIDADE,

        CASE
            WHEN UA.COD_UNIDADE IS NOT NULL THEN
                -1
            ELSE
                B.COD_CONTRATO
        END AS CHAVE_GRP,

        MAX(B.DES_UNIDADE) AS DES_UNIDADE,
        MAX(B.REDE) AS REDE,

        CASE
            WHEN MIN(B.IND_INATIVO) = 0 THEN
                'ATIVO'

            WHEN MAX(B.IND_INATIVO) = 1 THEN
                'INATIVO'

            ELSE
                TO_CHAR(MAX(B.IND_INATIVO))
        END AS DES_SITUACAO,

        MIN(B.DTA_INICIO) AS DTA_INICIO,
        MAX(B.DTA_TERMINO) AS DTA_TERMINO,
        MAX(R.DTA_ALTERACAO) AS DTA_ALTERACAO,

        SUM
        (
            NVL(B.VAL_FIXO, 0)
        ) AS VLR_ALUGUEL_FIXO,

        SUM
        (
            NVL(B.VAL_NOVO_ALUGUEL, 0)
        ) AS VLR_NOVO_ALUGUEL,

        SUM
        (
            NVL(B.VAL_ANTIGO_ALUGUEL, 0)
        ) AS VLR_ANTIGO_ALUGUEL,

        SUM
        (
            NVL(F_DIF.VAL_DIFERENCA, 0)
        ) AS VLR_DIFERENCA,

        MAX(F_DIF.VALIDADE_DIF) AS DTA_DIFERENCA,

        CASE
            WHEN B.COD_UNIDADE = 284 THEN
                NVL(MAX(F_RET.VLR_RETENCAO), 0)

            ELSE
                SUM(NVL(D.VAL_DESCTO, 0))
        END AS VLR_DESCONTO,

        CASE
            WHEN B.COD_UNIDADE = 284 THEN
                MAX(F_RET.RETENCAO_ATE)

            ELSE
                MAX(D.DESCONTO_ATE)
        END AS DESCONTO_ATE,

        SUM
        (
            NVL(E.VLR_EMPRESTIMO, 0)
        ) AS VLR_EMPRESTIMO,

        MAX(E.EMPRESTIMO_ATE) AS EMPRESTIMO_ATE

    FROM PERIODOS P

    CROSS JOIN BASE_CONTRATOS B

    LEFT JOIN UNIDADES_AGREGADAS UA
      ON UA.COD_UNIDADE = B.COD_UNIDADE

    LEFT JOIN DESCONTOS D
      ON D.COMPETENCIA_REF = P.COMPETENCIA_REF
     AND D.COD_UNIDADE = B.COD_UNIDADE
     AND D.COD_CONTRATO = B.COD_CONTRATO

    LEFT JOIN DIFERENCAS F_DIF
      ON F_DIF.COMPETENCIA_REF = P.COMPETENCIA_REF
     AND F_DIF.COD_UNIDADE = B.COD_UNIDADE
     AND F_DIF.COD_CONTRATO = B.COD_CONTRATO

    LEFT JOIN LOJAS_EMPRESTIMOS E
      ON E.COMPETENCIA_REF = P.COMPETENCIA_REF
     AND E.COD_UNIDADE = B.COD_UNIDADE
     AND E.COD_CONTRATO = B.COD_CONTRATO

    LEFT JOIN REAJUSTE R
      ON R.COMPETENCIA_REF = P.COMPETENCIA_REF
     AND R.COD_UNIDADE = B.COD_UNIDADE
     AND R.COD_CONTRATO = B.COD_CONTRATO

    LEFT JOIN LOJAS_RETENCAO F_RET
      ON F_RET.COMPETENCIA_REF = P.COMPETENCIA_REF
     AND F_RET.COD_UNIDADE = B.COD_UNIDADE

    GROUP BY
        P.COMPETENCIA_REF,
        B.COD_UNIDADE,

        CASE
            WHEN UA.COD_UNIDADE IS NOT NULL THEN
                -1
            ELSE
                B.COD_CONTRATO
        END,

        CASE
            WHEN B.COD_UNIDADE = 284 THEN
                F_RET.RETENCAO_ATE
        END
)

/* =========================================================
   RESULTADO FINAL

   Mantidos os mesmos formatos do SQL original.
========================================================= */
SELECT
    CT.COMPETENCIA_REF,
    CT.REDE,
    CT.UNIDADE,

    CASE
        WHEN CT.CHAVE_GRP = -1 THEN
            NULL
        ELSE
            CT.CHAVE_GRP
    END AS COD_CONTRATO,

    CT.DES_UNIDADE,
    CT.DES_SITUACAO,
    CT.DTA_INICIO,
    CT.DTA_TERMINO,
    CT.DTA_ALTERACAO,

    TO_CHAR
    (
        SUM
        (
            CASE
                WHEN CT.DTA_ALTERACAO IS NOT NULL
                 AND CT.DTA_ALTERACAO >= CT.COMPETENCIA_REF
                THEN
                    NVL(CT.VLR_ANTIGO_ALUGUEL, 0)
                ELSE
                    NVL
                    (
                        NULLIF(CT.VLR_ALUGUEL_FIXO, 0),
                        CT.VLR_NOVO_ALUGUEL
                    )
            END
        ),
        'FM999G999G990D00',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS VLR_ALUGUEL,
    

   TO_CHAR
    (
        SUM(CT.VLR_DIFERENCA),
        'FM999G999G990D00',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS DIFERENCA,
    

    TO_CHAR
    (
        CT.DTA_DIFERENCA,
        'fmMonth/yyyy',
        'NLS_DATE_LANGUAGE=Portuguese'
    ) AS DTA_DIFERENCA,

    TO_CHAR
    (
        SUM(CT.VLR_DESCONTO),
        'FM999G999G990D00',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS DESCONTO,

    TO_CHAR
    (
        CT.DESCONTO_ATE,
        'fmMonth/yyyy',
        'NLS_DATE_LANGUAGE=Portuguese'
    ) AS DESCONTO_ATE,

   TO_CHAR
    (
        SUM(CT.VLR_EMPRESTIMO),
        'FM999G999G990D00',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS EMPRESTIMO,

    TO_CHAR
    (
        CT.EMPRESTIMO_ATE,
        'fmMonth/yyyy',
        'NLS_DATE_LANGUAGE=Portuguese'
    ) AS EMPRESTIMO_ATE,

   TO_CHAR
  (
      SUM
      (
            CASE
                WHEN CT.DTA_ALTERACAO IS NOT NULL THEN
                    NVL(CT.VLR_ANTIGO_ALUGUEL, 0)
                ELSE
                    NVL
                    (
                        NULLIF(CT.VLR_ALUGUEL_FIXO, 0),
                        CT.VLR_NOVO_ALUGUEL
                    )
            END

          + NVL(CT.VLR_DIFERENCA, 0)
          - NVL(CT.VLR_DESCONTO, 0)
          - NVL(CT.VLR_EMPRESTIMO, 0)
      ),
      'FM999G999G990D00',
      'NLS_NUMERIC_CHARACTERS = '',.'''
  ) AS SALDO

FROM CONTRATOS CT

GROUP BY
    CT.COMPETENCIA_REF,
    CT.REDE,
    CT.UNIDADE,

    CASE
        WHEN CT.CHAVE_GRP = -1 THEN
            NULL
        ELSE
            CT.CHAVE_GRP
    END,

    CT.DES_UNIDADE,
    CT.DES_SITUACAO,
    CT.DTA_INICIO,
    CT.DTA_TERMINO,
    CT.DTA_ALTERACAO,
    CT.DTA_DIFERENCA,
    CT.DESCONTO_ATE,
    CT.EMPRESTIMO_ATE
ORDER BY CT.REDE,
         CT.UNIDADE;
