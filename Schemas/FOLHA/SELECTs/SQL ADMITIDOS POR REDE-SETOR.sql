--===SQL ADMITIDOS POR REDE/SETOR

--SELECT SEM TOTALIZADOR

SELECT COD_CONTRATO,
       COD_CONTRATO || ' - ' || DES_PESSOA AS NOME_COLAB,
       DES_FUNCAO,
       DATA_ADMISSAO,
       DATA_DEMISSAO,
       DES_UNIDADE,
       COD_REDE_LOCAL,
       CASE
          WHEN COD_REDE_LOCAL IN (10, 30, 40, 50, 70) THEN
           COD_REDE_LOCAL || ' - ' || DES_REDE_LOCAL
          ELSE
           COD_TIPO || ' - ' || DES_TIPO
       END AS DES_LOCAL,
       COD_TIPO,
       COD_TIPO || ' - ' || DES_TIPO AS TIPO_LOCAL
  FROM V_DADOS_COLAB_AVT
 WHERE STATUS = 0
   AND DATA_ADMISSAO BETWEEN :DATA_INICIO AND :DATA_FIM
   AND (COD_REDE_LOCAL = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
   AND (COD_TIPO = TO_CHAR(:TIPO_LOCAL) OR TO_CHAR(:TIPO_LOCAL) = 0)
   AND COD_EMP = '008'
 ORDER BY COD_REDE_LOCAL ASC,
          DES_UNIDADE ASC,
          DES_PESSOA ASC



--========================================--

--SELECT COM TOTALIZADOR DE CONTRATOS

SELECT *
  FROM (SELECT COD_CONTRATO,
               COD_CONTRATO || ' - ' || DES_PESSOA AS NOME_COLAB,
               DES_FUNCAO,
               DATA_ADMISSAO,
               DATA_DEMISSAO,
               DES_UNIDADE,
               COD_REDE_LOCAL,
               COD_REDE_LOCAL || ' - ' || DES_REDE_LOCAL AS DES_LOCAL,
               COD_TIPO,
               COD_TIPO || ' - ' || DES_TIPO AS TIPO_LOCAL,
               NULL AS TOTAL_CONTRATOS
          FROM V_DADOS_COLAB_AVT
         WHERE STATUS = 0
           AND DATA_ADMISSAO BETWEEN :DATA_INICIO AND :DATA_FIM
           AND (COD_REDE_LOCAL = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
           AND (COD_TIPO = TO_CHAR(:TIPO_LOCAL) OR TO_CHAR(:TIPO_LOCAL) = 0)
         

        UNION ALL

        SELECT NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               COUNT(*) AS TOTAL_CONTRATOS
          FROM V_DADOS_COLAB_AVT
         WHERE STATUS = 0
           AND DATA_ADMISSAO BETWEEN :DATA_INICIO AND :DATA_FIM
           AND (COD_REDE_LOCAL = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
           AND (COD_TIPO = TO_CHAR(:TIPO_LOCAL) OR TO_CHAR(:TIPO_LOCAL) = 0))
 ORDER BY CASE
            WHEN COD_CONTRATO IS NULL THEN
             1
            ELSE
             0
          END,
          COD_REDE_LOCAL ASC,
          DES_UNIDADE ASC

