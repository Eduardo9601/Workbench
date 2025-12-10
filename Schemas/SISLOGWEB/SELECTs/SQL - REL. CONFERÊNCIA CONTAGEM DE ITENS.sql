     WITH INV_BASE AS (
        SELECT
          gct.cod_unidade AS unidade,
          gct.seq         AS seq_tarefa,
          gcti.cod_item,
          gcti.cod_editado,
          gcti.des_item,
          gcti.qtd_contada,
          gcti.des_geral,
          gcti.dta_atualizado AS dta_sistema,
          MIN(gctih.qtd_estoque)
            KEEP (DENSE_RANK FIRST ORDER BY gctih.seq) AS qtd_estoque_hist
        FROM grz_cont_tarefas gct
        JOIN grz_cont_tarefas_itens gcti
          ON gcti.seq_tarefa = gct.seq
        JOIN grz_cont_tarefas_itens_hist gctih
          ON gctih.seq_tarefa = gct.seq
         AND gctih.cod_item   = gcti.cod_item
        WHERE gct.cod_unidade = ${codUnidadeNumber}
          AND gct.dta_sistema >= TO_DATE('${dtaInicio}', 'DD/MM/YYYY')
          AND gct.dta_sistema <  TO_DATE('${dtaFim}',    'DD/MM/YYYY') + 1
        GROUP BY
          gct.cod_unidade,
          gct.seq,
          gcti.cod_item,
          gcti.cod_editado,
          gcti.des_item,
          gcti.qtd_contada,
          gcti.des_geral,
          gcti.dta_atualizado
      ),
      QTD_VENDA AS (
        SELECT
          TO_DATE(
            TO_CHAR(eci.dta_movimento, 'DD/MM/YYYY') || ' ' || eci.hor_movimento,
            'DD/MM/YYYY HH24:MI:SS'
          ) AS dta_venda,
          eci.cod_item,
          SUM(eci.qtd_movimento) AS qtd_venda_dia
        FROM sislogweb.est_cupom_itens eci
        WHERE eci.cod_unidade   = ${codUnidadeNumber}
          AND eci.dta_movimento >= TO_DATE('${dtaInicio}', 'DD/MM/YYYY')
          AND eci.dta_movimento <  TO_DATE('${dtaFim}',    'DD/MM/YYYY') + 1
          and eci.ind_cancelado = 0
        GROUP BY
          TO_DATE(
            TO_CHAR(eci.dta_movimento, 'DD/MM/YYYY') || ' ' || eci.hor_movimento,
            'DD/MM/YYYY HH24:MI:SS'
          ),
          eci.cod_item
      ),
      DEVOL_DEMONST AS (
        SELECT
          TO_DATE(
            TO_CHAR(nfi.dta_movimento, 'DD/MM/YYYY') || ' ' || nfi.hor_movimento,
            'DD/MM/YYYY HH24:MI:SS'
          ) AS dta_devolucao,
          nfi.cod_item,
          SUM(CASE
                WHEN nn.cod_operacao IN (4202, 4203)
                THEN nfi.qtd_movimento
                ELSE 0
              END) AS qtd_devolucao,
          SUM(CASE
                WHEN nn.cod_operacao = 340
                THEN nfi.qtd_movimento
                ELSE 0
              END) AS qtd_saida_demo,
          SUM(CASE
                WHEN nn.cod_operacao = 150
                THEN nfi.qtd_movimento
                ELSE 0
              END) AS qtd_entrada_demo
        FROM sislogweb.nfi_notas_itens nfi
        JOIN sislogweb.nfi_notas nn
          ON nn.cod_unidade = nfi.cod_unidade
         AND nn.num_nota    = nfi.num_nota
        WHERE nfi.cod_unidade   = ${codUnidadeNumber}
          AND nfi.dta_movimento >= TO_DATE('${dtaInicio}', 'DD/MM/YYYY')
          AND nfi.dta_movimento <  TO_DATE('${dtaFim}',    'DD/MM/YYYY') + 1
          AND nfi.ind_status = 0
        GROUP BY
          TO_DATE(
            TO_CHAR(nfi.dta_movimento, 'DD/MM/YYYY') || ' ' || nfi.hor_movimento,
            'DD/MM/YYYY HH24:MI:SS'
          ),
          nfi.cod_item
      ),
      VLR_MEDIO_UNITARIO AS (
        SELECT
          ve.cod_item,
          MAX(ve.vlr_medio_unitario) AS vlr_medio_unitario
        FROM nl.ce_estoques ve
        WHERE ve.cod_unidade = ${codUnidadeNumber}
        GROUP BY
          ve.cod_item
      )
      SELECT
        i.unidade           AS "codUnidade",
        i.seq_tarefa        AS "seqTarefaCont",
        i.cod_item          AS "codItem",
        i.cod_editado       AS "codEditado",
        i.des_item          AS "desItem",
        i.qtd_contada       AS "qtdContada",
  
        NVL(v.qtd_venda_dia,    0) AS "qtdVenda",
        NVL(d.qtd_devolucao,    0) AS "qtdDevolucao",
        NVL(d.qtd_saida_demo,   0) AS "qtdSaidaDemonstracao",
        NVL(d.qtd_entrada_demo, 0) AS "qtdEntradaDemonstracao",
  
        NVL(vm.vlr_medio_unitario, 0) AS "vlrMedioUnitario",
        NVL(i.qtd_estoque_hist,   0)  AS "qtdEstoque",
  
          -- Valor de falta
        CASE 
          WHEN i.qtd_estoque_hist > (i.qtd_contada - NVL(d.qtd_devolucao, 0) + NVL(v.qtd_venda_dia, 0))
          THEN i.qtd_estoque_hist - (i.qtd_contada - NVL(d.qtd_devolucao, 0) + NVL(v.qtd_venda_dia, 0))
          ELSE 0 
        END AS "qtdFalta",
        -- Valor total falta 
        ROUND(CASE
          WHEN i.qtd_estoque_hist > (i.qtd_contada - NVL(d.qtd_devolucao, 0) + NVL(v.qtd_venda_dia, 0))
          THEN (i.qtd_estoque_hist - (i.qtd_contada - NVL(d.qtd_devolucao, 0) + NVL(v.qtd_venda_dia, 0))) * vm.vlr_medio_unitario
          ELSE 0
        END,2) AS "vlrTotalFalta",
        -- Valor de sobra
        CASE 
          WHEN i.qtd_estoque_hist < (i.qtd_contada - NVL(d.qtd_devolucao, 0) + NVL(v.qtd_venda_dia, 0)) 
          THEN (i.qtd_contada - NVL(d.qtd_devolucao, 0) + NVL(v.qtd_venda_dia, 0)) - i.qtd_estoque_hist
          ELSE 0 
        END AS "qtdSobra",
      -- Valor total sobra 
        ROUND(CASE
          WHEN i.qtd_estoque_hist < (i.qtd_contada - NVL(d.qtd_devolucao, 0) + NVL(v.qtd_venda_dia, 0)) 
          THEN ((i.qtd_contada - NVL(d.qtd_devolucao, 0) + NVL(v.qtd_venda_dia, 0)) - i.qtd_estoque_hist) * NVL(vm.vlr_medio_unitario, 0)
          ELSE 0
        END,2) AS "vlrTotalSobra",
  
        GREATEST(-NVL(i.qtd_estoque_hist, 0), 0) AS "qtdTotalEstoqueNegativo",
        ROUND(
          GREATEST(-NVL(i.qtd_estoque_hist, 0), 0) * NVL(vm.vlr_medio_unitario, 0),
          2
        ) AS "vlrTotalEstoqueNegativo"
      FROM INV_BASE i
      LEFT JOIN QTD_VENDA          v
        ON v.cod_item = i.cod_item
       AND v.dta_venda >= TRUNC(i.dta_sistema)
       AND v.dta_venda <  i.dta_sistema
      LEFT JOIN DEVOL_DEMONST      d
        ON d.cod_item = i.cod_item
       AND d.dta_devolucao >= TRUNC(i.dta_sistema)
       AND d.dta_devolucao <  i.dta_sistema
      LEFT JOIN VLR_MEDIO_UNITARIO vm
        ON vm.cod_item = i.cod_item
      ORDER BY i.cod_item