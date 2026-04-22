
select a.cod_unidade,
       a.num_cupom,
       a.num_equipamento as PDV,
       A.Dta_Movimento,
       b.num_seq_item,
       b.cod_estruturado,
       c.des_item,
       b.hor_movimento,
       b.qtd_movimento,
       b.vlr_total,
       num_cpf_cnpj,
       des_cliente,
       b.cod_usuario,
       g.cod_operador,
       g.cod_autorizante,
       g.cod_acesso,
       g.seq_mvto,
       g.hora_mvto,
       acessos.des_acesso
  from sislogweb.est_cupons           a,
       sislogweb.est_cupom_itens_canc b,
       nl.ie_itens                    c,
       nl.grz_lojas_mvto_acessos      g,
       sislogweb.ger_acessos          acessos
where a.cod_emp = b.cod_emp
   and a.cod_unidade = b.cod_unidade
   and a.num_equipamento = b.num_equipamento
   and a.num_cupom = b.num_cupom
   and b.cod_item = c.cod_item
   and a.dta_movimento >= '01/03/2026'
   and a.dta_movimento <= '11/04/2026'
   and a.cod_unidade = 539
   and (b.cod_usuario = 398093 or g.cod_autorizante = 398093)
   and a.cod_unidade = g.cod_unidade
   and a.num_cupom = g.num_cupom
   and g.cod_acesso in ('CITEM', 'CCUPO', 'LVCOL')
   and acessos.cod_acesso = g.cod_acesso
   and a.num_equipamento = g.num_equipamento
