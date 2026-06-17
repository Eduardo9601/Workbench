CREATE OR REPLACE PROCEDURE GRZ_TREINAMENTO_APR_ANUAL_SP
(PI_OPCAO IN VARCHAR2) IS
BEGIN
DECLARE
 --940#31/03/2016#
	/****par?metros de entrada****/
	PI_CODGRUPO		        NUMBER;
	PI_DATA_REF         DATE;
	PI_REDE             NUMBER;

    wUnidade     NUMBER;
	wG10         NUMBER;
	wTpd         NUMBER;
	wSegPessoa   NUMBER;
	wTrainee     NUMBER;
	wTotal       NUMBER;
	Wi			NUMBER;
	Wf			NUMBER;
	wRegiao   NUMBER;
	wInsereRegiao  NUMBER;
	wRede       varchar2(1);
	wTurnOver   NUMBER(10,2);
	wDemissoes  NUMBER;
	EfetivoINI NUMBER;
	wQtdPontosTurn NUMBER;
  wFilial        VARCHAR2(5);
	v_cur                       INTEGER;
    v_result                    INTEGER;

	CURSOR c_pontuacao_treinamento IS
	SELECT A.COD_UNIDADE,
	       G.DES_NOME,
           A.G10,
		   A.TPD,
		   A.SEG_PESSOA,
		   A.TRAINEE
		FROM GRZ_PONTUACAO_APR_ANO A, GE_GRUPOS_UNIDADES GE,ge_unidades g,ge_grupos_quebra d
                        WHERE A.COD_UNIDADE = GE.COD_UNIDADE
                          AND g.cod_emp = ge.cod_emp
                          AND g.cod_unidade = ge.cod_unidade
                          and d.cod_emp = ge.cod_emp
                          and d.cod_grupo = ge.cod_grupo
                          and d.cod_quebra = ge.cod_quebra
                          AND A.ANO = SUBSTR(PI_DATA_REF,7,4)
                          AND GE.COD_GRUPO  = PI_CODGRUPO
                          AND GE.COD_EMP    = 1
	                      ORDER BY A.COD_UNIDADE;
	r_pontuacao_treinamento c_pontuacao_treinamento%ROWTYPE;

	CURSOR c_pontuacao_regiao IS
	SELECT A.COD_UNIDADE,
	       D.DES_QUEBRA,
           A.G10,
		   A.TPD,
		   A.SEG_PESSOA,
		   A.TRAINEE
		FROM GRZ_PONTUACAO_APR_ANO A,ge_grupos_quebra d
                        WHERE a.cod_unidade = d.cod_quebra
                          AND A.ANO = SUBSTR(PI_DATA_REF,7,4)
                          AND d.COD_GRUPO  = PI_CODGRUPO
	                      ORDER BY A.COD_UNIDADE;
	r_pontuacao_regiao c_pontuacao_regiao%ROWTYPE;

	CURSOR c_apr IS
	  select *
	    from GRZ_DADOS_CALCULO_APR_ANUAL
	   where cod_unidade = wUnidade
             and ano     = SUBSTR(PI_DATA_REF,7,4);
	r_apr c_apr%ROWTYPE;

	CURSOR c_apr_regiao IS
	  select *
	    from GRZ_VALORES_REGIOES_APR_ANUAL
	   where cod_unidade = r_pontuacao_treinamento.cod_unidade
             and ano     = SUBSTR(PI_DATA_REF,7,4);
	r_apr_regiao c_apr_regiao%ROWTYPE;


	CURSOR c_calc IS
	   select * from  grz_cad_calculo_apr_anual
	   where cod_rede = PI_REDE
	   and ano = SUBSTR(PI_DATA_REF,7,4)
	   and cod_calculo in (7)
       order by cod_calculo,qtd_pontos;
    r_calc c_calc%ROWTYPE;

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
	      PI_REDE := TO_NUMBER(SUBSTR(pi_opcao,(wi+1),(wf-wi-1)));



	    OPEN c_pontuacao_treinamento;
		FETCH c_pontuacao_treinamento INTO r_pontuacao_treinamento;
		WHILE c_pontuacao_treinamento%FOUND LOOP
		BEGIN

	    wUnidade   := r_pontuacao_treinamento.COD_UNIDADE;
		wG10       := r_pontuacao_treinamento.G10;
		wTpd       := r_pontuacao_treinamento.TPD;
		wSegPessoa := r_pontuacao_treinamento.SEG_PESSOA;
		wTrainee   := r_pontuacao_treinamento.TRAINEE;

		wTotal := wG10 + wTpd + wSegPessoa;

    if length(wUnidade) < 3 then
       wFilial := to_char(lpad(wUnidade,3,'0'));
    else 
       wFilial := to_char(wUnidade);
    end if;

            BEGIN
			wRegiao := 0;
               select COD_QUEBRA
			   INTO wRegiao
			   from ge_grupos_unidades
			   where cod_unidade = r_pontuacao_treinamento.cod_unidade and cod_grupo in (PI_CODGRUPO);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               wRegiao := 0;
			END;

	/*	IF (PI_CODGRUPO = '940') THEN
	    	wInsereRegiao := SUBSTR(PI_CODGRUPO,1,2)||wRegiao;
		ELSE
		   wInsereRegiao := wRegiao;
		END IF;   */
