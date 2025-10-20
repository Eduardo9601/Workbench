SELECT CASE
         WHEN TIPO = 'LOJA' THEN
          COD_UNIDADE
         WHEN TIPO = 'SETOR' THEN
          COD_UNIDADE_SUB
         ELSE
          COD_UNIDADE
       END AS COD_UNIDADE,
       MAX(CASE
             WHEN TIPO = 'SETOR' THEN
              (SELECT DISTINCT DES_UNIDADE
                 FROM V_DADOS_COLAB_AVT SUB
                WHERE SUB.COD_UNIDADE = V_DADOS_COLAB_AVT.COD_UNIDADE_SUB
                  AND ROWNUM = 1)
             ELSE
              DES_UNIDADE
           END) AS DES_UNIDADE,
       MAX(COD_SETOR_LOJA) AS COD_SETOR_LOJA,
       TIPO,
       MAX(COD_UNIDADE_SUB) AS COD_UNIDADE_SUB,
       COUNT(COD_CONTRATO) AS QTD_CONTRATOS_GERAL,
       SUM(CASE
             WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' AND
                  DES_FUNCAO NOT LIKE '%ESTAGIARIO%' AND
                  DES_FUNCAO NOT LIKE '%APRENDIZ%' AND
                  (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_COLABORADORES,
       SUM(CASE
             WHEN COD_FUNCAO = 168 THEN
              1
             ELSE
              0
           END) AS QTD_ESTAGIARIOS,
       SUM(CASE
             WHEN COD_FUNCAO IN (71, 74, 310) AND
                  (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_APRENDIZ,
       SUM(CASE
             WHEN COD_FUNCAO = 68 AND (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_SERVENTES,
       SUM(CASE
             WHEN COD_AFAST NOT IN ('0', '7') THEN
              1
             ELSE
              0
           END) AS QTD_AFASTADOS,
       SUM(COUNT(COD_CONTRATO)) OVER() AS QTD_CONTRATOS_TOTAL,      

        SUM(
        SUM(CASE
            WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' 
                AND DES_FUNCAO NOT LIKE '%ESTAGIARIO%' 
                AND DES_FUNCAO NOT LIKE '%APRENDIZ%' 
                AND (COD_AFAST IS NULL OR COD_AFAST = 7) THEN 1
            ELSE 0
        END)
    ) OVER(
        PARTITION BY CASE WHEN TIPO = 'LOJA' THEN 'LOJA' ELSE 'ADM' END
    ) AS QTD_COLAB_TOTAL,
    SUM(
        CASE 
            WHEN TIPO = 'LOJA' THEN
                SUM(CASE
                    WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' 
                        AND DES_FUNCAO NOT LIKE '%ESTAGIARIO%' 
                        AND DES_FUNCAO NOT LIKE '%APRENDIZ%' 
                        AND (COD_AFAST IS NULL OR COD_AFAST = 7) THEN 1
                    ELSE 0
                END)
            ELSE 0
        END
    ) OVER() AS QTD_COLAB_TOTAL_LOJAS,
    SUM(
        CASE 
            WHEN TIPO IN ('SETOR', 'DEPÓSITO') THEN
                SUM(CASE
                    WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' 
                        AND DES_FUNCAO NOT LIKE '%ESTAGIARIO%' 
                        AND DES_FUNCAO NOT LIKE '%APRENDIZ%' 
                        AND (COD_AFAST IS NULL OR COD_AFAST = 7) THEN 1
                    ELSE 0
                END)
            ELSE 0
        END
    ) OVER() AS QTD_COLAB_TOTAL_ADM_CD,
       
       SUM(SUM(CASE
                 WHEN COD_FUNCAO = 168 THEN
                  1
                 ELSE
                  0
               END)) OVER() AS QTD_ESTAGIARIOS_TOTAL,
       SUM(SUM(CASE
                 WHEN COD_FUNCAO IN (71, 74, 310) AND
                      (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                  1
                 ELSE
                  0
               END)) OVER() AS QTD_APRENDIZ_TOTAL,
       SUM(SUM(CASE
                 WHEN COD_FUNCAO = 68 AND (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                  1
                 ELSE
                  0
               END)) OVER() AS QTD_SERVENTES_TOTAL,
       SUM(SUM(CASE
                 WHEN COD_AFAST NOT IN ('0', '7') THEN
                  1
                 ELSE
                  0
               END)) OVER() AS QTD_AFASTADOS_TOTAL
  FROM V_DADOS_COLAB_AVT
 WHERE COD_EMP = '008'
   AND STATUS = 0
   AND DATA_ADMISSAO <= '25/10/2023'
   AND (DATA_DEMISSAO IS NULL OR DATA_DEMISSAO >= '25/10/2023')
 GROUP BY CASE
            WHEN TIPO = 'LOJA' THEN
             COD_UNIDADE
            WHEN TIPO = 'SETOR' THEN
             COD_UNIDADE_SUB
            ELSE
             COD_UNIDADE
          END,
          TIPO
 ORDER BY CASE
            WHEN TIPO = 'LOJA' THEN
             1
            WHEN TIPO = 'SETOR' THEN
             2
            WHEN TIPO = 'DEPÓSITO' THEN
             3
            ELSE
             4
          END,
          COD_UNIDADE ASC;



-=============VERSÃO FINAL E OFICIAL PARA RELATÓRIO================



SELECT DES_UNIDADE,
       QTD_CONTRATOS_GERAL,
       QTD_COLABORADORES,
       QTD_ESTAGIARIOS,
       QTD_APRENDIZ,
       QTD_SERVENTES,
       QTD_AFASTADOS,
       TIPO,

       -- Colunas totalizadoras
       SUM(QTD_CONTRATOS_GERAL) OVER() AS QTD_TOTAL_CONTRATOS,
       CASE
         WHEN TIPO = 'LOJA' THEN
          QTD_COLABORADORES
         ELSE
          0
       END AS QTD_TOTAL_COLAB_LOJAS,
       SUM(CASE
             WHEN TIPO IN ('SETOR', 'DEPÓSITO') THEN
              QTD_COLABORADORES
             ELSE
              0
           END) OVER() AS QTD_TOTAL_COLAB_ADM,
       SUM(QTD_ESTAGIARIOS) OVER() AS QTD_TOTAL_ESTAGIARIOS,
       SUM(QTD_APRENDIZ) OVER() AS QTD_TOTAL_APRENDIZES,
       SUM(QTD_SERVENTES) OVER() AS QTD_TOTAL_SERVENTES,
       SUM(QTD_AFASTADOS) OVER() AS QTD_TOTAL_AFASTADOS

  FROM (
        /*============SUBSELECT CONTAGEM LOJAS============*/
        SELECT 'LOJAS' AS DES_UNIDADE,
                COUNT(COD_CONTRATO) AS QTD_CONTRATOS_GERAL,
                SUM(CASE
                      WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' AND
                           DES_FUNCAO NOT LIKE '%ESTAGIARIO%' AND
                           DES_FUNCAO NOT LIKE '%APRENDIZ%' AND
                           (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                       1
                      ELSE
                       0
                    END) AS QTD_COLABORADORES,
                SUM(CASE
                      WHEN COD_FUNCAO = 168 THEN
                       1
                      ELSE
                       0
                    END) AS QTD_ESTAGIARIOS,
                SUM(CASE
                      WHEN COD_FUNCAO IN (71, 74, 310) AND
                           (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                       1
                      ELSE
                       0
                    END) AS QTD_APRENDIZ,
                SUM(CASE
                      WHEN COD_FUNCAO = 68 AND (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                       1
                      ELSE
                       0
                    END) AS QTD_SERVENTES,
                SUM(CASE
                      WHEN COD_AFAST NOT IN ('0', '7') THEN
                       1
                      ELSE
                       0
                    END) AS QTD_AFASTADOS,
                TIPO
          FROM V_DADOS_COLAB_AVT
         WHERE COD_EMP = '008'
           AND TIPO = 'LOJA'
           AND DATA_ADMISSAO <= /*:DATA_REFERENCIA*/ '31/10/2023'
           AND (DATA_DEMISSAO IS NULL OR DATA_DEMISSAO >= /*:DATA_REFERENCIA*/ '31/10/2023')
         GROUP BY TIPO

        UNION ALL

        /*============SUBSELECT CONTAGEM ADM============*/
         SELECT CASE
                  WHEN TIPO = 'LOJA' THEN
                   'LOJAS'
                  ELSE
                   MAX(CASE
                  WHEN TIPO = 'SETOR' THEN
                   (SELECT DISTINCT DES_UNIDADE
                      FROM V_DADOS_COLAB_AVT SUB
                     WHERE SUB.COD_UNIDADE = V_DADOS_COLAB_AVT.COD_UNIDADE_SUB
                       AND ROWNUM = 1)
                  ELSE
                   DES_UNIDADE
                END) END AS DES_UNIDADE,

                COUNT(COD_CONTRATO) AS QTD_CONTRATOS_GERAL,
                SUM(CASE
                      WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' AND
                           DES_FUNCAO NOT LIKE '%ESTAGIARIO%' AND
                           DES_FUNCAO NOT LIKE '%APRENDIZ%' AND
                           (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                       1
                      ELSE
                       0
                    END) AS QTD_COLABORADORES,
                SUM(CASE
                      WHEN COD_FUNCAO = 168 THEN
                       1
                      ELSE
                       0
                    END) AS QTD_ESTAGIARIOS,
                SUM(CASE
                      WHEN COD_FUNCAO IN (71, 74, 310) AND
                           (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                       1
                      ELSE
                       0
                    END) AS QTD_APRENDIZ,
                SUM(CASE
                      WHEN COD_FUNCAO = 68 AND
                           (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
                       1
                      ELSE
                       0
                    END) AS QTD_SERVENTES,
                SUM(CASE
                      WHEN COD_AFAST NOT IN ('0', '7') THEN
                       1
                      ELSE
                       0
                    END) AS QTD_AFASTADOS,
                TIPO
           FROM V_DADOS_COLAB_AVT
          WHERE COD_EMP = '008'
            AND TIPO IN ('SETOR', 'DEPÓSITO')
            AND DATA_ADMISSAO <=  /*:DATA_REFERENCIA*/ '31/10/2023'
            AND (DATA_DEMISSAO IS NULL OR DATA_DEMISSAO >= /*:DATA_REFERENCIA*/ '31/10/2023')
          GROUP BY CASE
                     WHEN TIPO = 'SETOR' THEN
                      COD_UNIDADE_SUB
                     ELSE
                      COD_UNIDADE
                   END,
                   TIPO
        ) SUB
 ORDER BY DES_UNIDADE ASC



--=========================================================================================================--



--VERSÃO DIVIDIDA DOS SELECTS


/*============SUBSELECT CONTAGEM LOJAS============*/
SELECT 'LOJAS' AS DES_UNIDADE,
       COUNT(COD_CONTRATO) AS QTD_CONTRATOS_GERAL,
       SUM(CASE
             WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' AND
                  DES_FUNCAO NOT LIKE '%ESTAGIARIO%' AND
                  DES_FUNCAO NOT LIKE '%APRENDIZ%' AND
                  (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_COLABORADORES,
       SUM(CASE
             WHEN COD_FUNCAO = 168 THEN
              1
             ELSE
              0
           END) AS QTD_ESTAGIARIOS,
       SUM(CASE
             WHEN COD_FUNCAO IN (71, 74, 310) AND
                  (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_APRENDIZ,
       SUM(CASE
             WHEN COD_FUNCAO = 68 AND (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_SERVENTES,
       SUM(CASE
             WHEN COD_AFAST NOT IN ('0', '7') THEN
              1
             ELSE
              0
           END) AS QTD_AFASTADOS,
       TIPO
  FROM V_DADOS_COLAB_AVT
 WHERE COD_EMP = '008'
   AND TIPO = 'LOJA'
   AND DATA_ADMISSAO <= /*:DATA_REFERENCIA*/ '31/10/2023'
   AND (DATA_DEMISSAO IS NULL OR DATA_DEMISSAO >= /*:DATA_REFERENCIA*/ '31/10/2023')
 GROUP BY TIPO


UNION ALL


/*============SUBSELECT CONTAGEM ADM============*/
SELECT 
       CASE
         WHEN TIPO = 'LOJA' THEN
          'LOJAS'
         ELSE
          MAX(CASE
         WHEN TIPO = 'SETOR' THEN
          (SELECT DISTINCT DES_UNIDADE
             FROM V_DADOS_COLAB_AVT SUB
            WHERE SUB.COD_UNIDADE = V_DADOS_COLAB_AVT.COD_UNIDADE_SUB
              AND ROWNUM = 1)
         ELSE
          DES_UNIDADE
       END) END AS DES_UNIDADE,     
       
       COUNT(COD_CONTRATO) AS QTD_CONTRATOS_GERAL,
       SUM(CASE
             WHEN DES_FUNCAO NOT LIKE '%SERVENTE%' AND
                  DES_FUNCAO NOT LIKE '%ESTAGIARIO%' AND
                  DES_FUNCAO NOT LIKE '%APRENDIZ%' AND
                  (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_COLABORADORES,
       SUM(CASE
             WHEN COD_FUNCAO = 168 THEN
              1
             ELSE
              0
           END) AS QTD_ESTAGIARIOS,
       SUM(CASE
             WHEN COD_FUNCAO IN (71, 74, 310) AND
                  (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_APRENDIZ,
       SUM(CASE
             WHEN COD_FUNCAO = 68 AND (COD_AFAST IS NULL OR COD_AFAST = 7) THEN
              1
             ELSE
              0
           END) AS QTD_SERVENTES,
       SUM(CASE
             WHEN COD_AFAST NOT IN ('0', '7') THEN
              1
             ELSE
              0
           END) AS QTD_AFASTADOS,
       TIPO
  FROM V_DADOS_COLAB_AVT
 WHERE COD_EMP = '008'
   AND TIPO IN ('SETOR', 'DEPÓSITO')
   AND DATA_ADMISSAO <= /*:DATA_REFERENCIA*/ '31/10/2023'
   AND (DATA_DEMISSAO IS NULL OR DATA_DEMISSAO >= /*:DATA_REFERENCIA*/ '31/10/2023')
 GROUP BY 
    CASE
        WHEN TIPO = 'SETOR' THEN COD_UNIDADE_SUB
        ELSE COD_UNIDADE
    END,
    TIPO
 ORDER BY DES_UNIDADE ASC;