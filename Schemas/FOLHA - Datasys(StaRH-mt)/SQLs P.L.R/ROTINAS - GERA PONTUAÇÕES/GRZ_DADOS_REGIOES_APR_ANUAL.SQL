CREATE OR REPLACE PROCEDURE GRZ_REGIOES_APR_ANUAL_SP
(PI_OPCAO IN VARCHAR2) IS
BEGIN
DECLARE
   /****par?metros de entrada****/
	PI_CODGRUPO		        NUMBER;
	PI_DATA_REF         DATE;
	PI_CODREDE          NUMBER;


	wPontosOrcado NUMBER;
	wPontosMargem NUMBER;
	wPontosMargemPerc      NUMBER;
	wQtd_Pontos_Lucro NUMBER;
	wPerLucro NUMBER;
	wQtd_Pontos_Inventario NUMBER;
	wPerInventario NUMBER;
	wVlrPerm NUMBER;
	wPer_Preventiva NUMBER;
	wQtd_Pontos_Preventiva_CRE NUMBER;
	wQtd_Pontos_Perm NUMBER;
	wPer_Desp_Trans NUMBER;
	wQtd_Pontos_ValeT NUMBER;
	wQtd_Pontos_produt NUMBER;
	wProdutividade NUMBER;
	wDesUnidade VARCHAR2(50);
	wPer_Desp_Folha NUMBER;
	wQtd_Pontos_Folha NUMBER;
	wQtd_Pontos_turn NUMBER;
	wTurnOver  NUMBER(10,2);
	wLucroRede      NUMBER;
	wVendaLiqRede   NUMBER;
	wParamLucro     NUMBER;
	wVendaOrcada number(18,2);
	wValor_Devolucao	    NUMBER(15,2);
	wVlr_Venda_Bruta_Sem_Devol  NUMBER(15,2);
	wMargem_Percentual          NUMBER(8,2);
	wPontosCresc NUMBER;
	WCRESCIMENTO  NUMBER(15,2);
	v_cur                       INTEGER;
	v_result                    INTEGER;

	Wi			NUMBER;
	Wf			NUMBER;


    CURSOR c_pontuacao_regioes IS
	SELECT A.REGIAO
        ,SUM(A.VLR_VENDA_ORC) VENDA_ORCADO
        ,SUM(A.VLR_VENDA_REAL) VENDA_REL
        ,SUM(A.VLR_MARGEM_ORC)MARGEM_ORC
        ,SUM(A.VLR_MARGEM_REAL)MARGEM_REL
        ,SUM(A.VLR_VENDA_LIQUIDA)VENDA_LIQ
        ,SUM(A.VLR_FALTA_INVENTARIO)INVENTARIO
        ,SUM(A.VLR_LUCRO) LUCRO
        ,SUM(A.VLR_CUSTO_PERM)VLR_PERM
        ,SUM(A.VLR_EST_MEDIO_PERM)EST_PERM
        ,SUM(A.VLR_PREVENTIVA)PREVENTIVA
        ,SUM(A.QTD_MESES) QTD_MESES
        ,SUM(A.VALE_TRANSP) TRANSPORTE
        ,SUM(A.HORAS_TRAB) HORAS
	    ,SUM(A.FOLHA) FOLHA
		,SUM(A.DEMISSOES) DEMISSOES
		,SUM(A.EFET_INI)EFI
		,SUM(A.VLR_DEVOLUCAO) VLR_DEVOLUCAO
		,SUM(A.VLR_VENDA_ANO_ANT) VLR_VENDA_ANO_ANT
        FROM GRZ_VALORES_REGIOES_APR_ANUAL A
        WHERE A.VLR_VENDA_LIQUIDA > 0
		AND	A.ANO = SUBSTR(PI_DATA_REF,7,4)
        --AND   A.COD_REDE = PI_CODREDE--	SUBSTR(PI_CODGRUPO,2,2)
        group by a.regiao
        order by a.regiao;
	r_pontuacao_regioes c_pontuacao_regioes%ROWTYPE;

	CURSOR c_apr IS
	  select *
	    from GRZ_DADOS_CALCULO_APR_ANUAL
	   where cod_unidade = r_pontuacao_regioes.REGIAO
             and ano     = SUBSTR(PI_DATA_REF,7,4);
	r_apr c_apr%ROWTYPE;

	CURSOR c_calc IS
	   select * from  grz_cad_calculo_apr_anual
	   where /*cod_rede = PI_CODREDE
	   and*/ ano = SUBSTR(PI_DATA_REF,7,4)
	   and cod_calculo in (1,2,3,4,5,6,7)
       order by cod_calculo,qtd_pontos;
    r_calc c_calc%ROWTYPE;

	/*CURSOR c_nome_unidades IS
	    select * from GRZ_DADOS_CALCULO_APR_ANUAL a
		where a.ano = PI_ANO
		and a.cod_rede = substr(PI_CODGRUPO,2,2)
		and exists(select 1 from ge_grupos_unidades  where cod_unidade = a.cod_unidade and cod_grupo in (PI_GRUPO_ANTIGO));
	r_nome_unidades c_nome_unidades%ROWTYPE;*/

