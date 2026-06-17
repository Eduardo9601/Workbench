declare

  cursor c1 is 
  select a.cod_unidade, a.cod_rede, nvl(r.margem_perc,0) margem_perc from GRZ_DADOS_CALCULO_APR_ANUAL a, GRZ_VALORES_REGIOES_APR_ANUAL r
   where a.cod_unidade = r.cod_unidade
     and a.ano = r.ano
     and a.ano = 2016
   order by a.cod_unidade;
  r1 c1%rowtype;
  
 
  vQtdAtua      Number;
  vQtdAtua2     Number;
  vQtdNAtua     Number;
  vLidos        Number;
  vMensagem     Varchar2(100);
  wPontos       NUMBER;

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
      
      
      if r1.cod_rede = 10 then    
         if r1.margem_perc >= 50.0 then
            wPontos := 10;
         else 
            wpontos := 0;
         end if;
      elsif r1.cod_rede = 30 then 
         if r1.margem_perc >= 50.0 then
            wPontos := 10;
         else 
            wpontos := 0;
         end if;      	
      elsif r1.cod_rede = 40 then 
         if r1.margem_perc >= 58.0 then
            wPontos := 10;
         else 
            wpontos := 0;
         end if;        
      elsif r1.cod_rede = 50 then 
         if r1.margem_perc >= 49.0 then
            wPontos := 10;
         else 
            wpontos := 0;
         end if;  
      end if;      
      
      
      
      
      
      begin    
             update GRZ_DADOS_CALCULO_APR_ANUAL set margem_perc = wPontos
              where cod_unidade = r1.cod_unidade
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

