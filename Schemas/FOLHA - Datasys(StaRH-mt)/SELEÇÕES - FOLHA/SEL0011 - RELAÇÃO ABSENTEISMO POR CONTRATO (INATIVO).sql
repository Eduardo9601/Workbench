WITH Total_Contratos_Geral AS (
    -- Subconsulta para obter o total geral de contratos
    SELECT
        COUNT(COD_CONTRATO) AS TOTAL_CONTRATOS
    FROM
        V_DADOS_PESSOA_ALTER_AVT
    WHERE
        COD_EMP = '008'
),
Total_Contratos AS (
    -- Subconsulta para obter a quantidade total de contratos por unidade e setor
    SELECT
        D.COD_UNIDADE,
        D.COD_ORGANOGRAMA,
        COUNT(DISTINCT D.COD_CONTRATO) AS QTDE_TOTAL_CONTRATOS
    FROM
        V_DADOS_PESSOA_ALTER_AVT D
    WHERE
        D.COD_EMP = '008'
    GROUP BY
        D.COD_UNIDADE,
        D.COD_ORGANOGRAMA
),
Total_Gerais AS (
    -- Subconsulta para obter os totais gerais de absenteísmo, faltas e atestados
    SELECT
        COUNT(DISTINCT CASE
            WHEN A.COD_VD IN (631, 632, 831, 832, 897)
            THEN A.COD_CONTRATO
            ELSE NULL
        END) AS TOTAL_CONTR_ABS,  -- Total de contratos com absenteísmo
        SUM(CASE
            WHEN A.COD_VD IN (631, 632, 831, 832)
            THEN A.QTDE_VD
            ELSE 0
        END) AS TOTAL_FALTAS,  -- Total geral de faltas
        SUM(CASE
            WHEN A.COD_VD = 897
            THEN A.QTDE_VD
            ELSE 0
        END) AS TOTAL_ATESTADOS  -- Total geral de atestados
    FROM
        RHFP1006 A
    INNER JOIN
        RHFP1003 B ON A.COD_MESTRE_EVENTO = B.COD_MESTRE_EVENTO
    LEFT JOIN
        V_DADOS_PESSOA_ALTER_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
    WHERE
        D.COD_EMP = '008'
        AND A.COD_VD IN (631, 632, 831, 832, 897)
        AND B.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
),
Total_Faltas_Atestados_Unidade AS (
    -- Subconsulta para obter os totais de faltas e atestados por unidade e setor
    SELECT
        D.COD_UNIDADE,
        D.COD_ORGANOGRAMA,
        COUNT(DISTINCT CASE
            WHEN A.COD_VD IN (631, 632, 831, 832, 897)
            THEN A.COD_CONTRATO
            ELSE NULL
        END) AS TOTAL_CONTR_ABS_UNI,
        SUM(CASE
            WHEN A.COD_VD IN (631, 632, 831, 832)
            THEN A.QTDE_VD
            ELSE 0
        END) AS TOTAL_FALTAS_UNIDADE,  -- Total de faltas por unidade e setor
        SUM(CASE
            WHEN A.COD_VD = 897
            THEN A.QTDE_VD
            ELSE 0
        END) AS TOTAL_ATESTADOS_UNIDADE  -- Total de atestados por unidade e setor
    FROM
        RHFP1006 A
    INNER JOIN
        RHFP1003 B ON A.COD_MESTRE_EVENTO = B.COD_MESTRE_EVENTO
    LEFT JOIN
        V_DADOS_PESSOA_ALTER_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
    WHERE
        D.COD_EMP = '008'
        AND A.COD_VD IN (631, 632, 831, 832, 897)
        AND B.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
    GROUP BY
        D.COD_UNIDADE,
        D.COD_ORGANOGRAMA
)
SELECT
    A.COD_CONTRATO || ' - ' || D.DES_PESSOA AS COLABORADOR,
    D.DATA_ADMISSAO,
    D.DES_UNIDADE,
    CASE
        WHEN B.DATA_REFERENCIA != LAST_DAY(B.DATA_REFERENCIA)
        THEN B.DATA_REFERENCIA
        ELSE NULL
    END AS DTA_REF,
    INITCAP(TRIM(TO_CHAR(B.DATA_REFERENCIA, 'MONTH'))) || '/' || TO_CHAR(B.DATA_REFERENCIA, 'YYYY') AS REFERENCIA,
    -- Quantidade total de contratos por unidade e setor
    TCU.QTDE_TOTAL_CONTRATOS,
    -- Soma das quantidades dos códigos 631, 632, 831, 832 (faltas)
    SUM(CASE
            WHEN A.COD_VD IN (631, 632, 831, 832)
            THEN TO_CHAR((A.QTDE_VD), 'FM999G999G990D00')
            ELSE TO_CHAR(0)
        END) AS FALTAS,
    -- Soma das quantidades dos códigos 897 (atestados)
    SUM(CASE
            WHEN A.COD_VD = 897
            THEN TO_CHAR((A.QTDE_VD), 'FM999G999G990D00')
            ELSE TO_CHAR(0)
        END) AS ATESTADOS,
    -- Totais por unidade e setor
    TFU.TOTAL_CONTR_ABS_UNI,
    TO_CHAR(TFU.TOTAL_FALTAS_UNIDADE, 'FM999G999G990D00') AS TOTAL_FALTAS_UNIDADE,  -- Total de faltas por unidade e setor
    TO_CHAR(TFU.TOTAL_ATESTADOS_UNIDADE, 'FM999G999G990D00') AS TOTAL_ATESTADOS_UNIDADE,  -- Total de atestados por unidade e setor
    -- Totais gerais que são constantes para todas as linhas
    TG.TOTAL_CONTR_ABS,  -- Total de contratos com absenteísmo
    TO_CHAR(TG.TOTAL_FALTAS, 'FM999G999G990D00') AS TOTAL_FALTAS,        -- Total de faltas
    TO_CHAR(TG.TOTAL_ATESTADOS, 'FM999G999G990D00') AS TOTAL_ATESTADOS,  -- Total de atestados
    TC.TOTAL_CONTRATOS AS TOTAL_GERAL_CONTRATOS,  -- Total de contratos
    'Período informado: ' || TO_CHAR(:DATA_INICIO, 'DD/MM/YYYY') || ' à ' || TO_CHAR(:DATA_FIM, 'DD/MM/YYYY') AS PERIODO

