SELECT UPPER(A.DES_PESSOA),
       A.NACIONALIDADE,
       A.DES_EST_CIVIL,
       'Passo Fundo/RS, ' || TO_CHAR(A.DATA_INICIO_CLH, 'DD "de" FMMonth "de" YYYY', 'NLS_DATE_LANGUAGE=Portuguese') AS INICIO_FUNCAO,
       'Nº ' || A.NRO_IDENTIDADE || ' - ' || A.EMISSOR AS IDENTIDADE,
       A.DES_CIDADE || '/' || A.COD_UF AS CIDADE,
       'na ' || INITCAP(LOWER(B.DES_TIP_LOGRA)) || ' ' || INITCAP(LOWER(B.DES_LOGRA)) || ', ' || 
       'nº ' || B.NUMERO || ', ' ||
       -- Tratamento para "no Bairro" com base no valor de DES_BAIRRO
       CASE
           WHEN B.DES_BAIRRO = 'CENTRO' THEN INITCAP(LOWER(B.DES_BAIRRO)) || ', '
           ELSE 'no Bairro ' || INITCAP(LOWER(B.DES_BAIRRO)) || ', '
       END ||
       'na cidade de ' || B.DES_CIDADE || '/' || B.COD_UF AS ENDERECO_UNIDADE,
       B.DES_REDE || ' - ' || 'Loja - ' || A.COD_UNIDADE AS FANTASIA,
       'Passo Fundo/RS ' || TO_CHAR(SYSDATE, 'DD "de" FMMonth "de" YYYY', 'NLS_DATE_LANGUAGE=Portuguese') AS REFERENCIA
  FROM (SELECT *
          FROM V_DADOS_COLAB_AVT
         WHERE DATA_DEMISSAO IS NULL
           AND COD_TIPO IN (2, 3)
           AND COD_FUNCAO IN
               (1, 3, 4, 5, 6, 7, 8, 12, 13, 14, 16, 77, 78, 79, 80, 81, 86, 87, 88, 89,
                128, 137, 184, 185, 186, 188, 189, 190, 192, 255, 264, 266, 268, 275, 279,
                280, 283, 292, 294, 299, 302, 312, 316, 318, 325, 330, 341, 344, 345, 355,
                356, 373, 374, 390, 399, 402, 407, 408, 410)) A
 INNER JOIN V_ORGANOGRAMAS_AVT B ON A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA
WHERE (:COD_CONTRATO = '0' OR
       A.COD_CONTRATO IN
       (SELECT * FROM TABLE(SPLIT_CONTRACTS(:COD_CONTRATO))));
