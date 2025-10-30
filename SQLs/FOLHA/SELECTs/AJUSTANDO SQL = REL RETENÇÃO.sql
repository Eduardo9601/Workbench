/*AJUSTANDO SQL = REL RETENÇÃO*/


WITH 
-- Lista de meses no período desejado
meses AS (
    SELECT ADD_MONTHS(TO_DATE('01/09/2024', 'DD/MM/YYYY'), LEVEL - 1) AS mes_ano
    FROM dual
    CONNECT BY LEVEL <= MONTHS_BETWEEN(TO_DATE('30/09/2024', 'DD/MM/YYYY'), TO_DATE('01/09/2024', 'DD/MM/YYYY')) + 1
),

-- Unidades distintas da tabela
unidades AS (
    SELECT DISTINCT COD_UNIDADE, DES_UNIDADE
    FROM V_DADOS_COLAB_AVT
    WHERE COD_EMP = 8
),

-- Combinação de meses com unidades
meses_unidades AS (
    SELECT 
        u.COD_UNIDADE, 
        u.DES_UNIDADE, 
        TO_CHAR(m.mes_ano, 'MM/YYYY') AS mes_ano
    FROM unidades u
    CROSS JOIN meses m
),

-- Admissões em cada mês por unidade
admissoes AS (
    SELECT 
        COD_UNIDADE,
        TO_CHAR(DATA_ADMISSAO, 'MM/YYYY') AS mes_ano,
        COUNT(*) AS num_admissoes
    FROM V_DADOS_COLAB_AVT
    WHERE DATA_DEMISSAO IS NULL
      AND DATA_ADMISSAO BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2024', 'DD/MM/YYYY')
      AND COD_EMP = 8
    GROUP BY COD_UNIDADE, TO_CHAR(DATA_ADMISSAO, 'MM/YYYY')
),

-- Desligamentos em 90 dias por unidade
deslig_90 AS (
    SELECT 
        COD_UNIDADE,
        TO_CHAR(DATA_ADMISSAO, 'MM/YYYY') AS mes_ano,
        COUNT(*) AS deslig_90
    FROM V_DADOS_COLAB_AVT
    WHERE DATA_DEMISSAO IS NOT NULL
      AND DATA_DEMISSAO <= DATA_ADMISSAO + 90
      AND DATA_ADMISSAO BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2024', 'DD/MM/YYYY')
      AND COD_EMP = 8
    GROUP BY COD_UNIDADE, TO_CHAR(DATA_ADMISSAO, 'MM/YYYY')
),

-- Desligamentos em 180 dias por unidade
deslig_180 AS (
    SELECT 
        COD_UNIDADE,
        TO_CHAR(DATA_ADMISSAO, 'MM/YYYY') AS mes_ano,
        COUNT(*) AS deslig_180
    FROM V_DADOS_COLAB_AVT
    WHERE DATA_DEMISSAO IS NOT NULL
      AND DATA_DEMISSAO <= DATA_ADMISSAO + 180
      AND DATA_ADMISSAO BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2024', 'DD/MM/YYYY')
      AND COD_EMP = 8
    GROUP BY COD_UNIDADE, TO_CHAR(DATA_ADMISSAO, 'MM/YYYY')
),

-- Desligamentos em 360 dias por unidade
deslig_360 AS (
    SELECT 
        COD_UNIDADE,
        TO_CHAR(DATA_ADMISSAO, 'MM/YYYY') AS mes_ano,
        COUNT(*) AS deslig_360
    FROM V_DADOS_COLAB_AVT
    WHERE DATA_DEMISSAO IS NOT NULL
      AND DATA_DEMISSAO <= DATA_ADMISSAO + 360
      AND DATA_ADMISSAO BETWEEN TO_DATE('01/01/2024', 'DD/MM/YYYY') AND TO_DATE('31/12/2024', 'DD/MM/YYYY')
      AND COD_EMP = 8
    GROUP BY COD_UNIDADE, TO_CHAR(DATA_ADMISSAO, 'MM/YYYY')
)

-- Consulta final unificando os períodos por unidade e mês
SELECT 
    mu.COD_UNIDADE AS "Unidade",
    mu.mes_ano AS "Mês",
    NVL(a.num_admissoes, 0) AS "Nº de Admissões",
    
    -- Desligamentos e Retenção para 90 dias
    NVL(d90.deslig_90, 0) AS "Deslig 90 Dias",
    CASE 
        WHEN NVL(a.num_admissoes, 0) > 0 THEN ROUND((NVL(a.num_admissoes, 0) - NVL(d90.deslig_90, 0)) / NVL(a.num_admissoes, 0) * 100, 2)
        ELSE 0
    END AS "Retenção 90 Dias",
    
    -- Média de Retenção 90 dias acumulando o turnover
    CASE 
        WHEN NVL(a.num_admissoes, 0) > 0 THEN ROUND(((NVL(a.num_admissoes, 0) - NVL(d90.deslig_90, 0)) / NVL(a.num_admissoes, 0)) * 100, 2)
        ELSE 0
    END AS "Média Ret 90 Dias",
    
    -- Desligamentos e Retenção para 180 dias
    NVL(d180.deslig_180, 0) AS "Deslig 180 Dias",
    CASE 
        WHEN NVL(a.num_admissoes, 0) > 0 THEN ROUND((NVL(a.num_admissoes, 0) - NVL(d180.deslig_180, 0)) / NVL(a.num_admissoes, 0) * 100, 2)
        ELSE 0
    END AS "Retenção 180 Dias",
    
    -- Média de Retenção 180 dias
    CASE 
        WHEN NVL(a.num_admissoes, 0) > 0 THEN ROUND(((NVL(a.num_admissoes, 0) - NVL(d180.deslig_180, 0)) / NVL(a.num_admissoes, 0)) * 100, 2)
        ELSE 0
    END AS "Média Ret 180 Dias",
    
    -- Desligamentos e Retenção para 360 dias
    NVL(d360.deslig_360, 0) AS "Deslig 360 Dias",
    CASE 
        WHEN NVL(a.num_admissoes, 0) > 0 THEN ROUND((NVL(a.num_admissoes, 0) - NVL(d360.deslig_360, 0)) / NVL(a.num_admissoes, 0) * 100, 2)
        ELSE 0
    END AS "Retenção 360 Dias",
    
    -- Média de Retenção 360 dias
    CASE 
        WHEN NVL(a.num_admissoes, 0) > 0 THEN ROUND(((NVL(a.num_admissoes, 0) - NVL(d360.deslig_360, 0)) / NVL(a.num_admissoes, 0)) * 100, 2)
        ELSE 0
    END AS "Média Ret 360 Dias"

FROM meses_unidades mu
LEFT JOIN admissoes a ON mu.COD_UNIDADE = a.COD_UNIDADE AND mu.mes_ano = a.mes_ano
LEFT JOIN deslig_90 d90 ON mu.COD_UNIDADE = d90.COD_UNIDADE AND mu.mes_ano = d90.mes_ano
LEFT JOIN deslig_180 d180 ON mu.COD_UNIDADE = d180.COD_UNIDADE AND mu.mes_ano = d180.mes_ano
LEFT JOIN deslig_360 d360 ON mu.COD_UNIDADE = d360.COD_UNIDADE AND mu.mes_ano = d360.mes_ano
ORDER BY mu.COD_UNIDADE, TO_DATE(mu.mes_ano, 'MM/YYYY');


