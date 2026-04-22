WITH BASE_PRODUTIVIDADE AS (
    SELECT
        DECODE(T.COD_UNIDADE,
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
               T.COD_UNIDADE) AS COD_UNIDADE_AJUSTADA,
        T.DTA_INI,
        T.DTA_FIM,
        NVL(T.VLR_VENDA_LOJA, 0) AS VLR_VENDA_LOJA,
        NVL(T.TOTAL_HRS, 0)      AS TOTAL_HRS
    FROM GRZ_FOLHA.GRZ_KPI_AVALIACAO_PLR_TB@GRZFOLHA T
    WHERE TRUNC(T.DTA_INI, 'MM')
          BETWEEN TO_DATE('01/01/2025', 'DD/MM/YYYY')
              AND TO_DATE('31/12/2025', 'DD/MM/YYYY')
),
INDICADOR AS (
    SELECT
        B.COD_UNIDADE_AJUSTADA AS COD_UNIDADE,
        MIN(B.DTA_INI) AS REF_INI,
        MAX(B.DTA_FIM) AS REF_FIM,
        SUM(B.VLR_VENDA_LOJA) AS VLR_VENDA_LOJA_ANO,
        SUM(B.TOTAL_HRS)      AS TOTAL_HRS_ANO,
        NVL(
            TRUNC(
                SUM(B.VLR_VENDA_LOJA) / NULLIF(SUM(B.TOTAL_HRS), 0),
                0
            ),
            0
        ) AS PRODUTIVIDADE_ANUAL
    FROM BASE_PRODUTIVIDADE B
    WHERE B.COD_UNIDADE_AJUSTADA = 4
    GROUP BY B.COD_UNIDADE_AJUSTADA
),
PONTUACAO AS (
    SELECT
        I.COD_UNIDADE,
        MAX(C.QTD_PONTOS) AS PONTOS_PRODUTIVIDADE
    FROM INDICADOR I
    JOIN NL.GRZ_CAD_CALCULO_APR_ANUAL C
      ON C.COD_REDE = 10
     AND C.ANO = 2025
     AND C.COD_CALCULO = 5
     AND I.PRODUTIVIDADE_ANUAL >= C.VALOR1
    GROUP BY I.COD_UNIDADE
)
SELECT
    I.COD_UNIDADE,
    I.REF_INI,
    I.REF_FIM,
    I.VLR_VENDA_LOJA_ANO,
    I.TOTAL_HRS_ANO,
    I.PRODUTIVIDADE_ANUAL,
    NVL(P.PONTOS_PRODUTIVIDADE, 0) AS PONTOS_PRODUTIVIDADE
FROM INDICADOR I
LEFT JOIN PONTUACAO P
       ON P.COD_UNIDADE = I.COD_UNIDADE;