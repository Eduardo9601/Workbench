select * from  grz_cad_calculo_apr -- campo valor1 traz valor variável sMargem 
where cod_rede = :rede 
and cod_calculo = 1;

select * from  grz_cad_calculo_apr -- campo valor1 traz valor variável sPermanencia 
where cod_rede = :rede 
and cod_calculo = 2;

select * from  grz_cad_calculo_apr -- campo valor1 traz valor variável sPreventiva 
where cod_rede = :rede 
and cod_calculo = 5;

select g.cod_quebra "Região" 
      ,a.cod_unidade "Unidade" 
      ,p.des_fantasia "Nome"  
      ,a.vlr_venda_orc "Orçado Vda" 
      ,a.vlr_venda_real "Vda Realizada" 
      ,decode(a.qtd_pontos_vda_orc,1,'OK','N') "Av" 
      ,a.vlr_margem_orc "Orç.Margem" 
      ,a.vlr_margem_real "Margem Realiz." 
      ,decode(a.qtd_pontos_margem,1,'OK','N') "Av" 
      ,decode(g.cod_nivel2,810,':sMargem'
                          ,830,':sMargem' 
                          ,840,':sMargem'  
                          ,870,':sMargem'  
                          ,850,':sMargem','0') "Margem Plan" 
      ,a.per_margem  "Margem Loja" 
      ,decode(g.cod_nivel2,810,':sPermanencia'  
                          ,830,':sPermanencia'  
                          ,840,':sPermanencia'   
                          ,870,':sPermanencia'  
                          ,850,':sPermanencia','0') "Perm.Plan"  
      ,a.vlr_perm "Perm.Loja" 
      ,decode(a.qtd_pontos_perm,1,'OK','N') "Av" 
      ,decode(g.cod_nivel2,810,':sPreventiva' 
                          ,830,':sPreventiva'  
                          ,840,':sPreventiva'  
                          ,870,':sPreventiva'   
                          ,850,':sPreventiva' ,'0') "Prev.Plan"  
      ,a.per_preventiva_cre "Preventiva"  
      ,decode(a.qtd_pontos_preventiva_cre,1,'OK','N') "Av" 
      ,decode((a.qtd_pontos_vda_orc + a.qtd_pontos_margem + a.qtd_pontos_perm + a.qtd_pontos_preventiva_cre) 
               ,4,'OK','N') "Av.Final" 
  from grz_dados_calculo_apr a  
      ,ge_grupos_unidades g   
      ,ps_pessoas p 
 where p.cod_pessoa = a.cod_unidade  
   and g.cod_unidade = a.cod_unidade   
   and g.cod_grupo = :pGrupo  
   and g.cod_emp = 1  
   and a.dta_ref = :pDataRef  
   and a.ind_ano = :pindAno  
   and a.cod_unidade between 0000 and 9999 
   and not exists(select 1 from grz_lojas_unificadas_cia cia where cia.cod_unidade_para = a.cod_unidade) 
 order by g.cod_quebra,a.cod_unidade;