-- INICIO DO SELECT PARA PEGAR O TURN OVER

IF (PI_REDE = '10') THEN
		wRede := 1;
elsif (PI_REDE = '30') THEN
		wRede := 3;
elsif (PI_REDE = '40') THEN
		wRede := 4;
elsif (PI_REDE = '50') THEN
		wRede := 2;
elsif (PI_REDE = '70') THEN
		wRede := 8;
end if;

BEGIN
	wTurnOver := 0;
	wDemissoes := 0;
	EfetivoINI := 0;

	SELECT
		NVL(ROUND(AVG(NVL(T.TURNOVER, 0)), 2), 0) AS TURNOVER_ANUAL,
		NVL(SUM(NVL(T.DEMITIDOS, 0)), 0)          AS DEMITIDOS_ANO,
		NVL(MAX(T.EFETIVO_INICIAL) KEEP (DENSE_RANK FIRST ORDER BY T.DTA_INI), 0) AS EFETIVO_INICIAL_ANO
	INTO
		wTurnOver,
		wDemissoes,
		EfetivoINI
	FROM GRZ_FOLHA.GRZ_KPI_AVALIACAO_PLR_TB@GRZFOLHA T
	WHERE TRUNC(T.DTA_INI, 'MM') BETWEEN TRUNC(TO_DATE('01/01/' || TO_CHAR(PI_DATA_REF, 'YYYY'), 'DD/MM/YYYY'), 'MM')
	                                AND TRUNC(PI_DATA_REF, 'MM')
	  AND T.COD_UNIDADE = CASE wUnidade
							WHEN 22  THEN 7022
							WHEN 47  THEN 7047
							WHEN 59  THEN 7059
							WHEN 65  THEN 7065
							WHEN 138 THEN 7138
							WHEN 140 THEN 7140
							WHEN 183 THEN 7183
							WHEN 244 THEN 7244
							WHEN 353 THEN 7353
							WHEN 386 THEN 7386
							WHEN 412 THEN 7412
							WHEN 430 THEN 7430
							WHEN 442 THEN 7442
							WHEN 461 THEN 7461
							WHEN 466 THEN 7466
							WHEN 491 THEN 7491
							WHEN 543 THEN 7543
							WHEN 555 THEN 7555
							WHEN 570 THEN 7570
							WHEN 653 THEN 7577
							WHEN 587 THEN 7587
							WHEN 588 THEN 7588
							WHEN 592 THEN 7592
							WHEN 597 THEN 7597
							WHEN 601 THEN 7601
							WHEN 608 THEN 7602
							WHEN 620 THEN 7620
							WHEN 651 THEN 7500
							WHEN 652 THEN 7051
							WHEN 654 THEN 7066
							WHEN 643 THEN 7643
							ELSE wUnidade
						 END
	  AND T.REDE = PI_REDE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		wTurnOver := 0;
		wDemissoes := 0;
		EfetivoINI := 0;
END;

 /*
if wTurnOver < 2.5 then
   wQtdPontosTurn := 2;  antes de buscar nas tabelas era assim
else
    wQtdPontosTurn := 0;
end if;
*/
                     wQtdPontosTurn := 0;
                     OPEN C_CALC;
					 FETCH C_CALC INTO R_CALC;
					 WHILE C_CALC%FOUND LOOP
		             BEGIN
					  if	 r_calc.cod_calculo = 7 then	 ----TURN OVER----
                         if (wTurnOver <= r_calc.valor1) then
      		             wQtdPontosTurn := r_calc.qtd_pontos;
      	                end if;
					  end if;

					 END;
	 	             FETCH C_CALC INTO R_CALC;
					 END LOOP;
					 CLOSE C_CALC;

