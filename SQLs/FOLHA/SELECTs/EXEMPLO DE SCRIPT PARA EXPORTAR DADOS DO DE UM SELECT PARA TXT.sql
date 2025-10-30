/*EXEMPLO DE SCRIPT PARA EXPORTAR DADOS DO DE UM SELECT PARA TXT*/

   set linesize 500000
set pagesize 500000

spool C:\Users\389622\Documents\Export\Folha_de_Pagamento.txt

--

select a.cod_contrato,
       a.cod_vd,
       b.nome_vd,
       to_char(
          sum(nvl(
             a.valor_vd,
             0
          )),
          'FM999G999G990D00'
       ) as "TOTAL_MES",
       '01/06/2024'
       || ' - '
       || '30/06/2024' as "REFERENCIA"
  from rhfp1006 a,
       rhfp1000 b
 where a.cod_vd = b.cod_vd
   and cod_mestre_evento in (
   select cod_mestre_evento
     from rhfp1003
    where to_date(data_referencia) between '01/06/2024' and '30/06/2024'
                            --'01/10/2022' AND '31/10/2022'
      and cod_organograma = 8
      and cod_evento in ( 1,
                          17,
                          19,
                          26 )
)
 group by a.cod_contrato,
          a.cod_vd,
          b.nome_vd
 order by a.cod_contrato asc,
          a.cod_vd asc;

--spool off