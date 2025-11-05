--SQL DE QUANTIDADE COLABORADORES = INCORRETA

SELECT distinct c.edicao_nivel3
              , d.nome_organograma
              , count(distinct a.cod_contrato) as QTD_CONTRATOS
              , sum(case when f.cod_clh = '74' then 1 else 0 end) QTD_APRENDIZ
              , sum(case when f.cod_clh IN ('7','8','14','77','78','79','80','81','86','87','88','90','128','132','133','135','137','184','185','186','188'
                                           ,'189','190','192','255','264','268','275','283','294','299','301','302','318',304,191,196,197,252,89,92,93, 74,71) then 1 else 0 end) QTD_GERENTES
              , sum(case when f.cod_clh = '68' then 1 else 0 end) QTD_SERVENTE
              , sum(case when f.cod_clh = '123' then 1 else 0 end) QTD_FISCAL_DE_LOJA
FROM RHFP0310 a , rhfp0300 b, rhfp0401 c, rhfp0400 d, RHFP0340 f
where  b.cod_contrato = a.cod_contrato
and c.edicao_nivel3 between '004' and '7999'
and (b.data_fim > sysdate or b.data_fim is null)
and (a.data_fim > sysdate or a.data_fim is null)
and (f.data_fim > sysdate or f.data_fim is null)
and c.cod_organograma = a.cod_organograma
and d.cod_organograma = c.cod_organograma
and f.cod_contrato = b.cod_contrato
group by c.edicao_nivel3, d.nome_organograma
having  count(distinct a.cod_contrato) > 6
order by 1 asc
