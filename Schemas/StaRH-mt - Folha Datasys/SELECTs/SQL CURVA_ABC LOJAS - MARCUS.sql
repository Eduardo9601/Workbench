/*SQL PARA GERAR DADOS DA CURVA_ABC GERENTES LOJAS*/
SELECT DISTINCT A.COD_CONTRATO,
                
                -- Loja Admissão
                (SELECT C1.EDICAO_ORG
                   FROM RHFP0310 B1
                   JOIN RHFP0401 C1 ON B1.COD_ORGANOGRAMA =
                                       C1.COD_ORGANOGRAMA
                  WHERE B1.COD_CONTRATO = A.COD_CONTRATO
                  ORDER BY B1.DATA_INICIO FETCH FIRST 1 ROWS ONLY) AS LOJA_ADMISSAO,
                
                (SELECT D1.NOME_ORGANOGRAMA
                   FROM RHFP0310 B1
                   JOIN RHFP0400 D1 ON B1.COD_ORGANOGRAMA =
                                       D1.COD_ORGANOGRAMA
                  WHERE B1.COD_CONTRATO = A.COD_CONTRATO
                  ORDER BY B1.DATA_INICIO FETCH FIRST 1 ROWS ONLY) AS NOME_LOJA,
                
                PF.NOME_PESSOA AS COLABORADOR,
                A.DATA_INICIO  AS ADMISSAO,
                
                -- Origem Gerência
                (SELECT C2.EDICAO_ORG
                   FROM RHFP0340 E1
                   JOIN RHFP0500 F1 ON E1.COD_CLH = F1.COD_CLH
                   JOIN RHFP0310 B2 ON E1.COD_CONTRATO = B2.COD_CONTRATO
                                   AND B2.DATA_INICIO <= E1.DATA_INICIO
                   JOIN RHFP0401 C2 ON B2.COD_ORGANOGRAMA =
                                       C2.COD_ORGANOGRAMA
                  WHERE E1.COD_CONTRATO = A.COD_CONTRATO
                    AND F1.NOME_CLH LIKE '%GERENTE%'
                  ORDER BY E1.DATA_INICIO FETCH FIRST 1 ROWS ONLY) AS LOJA_ORIGEM_GERENCIA,
                
                (SELECT D2.NOME_ORGANOGRAMA
                   FROM RHFP0340 E1
                   JOIN RHFP0500 F1 ON E1.COD_CLH = F1.COD_CLH
                   JOIN RHFP0310 B2 ON E1.COD_CONTRATO = B2.COD_CONTRATO
                                   AND B2.DATA_INICIO <= E1.DATA_INICIO
                   JOIN RHFP0400 D2 ON B2.COD_ORGANOGRAMA =
                                       D2.COD_ORGANOGRAMA
                  WHERE E1.COD_CONTRATO = A.COD_CONTRATO
                    AND F1.NOME_CLH LIKE '%GERENTE%'
                  ORDER BY E1.DATA_INICIO FETCH FIRST 1 ROWS ONLY) AS NOME_LOJA_ORIGEM_GERENCIA,
                
                (SELECT E1.DATA_INICIO
                   FROM RHFP0340 E1
                   JOIN RHFP0500 F1 ON E1.COD_CLH = F1.COD_CLH
                  WHERE E1.COD_CONTRATO = A.COD_CONTRATO
                    AND F1.NOME_CLH LIKE '%GERENTE%' FETCH FIRST 1 ROWS ONLY) AS INICIO_GERENCIA,
                
                -- Tempo em anos no cargo de gerente
                (SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, E1.DATA_INICIO) / 12)
                   FROM RHFP0340 E1
                   JOIN RHFP0500 F1 ON E1.COD_CLH = F1.COD_CLH
                  WHERE E1.COD_CONTRATO = A.COD_CONTRATO
                    AND F1.NOME_CLH LIKE '%GERENTE%'
                  ORDER BY E1.DATA_INICIO FETCH FIRST 1 ROWS ONLY) AS TEMPO_GERENCIA_ANOS,
                
                -- Loja Atual
                (SELECT C3.EDICAO_ORG
                   FROM RHFP0310 B3
                   JOIN RHFP0401 C3 ON B3.COD_ORGANOGRAMA =
                                       C3.COD_ORGANOGRAMA
                  WHERE B3.COD_CONTRATO = A.COD_CONTRATO
                    AND B3.DATA_FIM = '31/12/2999' FETCH FIRST 1 ROWS ONLY) AS LOJA_ATUAL,
                
                (SELECT D3.NOME_ORGANOGRAMA
                   FROM RHFP0310 B3
                   JOIN RHFP0400 D3 ON B3.COD_ORGANOGRAMA =
                                       D3.COD_ORGANOGRAMA
                  WHERE B3.COD_CONTRATO = A.COD_CONTRATO
                    AND B3.DATA_FIM = '31/12/2999' FETCH FIRST 1 ROWS ONLY) AS NOME_LOJA_ATUAL,
                
                (SELECT TO_CHAR(NVL(SAL.VALOR_SALARIO, 0) +
                                NVL(MOV.VALOR_VD, 0),
                                'FM999G999G990D00')
                   FROM RHFP0608 SAL
                   LEFT JOIN (SELECT M.COD_CONTRATO, M.VALOR_VD
                               FROM RHFP1004 M
                              WHERE M.COD_VD = 935
                                AND M.PRESTACAO_VD = 99
                                AND M.COD_CONTRATO = A.COD_CONTRATO
                              ORDER BY M.DATA_MOV DESC FETCH FIRST 1 ROWS ONLY) MOV ON SAL.COD_CONTRATO =
                                                                                       MOV.COD_CONTRATO
                  WHERE SAL.COD_CONTRATO = A.COD_CONTRATO
                    AND SAL.DATA_FIM = '31/12/2999' FETCH FIRST 1 ROWS ONLY) AS SALARIO

  FROM RHFP0300 A
  LEFT JOIN PESSOA_FISICA PF ON A.COD_FUNC = PF.COD_PESSOA
 INNER JOIN V_DADOS_COLAB_AVT B ON A.COD_CONTRATO = B.COD_CONTRATO
--INNER JOIN RHFP0340 B ON A.COD_CONTRATO = B.COD_CONTRATO AND B.DATA_FIM = '31/12/2999'
--INNER JOIN RHFP0500 C ON B.COD_CLH = C.COD_CLH AND C.NOME_CLH LIKE '%GERENTE%'
 WHERE B.STATUS = 0
   AND B.DES_FUNCAO LIKE '%GERENTE%'
   AND B.DATA_FIM_ORG = '31/12/2999'
   AND B.COD_TIPO = 1
   --AND A.COD_CONTRATO = 168769
 ORDER BY A.COD_CONTRATO