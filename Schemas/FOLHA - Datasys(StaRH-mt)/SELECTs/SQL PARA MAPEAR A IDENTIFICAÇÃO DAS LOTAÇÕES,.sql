--===SELECT OFICIAL

SELECT --SS1.EDICAO_QL,
--SS2.DES_REDE_LOCAL,
 SS1.COD_LOTACAO,
 --SS1.NOME_LOTACAO,
 SS1.DATA_INICIO,
 SS1.DATA_FIM,
 CASE
   WHEN SS1.ORGANOGRAMA IS NULL THEN
    SS2.COD_ORGANOGRAMA
   ELSE
    NULL
 END COD_ORGANOGRAMA,
 CASE
   WHEN SS1.NOME_LOTACAO LIKE '%AUXI. LOJA%' THEN
    206
   WHEN SS1.NOME_LOTACAO LIKE '%APRENDIZ%' THEN
    74
   WHEN SS1.NOME_LOTACAO LIKE '%VEND. MODA MASC.%' THEN
    120
   WHEN SS1.NOME_LOTACAO LIKE '%CAIXA GERAL%' THEN
    102
   WHEN SS1.NOME_LOTACAO LIKE '%SERVENTE%' THEN
    68
   WHEN SS1.NOME_LOTACAO LIKE '%ORIENT. DE VENDA%' AND
        SS2.DES_REDE_LOCAL = 'GRAZZIOTIN' THEN
    122
   WHEN SS1.NOME_LOTACAO LIKE '%ORIENT. DE VENDA%' AND
        SS2.DES_REDE_LOCAL = 'TOTTAL' THEN
    121
   WHEN SS1.NOME_LOTACAO LIKE '%ORIENT. DE VENDA%' AND
        SS2.DES_REDE_LOCAL = 'GZT STORE' THEN
    305
   WHEN SS1.NOME_LOTACAO LIKE '%GERENTE%' AND SS3.IND_RESP_UNI = 'S ' THEN
    SS3.COD_FUNCAO
   ELSE
    NULL
 END AS COD_CLH,
 SS1.COD_TURNO,
 CASE
   WHEN SS1.NOME_LOTACAO LIKE '%AUXI. LOJA%' THEN
    SS2.NUM_AUXI_LOJA
   WHEN SS1.NOME_LOTACAO LIKE '%GERENTE%' THEN
    SS2.NUM_GERENTES
   WHEN SS1.NOME_LOTACAO LIKE '%APRENDIZ%' THEN
    SS2.NUM_APRENDIZ
   WHEN SS1.NOME_LOTACAO LIKE '%ORIENT. DE VENDA%' THEN
    SS2.NUM_ORIENT_VENDA
   WHEN SS1.NOME_LOTACAO LIKE '%VEND. MODA MASC.%' THEN
    SS2.NUM_VEND_MODA_MASC
   WHEN SS1.NOME_LOTACAO LIKE '%CAIXA GERAL%' THEN
    SS2.NUM_CAIXA_GERAL
   ELSE
    SS1.NUM_VAGAS
 END AS NUM_VAGAS,
 CASE
   WHEN SS1.NOME_LOTACAO LIKE '%SERVENTE%' THEN
    SS2.HORAS_BASE_SERVENTE
   ELSE
    NULL
 END AS NUM_HORAS,
 --SS1.NUM_HORAS,
 SS1.COD_MOTIVO,
 SS1.OBSERVACOES,
 SS1.VLR_PREMIO,
 SS1.VLR_CESTA
  FROM (SELECT A.EDICAO_QL,
               A.COD_LOTACAO,
               A.NOME_LOTACAO,
               CASE
                 WHEN B.DATA_INICIO IS NOT NULL THEN
                  B.DATA_INICIO
                 ELSE
                  TO_DATE('01/09/2023', 'DD/MM/YYYY')
               END AS DATA_INICIO,
               CASE
                 WHEN B.DATA_FIM IS NOT NULL THEN
                  B.DATA_FIM
                 ELSE
                  TO_DATE('31/12/2999', 'DD/MM/YYYY')
               END AS DATA_FIM,
               CASE
                 WHEN B.COD_ORGANOGRAMA IS NOT NULL THEN
                  B.COD_ORGANOGRAMA
                 ELSE
                  NULL
               END AS ORGANOGRAMA,
               CASE
                 WHEN B.COD_CLH IS NOT NULL THEN
                  B.COD_CLH
                 ELSE
                  NULL
               END AS COD_CLH,
               B.COD_TURNO,
               CASE
                 WHEN B.NUM_VAGAS IS NOT NULL THEN
                  B.NUM_VAGAS
                 ELSE
                  NULL
               END AS NUM_VAGAS,
               CASE
                 WHEN B.NUM_HORAS IS NOT NULL THEN
                  B.NUM_HORAS
                 ELSE
                  NULL
               END AS NUM_HORAS,
               CASE
                 WHEN B.COD_MOTIVO IS NOT NULL THEN
                  B.COD_MOTIVO
                 ELSE
                  414
               END AS COD_MOTIVO,
               B.OBSERVACOES,
               B.VLR_PREMIO,
               B.VLR_CESTA
          FROM RHFP0509 A
          LEFT JOIN RHFP0510 B ON A.COD_LOTACAO = B.COD_LOTACAO
         WHERE A.COD_LOTACAO NOT IN
               (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)) SS1
  LEFT JOIN (SELECT DISTINCT COD_UNIDADE,
                             DES_UNIDADE,
                             COD_ORGANOGRAMA,
                             COD_REDE_LOCAL,
                             DES_REDE_LOCAL,
                             COUNT(DISTINCT CASE
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
              GROUP BY COD_UNIDADE,
                       DES_UNIDADE,
                       COD_ORGANOGRAMA,
                       COD_REDE_LOCAL,
                       DES_REDE_LOCAL
              ORDER BY COD_UNIDADE ASC) SS2 ON SS1.EDICAO_QL =
                                               SS2.COD_UNIDADE
  LEFT JOIN (SELECT COD_UNIDADE, COD_FUNCAO, IND_RESP_UNI
               FROM V_DADOS_COLAB_AVT
              WHERE COD_EMP = '008'
                AND STATUS = 0
                AND TIPO = 'LOJA'
                AND IND_RESP_UNI = 'S') SS3 ON SS1.EDICAO_QL =
                                               SS3.COD_UNIDADE;