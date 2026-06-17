SELECT T.*, E.MEDIA_ANOS_EMPRESA, E.TOTAL_COLAB_EMPRESA
  FROM (SELECT STATUS,
               COD_CONTRATO,
               DES_PESSOA,
               DATA_ADMISSAO,
               DATA_AVANCO,
               DES_FUNCAO,
               COD_UNIDADE,
               DES_UNIDADE,
               COD_TIPO,
               COD_REDE_LOCAL,
               DES_REDE_LOCAL,
               
               -- Tempo de empresa individual
               TRUNC(MONTHS_BETWEEN(SYSDATE, DATA_AVANCO) / 12) ||
               ' ano(s) ' || ' e ' ||
               TRUNC(MOD(MONTHS_BETWEEN(SYSDATE, DATA_AVANCO), 12)) ||
               ' mês(es)' AS TEMPO_EMPRESA,
               
               MONTHS_BETWEEN(SYSDATE, DATA_AVANCO) AS MESES_TOTAIS,
               
               -- Média por unidade
               ROUND(SUM(MONTHS_BETWEEN(SYSDATE, DATA_AVANCO))
                     OVER(PARTITION BY DES_UNIDADE) / COUNT(*)
                     OVER(PARTITION BY DES_UNIDADE) / 12,
                     1) AS MEDIA_ANOS_UNIDADE,
               COUNT(*) OVER(PARTITION BY DES_UNIDADE) AS TOTAL_COLAB_UNIDADE,
               
               -- Média por rede
               ROUND(SUM(MONTHS_BETWEEN(SYSDATE, DATA_AVANCO))
                     OVER(PARTITION BY COD_REDE_LOCAL) / COUNT(*)
                     OVER(PARTITION BY COD_REDE_LOCAL) / 12,
                     1) AS MEDIA_ANOS_REDE,
               COUNT(*) OVER(PARTITION BY COD_REDE_LOCAL) AS TOTAL_COLAB_REDE,
               
               -- Afastamento formatado
               DES_AFAST,
               CASE
                 WHEN DATA_INI_AFAST IS NOT NULL AND
                      DATA_FIM_AFAST IS NOT NULL THEN
                  TO_CHAR(DATA_INI_AFAST, 'DD/MM/YYYY') || ' à ' ||
                  TO_CHAR(DATA_FIM_AFAST, 'DD/MM/YYYY')
                 WHEN DATA_INI_AFAST IS NOT NULL THEN
                  TO_CHAR(DATA_INI_AFAST, 'DD/MM/YYYY')
                 WHEN DATA_FIM_AFAST IS NOT NULL THEN
                  TO_CHAR(DATA_FIM_AFAST, 'DD/MM/YYYY')
                 ELSE
                  NULL
               END AS DT_AFAST,
               STATUS_AFAST
        
          FROM V_DADOS_COLAB_AVT
         WHERE STATUS = 0
           AND COD_EMP = 8
           AND (COD_TIPO = :TIPO OR :TIPO = 0)
           AND (COD_UNIDADE = :FILIAL OR :FILIAL = 0)
           AND (COD_REDE_LOCAL = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)) T
 CROSS JOIN (SELECT ROUND(SUM(MONTHS_BETWEEN(SYSDATE, DATA_AVANCO)) /
                          COUNT(*) / 12,
                          1) AS MEDIA_ANOS_EMPRESA,
                    COUNT(*) AS TOTAL_COLAB_EMPRESA
               FROM V_DADOS_COLAB_AVT
              WHERE STATUS = 0
                AND COD_EMP = 8) E
 ORDER BY T.COD_TIPO       ASC,
          T.COD_REDE_LOCAL ASC,
          T.COD_UNIDADE    ASC,
          T.MESES_TOTAIS   DESC,
          T.DATA_AVANCO    ASC
