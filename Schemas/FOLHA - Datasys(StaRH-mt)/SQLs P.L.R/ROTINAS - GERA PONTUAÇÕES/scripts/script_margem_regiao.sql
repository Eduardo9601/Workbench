declare

  cursor c1 is 
  select sum(nvl(a.vlr_venda_liquida,0)) vda_liq, sum(nvl(a.vlr_margem_real,0)) margem_real, a.regiao, a.cod_rede from GRZ_VALORES_REGIOES_APR_ANUAL a
   where a.ano = 2016
     and a.regiao > 0
   group by a.regiao, a.cod_rede;
  r1 c1%rowtype;
  
 
  vQtdAtua      Number;
  vQtdAtua2     Number;
  vQtdNAtua     Number;
  vLidos        Number;
  vMensagem     Varchar2(100);
  wPontos       NUMBER;
  wMargem       NUMBER(8,1);

begin
   open c1;
   vQtdAtua := 0;
   vQtdNAtua := 0;
   vLidos := 0;
   vQtdAtua2 := 0;
   vMensagem := ''; 
   fetch c1 into r1;
   while c1%found loop
      vLidos := vLidos + 1;	
      wpontos := 99;
      
      if r1.vda_liq > 0 then
      	 wMargem := round((r1.margem_real / r1.vda_liq) * 100,1);
      else
         wMargem := 0;
      end if;
      
      
      if r1.cod_rede = 10 then    
         if wMargem >= 50.0 then
            wPontos := 10;
         else 
            wpontos := 0;
         end if;
      elsif r1.cod_rede = 30 then 
         if wMargem >= 50.0 then
            wPontos := 10;
         else 
            wpontos := 0;
         end if;      	
      elsif r1.cod_rede = 40 then 
         if wMargem >= 58.0 then
            wPontos := 10;
         else 
            wpontos := 0;
         end if;        
      elsif r1.cod_rede = 50 then 
         if wMargem >= 49.0 then
            wPontos := 10;
         else 
            wpontos := 0;
         end if;  
      end if;      
      
      
      
      
      
      begin    
             update GRZ_DADOS_CALCULO_APR_ANUAL set margem_perc = wPontos
                   ,MARGEM_PERC_REGIAO = wMargem
              where cod_unidade = r1.regiao
                and cod_rede = r1.cod_rede
                and ano = 2016;
      end;
      	 

   fetch c1 into r1;
   end loop;
   close c1;
   vMensagem := 'Lidos = '||to_Char(vLidos)||' Atualizados = '||to_Char(vQtdAtua)||' Nao Atualizados = '||to_Char(vQtdNatua);
   dbms_output.put_line(vMensagem);
   --commit;
end;

