CREATE OR REPLACE PROCEDURE NL.GRZW_REL_QUADRO_LOJAS_SP(PI_OPCAO IN VARCHAR2) IS
BEGIN
  DECLARE
    /**** Parametros de entrada ****/
    pi_emp           NUMBER;
    pi_grupo         NUMBER;
    pi_uni_ini       NUMBER;
    pi_uni_fim       NUMBER;
    pi_data_ini      DATE;
    pi_data_fim      DATE;
    pi_usuario       VARCHAR2(50);
    pi_produtividade NUMBER;

    v_result integer;
    v_cur    integer;

    /**** Variaveis de trabalho ****/
    wi                   NUMBER;
    wf                   NUMBER;
    wQtdColaboradores220 NUMBER;
    wQtdColaboradores195 NUMBER;
    wQtdColaboradores180 NUMBER;
    wQtdColaboradores165 NUMBER;
    wQtdColaboradores150 NUMBER;
    wQtdColaboradores120 NUMBER;
    wQtdColaboradores110 NUMBER;
    wQtdColaboradores100 NUMBER;
    wTotColaboradores    NUMBER;
    wTotHorasTrab        NUMBER;
    wMesDivisor          NUMBER;
    wProdAtual           NUMBER;
    wHorasPoderiaTer     NUMBER;
    wQtdAprendiz         NUMBER;
    wDes_Quebra          VARCHAR2(50);
    wVenda_Media_Acum    NUMBER(18, 2);
    wQtdPCD              NUMBER;
    wEdicao              VARCHAR2(10);
    wEdicaoPdLaft        VARCHAR2(10);
    wFimdoMes            DATE;
    wVlrLucro            NUMBER(18, 2);
    wHoras_Trab          NUMBER;
    wMediaHorasTrab      NUMBER;
    wVlrCusto            NUMBER;
	wVlrICMS             NUMBER;
    wVlrPIS              NUMBER;
    wVlrCONFINS          NUMBER;
    wVlrDevolucao        NUMBER;
    wVdaLiquida          NUMBER;
    wProdAtualLiq        NUMBER;
    wVlrVendaBrutaAnoAnt NUMBER;
    wPerCresc            NUMBER;
    wQtdTemporarios      NUMBER;
    wQtdAfastados        NUMBER;
    wHorAbertura         VARCHAR2(8);
    wHorFechamento       VARCHAR2(8);
    wDta_Orcamento       DATE;
    wVlrLiqOrc           NUMBER;
    wDataINI             DATE;
    wVlrVdaBrutaOrc      NUMBER;
    wDesp_Pessoal        NUMBER;
    WVLR_HORAS_EXTRAS    NUMBER(18, 2);
    WVLR_VDA_DOMINGOS    NUMBER(18, 2);
	WVLR_BONUS_DOM       NUMBER(18, 2);

    SAIDA EXCEPTION;

    /* Cursor para Buscar os Valores de venda bruta */
    CURSOR c_venda_bruta is
	   --original
      /*select ge.cod_quebra regiao,
               a.cod_unidade,                           
             d.des_fantasia,
             d.dta_cadastro,
             min(a.dta_emissao) new_dta_cadastro,
             sum(oper.vlr_operacao) valor_venda_loja,
			 sum(case when to_char(a.dta_emissao,'d') = 1 then nvl(oper.vlr_operacao,0) else 0 end) vda_domingo
        from ns_notas           a,
             ns_notas_operacoes oper,
             ge_grupos_unidades ge,
             ps_pessoas         d
       where a.num_seq = oper.num_seq
         and a.cod_maquina = oper.cod_maquina
         and a.cod_unidade = ge.cod_unidade
         and ge.cod_grupo = pi_grupo
         and ge.cod_emp = pi_emp
         and a.cod_unidade >= pi_uni_ini
         and a.cod_unidade <= pi_uni_fim
         and a.cod_unidade = d.cod_pessoa
         and a.ind_status = 1
         and a.tip_nota = 4
         and a.dta_emissao between pi_data_ini and pi_data_fim
         and d.ind_inativo = 0
       group by ge.cod_quebra,
                a.cod_unidade,               
                d.des_fantasia,
                d.dta_cadastro
       order by ge.cod_quebra, a.cod_unidade, d.des_fantasia;*/

		
		
        select 
           ge.cod_quebra regiao,
           DECODE(a.cod_unidade,
                  7022, 22, 
                  7047, 47, 
                  7065, 65, 
                  7138, 138,
                  7140, 140,
                  7183, 183,
                  7244, 244,
                  7353, 353,
                  7386, 386,
                  7412, 412,
                  7430, 430,
                  7442, 442,
                  7491, 491,
                  7543, 543,
                  7555, 555,
                  7570, 570,
                  7587, 587,
                  7588, 588,
                  7592, 592,
                  7597, 597,
                  7601, 601,
                  7602, 608,
                  7620, 620,
                  7500, 651,
                  7051, 652,
                  7066, 654,
                  a.cod_unidade) cod_unidade,
           MIN(d.des_fantasia) des_fantasia,  -- usa MIN para "unificar"
           MIN(d.dta_cadastro) dta_cadastro,  -- idem
           MIN(a.dta_emissao) new_dta_cadastro,
           SUM(oper.vlr_operacao) valor_venda_loja,
           SUM(CASE WHEN TO_CHAR(a.dta_emissao, 'd') = 1 THEN NVL(oper.vlr_operacao, 0) ELSE 0 END) vda_domingo
         from NL.ns_notas a
         join NL.ns_notas_operacoes oper on a.num_seq = oper.num_seq and a.cod_maquina = oper.cod_maquina
         join NL.ge_grupos_unidades ge on a.cod_unidade = ge.cod_unidade
         join NL.ps_pessoas d on a.cod_unidade = d.cod_pessoa
         where ge.cod_grupo = pi_grupo
           and ge.cod_emp = pi_emp
           and a.cod_unidade >= pi_uni_ini
           and a.cod_unidade <= pi_uni_fim
           and a.ind_status = 1
           and a.tip_nota = 4
           and a.dta_emissaobetween pi_data_ini and pi_data_fim
           and d.ind_inativo = 0
         group by 
           ge.cod_quebra,
           DECODE(a.cod_unidade,
                  7022, 22, 
                  7047, 47, 
                  7065, 65, 
                  7138, 138,
                  7140, 140,
                  7183, 183,
                  7244, 244,
                  7353, 353,
                  7386, 386,
                  7412, 412,
                  7430, 430,
                  7442, 442,
                  7491, 491,
                  7543, 543,
                  7555, 555,
                  7570, 570,
                  7587, 587,
                  7588, 588,
                  7592, 592,
                  7597, 597,
                  7601, 601,
                  7602, 608,
                  7620, 620,
                  7500, 651,
                  7051, 652,
                  7066, 654,
                  a.cod_unidade)
         order by ge.cod_quebra, cod_unidade, des_fantasia;



    r_venda_bruta c_venda_bruta%ROWTYPE;


      /**** Inicio da procedure principal ****/
  BEGIN
    v_cur := dbms_sql.open_cursor;
    dbms_sql.parse(v_cur,
                   'alter session set nls_date_format= "dd/mm/rrrr"',
                   dbms_sql.native);
    v_result := dbms_sql.execute(v_cur);
    dbms_sql.close_cursor(v_cur);

    /**** Desmembra a opcao recebida ****/
    wi               := INSTR(pi_opcao, '#', 1, 1);
    pi_emp           := TO_NUMBER(SUBSTR(pi_opcao, 1, (wi - 1)));
    wf               := INSTR(pi_opcao, '#', 1, 2);
    pi_grupo         := TO_NUMBER(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)));
    wi               := wf;
    wf               := INSTR(pi_opcao, '#', 1, 3);
    pi_uni_ini       := TO_NUMBER(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)));
    wi               := wf;
    wf               := INSTR(pi_opcao, '#', 1, 4);
    pi_uni_fim       := TO_NUMBER(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)));
    wi               := wf;
    wf               := INSTR(pi_opcao, '#', 1, 5);
    pi_data_ini      := TO_DATE(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)));
    wi               := wf;
    wf               := INSTR(pi_opcao, '#', 1, 6);
    pi_data_fim      := TO_DATE(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)));
    wi               := wf;
    wf               := INSTR(pi_opcao, '#', 1, 7);
    pi_usuario       := SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1));
    wi               := wf;
    wf               := INSTR(pi_opcao, '#', 1, 8);
    pi_produtividade := TO_NUMBER(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)));

    delete from GRZW_REL_ORCAMENTO_RH
     where upper(des_usuario) = upper(pi_usuario);
    commit;

    if pi_grupo = 910 then
      wEdicao := '1';
    elsif pi_grupo = 930 then
      wEdicao := '3';
    elsif pi_grupo = 940 then
      wEdicao := '4';
    elsif pi_grupo = 950 then
      wEdicao := '2';
    elsif pi_grupo = 970 then
      wEdicao := '1,2,3,4,7';
    elsif pi_grupo = 999 then
      wEdicao := '1,2,3,4,7';
    end if;

    wDesp_Pessoal := 0;


    OPEN c_venda_bruta;
    FETCH c_venda_bruta
      INTO r_venda_bruta;
    WHILE c_venda_bruta%FOUND LOOP
      BEGIN
        wVdaLiquida := 0;

        BEGIN
          select des_quebra
            INTO wDes_Quebra
            from ge_grupos_quebra w
           where w.cod_emp = pi_emp
             and w.cod_quebra = substr(pi_grupo, 2, 2)
             and w.cod_grupo = r_venda_bruta.regiao;
        exception
          when no_data_found then
            wDes_Quebra := 'NAO ENCONTRADO';
        END;

        begin
            select round(sum(nvl(a.vlr_realizado, 0)), 2) vlr_realizado
                  ,nvl(max(dta_orcamento),'01/01/2000') dta
              Into wVlrLiqOrc
                  ,wDta_Orcamento
              from or_valores a
             where a.cod_emp = pi_emp
               and a.cod_unidade = r_venda_bruta.cod_unidade
               and a.cod_orcamento = 400
               and a.dta_orcamento >= '01/' || substr(pi_data_ini, 4, 7)
               and a.dta_orcamento <= '01/' || substr(pi_data_fim, 4, 7)
               and a.des_chave = '05#05001'; -- venda liquida
        exception
          when no_data_found then
                   wVlrLiqOrc := 0;
                   wDta_Orcamento := '01/01/2000';
        end;

        if (wDta_Orcamento = '01/01/2000') or (wDta_Orcamento is null) then
           wDataIni := pi_data_ini;
        else
           wDataIni := add_months(wDta_Orcamento,1);
        end if;

        if (wDta_Orcamento < '01/'|| substr(pi_data_fim, 4, 7)) then

        wVlrVdaBrutaOrc := 0;
        begin
            select round(sum(nvl(a.vlr_realizado, 0)), 2) vlr_realizado
              Into wVlrVdaBrutaOrc
              from or_valores a
             where a.cod_emp = pi_emp
               and a.cod_unidade = r_venda_bruta.cod_unidade
               and a.cod_orcamento = 400
               and a.dta_orcamento >= '01/' || substr(pi_data_ini, 4, 7)
               and a.dta_orcamento <= '01/' || substr(pi_data_fim, 4, 7)
               and (a.des_chave =  '01#01001'  -- venda bruta
                or a.des_chave = '01#01003'
                or a.des_chave = '01#01005');
        exception
          when no_data_found then
               wVlrVdaBrutaOrc := 0;
        end;


        begin
            select sum(decode(a.tip_lancamento,2,nvl(a.vlr_medio_emp,0),1,(nvl(a.vlr_medio_emp,0) * -1),0)) vlr_custo
                  ,sum(decode(a.tip_lancamento,2,nvl(a.vlr_icms,0),1,(nvl(a.vlr_icms,0) * -1),0)) vlr_icms
                  ,sum(decode(a.tip_lancamento,2,nvl(d.vlr_pis,0),1,(nvl(a.vlr_pis,0) * -1),0)) vlr_pis
                  ,sum(decode(a.tip_lancamento,2,nvl(d.vlr_cofins,0),1,(nvl(a.vlr_cofins,0) * -1),0)) vlr_cofins
                  ,sum(decode(a.tip_lancamento,1,nvl(a.vlr_total,0),0)) devolucao
              INTO wVlrCusto
                  ,wVlrICMS
                  ,wVlrPIS
                  ,wVlrCONFINS
                  ,wVlrDevolucao
              from nl.ce_diarios a
                  ,nl.t6_oper_quebras o
                  ,nl.ns_itens d
             where a.num_seq        = d.num_seq_ce(+)
	             and a.cod_maquina    = d.cod_maq_ce(+)
             	 and a.cod_oper       = o.cod_oper
               and o.cod_grupo_oper in (7300,7106)
               and a.cod_unidade = r_venda_bruta.cod_unidade
               and a.dta_lancamento >= wDataIni
               and a.dta_lancamento <= pi_data_fim
				       and (EXISTS (SELECT 1 FROM NL.NE_NOTAS NE
                             WHERE NE.NUM_SEQ     = A.NUM_SEQ_NE
                               AND NE.COD_MAQUINA = A.COD_MAQ_NE
														   AND A.TIP_LANCAMENTO = 1
                               AND NE.IND_STATUS  = 1)
                OR EXISTS (SELECT 1 FROM NL.NS_NOTAS NS
                            WHERE NS.NUM_SEQ     = A.NUM_SEQ_NS
                              AND NS.COD_MAQUINA = A.COD_MAQ_NS
													    AND A.TIP_LANCAMENTO = 2
                              AND NS.IND_STATUS  = 1));
        EXCEPTION
	           WHEN NO_DATA_FOUND THEN
	                wVlrCusto   := 0.0;
	                wVlrICMS    := 0.0;
                  wVlrPIS     := 0.0;
                  wVlrCONFINS := 0.0;
                  wVlrDevolucao := 0.0;
        end;

        if r_venda_bruta.valor_venda_loja > 0 then
           wVdaLiquida := (r_venda_bruta.valor_venda_loja - nvl(wVlrVdaBrutaOrc,0)) - nvl(wVlrCusto,0) - nvl(wVlrICMS,0) - nvl(wVlrPIS,0) - nvl(wVlrConfins,0) - nvl(wVlrDevolucao,0);
        else
           wVdaLiquida := 0;
        end if;
        end if;

        wVdaLiquida := nvl(wVdaLiquida,0) + nvl(wVlrLiqOrc,0);


        -- busca venda ano anterior para calcular crescimento
        begin
            select sum(oper.vlr_operacao) valor_venda_loja
              Into wVlrVendaBrutaAnoAnt
              from ns_notas           a,
                   ns_notas_operacoes oper
             where a.num_seq = oper.num_seq
               and a.cod_maquina = oper.cod_maquina
               and a.cod_unidade = r_venda_bruta.cod_unidade
               and a.ind_status = 1
               and a.tip_nota = 4
               and a.dta_emissao between add_months(pi_data_ini,-12) and add_months(pi_data_fim,-12);
          exception
            when no_data_found then
                 wVlrVendaBrutaAnoAnt := 0;
        end;

        if nvl(wVlrVendaBrutaAnoAnt,0) <= 0 then
           wPerCresc := 100;
        elsif r_venda_bruta.valor_venda_loja > 0 then
           wPerCresc := ((r_venda_bruta.valor_venda_loja * 100) / nvl(wVlrVendaBrutaAnoAnt,0)) - 100;
        end if;

        if wPerCresc > 100 then
           wPerCresc := 100;
        end if;


        -- busca o lucro da loja
        /*if pi_grupo = 970 or (r_venda_bruta.cod_unidade = 566) then
          begin
            select round(sum(nvl(a.vlr_realizado, 0)), 2) vlr_realizado
              Into wVlrLucro
              from or_valores a, grz_lojas_unificadas_cia t
             where a.cod_unidade = t.cod_unidade_para
               and t.cod_unidade_de = r_venda_bruta.cod_unidade
               and a.cod_emp = pi_emp
               and a.cod_orcamento = 400
               and a.dta_orcamento >= '01/' || substr(pi_data_ini, 4, 7)
               and a.dta_orcamento <= '01/' || substr(pi_data_fim, 4, 7)
               and a.des_chave = '45#45001'; -- lucro
          exception
            when no_data_found then
              wVlrLucro := 0;
          end;
        else */
          begin
            select round(sum(nvl(a.vlr_realizado, 0)), 2) vlr_realizado
              Into wVlrLucro
              from or_valores a
             where a.cod_emp = pi_emp
               and a.cod_unidade = r_venda_bruta.cod_unidade
               and a.cod_orcamento = 400
               and a.dta_orcamento >= '01/' || substr(pi_data_ini, 4, 7)
               and a.dta_orcamento <= '01/' || substr(pi_data_fim, 4, 7)
               and a.des_chave = '45#45001'; -- lucro
          exception
            when no_data_found then
              wVlrLucro := 0;
          end;
        --end if;

        if (Length(r_venda_bruta.cod_unidade)) <= 3 then
          wEdicaoPdLaft := lpad(to_char(r_venda_bruta.cod_unidade), 3, '0');
        else
          wEdicaoPdLaft := lpad(to_char(r_venda_bruta.cod_unidade), 4, '0');
        end if;

        begin
          select sum(decode(qtd_horbas_mes, 220, 1, 0)) q220,
                 sum(decode(qtd_horbas_mes, 195, 1, 0)) q195,
                 sum(decode(qtd_horbas_mes, 180, 1, 0)) q180,
                 sum(decode(qtd_horbas_mes, 165, 1, 0)) q165,
                 sum(decode(qtd_horbas_mes, 150, 1, 0)) q150,
                 sum(decode(qtd_horbas_mes, 120, 1, 0)) q120,
                 sum(decode(qtd_horbas_mes, 110, 1, 0)) q110,
                 sum(decode(qtd_horbas_mes, 100, 1, 0)) q100,
                 sum(decode(ind_deficiencia, 'S', 0, qtd_horbas_mes)) total,
                 sum(decode(ind_deficiencia, 'S', 0, 1)) total_colaboradores,
                 sum(decode(cod_clh, 204, 1, 0)) qtd_temporarios
            Into wQtdColaboradores220,
                 wQtdColaboradores195,
                 wQtdColaboradores180,
                 wQtdColaboradores165,
                 wQtdColaboradores150,
                 wQtdColaboradores120,
                 wQtdColaboradores110,
                 wQtdColaboradores100,
                 wTotHorasTrab,
                 wTotColaboradores,
                 wQtdTemporarios
            from GRZ_FOLHA.FUNCIONARIOS@NLGZT
           where edicao_filial = wEdicaoPdLaft
             and data_fim is null
             and cod_clh not in (71, 74, 75, 409, 68) -- aprendiz e servente n?o entram
             and status_afastamento in (0, 6, 7, 107) -- 0 padrao / 7 ferias / 107 afastamento temporario
             and (instr(',' || wEdicao || ',', ',' || edicao_nivel3 || ',') > 0);
        exception
          when no_data_found then
            wQtdColaboradores220 := 0;
            wQtdColaboradores195 := 0;
            wQtdColaboradores180 := 0;
            wQtdColaboradores165 := 0;
            wQtdColaboradores150 := 0;
            wQtdColaboradores120 := 0;
            wQtdColaboradores110 := 0;
            wQtdColaboradores100 := 0;
            wTotHorasTrab        := 0;
            wTotColaboradores    := 0;
            wQtdTemporarios      := 0;
        end;

        begin
          select count(1) total_colaboradores
            Into wQtdAfastados
            from GRZ_FOLHA.FUNCIONARIOS@NLGZT
           where edicao_filial = wEdicaoPdLaft
             and data_fim is null
             and cod_clh not in (71, 74, 75, 409, 68) -- aprendiz e servente n?o entram
             and status_afastamento not in (0, 6, 7, 107) -- 0 padrao / 7 ferias / 107 afastamento temporario
             and (instr(',' || wEdicao || ',', ',' || edicao_nivel3 || ',') > 0);
        exception
          when no_data_found then
            wQtdAfastados := 0;

        end;

        begin
          select count(1) total_colaboradores
            Into wQtdAprendiz
            from GRZ_FOLHA.FUNCIONARIOS@NLGZT a
           where edicao_filial = wEdicaoPdLaft
             and data_fim is null
             and cod_clh in (71, 74, 75, 409) -- aprendiz
             and (instr(',' || wEdicao || ',', ',' || edicao_nivel3 || ',') > 0);
        exception
          when no_data_found then
            wQtdAprendiz := 0;

        end;

        begin
          select count(1) total_colaboradores
            Into wQtdPCD
            from GRZ_FOLHA.FUNCIONARIOS@NLGZT a
           where edicao_filial = wEdicaoPdLaft
             and data_fim is null
             and cod_clh not in (71, 74, 75, 409, 68) -- aprendiz e servente n?o entram
             and status_afastamento in (0, 6, 7, 107) -- 0 padrao / 7 ferias / 107 afastamento temporario
             and ind_deficiencia = 'S'
             and (instr(',' || wEdicao || ',', ',' || edicao_nivel3 || ',') > 0);
        exception
          when no_data_found then
            wQtdPCD := 0;

        end;

        begin
          select round(sum(nvl(a.vlr_realizado, 0)), 2) vlr_realizado
            into wHoras_Trab
            from or_valores a
           where a.cod_emp = pi_emp
             and a.cod_unidade = r_venda_bruta.cod_unidade
             and a.cod_orcamento = 901
             and a.dta_orcamento >= '01/' || substr(pi_data_ini, 4, 7)
             and a.dta_orcamento <= '01/' || substr(pi_data_fim, 4, 7)
                --and to_char(a.dta_orcamento,'mm/yyyy') = wDta_Orcamento
             and substr(a.des_chave, 1, 3) = '002';
        exception
          when no_data_found then
            wHoras_Trab := 0;
        end;

        wFimdoMes := last_day(pi_data_fim);
        -- trocada a data para new_dta_cadastro considerando o primeiro dia de venda
        if (trunc(r_venda_bruta.new_dta_cadastro) < pi_data_ini) then
          wMesDivisor := months_between(wFimdoMes, pi_data_ini);
        else
          wMesDivisor := months_between(wFimdoMes,
                                        trunc(r_venda_bruta.new_dta_cadastro));

        end if;

        if wMesDivisor < 1 then
          wVenda_Media_Acum := r_venda_bruta.valor_venda_loja;
        else
          wVenda_Media_Acum := round(r_venda_bruta.valor_venda_loja /
                                     round(wMesDivisor, 0),
                                     2);
        end if;

        -- mudado em 29/03 pq a eronita veio reclamar na apr
        if r_venda_bruta.valor_venda_loja > 0 then
          wProdAtual := r_venda_bruta.valor_venda_loja / wHoras_Trab;
        end if;

        if wVdaLiquida > 0 then
           wProdAtualLiq := wVdaLiquida / wHoras_Trab;
        end if;

        if wVenda_Media_Acum > 0 then
          --calculo produtividade antes de 31/07/2017
          -- voltou em 06/07/2018
          --wProdAtual  := round(wVenda_Media_Acum / wTotHorasTrab,0);
          -- mudado em 29/03 pq a eronita veio reclamar na apr
          --wProdAtual := r_venda_bruta.valor_venda_loja / wHoras_Trab;

          --novo calculo
          -- comentado em 06/07/2018 voltou o calculo acima
          --wMediaHorasTrab := round(wHoras_Trab / round(wMesDivisor,0),0);

          --wProdAtual  := round(wVenda_Media_Acum / wMediaHorasTrab,0);

          wHorasPoderiaTer := round(wVenda_Media_Acum / pi_produtividade, 0);
        else
         -- wProdAtual       := 0;
          wHorasPoderiaTer := 0;
        end if;

        begin
           select substr(hora_ent,1,2)||':'||substr(hora_ent,3,2) entrada
                 ,substr(hora_sai,1,2)||':'||substr(hora_sai,3,2) saida
             Into wHorAbertura,
                  wHorFechamento
             from GRZ_FOLHA.v_Dados_filiais@NLGZT
            where filial = wEdicaoPdLaft
              and cod_seq_jornada = 2;
        exception
          when no_data_found then
            wHorAbertura   := '';
            wHorFechamento := '';

        end;

        begin
        select round(sum(nvl(a.vlr_realizado,0)),2) vlr_realizado
            into wDesp_Pessoal
            from or_valores a
           where a.cod_emp = pi_emp
             and a.cod_unidade = r_venda_bruta.cod_unidade
             and a.cod_orcamento = 400
             and a.dta_orcamento between pi_data_ini and pi_data_fim
             and (a.des_chave = '15#15001'  -- despesas com pessoal
               or a.des_chave = '15#15005'
               or a.des_chave = '15#15010'
               or a.des_chave = '15#15015'
               or a.des_chave = '15#15020'
               or a.des_chave = '15#15025'  -- despesas com vale-transporte
               or a.des_chave = '15#15030'  -- despesas com vale-transporte
               or a.des_chave = '15#15035'
               or a.des_chave = '15#15040'
               or a.des_chave = '15#15045'
               or a.des_chave = '15#15049'
               or a.des_chave = '15#15050'
               or a.des_chave = '15#15055');
           exception
            when no_data_found then
                 wDesp_Pessoal := 0;

           end;

        begin
           SELECT COALESCE(SUM(VLR_HORAS_EXTRAS), 0) AS VLR_HORAS_EXTRAS,
                  COALESCE(SUM(VLR_BONUS_DOM), 0) AS VLR_BONUS_DOM
           INTO WVLR_HORAS_EXTRAS,
		        WVLR_BONUS_DOM
           FROM GRZ_FOLHA.V_VALOR_HORAS_EXTRAS_AVT@GRZFOLHA
           WHERE COD_UNIDADE = r_venda_bruta.cod_unidade
            AND DATA_REFERENCIA BETWEEN pi_data_ini AND pi_data_fim;

           exception
            when no_data_found then
                 WVLR_HORAS_EXTRAS := 0;
				         WVLR_BONUS_DOM := 0;
        end;
       /*
        begin
           select sum(case when to_char(a.dta_emissao,'d') = 1 then nvl(oper.vlr_operacao,0) else 0 end) vda_domingo
           into WVLR_VDA_DOMINGOS
            from ns_notas           a,
                 ns_notas_operacoes oper,
                 ge_grupos_unidades ge,
                 ps_pessoas         d
           where a.num_seq = oper.num_seq
             and a.cod_maquina = oper.cod_maquina
             and a.cod_unidade = ge.cod_unidade
             and ge.cod_grupo = pi_grupo
             and ge.cod_emp = 1
             and a.cod_unidade = r_venda_bruta.cod_unidade
             and a.cod_unidade = d.cod_pessoa
             and a.ind_status = 1
             and a.tip_nota = 4
             and a.dta_emissao between pi_data_ini and pi_data_fim
             and d.ind_inativo = 0
           group by ge.cod_quebra,
                    a.cod_unidade,
                    d.des_fantasia,
                    d.dta_cadastro
           order by ge.cod_quebra, a.cod_unidade, d.des_fantasia;
        end;
         */
        begin
          insert into grzw_rel_orcamento_rh
            (DES_USUARIO,
             COD_GRUPO,
             COD_QUEBRA,
             DES_QUEBRA,
             COD_UNIDADE,
             DES_UNIDADE,
             VENDA_BRUTA,
             VENDA_MEDIA,
             QTD_MES_OPERACAO,
             HORAS_TRAB,
             PROD_LOJA,
             PROD_PODERIA_TER,
             QTD_COLAB_220,
             QTD_COLAB_195,
             QTD_COLAB_180,
             QTD_COLAB_165,
             QTD_COLAB_120,
             QTD_COLAB_110,
             QTD_COLAB_100,
             QTD_COLAB_PCD,
             QTD_APRENDIZ,
             QTD_COLAB_TOT,
             DTA_SISTEMA,
             QTD_COLAB_150,
             VLR_LUCRO,
             HORAS_TRAB_ACUM,
             VENDA_LIQUIDA,
             PROD_LOJA_VDA_LIQ,
             PER_CRESC,
             QTD_TEMPORARIOS,
             QTD_AFASTADOS,
             HOR_ABERTURA,
             HOR_FECHAMENTO,
             DESP_PESSOAL,
             VLR_HORAS_EXTRAS,
             VLR_VDA_DOMINGOS,
			       VLR_BONUS_DOM
             )
          VALUES
            (pi_usuario,
             r_venda_bruta.regiao,
             r_venda_bruta.regiao,
             wDes_Quebra,
			 r_venda_bruta.cod_unidade,             
             r_venda_bruta.des_fantasia,
             r_venda_bruta.valor_venda_loja,
             wVenda_Media_Acum,
             round(wMesDivisor, 0),
             wTotHorasTrab,
             wProdAtual,
             wHorasPoderiaTer,
             wQtdColaboradores220,
             wQtdColaboradores195,
             wQtdColaboradores180,
             wQtdColaboradores165,
             wQtdColaboradores120,
             wQtdColaboradores110,
             wQtdColaboradores100,
             wQtdPCD,
             wQtdAprendiz,
             wTotColaboradores,
             sysdate,
             wQtdColaboradores150,
             wVlrLucro,
             wHoras_Trab,
             wVdaLiquida,
             wProdAtualLiq,
             wPerCresc,
             wQtdTemporarios,
             wQtdAfastados,
             wHorAbertura,
             wHorFechamento,
             wDesp_Pessoal,
             WVLR_HORAS_EXTRAS,
             r_venda_bruta.vda_domingo,
			 WVLR_BONUS_DOM
             );
          commit;
        end;

      END;
      FETCH c_venda_bruta
        INTO r_venda_bruta;
    END LOOP;
    CLOSE c_venda_bruta;

    COMMIT;

  EXCEPTION
    WHEN SAIDA THEN
      NULL;
  END;
END GRZW_REL_QUADRO_LOJAS_SP;
