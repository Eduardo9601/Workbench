
--=========================================================================================================================--


/*PEDIDOS CESTA DE NATAL*/


SELECT DISTINCT 
    A.DES_PESSOA AS NOME, 
    A.CPF, 
    'R$ 480,00' AS CESTA_NATAL,
    A.COD_TIPO
FROM V_DADOS_COLAB_AVT A
--LEFT JOIN V_DADOS_LOJAS_AVT B ON A.COD_UNIDADE = B.COD_UNIDADE
WHERE STATUS = 0
  AND A.COD_EMP IN (8, 276, 282, 1629)
  AND A.COD_UNIDADE NOT IN (705, 707)
  AND A.COD_FUNCAO NOT IN (74, 75, 310, 409)
  AND A.DATA_ADMISSAO <= '31/10/2024'
  AND A.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
--AND A.DES_EMAIL IS NULL
--AND A.FONE_CEL IS NULL
ORDER BY 
    CASE A.COD_TIPO
        WHEN '1' THEN '1'
        WHEN '2' THEN '2'
        WHEN '3' THEN '3'
        ELSE '4'
    END,
    A.DES_PESSOA;











/*MAPEAMENTO DE DADOS NECESSÁRIOS PARA OS CARTÕES SWILE*/


------=====DADOS DOS COLABORADORES======--------


--==LOJAS

SELECT DISTINCT CASE
                  WHEN LENGTH(B.NUM_CNPJ) = 14 THEN
                   SUBSTR(B.NUM_CNPJ, 1, 2) || '.' ||
                   SUBSTR(B.NUM_CNPJ, 3, 3) || '.' ||
                   SUBSTR(B.NUM_CNPJ, 6, 3) || '/' ||
                   SUBSTR(B.NUM_CNPJ, 9, 4) || '-' ||
                   SUBSTR(B.NUM_CNPJ, 13, 2)
                  ELSE
                   B.NUM_CNPJ
                END AS CNPJ,
                B.DES_UNIDADE AS FANTASIA,
                A.DES_PESSOA AS NOME,
                A.CPF,
                A.DES_EMAIL,
                CASE
                  WHEN A.COD_DDD IS NOT NULL AND A.FONE_CEL IS NOT NULL THEN
                   '(' || A.COD_DDD || ')' || A.FONE_CEL
                  WHEN A.FONE_CEL IS NOT NULL THEN
                   A.FONE_CEL
                  ELSE
                   NULL
                END AS CELULAR,
                A.DATA_NASCIMENTO,
                'R$ 480,00' AS CARGA_TOTAL
  FROM V_DADOS_COLAB_AVT A
  LEFT JOIN V_DADOS_LOJAS_AVT B ON A.COD_UNIDADE = B.COD_UNIDADE
 WHERE A.COD_TIPO = 1
   AND STATUS = 0
   AND A.COD_UNIDADE NOT IN (705, 707)
   AND A.COD_FUNCAO NOT IN (74, 75, 310, 409)
   AND A.DATA_ADMISSAO <= '31/10/2024'
   AND A.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
   AND A.COD_UNIDADE = 7046
   --AND A.DES_EMAIL IS NULL
   --AND A.FONE_CEL IS NULL
 ORDER BY B.DES_UNIDADE, A.DES_PESSOA;



---V2

