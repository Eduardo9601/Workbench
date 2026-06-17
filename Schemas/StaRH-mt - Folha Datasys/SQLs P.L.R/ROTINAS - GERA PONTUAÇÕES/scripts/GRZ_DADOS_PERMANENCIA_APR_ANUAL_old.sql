CREATE OR REPLACE PROCEDURE GRZ_PERMANENCIA_APR_ANUAL_SP
(PI_OPCAO IN VARCHAR2) IS

BEGIN
DECLARE
    ---EXEC GRZ_DADOS_ESTOQUE_APR_SP('1#50#850#150#2015#');---
		--1#40#840#150#31/03/2016#
	/****par?metros de entrada****/
	PI_CODEMP		NUMBER;
	PI_CODREDE		VARCHAR2(02);
	PI_CODGRUPO		NUMBER;
	PI_CODMASCARA		NUMBER;
	PI_DATA_REF         DATE;


	Wi			NUMBER;
	Wf			NUMBER;
	wVlrPerm		NUMBER;
	wVlrCustoPerm  		NUMBER;
	wVlrEstMedPerm 		NUMBER;
	wQtd_Pontos_Perm  number;
	wRegiao     NUMBER;
	wInsereRegiao NUMBER;
	v_cur                       INTEGER;
    v_result                    INTEGER;


	SAIDA			EXCEPTION;

	/****cursor do total por unidade****/
	CURSOR c_totais_unidades IS
	 SELECT ge.cod_quebra regiao,ge.cod_unidade,g.des_nome
		                  FROM GE_GRUPOS_UNIDADES GE,ge_unidades g,ge_grupos_quebra d
                        WHERE  g.cod_emp = ge.cod_emp
                          AND g.cod_unidade = ge.cod_unidade
                          and d.cod_emp = ge.cod_emp
                          and d.cod_grupo = ge.cod_grupo
                          and d.cod_quebra = ge.cod_quebra
                          AND GE.COD_GRUPO  = PI_CODGRUPO
                          AND GE.COD_EMP    = 1
						  and ge.cod_unidade between 000 and 9999
                          order by ge.cod_unidade;
	r_totais_unidades c_totais_unidades%ROWTYPE;


	/****cursor dos totais p/calc. permanencia****/
	CURSOR c_totais IS
	  select SUM(NVL(A.VLR_CUSTO,0)) VLR_CUSTO_PERM
		,SUM(NVL(A.VLR_ESTOQUE_ANT,0)+NVL(A.VLR_MEDIO_EMP,0)) VLR_EST_MEDIO_PERM
	   From es_0124_ce_estmedio a
               ,ie_mascaras b
               ,ie_itens c
	  Where c.cod_item    = a.cod_item
            and c.ind_avulso  = 0
            and b.cod_item    = a.cod_item
	    and b.cod_mascara = PI_CODMASCARA
	    and b.cod_niv0    = '1'
	    and b.cod_niv1    = PI_CODREDE
	    and a.Cod_Unidade  = r_totais_unidades.cod_unidade
	    and a.dta_mvto    >= '01/'||SUBSTR(ADD_MONTHS(PI_DATA_REF,-11),4,7)
	    and a.dta_mvto    <= PI_DATA_REF;
	r_totais c_totais%ROWTYPE;

	CURSOR c_totais_cia IS
	select SUM(NVL(A.VLR_CUSTO,0)) VLR_CUSTO_PERM
		,SUM(NVL(A.VLR_ESTOQUE_ANT,0)+NVL(A.VLR_MEDIO_EMP,0)) VLR_EST_MEDIO_PERM
	   From es_0124_ce_estmedio a
               ,ie_mascaras b
               ,ie_itens c
               ,grz_lojas_unificadas_cia cia
 	  Where c.cod_item    = a.cod_item
            and c.ind_avulso  = 0
            and b.cod_item    = a.cod_item
            and a.cod_unidade = cia.cod_unidade_para
	    and b.cod_mascara = PI_CODMASCARA
	    and b.cod_niv0    = '1'
	    and b.cod_niv1    = cia.cod_emp_para
	    and a.Cod_Unidade  = cia.cod_unidade_para
        and cia.cod_unidade_de = r_totais_unidades.cod_unidade
	    and a.dta_mvto    >= '01/'||SUBSTR(ADD_MONTHS(PI_DATA_REF,-11),4,7)
	    and a.dta_mvto    <= PI_DATA_REF;
    r_totais_cia c_totais_cia%ROWTYPE;

	/****cursor registro dados APR****/
	CURSOR c_apr IS
	  select *
	    from grz_dados_calculo_apr_anual
	   where cod_unidade = r_totais_unidades.COD_UNIDADE
             and ano   = SUBSTR(PI_DATA_REF,7,4);
	r_apr c_apr%ROWTYPE;

	CURSOR c_apr_regiao IS
	  select *
	    from GRZ_VALORES_REGIOES_APR_ANUAL
	   where cod_unidade = r_totais_unidades.cod_unidade
             and ano     = SUBSTR(PI_DATA_REF,7,4);
	r_apr_regiao c_apr_regiao%ROWTYPE;

	CURSOR c_calc IS
	   select * from  grz_cad_calculo_apr_anual
	   where cod_rede = PI_CODREDE
	   and ano = SUBSTR(PI_DATA_REF,7,4)
	   and cod_calculo in (2)
       order by cod_calculo,qtd_pontos;
    r_calc c_calc%ROWTYPE;

	/*** inicio da procedure principal ***/
	begin
	          v_cur := dbms_sql.open_cursor;
              dbms_sql.parse(v_cur,'alter session set nls_date_format= "dd/mm/rrrr"',dbms_sql.native);
              v_result := dbms_sql.execute(v_cur);
              dbms_sql.close_cursor(v_cur);

              ---EXEC GRZ_DADOS_ESTOQUE_APR_SP('1#50#850#150#01/10/2015#31/12/2015#');---
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
	      PI_CODMASCARA := TO_NUMBER(SUBSTR(pi_opcao,(wi+1),(wf-wi-1)));
	      wi := wf;
	      wf := INSTR(pi_opcao,'#',1,5);
	      PI_DATA_REF := TO_DATE(SUBSTR(pi_opcao,(wi+1),(wf-wi-1)));

		  PI_CODMASCARA := 170;


        /****Abre o cursor****/

	BEGIN
		OPEN c_totais_unidades;
		FETCH c_totais_unidades INTO r_totais_unidades;
		WHILE c_totais_unidades%FOUND LOOP
		BEGIN
		   wVlrCustoPerm      := 0;
	       wVlrEstMedPerm     := 0;


        if PI_CODREDE <> '70' then

		 OPEN c_totais;
		   FETCH c_totais INTO r_totais;
		   IF c_totais%FOUND THEN
		   BEGIN
   			wVlrCustoPerm  := wVlrCustoPerm + r_totais.Vlr_Custo_Perm;
			wVlrEstMedPerm := wVlrEstMedPerm + r_totais.Vlr_Est_Medio_Perm;
		   END;
	 	   END IF;
 		   CLOSE c_totais;

		else

		   OPEN c_totais_cia;
		   FETCH c_totais_cia INTO r_totais_cia;
		   IF c_totais_cia%FOUND THEN
		   BEGIN
   			wVlrCustoPerm  := wVlrCustoPerm + r_totais_cia.Vlr_Custo_Perm;
			wVlrEstMedPerm := wVlrEstMedPerm + r_totais_cia.Vlr_Est_Medio_Perm;
		   END;
	 	   END IF;
	   	   CLOSE c_totais_cia;

        end if;




		If (wVlrEstMedPerm <> 0) and (wVlrCustoPerm  <> 0) then
      	     wVlrPerm := Round(360 / (wVlrCustoPerm /(wVlrEstMedPerm / 365.25)),0);

			 if wVlrPerm > 9999 then
         	 wVlrPerm := 9999;
      	     end if;
   	    else
      	    wVlrPerm := 0;
        end if;

     	if wVlrPerm < 0 then
   	      wVlrPerm := 0;
    	end if;

	/*
	 ----PERMANENCIA---
      if PI_CODREDE = '10' then
        if (wVlrPerm >= 60) and
           (wVlrPerm <= 90) then
        wQtd_Pontos_Perm := 10;
        else
        wQtd_Pontos_Perm := 0;
        end if;
     elsif PI_CODREDE = '30' then
        if (wVlrPerm >= 60) and
           (wVlrPerm <= 90) then
        wQtd_Pontos_Perm := 10;
        else
        wQtd_Pontos_Perm := 0;         assim era feito antes de buscar da tabela os parametros
        end if;
     elsif PI_CODREDE = '40' then
        if (wVlrPerm >= 60) and
           (wVlrPerm <= 90) then
      	wQtd_Pontos_Perm := 10;
        else
      	wQtd_Pontos_Perm := 0;
      	end if;
     elsif PI_CODREDE = '50' then
        if (wVlrPerm>= 60) and
           (wVlrPerm <= 90) then
      	wQtd_Pontos_Perm := 10;
        else
      	wQtd_Pontos_Perm := 0;
      	end if;
     end if; 	*/

	                 wQtd_Pontos_Perm := 0;
                     OPEN C_CALC;
					 FETCH C_CALC INTO R_CALC;
					 WHILE C_CALC%FOUND LOOP
		             BEGIN
					     if	 r_calc.cod_calculo = 2 then   ----PERMANENCIA---
                         if (wVlrPerm >=r_calc.valor1) and
                            (wVlrPerm <=r_calc.valor2) then
      		              wQtd_Pontos_Perm :=r_calc.qtd_pontos;
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
			   where cod_unidade = r_totais_unidades.cod_unidade and cod_grupo = PI_CODGRUPO;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               wRegiao := 0;
			END;


		OPEN c_apr;
	    FETCH c_apr INTO r_apr;
	    IF c_apr%FOUND THEN
	    BEGIN
   	         update grz_dados_calculo_apr_anual
                    set PERMANENCIA  = wQtd_Pontos_Perm
					    ,TIP_UNIDADE  = 1
						,COD_REDE = PI_CODREDE
						,REGIAO = wRegiao
						,DATA_REFERENCIA = PI_DATA_REF
                  where cod_unidade = r_totais_unidades.cod_unidade
					AND ANO   = SUBSTR(PI_DATA_REF,7,4);
            END;
        ELSE
            begin
                 insert into GRZ_DADOS_CALCULO_APR_ANUAL (COD_UNIDADE,PERMANENCIA,COD_REDE,TIP_UNIDADE,REGIAO,ANO,DATA_REFERENCIA)
                                            VALUES (r_totais_unidades.cod_unidade,wQtd_Pontos_Perm,PI_CODREDE,1,wRegiao,SUBSTR(PI_DATA_REF,7,4),PI_DATA_REF);
            end;
        END IF;
	    CLOSE c_apr;

           --cursor que insere os valores para depois cancular a pontuacao da regiao

			OPEN c_apr_regiao;
		     FETCH c_apr_regiao INTO r_apr_regiao;
		     IF c_apr_regiao%FOUND THEN
		     BEGIN
   			      update GRZ_VALORES_REGIOES_APR_ANUAL
                                 set VLR_CUSTO_PERM = wVlrCustoPerm
								     ,VLR_EST_MEDIO_PERM  = wVlrEstMedPerm
                                     ,REGIAO = wRegiao
									 ,COD_REDE = PI_CODREDE
                                 where cod_unidade = r_totais_unidades.cod_unidade
                                 and ano     = SUBSTR(PI_DATA_REF,7,4);
			 END;
             ELSE
             BEGIN
                              insert into GRZ_VALORES_REGIOES_APR_ANUAL (COD_UNIDADE,VLR_CUSTO_PERM,VLR_EST_MEDIO_PERM,REGIAO,COD_REDE,ANO)
                              VALUES (r_totais_unidades.cod_unidade,wVlrCustoPerm,wVlrEstMedPerm,wRegiao,PI_CODREDE,SUBSTR(PI_DATA_REF,7,4));
             END;
             END IF;
	   	     CLOSE c_apr_regiao;


		END;
	 	FETCH c_totais_unidades INTO r_totais_unidades;
	 	END LOOP;
	 	CLOSE c_totais_unidades;
	END;

        COMMIT;

	EXCEPTION
	    WHEN SAIDA THEN
	       NULL;

END;
END GRZ_PERMANENCIA_APR_ANUAL_SP;


