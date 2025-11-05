SELECT COD_UNIDADE,
       COD_ITEM,
       COD_EDITADO,
       DES_ITEM,
       DTA_ATUALIZADO,
       ROUND(VLR_MEDIO_UNITARIO, 2) AS VLR_MEDIO_UNITARIO,
       QTD_CONTADA,
       -- ESTOQUE ATUAL
       NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) AS QTD_ESTOQUE,
       QTD_VENDA,
       QTD_DEVOLUCAO,
       QTD_ENTRADA_DEMONSTRACAO,
       QTD_SAIDA_DEMONSTRACAO,
       -- VALOR DE FALTA
       CASE
         WHEN NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) >
              (QTD_CONTADA + QTD_DEVOLUCAO - QTD_VENDA) THEN
          NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) -
          (QTD_CONTADA + QTD_DEVOLUCAO - QTD_VENDA)
         ELSE
          0
       END QTD_FALTA,
       
       ROUND(CASE
               WHEN NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) >
                    (QTD_CONTADA + QTD_DEVOLUCAO - QTD_VENDA) THEN
                (NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) -
                (QTD_CONTADA + QTD_DEVOLUCAO - QTD_VENDA)) * VLR_MEDIO_UNITARIO
               ELSE
                0
             END,
             2) AS VLR_TOTAL_FALTA,
       
       -- VALOR DE SOBRA
       CASE
         WHEN NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) <
              (QTD_CONTADA + QTD_DEVOLUCAO - QTD_VENDA) THEN
          (QTD_CONTADA + QTD_DEVOLUCAO - QTD_VENDA) -
          NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE)
         ELSE
          0
       END QTD_SOBRA,
       ROUND(CASE
               WHEN NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) <
                    (QTD_CONTADA + QTD_DEVOLUCAO - QTD_VENDA) THEN
                ((QTD_CONTADA + QTD_DEVOLUCAO - QTD_VENDA) -
                NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE)) *
                VLR_MEDIO_UNITARIO
               ELSE
                0
             END,
             2) AS VLR_TOTAL_SOBRA,
       
       -- VALOR ESTOQUE NEGATIVO
       CASE
         WHEN NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) < 0 THEN
          ABS(NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE))
         ELSE
          0
       END QTD_TOTAL_ESTOQUE_NEGATIVO,
       ROUND(CASE
               WHEN NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE) < 0 THEN
                ABS(NL.CE_SALDO_ESTOQUE_SP(1, COD_UNIDADE, COD_ITEM, 2, SYSDATE)) *
                VLR_MEDIO_UNITARIO
               ELSE
                0
             END,
             2) AS VLR_TOTAL_ESTOQUE_NEGATIVO
  FROM (WITH PRECO_ITEM AS (SELECT COD_ITEM, VLR_MEDIO_UNITARIO
                              FROM CE_ESTOQUES
                             WHERE COD_UNIDADE = 0)
         SELECT CE.COD_UNIDADE,
                CE.COD_ITEM,
                CE.COD_EDITADO,
                CE.DES_ITEM,
                CE.DTA_ATUALIZADO,
                SUM(CE.QTD_CONTADA) QTD_CONTADA,
                SUM(CE.QTD_VENDA) QTD_VENDA,
                SUM(CE.QTD_DEVOLUCAO) QTD_DEVOLUCAO,
                SUM(CE.QTD_SAIDA_DEMONSTRACAO) QTD_SAIDA_DEMONSTRACAO,
                SUM(CE.QTD_ENTRADA_DEMONSTRACAO) QTD_ENTRADA_DEMONSTRACAO,
                
                -- PREÇO MÉDIO
                PI.VLR_MEDIO_UNITARIO
         
           FROM (SELECT DISTINCT NVL(CE.COD_UNIDADE, GCT.COD_UNIDADE) AS COD_UNIDADE,
                                 GCTI.COD_ITEM,
                                 GCTI.DES_ITEM,
                                 GCTI.COD_EDITADO,
                                 GCTI.QTD_CONTADA,
                                 GCTI.DTA_ATUALIZADO,
                                 
                                 -- VENDAS APÓS CONTAGEM
                                 NVL((SELECT SUM(ECI.QTD_MOVIMENTO)
                                       FROM EST_CUPOM_ITENS ECI
                                      WHERE ECI.COD_ITEM = GCTI.COD_ITEM
                                        AND ECI.COD_UNIDADE = GCT.COD_UNIDADE
                                        AND ECI.DTA_MOVIMENTO >
                                            TRUNC(SYSDATE) - 15
                                        AND TO_DATE(TO_CHAR(ECI.DTA_MOVIMENTO,
                                                            'DD/MM/YYYY') || ' ' ||
                                                    ECI.HOR_MOVIMENTO,
                                                    'DD/MM/YYYY HH24:MI:SS') >
                                            GCTI.DTA_ATUALIZADO),
                                     0) AS QTD_VENDA,
                                 
                                 -- DEVOLUÇÕES APÓS CONTAGEM
                                 NVL((SELECT SUM(NFI.QTD_MOVIMENTO)
                                       FROM NFI_NOTAS_ITENS NFI
                                       JOIN NFI_NOTAS NN ON NN.COD_UNIDADE =
                                                            NFI.COD_UNIDADE
                                                        AND NN.NUM_NOTA =
                                                            NFI.NUM_NOTA
                                      WHERE NFI.COD_ITEM = GCTI.COD_ITEM
                                        AND NFI.COD_UNIDADE = GCT.COD_UNIDADE
                                        AND NFI.DTA_MOVIMENTO >
                                            TRUNC(SYSDATE) - 15
                                        AND TO_DATE(TO_CHAR(NFI.DTA_MOVIMENTO,
                                                            'DD/MM/YYYY') || ' ' ||
                                                    NFI.HOR_MOVIMENTO,
                                                    'DD/MM/YYYY HH24:MI:SS') >
                                            GCTI.DTA_ATUALIZADO
                                        AND NN.COD_OPERACAO IN
                                            (106, 107, 4107, 4106)),
                                     0) AS QTD_DEVOLUCAO,
                                 
                                 -- SAÍDA DEMONSTRAÇÃO ANTES DA CONTAGEM
                                 NVL((SELECT SUM(NFI.QTD_MOVIMENTO)
                                       FROM NFI_NOTAS_ITENS NFI
                                       JOIN NFI_NOTAS NN ON NN.COD_UNIDADE =
                                                            NFI.COD_UNIDADE
                                                        AND NN.NUM_NOTA =
                                                            NFI.NUM_NOTA
                                      WHERE NFI.COD_ITEM = GCTI.COD_ITEM
                                        AND NFI.COD_UNIDADE = GCT.COD_UNIDADE
                                        AND NFI.DTA_MOVIMENTO >=
                                            TRUNC(SYSDATE) - 15
                                        AND TO_DATE(TO_CHAR(NFI.DTA_MOVIMENTO,
                                                            'DD/MM/YYYY') || ' ' ||
                                                    NFI.HOR_MOVIMENTO,
                                                    'DD/MM/YYYY HH24:MI:SS') <
                                            GCTI.DTA_ATUALIZADO
                                        AND NN.COD_OPERACAO = 340),
                                     0) AS QTD_SAIDA_DEMONSTRACAO,
                                 
                                 -- RETORNO DEMONSTRAÇÃO APÓS A CONTAGEM
                                 NVL((SELECT SUM(NFI.QTD_MOVIMENTO)
                                       FROM NFI_NOTAS_ITENS NFI
                                       JOIN NFI_NOTAS NN ON NN.COD_UNIDADE =
                                                            NFI.COD_UNIDADE
                                                        AND NN.NUM_NOTA =
                                                            NFI.NUM_NOTA
                                      WHERE NFI.COD_ITEM = GCTI.COD_ITEM
                                        AND NFI.COD_UNIDADE = GCT.COD_UNIDADE
                                        AND NFI.DTA_MOVIMENTO >=
                                            TRUNC(SYSDATE) - 15
                                        AND TO_DATE(TO_CHAR(NFI.DTA_MOVIMENTO,
                                                            'DD/MM/YYYY') || ' ' ||
                                                    NFI.HOR_MOVIMENTO,
                                                    'DD/MM/YYYY HH24:MI:SS') >
                                            GCTI.DTA_ATUALIZADO
                                        AND NN.COD_OPERACAO = 150),
                                     0) AS QTD_ENTRADA_DEMONSTRACAO
                 
                   FROM GRZ_CONT_TAREFAS_ITENS GCTI
                   JOIN GRZ_CONT_TAREFAS GCT ON GCT.SEQ = GCTI.SEQ_TAREFA
                   LEFT JOIN CE_ESTOQUES CE ON CE.COD_UNIDADE =
                                               GCT.COD_UNIDADE
                                           AND CE.COD_ITEM = GCTI.COD_ITEM
                  WHERE GCT.COD_UNIDADE = 528
                    AND (NVL(CE.QTD_ESTOQUE, 0) > 0 OR GCTI.QTD_CONTADA > 0)
                    AND GCT.DTA_SISTEMA > TRUNC(SYSDATE) - 15
                    AND GCT.SEQ IN (528001)
                    --AND GCTI.COD_ITEM IN (394045, 480574, 452895, 394043)
                 
                 ) CE
         
           LEFT JOIN PRECO_ITEM PI ON PI.COD_ITEM = CE.COD_ITEM
          GROUP BY CE.COD_UNIDADE,
                   CE.COD_ITEM,
                   CE.COD_EDITADO,
                   CE.DES_ITEM,
                   CE.DTA_ATUALIZADO,
                   PI.VLR_MEDIO_UNITARIO)
          ORDER BY TO_NUMBER(GRZ_UTIL.ONLY_NUMBERS(COD_EDITADO)),
                   TO_NUMBER(GRZ_UTIL.ONLY_NUMBERS(COD_ITEM))