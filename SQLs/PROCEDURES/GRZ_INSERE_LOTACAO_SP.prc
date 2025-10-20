CREATE OR REPLACE PROCEDURE GRZ_INSERE_LOTACAO_SP AS
BEGIN
  FOR REC IN (
    SELECT MIN(COD_UNIDADE) AS COD_LOTACAO,
           'LOT' || ' ' || DES_UNIDADE || ' - ' || NOME_FUNCAO AS NOME_LOTACAO,
           CASE
             WHEN NOME_FUNCAO = 'SERVENTE' THEN 'H'
             ELSE 'V'
           END AS TIPO_LOTACAO,
           CASE
             WHEN NOME_FUNCAO = 'AUX. TEMP.' THEN 3
             WHEN NOME_FUNCAO = 'APRENDIZ' THEN 4
             ELSE 1
           END AS COD_TIPO_VAGA,
           TO_CHAR(MIN(COD_UNIDADE)) AS EDICAO_QL           
      FROM (
            -- Funções reais dos colaboradores
            SELECT COD_UNIDADE,
                   DES_UNIDADE,
                   CASE
                     WHEN DES_FUNCAO LIKE '%GERENTE%' THEN 'GERENTE'
                     WHEN DES_FUNCAO LIKE '%ORIENTADOR DE VENDA%' THEN 'ORIENT. DE VENDA'
                     WHEN DES_FUNCAO LIKE '%AUXILIAR DE LOJA%' THEN 'AUX. DE LOJA'
                     WHEN DES_FUNCAO LIKE '%VENDEDOR MODA MASCULINA%' THEN 'VEND. MODA MASC.'
                     WHEN DES_FUNCAO LIKE '%CAIXA GERAL%' THEN 'CAIXA GERAL'
                     WHEN DES_FUNCAO LIKE '%APRENDIZ%' THEN 'APRENDIZ'
                     WHEN DES_FUNCAO LIKE '%SERVENTE%' THEN 'SERVENTE'
                     WHEN DES_FUNCAO LIKE '%AUX. DE LOJA TEMPORARIO%' THEN 'AUX. TEMP.'
                     ELSE NULL
                   END AS NOME_FUNCAO
              FROM V_DADOS_COLAB_AVT
             WHERE COD_EMP = 8
               AND COD_TIPO = 1
               AND STATUS = 0
               AND STATUS_AFAST IN ('EM ATIVIDADE', 'AFASTADO TEMP', 'EM FÉRIAS')
             GROUP BY COD_UNIDADE, DES_UNIDADE, DES_FUNCAO, COD_REDE_LOCAL
            
            UNION ALL
            
            -- LOTAÇÃO extra para garantir que GERENTE exista nessas unidades específicas
            SELECT COD_UNIDADE,
                   DES_UNIDADE,
                   'GERENTE' AS NOME_FUNCAO                   
              FROM (SELECT DISTINCT COD_UNIDADE, DES_UNIDADE, COD_REDE_LOCAL
                      FROM V_DADOS_COLAB_AVT
                     WHERE COD_EMP = 8
                       AND COD_TIPO = 1
                       AND STATUS = 0
                       AND COD_UNIDADE IN ('042', '055', '074', '187', '285', '351', '366', '376', '379', '383', '428', '444', '448', '450', '457', '519', '573', '574', '590', '624', '626', '644', '649', '650', '7066', '7500', '7587', '7597', '7612'))
            
            UNION ALL
            
            -- LOTAÇÃO extra para garantir que AUX. TEMP. exista em todas as unidades
            SELECT COD_UNIDADE,
                   DES_UNIDADE,
                   'AUX. TEMP.' AS NOME_FUNCAO                   
              FROM (SELECT DISTINCT COD_UNIDADE, DES_UNIDADE, COD_REDE_LOCAL
                      FROM V_DADOS_COLAB_AVT
                     WHERE COD_EMP = 8
                       AND COD_TIPO = 1
                       AND STATUS = 0
                       AND STATUS_AFAST IN ('EM ATIVIDADE', 'AFASTADO TEMP', 'EM FÉRIAS'))
            
            UNION ALL           
            
            -- LOTAÇÃO extra para garantir que APRENDIZ exista em todas as unidades
            SELECT COD_UNIDADE,
                   DES_UNIDADE,
                   'APRENDIZ' AS NOME_FUNCAO                   
              FROM (SELECT DISTINCT COD_UNIDADE, DES_UNIDADE, COD_REDE_LOCAL
                      FROM V_DADOS_COLAB_AVT
                     WHERE COD_EMP = 8
                       AND COD_TIPO = 1
                       AND STATUS = 0
                       AND STATUS_AFAST IN ('EM ATIVIDADE', 'AFASTADO TEMP', 'EM FÉRIAS'))
            
            UNION ALL
            
            /*-- LOTAÇÕES para a nova unidade 649 com as funções GERENTE, AUX. DE LOJA, e AUX. TEMP.
            SELECT '649' AS COD_UNIDADE,
                   '649 - SANTA ROSA 649' AS DES_UNIDADE,
                   'GERENTE' AS NOME_FUNCAO
              FROM dual
            UNION ALL
            SELECT '649' AS COD_UNIDADE,
                   '649 - SANTA ROSA 649' AS DES_UNIDADE,
                   'AUX. DE LOJA' AS NOME_FUNCAO
              FROM dual
            UNION ALL
            SELECT '649' AS COD_UNIDADE,
                   '649 - SANTA ROSA 649' AS DES_UNIDADE,
                   'AUX. TEMP.' AS NOME_FUNCAO
              FROM dual
            
            UNION ALL*/
            
            -- LOTAÇÃO adicional para unidade 7093 com a função GERENTE ADJ
            SELECT '7093' AS COD_UNIDADE,
                   '7093 - CIA SAO LEOPOLDO 7093' AS DES_UNIDADE,
                   'GERENTE ADJ' AS NOME_FUNCAO                   
              FROM dual
            
            UNION ALL
              
             -- LOTAÇÃO adicional para unidade 7093 com a função GERENTE ADJ
            SELECT '545' AS COD_UNIDADE,
                   '545 - SELBACH 545' AS DES_UNIDADE,
                   'SERVENTE' AS NOME_FUNCAO                   
              FROM dual
           ) 
     WHERE NOME_FUNCAO IS NOT NULL
     GROUP BY DES_UNIDADE, NOME_FUNCAO
     ORDER BY MIN(COD_UNIDADE) ASC
  ) LOOP

    INSERT INTO RHFP0509
      (COD_LOTACAO, NOME_LOTACAO, TIPO_LOTACAO, COD_TIPO_VAGA, EDICAO_QL)
    VALUES
      (SEQ_COD_LOTACAO.NEXTVAL,
       REC.NOME_LOTACAO,
       REC.TIPO_LOTACAO,
       REC.COD_TIPO_VAGA,
       REC.EDICAO_QL );
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END GRZ_INSERE_LOTACAO_SP;
/
