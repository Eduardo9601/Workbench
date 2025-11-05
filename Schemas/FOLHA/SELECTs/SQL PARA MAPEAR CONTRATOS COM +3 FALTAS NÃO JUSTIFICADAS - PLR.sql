--===VERIFICANDO CASOS COM +3 FALATAS NÃO JUSTIFICADAS===--

SELECT *
  FROM (
        
        SELECT NULL AS COD_CONTRATO,
                NULL AS DES_PESSOA,
                '===APENAS COLABORADORES INATIVOS===' AS DES_FUNCAO,
                NULL AS DATA_ADMISSAO,
                NULL AS DATA_DEMISSAO,
                NULL AS DES_UNIDADE,
                NULL AS FALTAS,
                1 AS ORDER_BLOCK
          FROM DUAL
        
        UNION ALL
        
        SELECT A.COD_CONTRATO,
               C.DES_PESSOA,
               C.DES_FUNCAO,
               C.DATA_ADMISSAO,
               C.DATA_DEMISSAO,
               C.DES_UNIDADE,
               COUNT(A.COD_CONTRATO) AS FALTAS,
               2 AS ORDER_BLOCK
          FROM RHFP1006 A
         INNER JOIN RHFP1003 B ON A.COD_MESTRE_EVENTO = B.COD_MESTRE_EVENTO
         INNER JOIN V_DADOS_COLAB_AVT C ON A.COD_CONTRATO = C.COD_CONTRATO
         WHERE A.COD_VD IN (832, 632)
           AND A.COD_VD NOT IN (633)
           AND C.COD_EMP = '008'
           AND B.DATA_INI_MOV >= '01/01/2023'
           AND B.DATA_INI_MOV <= '31/12/2023'
           AND C.DATA_ADMISSAO <= '01/07/2023'
           AND C.DATA_DEMISSAO IS NOT NULL
           AND C.DES_FUNCAO NOT LIKE '%APRENDIZ%'
           AND C.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
         GROUP BY A.COD_CONTRATO,
                  C.DES_PESSOA,
                  C.DES_FUNCAO,
                  C.DATA_ADMISSAO,
                  C.DATA_DEMISSAO,
                  C.DES_UNIDADE
        HAVING COUNT(A.COD_CONTRATO) > 3
        
        UNION ALL
        
        SELECT NULL AS COD_CONTRATO,
               NULL AS DES_PESSOA,
               NULL AS DES_FUNCAO,
               NULL AS DATA_ADMISSAO,
               NULL AS DATA_DEMISSAO,
               NULL AS DES_UNIDADE,
               NULL AS FALTAS,
               2    AS ORDER_BLOCK
          FROM DUAL
        
        UNION ALL
        
        SELECT NULL AS COD_CONTRATO,
               NULL AS DES_PESSOA,
               '===APENAS COLABORADORES ATIVOS===' AS DES_FUNCAO,
               NULL AS DATA_ADMISSAO,
               NULL AS DATA_DEMISSAO,
               NULL AS DES_UNIDADE,
               NULL AS FALTAS,
               3 AS ORDER_BLOCK
          FROM DUAL
        
        UNION ALL
        
        SELECT A.COD_CONTRATO,
               C.DES_PESSOA,
               C.DES_FUNCAO,
               C.DATA_ADMISSAO,
               C.DATA_DEMISSAO,
               C.DES_UNIDADE,
               COUNT(A.COD_CONTRATO) AS FALTAS,
               4 AS ORDER_BLOCK
          FROM RHFP1006 A
         INNER JOIN RHFP1003 B ON A.COD_MESTRE_EVENTO = B.COD_MESTRE_EVENTO
         INNER JOIN V_DADOS_COLAB_AVT C ON A.COD_CONTRATO = C.COD_CONTRATO
         WHERE A.COD_VD IN (832, 632)
           AND A.COD_VD NOT IN (633)
           AND C.COD_EMP = '008'
           AND B.DATA_INI_MOV >= '01/01/2023'
           AND B.DATA_INI_MOV <= '31/12/2023'
           AND C.DATA_ADMISSAO <= '01/07/2023'
           AND C.DATA_DEMISSAO IS NULL
           AND C.DES_FUNCAO NOT LIKE '%APRENDIZ%'
           AND C.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
         GROUP BY A.COD_CONTRATO,
                  C.DES_PESSOA,
                  C.DES_FUNCAO,
                  C.DATA_ADMISSAO,
                  C.DATA_DEMISSAO,
                  C.DES_UNIDADE
        HAVING COUNT(A.COD_CONTRATO) > 3)
 ORDER BY ORDER_BLOCK, DES_UNIDADE ASC