SELECT DISTINCT 
                B.DES_UNIDADE AS FANTASIA,
                A.COD_CONTRATO,
                A.DES_PESSOA AS NOME,
                A.DATA_ADMISSAO,
                A.CPF,
                CASE 
                    WHEN A.DES_EMAIL IS NOT NULL THEN
                     A.DES_EMAIL
                    ELSE
                     'NÃO CADASTRADO'
                END AS EMAIL,
                CASE
                  WHEN A.COD_DDD IS NOT NULL AND A.FONE_CEL IS NOT NULL THEN
                   '(' || A.COD_DDD || ')' || A.FONE_CEL
                  WHEN A.FONE_CEL IS NOT NULL THEN
                   A.FONE_CEL
                  ELSE
                   'NÃO CADASTRADO'
                END AS CELULAR,
                A.DATA_NASCIMENTO
                --'R$ 480,00' AS CARGA_TOTAL
  FROM V_DADOS_COLAB_AVT A
  LEFT JOIN V_DADOS_LOJAS_AVT B ON A.COD_UNIDADE = B.COD_UNIDADE
 WHERE A.COD_TIPO = 1
   AND STATUS = 0
   AND A.COD_UNIDADE NOT IN (705, 707)
   AND A.COD_FUNCAO NOT IN (74, 75, 310, 409)
   AND A.DATA_ADMISSAO <= '31/10/2024'
   AND A.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
   AND A.COD_UNIDADE = 7046
   --AND A.DES_EMAIL IS NULL
   --AND A.FONE_CEL IS NULL
 ORDER BY B.DES_UNIDADE, A.DES_PESSOA;




--=============================


--==ADM

SELECT DISTINCT '92.012.467/0001-70' AS CNPJ,
                A.DES_FILIAL AS FANTASIA,
                A.DES_PESSOA AS NOME,
                A.CPF,
                A.DES_EMAIL,
                CASE
                  WHEN A.COD_DDD IS NOT NULL AND A.FONE_CEL IS NOT NULL THEN
                   '(' || A.COD_DDD || ')' || A.FONE_CEL
                  WHEN A.FONE_CEL IS NOT NULL THEN
                   A.FONE_CEL
                  ELSE
                   NULL
                END AS CELULAR,
                A.DATA_NASCIMENTO,
                'R$ 480,00' AS CARGA_TOTAL
  FROM V_DADOS_COLAB_AVT A
 WHERE A.COD_TIPO = 2
   AND STATUS = 0
   AND A.COD_UNIDADE NOT IN (705, 707)
   AND A.COD_FUNCAO NOT IN (74, 75, 310, 409)
   AND A.DATA_ADMISSAO <= '31/10/2024'
   AND A.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
   --AND A.DES_EMAIL IS NULL
   --AND A.FONE_CEL IS NULL
 ORDER BY A.DES_PESSOA;




--=============================

--==CD

SELECT DISTINCT '92.012.467/0001-70' AS CNPJ,
                A.DES_FILIAL AS FANTASIA,
                A.DES_PESSOA AS NOME,
                A.CPF,
                A.DES_EMAIL,
                CASE
                  WHEN A.COD_DDD IS NOT NULL AND A.FONE_CEL IS NOT NULL THEN
                   '(' || A.COD_DDD || ')' || A.FONE_CEL
                  WHEN A.FONE_CEL IS NOT NULL THEN
                   A.FONE_CEL
                  ELSE
                   NULL
                END AS CELULAR,
                A.DATA_NASCIMENTO,
                'R$ 480,00' AS CARGA_TOTAL
  FROM V_DADOS_COLAB_AVT A
 WHERE A.COD_TIPO = 3
   AND STATUS = 0
   AND A.COD_UNIDADE NOT IN (705, 707)
   AND A.COD_FUNCAO NOT IN (74, 75, 310, 409)
   AND A.DATA_ADMISSAO <= '31/10/2024'
   AND A.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
 ORDER BY A.DES_PESSOA;



--=============================


--==FINANCEIRA

SELECT DISTINCT '06.339.468/0001-91' AS CNPJ,
                A.DES_FILIAL AS FANTASIA,
                --A.COD_CONTRATO,
                A.DES_PESSOA AS NOME,
                A.CPF,
                A.DES_EMAIL,
                CASE
                  WHEN A.COD_DDD IS NOT NULL AND A.FONE_CEL IS NOT NULL THEN
                   '(' || A.COD_DDD || ')' || A.FONE_CEL
                  WHEN A.FONE_CEL IS NOT NULL THEN
                   A.FONE_CEL
                  ELSE
                   NULL
                END AS CELULAR,
                A.DATA_NASCIMENTO,
                'R$ 480,00' AS CARGA_TOTAL
  FROM V_DADOS_COLAB_AVT A
 WHERE A.COD_EMP = 282      
   AND STATUS = 0
   AND A.COD_UNIDADE NOT IN (705, 707)
   AND A.COD_FUNCAO NOT IN (74, 75, 310, 168, 204, 175)
   AND A.DATA_ADMISSAO <= '31/10/2024'
   AND A.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
   AND A.COD_CONTRATO NOT IN (379244, 386731, 377540)
   --AND A.DES_EMAIL IS NULL
   --AND A.FONE_CEL IS NULL
 ORDER BY A.DES_PESSOA;