--FIM DO SELECT PARA PEGAR O TURN OVER

		        OPEN c_apr;
		        FETCH c_apr INTO r_apr;
		        IF c_apr%FOUND THEN
		            BEGIN
   			          update GRZ_DADOS_CALCULO_APR_ANUAL
                                     set TREINAMENTO = wTotal
                                        ,TRAINEE     = wTrainee
										,DES_NOME = r_pontuacao_treinamento.des_nome
										,TIP_UNIDADE = 1
										,COD_REDE = PI_REDE--SUBSTR(PI_CODGRUPO,2,2)
										,REGIAO   =  wRegiao
										,TURN_OVER = wQtdPontosTurn
                                   where cod_unidade = wUnidade
                                     and ano     = SUBSTR(PI_DATA_REF,7,4);
		            END;
                ELSE
                    begin
                        INSERT INTO GRZ_DADOS_CALCULO_APR_ANUAL (COD_UNIDADE,TURN_OVER,TREINAMENTO,TRAINEE,COD_REDE,TIP_UNIDADE,DES_NOME,REGIAO,ANO)
						VALUES (wUnidade,wQtdPontosTurn,wTotal,wTrainee,PI_REDE/*SUBSTR(PI_CODGRUPO,2,2)*/,1,r_pontuacao_treinamento.des_nome,wRegiao,SUBSTR(PI_DATA_REF,7,4));
                    end;
	 	        END IF;
	   	        CLOSE c_apr;
                     COMMIT;
                OPEN c_apr_regiao;
		        FETCH c_apr_regiao INTO r_apr_regiao;
		        IF c_apr_regiao%FOUND THEN
		            BEGIN
   			          update GRZ_VALORES_REGIOES_APR_ANUAL
                                     set TURN_OVER = wTurnOver
									     ,DEMISSOES = wDemissoes
										 ,EFET_INI = EfetivoINI
                                   where cod_unidade = wUnidade
                                     and ano     = SUBSTR(PI_DATA_REF,7,4);
		            END;
                ELSE
                    begin
                        INSERT INTO GRZ_VALORES_REGIOES_APR_ANUAL (COD_UNIDADE,TURN_OVER,DEMISSOES,EFET_INI,ANO)
						VALUES (wUnidade,wTurnOver,wDemissoes,EfetivoINI,SUBSTR(PI_DATA_REF,7,4));
                    end;
	 	        END IF;
	   	        CLOSE c_apr_regiao;
		        COMMIT;
	    END;
	 	FETCH c_pontuacao_treinamento INTO r_pontuacao_treinamento;
	 	END LOOP;
	 	CLOSE c_pontuacao_treinamento;


		OPEN c_pontuacao_regiao;
		FETCH c_pontuacao_regiao INTO r_pontuacao_regiao;
		WHILE c_pontuacao_regiao%FOUND LOOP
		BEGIN

	    wUnidade   := r_pontuacao_regiao.COD_UNIDADE;
		wG10       := r_pontuacao_regiao.G10;
		wTpd       := r_pontuacao_regiao.TPD;
		wSegPessoa := r_pontuacao_regiao.SEG_PESSOA;
		wTrainee   := r_pontuacao_regiao.TRAINEE;

		wTotal := wG10 + wTpd + wSegPessoa;


		OPEN c_apr;
		        FETCH c_apr INTO r_apr;
		        IF c_apr%FOUND THEN
		            BEGIN
   			          update GRZ_DADOS_CALCULO_APR_ANUAL
                                     set TREINAMENTO = wTotal
                                        ,TRAINEE     = wTrainee
										,DES_NOME = r_pontuacao_regiao.des_quebra
										,TIP_UNIDADE = 2
										,REGIAO = wUnidade
										,COD_REDE = PI_REDE--SUBSTR(PI_CODGRUPO,2,2)
										,DATA_REFERENCIA = PI_DATA_REF
                                   where cod_unidade = wUnidade
                                     and ano     = SUBSTR(PI_DATA_REF,7,4);
		            END;
                ELSE
                    begin
                        INSERT INTO GRZ_DADOS_CALCULO_APR_ANUAL (COD_UNIDADE,TREINAMENTO,TRAINEE,COD_REDE,DES_NOME,TIP_UNIDADE,REGIAO,ANO,DATA_REFERENCIA)
						VALUES (wUnidade,wTotal,wTrainee,PI_REDE/*SUBSTR(PI_CODGRUPO,2,2)*/,r_pontuacao_regiao.des_quebra,2,wUnidade,SUBSTR(PI_DATA_REF,7,4),PI_DATA_REF);
                    end;
	 	        END IF;
	   	        CLOSE c_apr;

	    END;
	 	FETCH c_pontuacao_regiao INTO r_pontuacao_regiao;
	 	END LOOP;
	 	CLOSE c_pontuacao_regiao;


	    COMMIT;


END;
END GRZ_TREINAMENTO_APR_ANUAL_SP;



