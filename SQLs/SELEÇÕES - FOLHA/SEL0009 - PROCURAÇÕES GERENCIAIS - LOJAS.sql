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
           AND COD_TIPO = 1
           AND COD_FUNCAO IN
               (77, 78, 79, 80, 81, 86, 87, 88, 89, 184, 185, 186, 188, 189, 190, 192, 294, 318)) A
 INNER JOIN V_ORGANOGRAMAS_AVT B ON A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA
WHERE (:COD_CONTRATO = '0' OR
       A.COD_CONTRATO IN
       (SELECT * FROM TABLE(SPLIT_CONTRACTS(:COD_CONTRATO))))