--==CSH

SELECT DISTINCT '06.018.086/0002-47' AS CNPJ,
                A.DES_FILIAL AS FANTASIA,
                A.DES_PESSOA AS NOME,
                A.CPF,
                A.DES_EMAIL,
                CASE
                  WHEN A.COD_DDD IS NOT NULL AND A.FONE_CEL IS NOT NULL THEN
                   '(' || A.COD_DDD || ') ' || A.FONE_CEL
                  WHEN A.FONE_CEL IS NOT NULL THEN
                   A.FONE_CEL
                  ELSE
                   NULL
                END AS CELULAR,
                A.DATA_NASCIMENTO,
                'R$ 480,00' AS CARGA_TOTAL
  FROM V_DADOS_COLAB_AVT A
 WHERE A.COD_EMP = 276
      
   AND STATUS = 0
   AND A.COD_UNIDADE NOT IN (705, 707)
   AND A.COD_FUNCAO NOT IN (74, 75, 310, 168, 204, 175)
   AND A.DATA_ADMISSAO <= '31/10/2024'
   AND A.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
 ORDER BY A.DES_PESSOA;





--==FLORESTA ?

SELECT DISTINCT '24.644.903/0002-54' AS CNPJ,
                A.DES_FILIAL AS FANTASIA,
                A.DES_PESSOA AS NOME,
                A.CPF,
                A.DES_EMAIL,
                CASE
                  WHEN A.COD_DDD IS NOT NULL AND A.FONE_CEL IS NOT NULL THEN
                   '(' || A.COD_DDD || ')' || A.FONE_CEL
                  WHEN A.FONE_CEL IS NOT NULL THEN
                   A.FONE_CEL
                  ELSE
                   NULL
                END AS CELULAR,
                A.DATA_NASCIMENTO,
                'R$ 480,00' AS CARGA_TOTAL
  FROM V_DADOS_COLAB_AVT A
 WHERE A.COD_EMP = 1629
      
   AND STATUS = 0
   AND A.COD_UNIDADE NOT IN (705, 707)
   AND A.COD_FUNCAO NOT IN (74, 75, 310, 168, 204, 175)
   AND A.DATA_ADMISSAO <= '31/10/2024'
   AND A.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
   --AND A.DES_EMAIL IS NULL
   --AND A.FONE_CEL IS NULL
 ORDER BY A.DES_PESSOA;


 
 
 
 
 
 
 
 
--===============================================================================






--===DADOS LOJAS ATUALIZADO

WITH Contratos AS (
    SELECT
        B2.COD_UNIDADE,
        COUNT(B2.COD_CONTRATO) AS QUANTIDADE_CARTOES
    FROM
        V_DADOS_COLAB_AVT B2
    WHERE
        B2.COD_TIPO = 1
        AND B2.STATUS = 0
        --AND B2.IND_RESP_UNI = 'S'
        AND B2.COD_FUNCAO = 168 --NOT IN (74, 75, 310, 168, 204, 175)
        AND B2.DATA_ADMISSAO <= '31/10/2024'
        AND B2.STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
    GROUP BY
        B2.COD_UNIDADE
)
SELECT
    A.DES_UNIDADE,
    A.DES_LOGRA AS LOGRADOURO,
    A.NUMERO,
    A.COMPLEMENTO,
    A.DES_BAIRRO AS BAIRRO,
    A.DES_CIDADE AS CIDADE,
    A.COD_UF AS UF,
    A.CEP,
    COALESCE(C.QUANTIDADE_CARTOES, 0) AS QUANTIDADE_CARTOES,
    B.DES_PESSOA AS RESPONSAVEL,
    A.EMAIL_LOJA,
    A.CELULAR,
    B.CPF
