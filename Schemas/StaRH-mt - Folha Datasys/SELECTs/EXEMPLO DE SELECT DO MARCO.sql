select case
   when grouping(cod_unidade) = 1
      and grouping(cod_regiao) = 1
      and grouping(cod_grupo_macro) = 1 then
      null
   when grouping(cod_unidade) = 1
      and grouping(cod_regiao) = 1 then
      cod_grupo_macro
   when grouping(cod_unidade) = 1 then
      cod_regiao
   else
      cod_unidade
       end as "cod_unidade",
       case
          when grouping(cod_grupo_macro) = 1
             and grouping(cod_regiao) = 1
             and grouping(cod_unidade) = 1 then
             'Total Geral'
          when grouping(cod_regiao) = 1
             and grouping(cod_unidade) = 1 then
             'Total ' || max(des_grupo_macro)
          when grouping(cod_unidade) = 1 then
             'Total ' || max(des_regiao)
          else
             max(des_rede)
       end as "des_rede",
       case
          when grouping(cod_unidade) = 1 then
             null
          else
             max(des_cidade)
       end as "des_cidade",
       case
          when grouping(cod_unidade) = 1 then
             null
          else
             max(des_uf)
       end as "des_uf",
       to_char(
          sum(vlr_vd),
          '9G999G999G990D00'
       ) "Valor da Venda",
       to_char(
          sum(qtd_negocio),
          '9G999G999G990D00'
       ) "Quantidade Negocio",
       to_char(
          sum(ticket_medio),
          '9G999G999G990D00'
       ) "Ticket Médio",
       to_char(
          sum(vlr_vd_whats),
          '9G999G999G990D00'
       ) "Vlr_Venda_Whats",
       to_char(
          sum(vlr_vd_whats) * 100 / sum(vlr_vd),
          '9G999G999G990D00'
       ) "Perc_Whats",
       to_char(
          sum(vlr_demost),
          '9G999G999G990D00'
       ) "Vlr_Demostração",
       to_char(
          sum(vlr_demost) * 100 / sum(vlr_vd),
          '9G999G999G990D00'
       ) "Perc_Demost",
       to_char(
          sum(vlr_vd_prazo),
          '9G999G999G990D00'
       ) "Vlr_Venda_Prazo",
       to_char(
          sum(vlr_vd_prazo) * 100 / sum(vlr_vd),
          '9G999G999G990D00'
       ) "Perc_Vda_Prazo",
       to_char(
          sum(vlr_acresc),
          '9G999G999G990D00'
       ) "Vlr_Acrescimo",
       to_char(
          sum(vlr_acresc) * 100 / sum(vlr_vd_prazo),
          '9G999G999G990D00'
       ) "Perc_Acresc",
       to_char(
          sum(vlr_cpp),
          '9G999G999G990D00'
       ) "Valor CPP",
       to_char(
          sum(qtd_cpp),
          '9G999G999G990'
       ) "Quantidade CPP",
       to_char(
          sum(qtd_cartoes_novos),
          '9G999G999G990'
       ) "Qtd_Cartões_Novos",
       nvl(
          to_char(
             sum(nvl(
                qtd_kit_meia,
                0
             )),
             '9G999G999G990'
          ),
          ''
       ) "Qtd_Kit_Meia",
       to_char(
          sum(nvl(
             qtd_kit_meia,
             0
          )) * 100 / sum(nvl(
             qtd_negocio,
             0
          )),
          '9G999G999G990D00'
       ) "Perc_Kit_Meia",
       to_char(
          sum(nvl(
             a.vlr_vda_quarta_intima,
             0
          )),
          '9G999G999G990D00'
       ) "Vlr_Venda_Quarta_Intima",
       nvl(
          to_char(
             sum(a.vlr_vda_quarta_intima) / sum(a.vlr_vd) * 100,
             '9G999G999G990D00'
          ),
          '0'
       ) "Perc_Quarta_Intima",
       to_char(
          sum(nvl(
             a.qtd_bonus_vencidos,
             0
          )),
          '9G999G999G990'
       ) "Qtd_Bonus_Vencidos",
       nvl(
          to_char(
             sum(a.qtd_bonus_vencidos) / sum(a.qtd_bonus_venc_ret) * 100,
             '9G999G999G990D00'
          ),
          '0'
       ) "Perc_Bonus_Vencidos",
       to_char(
          sum(vlr_vale_presente),
          '9G999G999G990D00'
       ) "Vlr_Vale_Presente",
       to_char(
          sum(qtd_vale_presente),
          '9G999G999G990'
       ) "Qtd_Vale_Presente",
       max((
          select sum(
             case
                when b.cod_quebra = 52 then
                   b.per_ind_cobranca
                else
                   0
             end
          )
            from grz_kpi_vendas_tot_unidade b
           where b.cod_unidade = a.cod_unidade
             and b.ano_mes between to_char(
             to_date('01/05/2022',
               'dd/mm/yyyy'),
             'yyyymm'
          ) and to_char(
             to_date('30/07/2022',
               'dd/mm/yyyy'),
             'yyyymm'
          )
       )) as cpp,
       max((
          select sum(
             case
                when b.cod_quebra = 51 then
                   b.per_ind_cobranca
                else
                   0
             end
          )
            from grz_kpi_vendas_tot_unidade b
           where b.cod_unidade = a.cod_unidade
             and b.ano_mes between to_char(
             to_date('01/05/2022',
               'dd/mm/yyyy'),
             'yyyymm'
          ) and to_char(
             to_date('30/07/2022',
               'dd/mm/yyyy'),
             'yyyymm'
          )
       )) as cre,
       to_char(
          sum(vlr_cre_seguro),
          '9G999G999G990D00'
       ) "Vlr_CRE",
       to_char(
          sum(vlr_cre_seguro) * 100 / sum(vlr_vd_prazo),
          '9G999G999G990D00'
       ) "Perc_CRE",
       case
          when sum(qtd_cre_seguro) > 0
             and sum(qtd_cre_elegiveis) > 0 then
             to_char(
                sum(qtd_cre_seguro) / sum(qtd_cre_elegiveis) * 100,
                '9G999G999G990D00'
             )
          else
             '0'
       end "Conv_CRE",
       to_char(
          sum(vlr_cpp_seguro),
          '9G999G999G990D00'
       ) "Vlr_CPP",
       to_char(
          sum(vlr_dih_seguro),
          '9G999G999G990D00'
       ) "Vlr_DIH",
       to_char(
          sum(vlr_dih_seguro) * 100 / sum(vlr_vd_prazo),
          '9G999G999G990D00'
       ) "Perc_DIH",
       case
          when sum(qtd_dih_seguro) > 0
             and sum(qtd_dih_elegiveis) > 0 then
             to_char(
                sum(qtd_dih_seguro) / sum(qtd_dih_elegiveis) * 100,
                '9G999G999G990D00'
             )
          else
             '0'
       end "Conv_DIH",
       to_char(
          sum(vlr_ge_seguro),
          '9G999G999G990D00'
       ) "Vlr_GE",
       to_char(
          sum(vlr_ge_seguro) * 100 / sum(vlr_vd_prazo),
          '9G999G999G990D00'
       ) "Perc_GE",
       case
          when sum(qtd_ge_seguro) > 0
             and sum(qtd_ge_elegiveis) > 0 then
             to_char(
                sum(qtd_ge_seguro) / sum(qtd_ge_elegiveis) * 100,
                '9G999G999G990D00'
             )
          else
             '0'
       end "Conv_GE",
       to_char(
          sum(vlr_rfq_seguro),
          '9G999G999G990D00'
       ) "Vlr_RFQ",
       to_char(
          sum(vlr_rfq_seguro) * 100 / sum(vlr_vd_prazo),
          '9G999G999G990D00'
       ) "Perc_RFQ",
       case
          when sum(qtd_rfq_seguro) > 0
             and sum(qtd_rfq_elegiveis) > 0 then
             to_char(
                sum(qtd_rfq_seguro) / sum(qtd_rfq_elegiveis) * 100,
                '9G999G999G990D00'
             )
          else
             '0'
       end "Conv_RFQ"
  from grz_rel_kpi_vendas a
 where ( ( 999 = 999
   and cod_grupo_macro in ( 1739,
                            1740,
                            1741 ) )
    or ( 999 <> 999
   and cod_grupo_macro = 999 ) )
   and a.dta_movimento between '01/05/2022' and '30/07/2022'
   and cod_unidade between 0 and 999
 group by rollup(cod_grupo_macro,
                 cod_regiao,
                 cod_unidade)
 order by cod_grupo_macro,
          cod_regiao,
          cod_unidade;