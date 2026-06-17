--SQL PARA CONTAR A QUANTIDADE DE COLABORADORES POR FUNÇÃO PARA AS LOTAÇÕES

SELECT COD_UNIDADE,
       DES_UNIDADE,
       COUNT(CASE
               WHEN COD_FUNCAO = 68 THEN
                COD_CONTRATO
               ELSE
                NULL
             END) AS NUM_SERVENTES,
       COUNT(CASE
               WHEN COD_FUNCAO IN
                    (77, 78, 79, 80, 81, 86, 87, 88, 89, 90, 184, 185, 186, 188, 189, 190, 192, 294, 318) THEN
                COD_CONTRATO
               ELSE
                NULL
             END) AS NUM_GERENTES,
       COUNT(CASE
               WHEN COD_FUNCAO IN (121, 305, 122) THEN
                COD_CONTRATO
               ELSE
                NULL
             END) AS NUM_ORIENT_VENDA,
       COUNT(CASE
               WHEN COD_FUNCAO = 206 THEN
                COD_CONTRATO
               ELSE
                NULL
             END) AS NUM_AUXI_LOJA,
       COUNT(CASE
               WHEN COD_FUNCAO = 120 THEN
                COD_CONTRATO
               ELSE
                NULL
             END) AS NUM_VEND_MODA_MASC,
       COUNT(CASE
               WHEN COD_FUNCAO = 102 THEN
                COD_CONTRATO
               ELSE
                NULL
             END) AS NUM_CAIXA_GERAL,
       COUNT(CASE
               WHEN COD_FUNCAO = 74 THEN
                COD_CONTRATO
               ELSE
                NULL
             END) AS NUM_APRENDIZ,
       MAX(CASE
             WHEN COD_FUNCAO = 68 THEN
              HR_BASE_MES
             ELSE
              NULL
           END) AS HORAS_BASE_SERVENTE
  FROM V_DADOS_COLAB_AVT
 WHERE COD_EMP = '008'
   AND STATUS = 0
   AND STATUS_AFAST IN ('EM ATIVIDADE', 'AFASTADO TEMP')
   AND TIPO = 'LOJA'
   AND (COD_FUNCAO = 68 OR
       COD_FUNCAO IN
       (77, 78, 79, 80, 81, 86, 87, 88, 89, 90, 184, 185, 186, 188, 189, 190, 192, 294, 318) OR
       COD_FUNCAO IN (121, 305, 122) OR COD_FUNCAO = 206 OR
       COD_FUNCAO = 120 OR COD_FUNCAO = 102 OR COD_FUNCAO = 74)
   AND COD_UNIDADE NOT IN (004, 014, 016, 019)
 GROUP BY COD_UNIDADE, DES_UNIDADE
 ORDER BY COD_UNIDADE ASC;