BEGIN
	          v_cur := dbms_sql.open_cursor;
              dbms_sql.parse(v_cur,'alter session set nls_date_format= "dd/mm/rrrr"',dbms_sql.native);
              v_result := dbms_sql.execute(v_cur);
              dbms_sql.close_cursor(v_cur);
    /*** Desmembra a opcao recebida ***/
	      wi := INSTR(pi_opcao,'#',1,1);
	      PI_CODGRUPO := TO_NUMBER(SUBSTR(pi_opcao,1,(wi-1)));
	      wf := INSTR(pi_opcao,'#',1,2);
	      PI_DATA_REF := TO_DATE(SUBSTR(pi_opcao,(wi+1),(wf-wi-1)));
          wi := wf;
	      wf := INSTR(pi_opcao,'#',1,3);
	      PI_CODREDE := TO_NUMBER(SUBSTR(pi_opcao,(wi+1),(wf-wi-1)));


		wLucroRede := 0;
     wVendaLiqRede := 0;

	    select sum(Vlr_Lucro),sum(Vlr_Venda_Liquida) INTO wLucroRede,wVendaLiqRede from (select    a.cod_unidade,
                    sum(decode(a.des_chave,'05#05001',nvl(a.vlr_realizado,0),0)) Vlr_Venda_Liquida
                    ,sum(decode(a.des_chave,'45#45001',nvl(a.vlr_realizado,0),0)) Vlr_Lucro
                from or_valores a
                    ,ge_grupos_unidades b
               where a.cod_unidade    = b.cod_unidade
                 and b.cod_grupo      IN (71010,71030,71040,71050,71070)
                 and b.cod_emp        = 1
                 and a.cod_emp        = 1
                 and a.cod_orcamento  = 400
                 and a.dta_orcamento >= '01/01/'||SUBSTR(PI_DATA_REF,7,4)
                 and a.dta_orcamento <= '01/'||SUBSTR(PI_DATA_REF,4,7)
				 and a.dta_orcamento not in ('01/03/2020','01/04/2020','01/07/2020')
                 and (a.des_chave      = '05#05001'
                  or a.des_chave      = '45#45001')
				having sum(decode(a.des_chave,'45#45001',nvl(a.vlr_realizado,0),0)) >0
                group by a.cod_unidade
                order by a.cod_unidade);
		   wParamLucro :=  Round((wLucroRede * 100)/ wVendaLiqRede,2);
		   wParamLucro := wParamLucro / 4 ;


	    OPEN c_pontuacao_regioes;
		FETCH c_pontuacao_regioes INTO r_pontuacao_regioes;
		WHILE c_pontuacao_regioes%FOUND LOOP
		BEGIN

		wPontosOrcado := 0;
		wPontosMargem := 0;
		wQtd_Pontos_Lucro := 0;
		wPerLucro := 0;
		wQtd_Pontos_Inventario := 0;
		wQtd_Pontos_Preventiva_CRE := 0;
		wQtd_Pontos_Perm := 0;
		wQtd_Pontos_ValeT :=0;
		wQtd_Pontos_produt := 0;
		wQtd_Pontos_Folha :=0;
		wQtd_Pontos_turn := 0;

		    If (r_pontuacao_regioes.VENDA_LIQ <> 0) then
      		         wPerLucro := Round((r_pontuacao_regioes.LUCRO * 100)/ r_pontuacao_regioes.VENDA_LIQ,2);

				 if wPerLucro > 999 then
         		      wPerLucro := 999;
      			  end if;

                    wPerInventario := Round((r_pontuacao_regioes.INVENTARIO * 100)/ r_pontuacao_regioes.VENDA_LIQ,2);
      			  if wPerInventario > 999 then
         		      wPerInventario := 999;
                  end if;

				  wPer_Desp_Trans := round(((r_pontuacao_regioes.TRANSPORTE*100)/r_pontuacao_regioes.VENDA_LIQ),2);

				  wPer_Desp_Folha  := round(((r_pontuacao_regioes.FOLHA*100)/r_pontuacao_regioes.VENDA_LIQ),2);

		     else
		 	  wPerLucro      := 0;
			  wPerInventario := 0;
			  wPer_Desp_Trans :=0;
			  wPer_Desp_Folha :=0;
		     end if;

		     if wPerLucro < 0 then
		 	 wPerLucro := 0;
		     end if;

		If (r_pontuacao_regioes.EST_PERM <> 0) and (r_pontuacao_regioes.VLR_PERM  <> 0) then
      	     wVlrPerm := Round(360 / (r_pontuacao_regioes.VLR_PERM /(r_pontuacao_regioes.EST_PERM / 365.25)),0);

			 if wVlrPerm > 9999 then
         	 wVlrPerm := 9999;
      	     end if;
   	    else
      	    wVlrPerm := 0;
        end if;

     	if wVlrPerm < 0 then
   	      wVlrPerm := 0;
    	end if;

		IF (r_pontuacao_regioes.qtd_meses > 0 ) THEN
                         wPer_Preventiva := trunc(r_pontuacao_regioes.PREVENTIVA / r_pontuacao_regioes.qtd_meses,1);
        ELSE
            wPer_Preventiva :=0;
		END IF;

        if (r_pontuacao_regioes.HORAS <> 0) then
                wProdutividade := r_pontuacao_regioes.VENDA_REL/r_pontuacao_regioes.HORAS;
        ELSE
            wProdutividade := 0;
		End if;

		if (r_pontuacao_regioes.EFI <> 0 ) then
            wTurnOver:=  ((r_pontuacao_regioes.DEMISSOES * 100)/r_pontuacao_regioes.EFI);
        else
            wTurnOver :=0;
		end if;


		-- PONTUA�AO DE VENDA ORCADO
			-- if (r_pontuacao_regioes.VENDA_REL >= r_pontuacao_regioes.VENDA_ORCADO ) then
			wVendaOrcada:=0;
			-- wVendaOrcada:= r_pontuacao_regioes.VENDA_ORCADO - ((r_pontuacao_regioes.VENDA_ORCADO *1)/100);

			wVlr_Venda_Bruta_Sem_Devol := r_pontuacao_regioes.VENDA_REL - nvl(r_pontuacao_regioes.vlr_devolucao,0);

			 if (wVlr_Venda_Bruta_Sem_Devol >= r_pontuacao_regioes.VENDA_ORCADO ) then
			    wPontosOrcado := 10;
		     else
			    wPontosOrcado := 0;
			 end if;
			 
			 if r_pontuacao_regioes.vlr_venda_ano_ant > 0 then
			    wCrescimento := round(((wVlr_Venda_Bruta_Sem_Devol * 100) / r_pontuacao_regioes.vlr_venda_ano_ant) - 100,2);
			 else 
			    wCrescimento := 0;
			 end if;
			 
			 if wCrescimento > 0.01 then
			    wPontosCresc := 10;
			 else
			    wPontosCresc := 0;
			 end if;			 
			 

			-- margem percentual para outra avaliacao
			if r_pontuacao_regioes.VENDA_LIQ > 0 then
			   wMargem_Percentual := round((r_pontuacao_regioes.MARGEM_REL / r_pontuacao_regioes.VENDA_LIQ) * 100,1);
			else
			   wMargem_Percentual := 99;
			end if;

		    if wMargem_Percentual >= 50.0 then
               wPontosMargemPerc := 10;
            else
               wPontosMargemPerc := 0;
            end if;
            

		-- PONTUA�AO DE MARGEM
			 if (r_pontuacao_regioes.MARGEM_REL >= r_pontuacao_regioes.MARGEM_ORC ) then
			    wPontosMargem := 10;
		     else
			    wPontosMargem := 0;
	         end if;
		-- PONTUACAO DE LUCRO
		-- mudado para 5 pontos em 22/03/2019
			 if (wPerLucro > 0.00) and
                (wPerLucro <= wParamLucro) then
      		 wQtd_Pontos_Lucro := 05;
             elsif (wPerLucro > (wParamLucro)) and
                   (wPerLucro <= (wParamLucro * 2)) then
      		 wQtd_Pontos_Lucro := 10;
             elsif (wPerLucro > (wParamLucro * 2)) and
                   (wPerLucro <= (wParamLucro * 3)) then
      		 wQtd_Pontos_Lucro := 15;
             elsif (wPerLucro > (wParamLucro * 3)) and
                   (wPerLucro <= (wParamLucro * 4)) then
      		 wQtd_Pontos_Lucro := 20;
             elsif (wPerLucro > (wParamLucro * 4)) then
      		 wQtd_Pontos_Lucro := 25;
             else
      		 wQtd_Pontos_Lucro := 0;
      	     end if;
	/*
        ----INVENTARIO----
                     if SUBSTR(PI_CODGRUPO,2,2) = '10' then
                         if (ABS(wPerInventario) <= 0.50) then
      		             wQtd_Pontos_Inventario := 5;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2)  = '30' then
                         if (ABS(wPerInventario) <= 0.40) then
      		             wQtd_Pontos_Inventario := 5;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2)  = '40' then
                         if (ABS(wPerInventario) <= 0.15) then
      		             wQtd_Pontos_Inventario := 5;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2)  = '50' then
                         if (ABS(wPerInventario) <= 0.40) then
      		             wQtd_Pontos_Inventario := 5;
                         else
      		             wQtd_Pontos_Inventario := 0;
      	                 end if;
                     end if;

----PERMANENCIA---
      if SUBSTR(PI_CODGRUPO,2,2)  = '10' then
        if (wVlrPerm >= 60) and
           (wVlrPerm <= 90) then
        wQtd_Pontos_Perm := 10;
        else
        wQtd_Pontos_Perm := 0;
        end if;
     elsif SUBSTR(PI_CODGRUPO,2,2)  = '30' then
        if (wVlrPerm >= 60) and
           (wVlrPerm <= 90) then
        wQtd_Pontos_Perm := 10;
        else
        wQtd_Pontos_Perm := 0;
        end if;
     elsif SUBSTR(PI_CODGRUPO,2,2)  = '40' then
        if (wVlrPerm >= 60) and
           (wVlrPerm <= 90) then
      	wQtd_Pontos_Perm := 10;
        else
      	wQtd_Pontos_Perm := 0;
      	end if;
     elsif SUBSTR(PI_CODGRUPO,2,2)  = '50' then
        if (wVlrPerm>= 60) and
           (wVlrPerm <= 90) then
      	wQtd_Pontos_Perm := 10;
        else
      	wQtd_Pontos_Perm := 0;
      	end if;
     end if;

			----PREVENTIVA----
                     if SUBSTR(PI_CODGRUPO,2,2)  = '10' then
                         if (wPer_Preventiva) < 13.5 then
      		             wQtd_Pontos_Preventiva_CRE := 10;
                         else
      		             wQtd_Pontos_Preventiva_CRE := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2)  = '30' then
                         if (wPer_Preventiva) < 13.5 then
      		             wQtd_Pontos_Preventiva_CRE := 10;
                         else
      		             wQtd_Pontos_Preventiva_CRE := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2)  = '40' then
                         if (wPer_Preventiva) < 12.5 then
      		             wQtd_Pontos_Preventiva_CRE := 10;
                         else
      		             wQtd_Pontos_Preventiva_CRE := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2)  = '50' then
                         if (wPer_Preventiva) < 13.0 then
      		             wQtd_Pontos_Preventiva_CRE := 10;
                         else
      		             wQtd_Pontos_Preventiva_CRE := 0;
      	                 end if;
                     end if;

			----VALE TRANSPORTE ----
                     if SUBSTR(PI_CODGRUPO,2,2) = '10' then
                         if (ABS(wPer_Desp_Trans) < 0.20) then
      		             wQtd_Pontos_ValeT := 2;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2) = '30' then
                         if (ABS(wPer_Desp_Trans) < 0.10) then
      		             wQtd_Pontos_ValeT := 2;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2) = '40' then
                         if (ABS(wPer_Desp_Trans) < 0.20) then
      		             wQtd_Pontos_ValeT := 2;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2) = '50' then
                         if (ABS(wPer_Desp_Trans) < 0.15) then
      		             wQtd_Pontos_ValeT := 2;
                         else
      		             wQtd_Pontos_ValeT := 0;
      	                 end if;
                     end if;
	     --PRODUTIVIDADE----
        		     IF wProdutividade >= 140.00 THEN
					    wQtd_Pontos_produt := 2;
					 ELSE
                        wQtd_Pontos_produt := 0;
                     END IF;
			---CUSTO DE FOLHA -----
			if  wPer_Desp_Folha < 0 then
                wPer_Desp_Folha := wPer_Desp_Folha * -1;
		    end if;
		            if SUBSTR(PI_CODGRUPO,2,2) = '10' then
                         if (wPer_Desp_Folha < 12.00) then
      		             wQtd_Pontos_Folha := 2;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2) = '30' then
                         if (wPer_Desp_Folha < 12.00) then
      		             wQtd_Pontos_Folha := 2;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2) = '40' then
                         if (wPer_Desp_Folha < 15.00) then
      		             wQtd_Pontos_Folha := 2;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
                     elsif SUBSTR(PI_CODGRUPO,2,2) = '50' then
                         if (wPer_Desp_Folha < 12.00) then
      		             wQtd_Pontos_Folha := 2;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
                     end if;


		---TURN OVER -----
			     if wTurnOver < 2.5 then
					wQtd_Pontos_turn := 2;
				else
					wQtd_Pontos_turn := 0;
				end if;		*/
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
					  elsif	 r_calc.cod_calculo = 2 then   ----PERMANENCIA---
                         if (wVlrPerm >=r_calc.valor1) and
                            (wVlrPerm <=r_calc.valor2) then
      		              wQtd_Pontos_Perm :=r_calc.qtd_pontos;
						 else
                         wQtd_Pontos_Perm := 0;
      	                 end if;
                      elsif	 r_calc.cod_calculo = 3 then	 ----PREVENTIVA----
                         if (wPer_Preventiva <= r_calc.valor1) then
      		             wQtd_Pontos_Preventiva_CRE := r_calc.qtd_pontos;
						 else
						 wQtd_Pontos_Preventiva_CRE :=0;
      	                 end if;
					  elsif	 r_calc.cod_calculo = 4 then   ----VALE TRANSPORTE---
                         if (ABS(wPer_Desp_Trans) <= r_calc.valor1) then
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
                         if (wPer_Desp_Folha <= r_calc.valor1) then
      		             wQtd_Pontos_Folha := r_calc.qtd_pontos;
                         else
      		             wQtd_Pontos_Folha := 0;
      	                 end if;
					 elsif	 r_calc.cod_calculo = 7 then	 ----TURN OVER----
                         if (wTurnOver <= r_calc.valor1) then
      		             wQtd_Pontos_turn := r_calc.qtd_pontos;
						 else
						 wQtd_Pontos_turn :=0;
      	                 end if;
					 end if;

					 END;
	 	             FETCH C_CALC INTO R_CALC;
					 END LOOP;
					 CLOSE C_CALC;



				OPEN c_apr;
		        FETCH c_apr INTO r_apr;
		        IF c_apr%FOUND THEN
		            BEGIN
   			          update GRZ_DADOS_CALCULO_APR_ANUAL
                                     set ORCADO = wPontosOrcado
                                         ,MARGEM = wPontosMargem
                                         ,LUCRO = wQtd_Pontos_Lucro
										,PERMANENCIA = wQtd_Pontos_Perm
										,INVENTARIO = wQtd_Pontos_Inventario
										,PREVENTIVA = wQtd_Pontos_Preventiva_CRE
										,VALE_TRANSP = wQtd_Pontos_ValeT
										,PRODUTIVIDADE = wQtd_Pontos_produt
										,COD_REDE = 99
										,FOLHA = wQtd_Pontos_Folha
										,TIP_UNIDADE = 2
										,REGIAO   =  r_pontuacao_regioes.REGIAO
										,TURN_OVER = wQtd_Pontos_turn
										,margem_perc = wPontosMargemPerc
										,MARGEM_PERC_REGIAO = wMargem_Percentual
										,DATA_REFERENCIA = PI_DATA_REF
										,CRESCIMENTO = wPontosCresc
                                   where cod_unidade = r_pontuacao_regioes.REGIAO
                                     and ano     = SUBSTR(PI_DATA_REF,7,4);
		            END;
                ELSE
                    begin
                        INSERT INTO GRZ_DADOS_CALCULO_APR_ANUAL (COD_UNIDADE,ORCADO,MARGEM,LUCRO,INVENTARIO,PERMANENCIA,PREVENTIVA,VALE_TRANSP,PRODUTIVIDADE,FOLHA,COD_REDE,TIP_UNIDADE,REGIAO,TURN_OVER,ANO,DATA_REFERENCIA,margem_perc,MARGEM_PERC_REGIAO,CRESCIMENTO) VALUES
						(r_pontuacao_regioes.REGIAO,wPontosOrcado,wPontosMargem,wQtd_Pontos_Lucro,wQtd_Pontos_Inventario,wQtd_Pontos_Perm,wQtd_Pontos_Preventiva_CRE,wQtd_Pontos_ValeT,
						wQtd_Pontos_produt,wQtd_Pontos_Folha,PI_CODREDE,2,r_pontuacao_regioes.REGIAO,wQtd_Pontos_turn,SUBSTR(PI_DATA_REF,7,4),PI_DATA_REF,wPontosMargemPerc,wMargem_Percentual,wPontosCresc);
                    end;
	 	        END IF;
	   	        CLOSE c_apr;

	    END;
	 	FETCH c_pontuacao_regioes INTO r_pontuacao_regioes;
	 	END LOOP;
	 	CLOSE c_pontuacao_regioes;

 COMMIT;

  /*      OPEN c_nome_unidades;
		FETCH c_nome_unidades INTO r_nome_unidades;
		WHILE c_nome_unidades%FOUND LOOP
		BEGIN
            update GRZ_DADOS_CALCULO_APR_ANUAL set des_nome = (select des_nome from ge_unidades where cod_emp = 1 and cod_unidade =r_nome_unidades.cod_unidade)
			        where cod_unidade =r_nome_unidades.cod_unidade
					AND ano = PI_ANO;
        END;
	 	FETCH c_nome_unidades INTO r_nome_unidades;
	 	END LOOP;
	 	CLOSE c_nome_unidades;

	commit;*/

END;
END GRZ_REGIOES_APR_ANUAL_SP;