FROM
    RHFP1006 A
INNER JOIN
    RHFP1003 B ON A.COD_MESTRE_EVENTO = B.COD_MESTRE_EVENTO
LEFT JOIN
    V_DADOS_PESSOA_ALTER_AVT D ON A.COD_CONTRATO = D.COD_CONTRATO
LEFT JOIN
    Total_Contratos TCU ON D.COD_UNIDADE = TCU.COD_UNIDADE AND D.COD_ORGANOGRAMA = TCU.COD_ORGANOGRAMA -- JUNTA A CTE de contratos por unidade e setor
JOIN
    Total_Gerais TG ON 1=1  -- Junta a CTE dos totais gerais
JOIN
    Total_Contratos_Geral TC ON 1=1  -- Junta a CTE do total de contratos
JOIN
    Total_Faltas_Atestados_Unidade TFU ON D.COD_UNIDADE = TFU.COD_UNIDADE AND D.COD_ORGANOGRAMA = TFU.COD_ORGANOGRAMA -- Junta a CTE dos totais por unidade e setor
WHERE
    B.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
    AND A.COD_VD IN (631, 632, 831, 832, 897)  -- Incluindo código 897
    AND D.COD_EMP = '008'
GROUP BY
    A.COD_CONTRATO,
    D.DES_PESSOA,
    D.DATA_ADMISSAO,
    D.DES_UNIDADE,
    B.DATA_REFERENCIA,
    TCU.QTDE_TOTAL_CONTRATOS,
    TFU.TOTAL_CONTR_ABS_UNI,
    TFU.TOTAL_FALTAS_UNIDADE,
    TFU.TOTAL_ATESTADOS_UNIDADE,
    TG.TOTAL_CONTR_ABS,
    TG.TOTAL_FALTAS,
    TG.TOTAL_ATESTADOS,
    TC.TOTAL_CONTRATOS
ORDER BY
    D.DES_UNIDADE ASC,
    D.DES_PESSOA ASC,
    B.DATA_REFERENCIA ASC;
