 select distinct (x.num_cupom) num_cupom_1,
                 x.num_equipamento,
                 gg.cod_grupo,
                 gg.cod_regiao,
                 gg.des_regiao,
                 gg.cod_unidade,
                 gg.des_unidade,
                 nt.operacao,
                 nt.num_nota_devol,
                 nt.vlr_nota_devol,
                 nt.dta_emissao_devol,
                 nt.hor_emissao_devol,
                 nt.num_cupom,
                 nt.num_ecf_cupom,
                 rec.num_contrato as num_contrato_rec,
                 trunc(ns.dth_saida) dta_cupom,
                 to_char(ns.dth_saida, 'hh24:mi:ss') hor_cupom,
                 (select substr(m.cod_editado, 4, 12)
                    from ps_mascaras m
                   where p.cod_pessoa = m.cod_pessoa
                     and m.cod_mascara = 50
                     and rownum = 1) cod_cliente_completo,
                 p.cod_pessoa cod_cliente,
                 p.des_pessoa des_cliente,
                 ns.cod_cliente cod_cli_compra,
                 pf.num_cpf
   from (select distinct (ce.num_seq_ns),
                         ce.cod_maq_ns,
                         ne.cod_unidade,
                         ne.cod_pessoa_forn,
                         ne.operacao,
                         ne.num_nota_devol,
                         ne.dta_emissao_devol,
                         ne.hor_emissao_devol,
                         ne.num_cupom,
                         ne.num_ecf_cupom,
                         ne.vlr_nota_devol
           from ce_diarios ce,
                (select c.num_seq,
                        c.cod_maquina,
                        c.cod_unidade,
                        c.cod_pessoa_forn,
                        a.cod_oper operacao,
                        c.num_nota num_nota_devol,
                        trunc(c.dta_emissao) dta_emissao_devol,
                        to_char(c.dta_emissao, 'hh24:mi:ss') hor_emissao_devol,
                        c.num_autorizacao_transporte num_cupom,
                        c.num_nota_produtor num_ecf_cupom,
                        sum(nvl(a.vlr_operacao, 0)) vlr_nota_devol
                   from ne_notas c, ne_notas_operacoes a
                  where c.num_seq = a.num_seq
                    and c.cod_maquina = a.cod_maquina
                    and a.cod_oper in (106, 107, 4106, 4107)
                    and c.cod_unidade between 0 and 9999
                    and trunc(c.dta_emissao) between '01/03/2023' and '28/03/2024'
                    and to_char(c.dta_emissao, 'hh24:mi:ss') between
                        '00:00:00' and '23:59:59'
                    and c.ind_status = 1
                  group by c.num_seq,
                           c.cod_maquina,
                           c.cod_unidade,
                           c.cod_pessoa_forn,
                           a.cod_oper,
                           c.num_nota,
                           c.dta_emissao,
                           c.num_autorizacao_transporte,
                           c.num_nota_produtor) ne
          where ne.num_seq = ce.num_seq_ne
            and ne.cod_maquina = ce.cod_maq_ne),
        nt ps_pessoas p,
        ns_notas ns,
        grz_lojas_cupom_itens x,
        ps_fisicas pf,
        grz_lojas_recebimentos rec,
        (select ge.cod_grupo   cod_grupo,
                gr.cod_grupo   cod_regiao,
                gr.des_grupo   des_regiao,
                gu.cod_unidade cod_unidade,
                gu.des_nome    des_unidade
           from ge_grupos_unidades ge, ge_unidades gu, ge_grupos gr
          where ge.cod_quebra = gr.cod_grupo
            and ge.cod_unidade = gu.cod_unidade
            and ge.cod_emp = 1
            and ge.cod_grupo in (910, 930, 940, 950, 970)
          order by ge.cod_grupo, gr.cod_grupo, gu.cod_unidade) gg
  where nt.cod_pessoa_forn = p.cod_pessoa
    and nt.cod_unidade = gg.cod_unidade
    and nt.cod_unidade = x.cod_unidade(+)
    and nt.dta_emissao_devol = x.dta_lancamento(+)
    and nt.num_nota_devol = x.num_nota_devolucao(+)
    and nt.cod_unidade = rec.cod_unidade(+)
    and nt.dta_emissao_devol = rec.dta_mvto(+)
    and nt.num_nota_devol = rec.num_nota(+)
    and gg.cod_grupo = 999
    and nt.cod_pessoa_forn = pf.cod_pessoa(+)
    and nt.num_seq_ns = ns.num_seq(+)
    and nt.cod_maq_ns = ns.cod_maquina(+)
    and ns.tip_nota(+) = 3
    and ns.ind_status(+) = 1
    and ns.dta_emissao(+) >= to_date(nt.dta_emissao_devol - 0)
    and ns.dta_emissao(+) <= to_date(nt.dta_emissao_devol - 999)
    order by gg.cod_grupo, 
             gg.cod_regiao, 
             gg.cod_unidade, 
             nt.num_nota_devol