FROM
    V_DADOS_LOJAS_AVT A
LEFT JOIN
    Contratos C
ON
    A.COD_UNIDADE = C.COD_UNIDADE
LEFT JOIN
    V_DADOS_COLAB_AVT B
ON
    A.COD_UNIDADE = B.COD_UNIDADE
    AND B.COD_TIPO = 1
    AND B.IND_RESP_UNI = 'S'
    AND B.COD_FUNCAO = 168 --NOT IN (74, 75, 310, 168, 204, 175)
    AND B.DATA_ADMISSAO <= '31/10/2024'
GROUP BY
    A.COD_UNIDADE,
    A.DES_UNIDADE,
    A.DES_LOGRA,
    A.NUMERO,
    A.COMPLEMENTO,
    A.DES_BAIRRO,
    A.DES_CIDADE,
    A.COD_UF,
    A.CEP,
    C.QUANTIDADE_CARTOES,
    B.DES_PESSOA,
    A.EMAIL_LOJA,
    A.CELULAR,
    B.CPF
ORDER BY
    A.DES_UNIDADE;





--===ADM


SELECT  DES_FILIAL,
        'Valentin Grazziotin' AS LOGRADOURO,
        77 AS NUMERO,
        'CMatriz' AS COMPLEMENTO,
        'São Cristóvão' AS BAIRRO,
        'Passo Fundo' AS CIDADE,
        'RS' AS UF,
        '99060-030'	AS CEP,
        COUNT(COD_CONTRATO) AS QTDE_CARTOES,
        'MAURICELIA VIEIRA TESSARO' AS RESPONSAVEL,
        'mauricelia.tessaro@grazziotin.com.br' AS EMAIL_RESPONSAVEL,
        ' ' AS CELULAR_SMS,
        94215553091 AS CPF_RESPONSAVEL
FROM V_DADOS_COLAB_AVT
WHERE STATUS = 0
AND EDICAO_FILIAL = '001'
AND COD_TIPO = 2
AND COD_UNIDADE NOT IN (705, 707)
AND COD_FUNCAO = 168 --NOT IN (74, 75, 310, 168, 204, 175)
AND DATA_ADMISSAO <= '31/10/2024'
AND STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
GROUP BY EDICAO_FILIAL, DES_FILIAL;




--===CD




SELECT  DES_FILIAL AS UNIDADE,
        'Valentin Grazziotin' AS LOGRADOURO,
        77 AS NUMERO,
        'CD' AS COMPLEMENTO,
        'São Cristóvão' AS BAIRRO,
        'Passo Fundo' AS CIDADE,
        'RS' AS UF,
        '99060-030'	AS CEP,
        COUNT(COD_CONTRATO) AS QTDE_CARTOES,
        'MAURICELIA VIEIRA TESSARO' AS RESPONSAVEL,
        'mauricelia.tessaro@grazziotin.com.br' AS EMAIL_RESPONSAVEL,
        ' ' AS CELULAR_SMS,
        94215553091 AS CPF_RESPONSAVEL
FROM V_DADOS_COLAB_AVT
WHERE STATUS = 0
AND EDICAO_FILIAL = '013'
AND COD_TIPO = 3
AND COD_UNIDADE NOT IN (705, 707)
AND COD_FUNCAO = 175 --NOT IN (74, 75, 310, 168, 204, 175)
AND DATA_ADMISSAO <= '31/10/2024'
AND STATUS_AFAST IN ('EM ATIVIDADE', 'EM FÉRIAS', 'AFASTADO TEMP')
GROUP BY EDICAO_FILIAL, DES_FILIAL;



