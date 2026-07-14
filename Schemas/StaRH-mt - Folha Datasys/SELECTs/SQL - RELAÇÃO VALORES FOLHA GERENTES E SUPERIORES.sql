WITH MOVIMENTO AS (
    SELECT 
        A.COD_CONTRATO,
        SUM(A.VALOR_VD) AS VALOR
    FROM RHFP1006 A
    JOIN RHFP1003 B
      ON A.COD_MESTRE_EVENTO = B.COD_MESTRE_EVENTO
    WHERE B.COD_EVENTO = 9
      AND B.DATA_REFERENCIA >= DATE '2026-04-01'
      AND B.DATA_REFERENCIA <  DATE '2026-05-01'
      AND A.COD_VD = 219
    GROUP BY A.COD_CONTRATO
),

CARGO_UNICO AS (
    SELECT 
        C.COD_CONTRATO,

        CASE
            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%DIRETOR%' 
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 'DIRETORES'

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%COMPRA%'
                        AND UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%GERENTE%'
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 'GERENTES COMPRAS'

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%COMPRADOR%'
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 'COMPRADORES'

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%REGIONAL%' 
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 'GERENTES REGIONAIS'

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%SUPERVISOR%' 
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 'SUPERVISORES'

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%GERENTE%' 
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 'GERENTES ADM'

            ELSE 'COLABORADORES'
        END AS CARGOS,

        CASE
            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%DIRETOR%' 
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 1

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%COMPRA%'
                        AND UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%GERENTE%'
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 2

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%COMPRADOR%'
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 3

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%REGIONAL%' 
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 4

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%SUPERVISOR%' 
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 5

            WHEN MAX(CASE 
                       WHEN UPPER(NVL(C.DES_FUNCAO, '')) LIKE '%GERENTE%' 
                       THEN 1 ELSE 0 
                     END) = 1
            THEN 6

            ELSE 7
        END AS ORDEM

    FROM V_DADOS_COLAB_AVT C
    WHERE C.COD_TIPO = 2
    GROUP BY C.COD_CONTRATO
),

RESULTADO AS (
    SELECT 
        CU.ORDEM,
        CU.CARGOS,
        SUM(M.VALOR) AS VALOR
    FROM MOVIMENTO M
    JOIN CARGO_UNICO CU
      ON CU.COD_CONTRATO = M.COD_CONTRATO
    GROUP BY 
        CU.ORDEM,
        CU.CARGOS

    UNION ALL

    SELECT 
        999 AS ORDEM,
        'TOTAL VENCIMENTOS' AS CARGOS,
        SUM(M.VALOR) AS VALOR
    FROM MOVIMENTO M
    JOIN CARGO_UNICO CU
      ON CU.COD_CONTRATO = M.COD_CONTRATO
)

SELECT 
    CARGOS,
    TO_CHAR(
        NVL(VALOR, 0),
        'FM999G999G999G999G990D00',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS VALOR
FROM RESULTADO
ORDER BY ORDEM;