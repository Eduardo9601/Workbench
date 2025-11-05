CREATE OR REPLACE PROCEDURE GRZ_INSERE_LOTACAO_SP AS
BEGIN
  FOR REC IN (SELECT MIN(COD_UNIDADE) AS COD_LOTACAO,
                     'LOT' || ' ' || DES_UNIDADE || ' - ' || NOME_FUNCAO AS NOME_LOTACAO,
                     CASE
                       WHEN NOME_FUNCAO = 'SERVENTE' THEN
                        'H'
                       ELSE
                        'V'
                     END AS TIPO_LOTACAO,
                     CASE
                       WHEN NOME_FUNCAO = 'APRENDIZ' THEN
                        4
                       ELSE
                        1
                     END AS COD_TIPO_VAGA,
                     TO_CHAR(MIN(COD_UNIDADE)) AS EDICAO_QL
                FROM (SELECT COD_UNIDADE,
                             DES_UNIDADE,
                             CASE
                               WHEN DES_FUNCAO LIKE '%GERENTE%' THEN
                                'GERENTE'
                               WHEN DES_FUNCAO LIKE '%ORIENTADOR DE VENDA%' THEN
                                'ORIENT. DE VENDA'
                               WHEN DES_FUNCAO LIKE '%AUXILIAR DE LOJA%' THEN
                                'AUXI. LOJA'
                               WHEN DES_FUNCAO LIKE
                                    '%VENDEDOR MODA MASCULINA%' THEN
                                'VEND. MODA MASC.'
                               WHEN DES_FUNCAO LIKE '%CAIXA GERAL%' THEN
                                'CAIXA GERAL'
                               WHEN DES_FUNCAO LIKE '%APRENDIZ%' THEN
                                'APRENDIZ'
                               WHEN DES_FUNCAO LIKE '%SERVENTE%' THEN
                                'SERVENTE'
                               ELSE
                                NULL -- Não atribuímos 'OUTRO' aqui para evitar criar lotações desnecessárias
                             END AS NOME_FUNCAO
                        FROM V_DADOS_COLAB_AVT
                       WHERE COD_EMP = '008'
                         AND TIPO = 'LOJA'
                         AND STATUS = 0
                         AND STATUS_AFAST IN
                             ('EM ATIVIDADE', 'AFASTADO TEMP')
                         --AND COD_UNIDADE NOT IN (4, 14, 16, 19, 023, 025)
                         --AND COD_UNIDADE = 025
                       GROUP BY COD_UNIDADE, DES_UNIDADE, DES_FUNCAO
                      HAVING(DES_FUNCAO NOT LIKE '%GERENTE%' OR COD_UNIDADE NOT IN (25, 566, 580, 7046, 7093)) OR (DES_FUNCAO LIKE '%GERENTE%' AND COD_UNIDADE IN (25, 566, 580, 7046, 7093) AND COUNT(*) = 1))
               WHERE NOME_FUNCAO IS NOT NULL -- Isto exclui as funções que não correspondem aos padrões
               GROUP BY DES_UNIDADE, NOME_FUNCAO
               ORDER BY MIN(COD_UNIDADE) ASC) LOOP
    INSERT INTO RHFP0509
      (COD_LOTACAO, NOME_LOTACAO, TIPO_LOTACAO, COD_TIPO_VAGA, EDICAO_QL)
    VALUES
      (seq_cod_lotacao.NEXTVAL, -- Aqui usamos o valor da sequência
       REC.NOME_LOTACAO,
       REC.TIPO_LOTACAO,
       REC.COD_TIPO_VAGA,
       REC.EDICAO_QL);
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END GRZ_INSERE_LOTACAO_SP;
