CREATE OR REPLACE PROCEDURE GRZ_ORCAMENTO_APR_ANUAL_SP
(PI_OPCAO IN VARCHAR2) IS

BEGIN
DECLARE
	/****par?metros de entrada****/
	PI_CODEMP		NUMBER;
	PI_CODREDE		VARCHAR2(02);
	PI_CODGRUPO		NUMBER;
	PI_ORCAMENTO    NUMBER;
	PI_DATA_REF       DATE;

	Wi			    NUMBER;
	Wf			    NUMBER;
	wPerLucro		NUMBER;
	wLucroRede      NUMBER;
	wVendaLiqRede   NUMBER;
	wParamLucro     NUMBER;
	wUnidads   number;
	
    wPontosOrcado      NUMBER;
	wPontosMargem      NUMBER;
	wPontosMargemPerc      NUMBER;
	wQtd_Pontos_Lucro  NUMBER;
	wQtd_Pontos_Inventario NUMBER;
	wPerInventario     NUMBER;
	wRegiao  NUMBER;
	wInsereRegiao NUMBER;
	wDesp_Transporte NUMBER;
	wPer_Desp_Trans NUMBER;
	wQtd_Pontos_ValeT NUMBER;
	wProdutividade NUMBER;
	wQtd_Pontos_produt NUMBER;
	wHoras_Trab NUMBER;
	wPer_Desp_Folha  NUMBER;
	wQtd_Pontos_Folha NUMBER;
	wVendaOrcada number(18,2);
	wValor_Devolucao	    NUMBER(15,2);
	wVlr_Venda_Bruta_Sem_Devol  NUMBER(15,2);
	wMargem_Percentual          NUMBER(8,2);
	v_cur                       INTEGER;
    v_result                    INTEGER;

	SAIDA			EXCEPTION;

	/****cursor do total por unidade****/
	CURSOR c_totais_orcamento IS
              select a.cod_unidade
                    ,sum(decode(a.des_chave,'01#01001',nvl(a.vlr_orcado,0)
                                           ,'01#01003',nvl(a.vlr_orcado,0)
                                           ,'01#01005',nvl(a.vlr_orcado,0),0)) Vlr_Venda_Orc
                    ,sum(decode(a.des_chave,'01#01001',nvl(a.vlr_realizado,0)
                                           ,'01#01003',nvl(a.vlr_realizado,0)
                                           ,'01#01005',nvl(a.vlr_realizado,0),0)) Vlr_Venda_Real
                    ,sum(decode(a.des_chave,'05#05001',nvl(a.vlr_realizado,0),0)) Vlr_Venda_Liquida
                    ,sum(decode(a.des_chave,'09#09001',nvl(a.vlr_orcado,0),0)) Vlr_Margem_Orc
                    ,sum(decode(a.des_chave,'09#09001',nvl(a.vlr_realizado,0),0)) Vlr_Margem_Real
                    ,sum(decode(a.des_chave,'11#11001',nvl(a.vlr_realizado,0),0)) Vlr_Falta_Inventario
                    ,sum(decode(a.des_chave,'45#45001',nvl(a.vlr_realizado,0),0)) Vlr_Lucro
					,sum(decode(a.des_chave,'15#15001',nvl(a.vlr_realizado,0)
                                           ,'15#15005',nvl(a.vlr_realizado,0)              
                                           ,'15#15010',nvl(a.vlr_realizado,0)
                                           ,'15#15015',nvl(a.vlr_realizado,0)
                                           ,'15#15020',nvl(a.vlr_realizado,0)
                                           ,'15#15025',nvl(a.vlr_realizado,0) 
                                           ,'15#15030',nvl(a.vlr_realizado,0)
                                           ,'15#15035',nvl(a.vlr_realizado,0)
                                           ,'15#15040',nvl(a.vlr_realizado,0)
                                           ,'15#15045',nvl(a.vlr_realizado,0)
                                           ,'15#15049',nvl(a.vlr_realizado,0)
                                           ,'15#15050',nvl(a.vlr_realizado,0)
                                           ,'15#15055',nvl(a.vlr_realizado,0),0))Custo_Folha
                from or_valores a
                    ,ge_grupos_unidades b
               where a.cod_unidade    = b.cod_unidade
                 and b.cod_grupo      = '8'||PI_CODREDE
                 and b.cod_emp        = pi_codemp
                 and a.cod_emp        = pi_codemp
                 and a.cod_orcamento  = PI_ORCAMENTO
                 and a.dta_orcamento >= '01/01/'||SUBSTR(PI_DATA_REF,7,4)
                 and a.dta_orcamento <= '01/'||SUBSTR(PI_DATA_REF,4,7)
                 and (a.des_chave     = '01#01001'
                  or a.des_chave      = '01#01003'
                  or a.des_chave      = '01#01005'
                  or a.des_chave      = '05#05001'
                  or a.des_chave      = '09#09001'
                  or a.des_chave      = '11#11001'
                  or a.des_chave      = '45#45001'
				  or a.des_chave      = '15#15001'
                  or a.des_chave      = '15#15005'
                  or a.des_chave      = '15#15010'
                  or a.des_chave      = '15#15015'
                  or a.des_chave      = '15#15020'
                  or a.des_chave      = '15#15025'
                  or a.des_chave      = '15#15030'
                  or a.des_chave      = '15#15035'
                  or a.des_chave      = '15#15040'
                  or a.des_chave      = '15#15045' 
                  or a.des_chave      = '15#15049'
                  or a.des_chave      = '15#15050'
                  or a.des_chave      = '15#15055')
				--  and exists(select 1 from ge_grupos_unidades  where cod_unidade = a.cod_unidade and cod_grupo in (PI_GRUPO_ANTIGO))
               group by a.cod_unidade
			   order by a.cod_unidade;
	r_totais_orcamento c_totais_orcamento%ROWTYPE;


	/****cursor registro dados APR****/
	CURSOR c_apr IS
	  select * 
	    from GRZ_DADOS_CALCULO_APR_ANUAL
	   where cod_unidade = r_totais_orcamento.cod_unidade
             and ano     = SUBSTR(PI_DATA_REF,7,4);
	r_apr c_apr%ROWTYPE;
	
	CURSOR c_apr_regiao IS
	  select * 
	    from GRZ_VALORES_REGIOES_APR_ANUAL
	   where cod_unidade = r_totais_orcamento.cod_unidade
             and ano     = SUBSTR(PI_DATA_REF,7,4);
	r_apr_regiao c_apr_regiao%ROWTYPE;	
	
    CURSOR c_calc IS 
	   select * from  grz_cad_calculo_apr_anual 
	   where cod_rede = PI_CODREDE
	   and ano = SUBSTR(PI_DATA_REF,7,4)
	   and cod_calculo in (1,4,5,6)
       order by cod_calculo,qtd_pontos;
    r_calc c_calc%ROWTYPE;

	/*** inicio da procedure principal ***/
	begin
	          v_cur := dbms_sql.open_cursor;
              dbms_sql.parse(v_cur,'alter session set nls_date_format= "dd/mm/rrrr"',dbms_sql.native);
              v_result := dbms_sql.execute(v_cur);
              dbms_sql.close_cursor(v_cur);
              ---EXEC GRZ_DADOS_ORCAMENTO_APR_SP('1#40#840#400#2014#');---
			  
			  --1#40#840#400#31/03/2013#
	      /*** Desmembra a opcao recebida ***/
	      wi := INSTR(pi_opcao,'#',1,1);
	      PI_CODEMP := TO_NUMBER(SUBSTR(pi_opcao,1,(wi-1)));
	      wf := INSTR(pi_opcao,'#',1,2);
	      PI_CODREDE := SUBSTR(pi_opcao,(wi+1),(wf-wi-1));
	      wi := wf;
	      wf := INSTR(pi_opcao,'#',1,3);
	      PI_CODGRUPO := TO_NUMBER(SUBSTR(pi_opcao,(wi+1),(wf-wi-1)));
	      wi := wf;
	      wf := INSTR(pi_opcao,'#',1,4);
	      PI_ORCAMENTO := TO_NUMBER(SUBSTR(pi_opcao,(wi+1),(wf-wi-1)));
	      wi := wf;
	      wf := INSTR(pi_opcao,'#',1,5);
	      PI_DATA_REF := TO_DATE(SUBSTR(pi_opcao,(wi+1),(wf-wi-1)));
	      


        /****Abre o cursor****/

	BEGIN
	 wLucroRede := 0;
     wVendaLiqRede := 0;
	 select sum(Vlr_Lucro),sum(Vlr_Venda_Liquida) INTO wLucroRede,wVendaLiqRede  from (select    a.cod_unidade,               
                    sum(decode(a.des_chave,'05#05001',nvl(a.vlr_realizado,0),0)) Vlr_Venda_Liquida
                    ,sum(decode(a.des_chave,'45#45001',nvl(a.vlr_realizado,0),0)) Vlr_Lucro
                from or_valores a
                    ,ge_grupos_unidades b
               where a.cod_unidade    = b.cod_unidade
                 and b.cod_grupo      = '8'||PI_CODREDE
                 and b.cod_emp        = pi_codemp
                 and a.cod_emp        = pi_codemp
                 and a.cod_orcamento  = PI_ORCAMENTO
                 and a.dta_orcamento >= '01/01/'||SUBSTR(PI_DATA_REF,7,4)
                 and a.dta_orcamento <= '01/'||SUBSTR(PI_DATA_REF,4,7)
                 and (a.des_chave      = '05#05001'
                  or a.des_chave      = '45#45001')
                  having sum(decode(a.des_chave,'45#45001',nvl(a.vlr_realizado,0),0)) >0		
                group by a.cod_unidade
                order by a.cod_unidade);   
	   
		   wParamLucro :=  Round((wLucroRede * 100)/ wVendaLiqRede,2);
		   wParamLucro := wParamLucro / 4 ;
	 
		OPEN c_totais_orcamento;
		FETCH c_totais_orcamento INTO r_totais_orcamento;
		WHILE c_totais_orcamento%FOUND LOOP
		BEGIN		
		
            If (r_totais_orcamento.Vlr_Venda_Liquida <> 0) then
      		         wPerLucro := Round((r_totais_orcamento.vlr_lucro * 100)/ r_totais_orcamento.Vlr_Venda_Liquida,2);
			
				if wPerLucro > 999 then
         		      wPerLucro := 999;
      			  end if;   
                    wPerInventario := Round((r_totais_orcamento.vlr_falta_inventario * 100)/ r_totais_orcamento.Vlr_Venda_Liquida,2);
      			  if wPerInventario > 999 then
         		      wPerInventario := 999;
                  end if;
            
			wPer_Desp_Folha  := round(((r_totais_orcamento.Custo_Folha*100)/r_totais_orcamento.Vlr_Venda_Liquida),2);					  
				  
		     else
		 	  wPerLucro      := 0;
			  wPerInventario := 0; 
			  wPer_Desp_Folha :=0;
		     end if;
			 
		     if wPerLucro < 0 then
		 	 wPerLucro := 0;
		     end if;
			 
			wDesp_Transporte := 0; 
			BEGIN 			
			select NVL(round(sum(nvl(a.vlr_realizado,0)),2),0) vlr_realizado
			       into wDesp_Transporte
                   from or_valores a
                    where a.cod_emp = 1
                   and a.cod_unidade = r_totais_orcamento.cod_unidade
                   and a.cod_orcamento = 400
                   and a.dta_orcamento >= '01/01/'||SUBSTR(PI_DATA_REF,7,4)
                   and a.dta_orcamento <= '01/'||SUBSTR(PI_DATA_REF,4,7)
                   and (a.des_chave = '15#15025'  -- despesas com vale-transporte
                   or a.des_chave = '15#15030'); 
	         end; 
	 
			  If (r_totais_orcamento.Vlr_Venda_Liquida <> 0) then
			     wPer_Desp_Trans := round(((wDesp_Transporte*100)/r_totais_orcamento.Vlr_Venda_Liquida),2);
			  end if;		 
			
			wHoras_Trab := 0;
	       begin
	         select round(sum(nvl(a.vlr_realizado,0)),2) vlr_realizado
	         into wHoras_Trab
             from or_valores a
             where a.cod_emp = 1
             and a.cod_unidade = r_totais_orcamento.cod_unidade
             and a.cod_orcamento = 901
             and a.dta_orcamento >= '01/01/'||SUBSTR(PI_DATA_REF,7,4)
             and a.dta_orcamento <= '01/'||SUBSTR(PI_DATA_REF,4,7)
             and substr(a.des_chave,1,3) = '002';
           end;         
             
			if (wHoras_Trab <> 0) then
                wProdutividade := r_totais_orcamento.Vlr_Venda_Real/wHoras_Trab;			
			end if; 
			 
			 
			 -- PONTUAÇAO DE VENDA ORCADO
			 wVendaOrcada:=0;
			 -- wVendaOrcada:= r_totais_orcamento.Vlr_Venda_Orc - ((r_totais_orcamento.Vlr_Venda_Orc *1)/100);
			 
			 begin
                             select sum(nvl(o.vlr_operacao,0)) vlr_operacao
                               INTO wValor_Devolucao
                               from nl.ne_notas t
                                   ,nl.ne_notas_operacoes o
                              where t.num_seq     = o.num_seq
                                and t.cod_maquina = o.cod_maquina                                
                                and trunc(t.dta_emissao) between '01/01/'||SUBSTR(PI_DATA_REF,7,4) and '31/'||SUBSTR(PI_DATA_REF,4,7)
                                and t.cod_unidade = r_totais_orcamento.cod_unidade
                                and nvl(t.ind_status,0) <> 2 
                                and o.cod_oper in (106, 107);
	                  EXCEPTION
	                       WHEN NO_DATA_FOUND THEN
	                            wValor_Devolucao := 0;
	                 end; 
			 
			 wVlr_Venda_Bruta_Sem_Devol := r_totais_orcamento.Vlr_Venda_Real - nvl(wValor_Devolucao,0);
			 
			 if (wVlr_Venda_Bruta_Sem_Devol >= r_totais_orcamento.Vlr_Venda_Orc ) then 
			    wPontosOrcado := 5;
                         else		
			    wPontosOrcado := 0;
			 end if;	
			 
			-- margem percentual para nova avaliacao a partir de 2016
			if r_totais_orcamento.vlr_venda_liquida > 0 then
			   wMargem_Percentual := round((r_totais_orcamento.vlr_margem_real / r_totais_orcamento.vlr_venda_liquida) * 100,1);
			else 
			   wMargem_Percentual := 99;
			end if;
			
		        if PI_CODREDE = 10 then    
                           if wMargem_Percentual >= 50.0 then
                              wPontosMargemPerc := 10;
                           else 
                              wPontosMargemPerc := 0;
                           end if;
                        elsif PI_CODREDE = 30 then 
                           if wMargem_Percentual >= 50.0 then
                              wPontosMargemPerc := 10;
                           else 
                              wPontosMargemPerc := 0;
                           end if;      	
                        elsif PI_CODREDE = 40 then 
                           if wMargem_Percentual >= 58.0 then
                              wPontosMargemPerc := 10;
                           else 
                              wPontosMargemPerc := 0;
                           end if;        
                        elsif PI_CODREDE = 50 then 
                           if wMargem_Percentual >= 49.0 then
                              wPontosMargemPerc := 10;
                           else 
                              wPontosMargemPerc := 0;
                           end if;  
                        end if;      
			 
			-- PONTUAÇAO DE MARGEM
			 if (r_totais_orcamento.Vlr_Margem_Real >= r_totais_orcamento.Vlr_Margem_Orc ) then 
			    wPontosMargem := 10;
		         else		
			     wPontosMargem := 0;	
	                 end if;
			 
			-- PONTUACAO DE LUCRO
			 if (wPerLucro > 0.00) and
                (wPerLucro <= wParamLucro) then
      		 wQtd_Pontos_Lucro := 07;
             elsif (wPerLucro > (wParamLucro)) and
                   (wPerLucro <= (wParamLucro * 2)) then
      		 wQtd_Pontos_Lucro := 14;
             elsif (wPerLucro > (wParamLucro * 2)) and
                   (wPerLucro <= (wParamLucro * 3)) then
      		 wQtd_Pontos_Lucro := 21;
             elsif (wPerLucro > (wParamLucro * 3)) and
                   (wPerLucro <= (wParamLucro * 4)) then
      		 wQtd_Pontos_Lucro := 28;
             elsif (wPerLucro > (wParamLucro * 4)) then
      		 wQtd_Pontos_Lucro := 35;
             else
      		 wQtd_Pontos_Lucro := 0;
      	     end if;	 
			 
        /*       ----INVENTARIO----
                     if PI_CODREDE = '10' then
                         if (ABS(wPerInventario) <= 0.50) then
      		             wQtd_Pontos_Inventario := 5;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
                     elsif PI_CODREDE = '30' then
                         if (ABS(wPerInventario) <= 0.40) then
      		             wQtd_Pontos_Inventario := 5;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
                     elsif PI_CODREDE = '40' then
                         if (ABS(wPerInventario) <= 0.15) then
      		             wQtd_Pontos_Inventario := 5;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
                     elsif PI_CODREDE = '50' then
                         if (ABS(wPerInventario) <= 0.40) then
      		             wQtd_Pontos_Inventario := 5;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
                     end if;  

          ----VALE TRANSPORTE ----
                     if PI_CODREDE = '10' then
                         if (ABS(wPer_Desp_Trans) < 0.20) then
      		             wQtd_Pontos_ValeT := 2;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;
                     elsif PI_CODREDE = '30' then
                         if (ABS(wPer_Desp_Trans) < 0.10) then
      		             wQtd_Pontos_ValeT := 2;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;
                     elsif PI_CODREDE = '40' then
                         if (ABS(wPer_Desp_Trans) < 0.20) then
      		             wQtd_Pontos_ValeT := 2;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;
                     elsif PI_CODREDE = '50' then
                         if (ABS(wPer_Desp_Trans) < 0.15) then
      		             wQtd_Pontos_ValeT := 2;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;
                     end if;
					 
		---PRODUTIVIDADE----
        		     IF wProdutividade >= 140.00 THEN
					    wQtd_Pontos_produt := 2;
					 ELSE
                        wQtd_Pontos_produt := 0;
                     END IF;									 
		---CUSTO DE FOLHA -----
		
	             if  wPer_Desp_Folha < 0 then
                     wPer_Desp_Folha := wPer_Desp_Folha * -1; 	
		         end if;
		            if PI_CODREDE = '10' then
                         if (wPer_Desp_Folha < 12.00) then
      		             wQtd_Pontos_Folha := 2;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
                     elsif PI_CODREDE = '30' then
                         if (wPer_Desp_Folha < 12.00) then
      		             wQtd_Pontos_Folha := 2;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
                     elsif PI_CODREDE = '40' then
                         if (wPer_Desp_Folha < 15.00) then
      		             wQtd_Pontos_Folha := 2;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
                     elsif PI_CODREDE = '50' then
                         if (wPer_Desp_Folha < 12.00) then
      		             wQtd_Pontos_Folha := 2;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
                     end if; */
                 if  wPer_Desp_Folha < 0 then 
                     wPer_Desp_Folha := wPer_Desp_Folha * -1; 	
		         end if;
	                 OPEN C_CALC;
					 FETCH C_CALC INTO R_CALC;
					 WHILE C_CALC%FOUND LOOP
		             BEGIN
					  if r_calc.cod_calculo = 1 then  ----INVENTARIO--- 	
                         if (ABS(wPerInventario) <= r_calc.valor1) then
      		             wQtd_Pontos_Inventario := r_calc.qtd_pontos;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
					  elsif	 r_calc.cod_calculo = 4 then   ----VALE TRANSPORTE--- 						                    
                         if (ABS(wPer_Desp_Trans) < r_calc.valor1) then
      		             wQtd_Pontos_ValeT := r_calc.qtd_pontos;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;					 
					  elsif	 r_calc.cod_calculo = 5 then	 ----PRODUTIVIDADE---
                         IF wProdutividade >= r_calc.valor1 THEN
					     wQtd_Pontos_produt := r_calc.qtd_pontos;
					     ELSE
                         wQtd_Pontos_produt := 0;
                         END IF;						 
					  elsif	 r_calc.cod_calculo = 6 then	 ----CUSTO DE FOLHA----
                         if (wPer_Desp_Folha < r_calc.valor1) then
      		             wQtd_Pontos_Folha := r_calc.qtd_pontos;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;					 					  
					  end if;	 
						 
					 END;
	 	             FETCH C_CALC INTO R_CALC;
					 END LOOP;
					 CLOSE C_CALC;				 
					 
					 
					 
					 
			BEGIN
			wRegiao := 0;
               select COD_QUEBRA 
			   INTO wRegiao
			   from ge_grupos_unidades  
			   where cod_unidade = r_totais_orcamento.cod_unidade and cod_grupo =PI_CODGRUPO;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               wRegiao := 0;
			END;			
		/* 
		IF (PI_CODGRUPO = '840') THEN
	    	wInsereRegiao := '9'||SUBSTR(wRegiao,2,1);
		ELSE
		   wInsereRegiao := wRegiao;
		END IF;
		 */
			 
		     OPEN c_apr;
		     FETCH c_apr INTO r_apr;
		     IF c_apr%FOUND THEN
		     BEGIN
   			      update grz_dados_calculo_apr_ANUAL
                                 set ORCADO = wPontosOrcado,
								     MARGEM = wPontosMargem,
									 LUCRO  = wQtd_Pontos_Lucro,
									 INVENTARIO = wQtd_Pontos_Inventario,
									 VALE_TRANSP = wQtd_Pontos_ValeT,
									 PRODUTIVIDADE = wQtd_Pontos_produt,
									 FOLHA = wQtd_Pontos_Folha,
									 TIP_UNIDADE = 1,
									 COD_REDE = PI_CODREDE,
									 REGIAO   = wRegiao,
									 margem_perc = wPontosMargemPerc,
									 DATA_REFERENCIA = PI_DATA_REF
                                 where cod_unidade = r_totais_orcamento.cod_unidade
                                 and ano     = SUBSTR(PI_DATA_REF,7,4);
					COMMIT;			 
			 END;					 
             ELSE  
             BEGIN			 
                              insert into GRZ_DADOS_CALCULO_APR_ANUAL (COD_UNIDADE,ORCADO,MARGEM,LUCRO,INVENTARIO,VALE_TRANSP,PRODUTIVIDADE,FOLHA,COD_REDE,TIP_UNIDADE,REGIAO,ANO,DATA_REFERENCIA,MARGEM_PERC)
                              VALUES (r_totais_orcamento.cod_unidade,wPontosOrcado,wPontosMargem,wQtd_Pontos_Lucro,wQtd_Pontos_Inventario,wQtd_Pontos_ValeT,wQtd_Pontos_produt,wQtd_Pontos_Folha,
							  PI_CODREDE,1,wRegiao,SUBSTR(PI_DATA_REF,7,4),PI_DATA_REF,wPontosMargemPerc);	
				  COMMIT;
							  
             END;							  
             END IF;
	   	     CLOSE c_apr;
			 	 
				 
			--cursor que insere os valores para depois cancular a pontuacao da regiao
			
			OPEN c_apr_regiao;
		     FETCH c_apr_regiao INTO r_apr_regiao;
		     IF c_apr_regiao%FOUND THEN
		     BEGIN
   			      update GRZ_VALORES_REGIOES_APR_ANUAL
                                 set VLR_VENDA_ORC = r_totais_orcamento.VLR_VENDA_ORC
									 ,VLR_VENDA_REAL = r_totais_orcamento.VLR_VENDA_REAL
									 ,VLR_MARGEM_ORC = r_totais_orcamento.VLR_MARGEM_ORC
									 ,VLR_MARGEM_REAL = r_totais_orcamento.VLR_MARGEM_REAL
									 ,VLR_VENDA_LIQUIDA = r_totais_orcamento.VLR_VENDA_LIQUIDA
									 ,VLR_FALTA_INVENTARIO = r_totais_orcamento.VLR_FALTA_INVENTARIO
									 ,VLR_LUCRO = r_totais_orcamento.VLR_LUCRO	
									 ,VALE_TRANSP = wDesp_Transporte
									 ,HORAS_TRAB = wHoras_Trab
                                                                         ,REGIAO = wRegiao 	
									 ,FOLHA  = r_totais_orcamento.CUSTO_FOLHA		
									 ,COD_REDE = PI_CODREDE	
									 ,VLR_DEVOLUCAO = wValor_Devolucao
									 ,MARGEM_PERC = wMargem_Percentual
                                 where cod_unidade = r_totais_orcamento.cod_unidade
                                 and ano     = SUBSTR(PI_DATA_REF,7,4);
								 COMMIT;
			 END;					 
             ELSE  
             BEGIN			 
                              insert into GRZ_VALORES_REGIOES_APR_ANUAL (COD_UNIDADE,VLR_VENDA_ORC,VLR_VENDA_REAL,VLR_MARGEM_ORC,VLR_MARGEM_REAL,VLR_VENDA_LIQUIDA,VLR_FALTA_INVENTARIO,
							              VLR_LUCRO,VALE_TRANSP,HORAS_TRAB,REGIAO,FOLHA,COD_REDE,ANO,VLR_DEVOLUCAO,MARGEM_PERC)
                              VALUES (r_totais_orcamento.cod_unidade,r_totais_orcamento.VLR_VENDA_ORC,r_totais_orcamento.VLR_VENDA_REAL,r_totais_orcamento.VLR_MARGEM_ORC,r_totais_orcamento.VLR_MARGEM_REAL,
        							  r_totais_orcamento.VLR_VENDA_LIQUIDA,r_totais_orcamento.VLR_FALTA_INVENTARIO,r_totais_orcamento.VLR_LUCRO,wDesp_Transporte,wHoras_Trab,wRegiao,
									  r_totais_orcamento.CUSTO_FOLHA,PI_CODREDE,SUBSTR(PI_DATA_REF,7,4),wValor_Devolucao,wMargem_Percentual);
							COMMIT;		  
             END;							  
             END IF;
	   	     CLOSE c_apr_regiao;	 
 
				 
	END;
	 	FETCH c_totais_orcamento INTO r_totais_orcamento;
	 	END LOOP;
	 	CLOSE c_totais_orcamento;
		
	END;

        

	EXCEPTION
	    WHEN SAIDA THEN
	       NULL;
		   
END;
END GRZ_ORCAMENTO_APR_ANUAL_SP;