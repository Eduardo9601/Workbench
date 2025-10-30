
SELECT
    *
FROM (
    -- Tratamento para tipos diferentes de 'LOJA'
    SELECT 
        CASE
            WHEN TIPO = 'SETOR' THEN COD_UNIDADE_SUB
            ELSE COD_UNIDADE
        END AS COD_UNIDADE_AJUSTADA,
        CASE
            WHEN TIPO = 'SETOR' THEN
                (SELECT DISTINCT SUB.DES_UNIDADE
                 FROM V_DADOS_COLAB_AVT SUB
                 WHERE SUB.COD_UNIDADE = V_DADOS_COLAB_AVT.COD_UNIDADE_SUB
                   AND ROWNUM = 1)
            ELSE
                DES_UNIDADE
        END AS DES_UNIDADE,
        CASE WHEN TIPO = 'SETOR' THEN MAX(COD_SETOR_LOJA) ELSE NULL END AS COD_SETOR_LOJA,
        TIPO,
        MAX(COD_UNIDADE_SUB) AS COD_UNIDADE_SUB,
        COUNT(COD_CONTRATO) AS QTD_CONTRATOS,
        SUM(CASE
                WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' AND
                     DES_FUNCAO NOT LIKE '%ESTAGIARIO%' AND
                     DES_FUNCAO NOT LIKE '%APRENDIZ%' AND
                     (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                     1
                ELSE
                     0
            END) AS QTD_COLABORADORES,
        -- Outras colunas e cálculos
    FROM V_DADOS_COLAB_AVT
    WHERE TIPO != 'LOJA'
    AND COD_EMP = '008'
    AND STATUS = 0
    AND DATA_ADMISSAO <= '26/10/2023'
    AND (DATA_DEMISSAO IS NULL OR DATA_DEMISSAO >= '26/10/2023')

    UNION ALL

    -- Tratamento específico para o tipo 'LOJA'
    SELECT
        'LOJAS' AS COD_UNIDADE_AJUSTADA,
        'LOJAS' AS DES_UNIDADE,
        NULL AS COD_SETOR_LOJA,
        'LOJA' AS TIPO,
        NULL AS COD_UNIDADE_SUB,
        NULL AS QTD_CONTRATOS,
        NULL AS QTD_COLABORADORES,
        -- Outras colunas e cálculos específicos para 'LOJA'
    FROM V_DADOS_COLAB_AVT
    WHERE TIPO = 'LOJA'
    AND COD_EMP = '008'
    AND STATUS = 0
    AND DATA_ADMISSAO <= '26/10/2023'
    AND (DATA_DEMISSAO IS NULL OR DATA_DEMISSAO >= '26/10/2023')
    GROUP BY 'LOJAS', 'LOJA'
) 
ORDER BY 
    -- Critérios de ordenação conforme necessário
