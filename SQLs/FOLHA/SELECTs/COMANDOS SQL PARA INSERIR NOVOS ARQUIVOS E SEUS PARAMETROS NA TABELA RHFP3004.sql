--=====COMANDOS SQL PARA INSERIR NOVOS ARQUIVOS E SEUS PARAMETROS NA TABELA RHFP3004


SELECT * FROM RHFP3004
WHERE COD_ARQUIVO IN (5073, 5074)
ORDER BY COD_ARQUIVO ASC, COD_FUNCAO ASC


INSERT INTO RHFP3004 (COD_ARQUIVO, COD_FUNCAO, SEQUENCIA, OPERACAO, CAMPO, TIPO_REGISTRO, CONSTANTE, TIPO_INFORMACAO)
SELECT DISTINCT COD_ARQUIVO, COD_FUNCAO, SEQUENCIA, OPERACAO, CAMPO, TIPO_REGISTRO, CONSTANTE, TIPO_INFORMACAO FROM(
SELECT DISTINCT 5073 AS COD_ARQUIVO,
                3 AS COD_FUNCAO,
                1 AS SEQUENCIA,
                '+' AS OPERACAO,
                7 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'S' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5073 AS COD_ARQUIVO,
                3 AS COD_FUNCAO,
                2 AS SEQUENCIA,
                '-' AS OPERACAO,
                NULL AS CAMPO,
                NULL AS TIPO_REGISTRO,
                1 AS CONSTANTE,
                'C' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5073 AS COD_ARQUIVO,
                4 AS COD_FUNCAO,
                1 AS SEQUENCIA,
                '+' AS OPERACAO,
                20 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'S' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5073 AS COD_ARQUIVO,
                4 AS COD_FUNCAO,
                2 AS SEQUENCIA,
                '*' AS OPERACAO,
                2 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'V' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5073 AS COD_ARQUIVO,
                5 AS COD_FUNCAO,
                1 AS SEQUENCIA,
                '+' AS OPERACAO,
                7 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'S' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5073 AS COD_ARQUIVO,
                5 AS COD_FUNCAO,
                2 AS SEQUENCIA,
                '-' AS OPERACAO,
                NULL AS CAMPO,
                NULL AS TIPO_REGISTRO,
                4 AS CONSTANTE,
                'C' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL


SELECT DISTINCT 5074 AS COD_ARQUIVO,
                3 AS COD_FUNCAO,
                1 AS SEQUENCIA,
                '+' AS OPERACAO,
                7 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'S' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5074 AS COD_ARQUIVO,
                3 AS COD_FUNCAO,
                2 AS SEQUENCIA,
                '-' AS OPERACAO,
                NULL AS CAMPO,
                NULL AS TIPO_REGISTRO,
                1 AS CONSTANTE,
                'C' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5074 AS COD_ARQUIVO,
                4 AS COD_FUNCAO,
                1 AS SEQUENCIA,
                'S' AS OPERACAO,
                517 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'P' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5074 AS COD_ARQUIVO,
                5 AS COD_FUNCAO,
                1 AS SEQUENCIA,
                '+' AS OPERACAO,
                7 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'S' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5074 AS COD_ARQUIVO,
                5 AS COD_FUNCAO,
                3 AS SEQUENCIA,
                '+' AS OPERACAO,
                3 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'V' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5074 AS COD_ARQUIVO,
                5 AS COD_FUNCAO,
                4 AS SEQUENCIA,
                '-' AS OPERACAO,
                NULL AS CAMPO,
                NULL AS TIPO_REGISTRO,
                3 AS CONSTANTE,
                'C' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5074 AS COD_ARQUIVO,
                6 AS COD_FUNCAO,
                1 AS SEQUENCIA,
                '+' AS OPERACAO,
                7 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'S' AS TIPO_INFORMACAO
  FROM RHFP3004

UNION ALL

SELECT DISTINCT 5074 AS COD_ARQUIVO,
                6 AS COD_FUNCAO,
                2 AS SEQUENCIA,
                '+' AS OPERACAO,
                3 AS CAMPO,
                NULL AS TIPO_REGISTRO,
                NULL AS CONSTANTE,
                'V' AS TIPO_INFORMACAO
  FROM RHFP3004
);