CREATE OR REPLACE PROCEDURE GRZ_NAO_CONFORMIDADES_INDC_SP(pi_data VARCHAR2)

 IS
BEGIN
  DECLARE

    pi_empresa NUMBER(02);
    --pi_rede                   NUMBER(04) := 70;
    --pi_grupo                  NUMBER(04) := 910;
    wDataMovimento VARCHAR2(10); -- := to_char((sysdate - 60), 'mm/yyyy');
    --wDataMovimento              VARCHAR2(10) := '06/2022';
    --pi_dta_fim               DATE;
    pi_usuario VARCHAR2(50) := 'grz-indices-conformidade';
    pi_uni_ini NUMBER(04) := 000;
    pi_uni_fim NUMBER(04) := 9999;
    wi         NUMBER;
    wf         NUMBER;

    wPer_CuponsCanc           NUMBER(18, 2);
    wPerc_itens_canc          NUMBER(18, 2);
    wSoma_Desc                NUMBER(18, 2);
    wPer_Inventario           NUMBER(18, 2);
    wPer_Inventario_Max       NUMBER(18, 2);
    wPer_Devolucao            NUMBER(18, 2);
    wDesc_F4                  NUMBER(18, 2);
    wPer_Desc_F4              NUMBER(18, 2);
    wPer_Cres_Vda             NUMBER(18);
    wColuna                   NUMBER(1);
    wMesLP                    date;
    wDescricao                VARCHAR2(50);
    wVlr_Falta_invent_distrib NUMBER(18, 2);
    wRank                     NUMBER(3);
    wCup_Canc_rede            NUMBER(18, 2);
    wIte_Canc_Rede            NUMBER(18, 2);
    wF4_Rede                  NUMBER(18, 2);
    wpi_dev_vendas            NUMBER(5, 2);
    wpi_inventario            NUMBER(5, 2);
    wpi_inventario_max        NUMBER(5, 2);
    wpi_inventario_max_loja   NUMBER(5, 2);
    wpi_perda_crediario       NUMBER(5, 2);
    wpi_cupom_canc            NUMBER(5, 2);
    wpi_item_canc             NUMBER(5, 2);
    wpi_desc_f4               NUMBER(5, 2);
    ----------------Bruno-------------------
    wDevolucao_loja       NUMBER(5, 2);
    wInventario_loja      NUMBER(5, 2);
    wPerdas_clientes_loja NUMBER(5, 2);
    wCup_canc_loja        NUMBER(5, 2);
    wIte_canc_loja        NUMBER(5, 2);
    wDesconto_loja        NUMBER(5, 2);
    ----------------Bruno-------------------

    CURSOR c_insereUnidade IS
      select ge.cod_quebra regiao,
             ge.cod_unidade,
             d.des_fantasia,
             cod_emp,
             substr(ge.cod_nivel2, 2, 2) cod_rede
        from ge_grupos_unidades ge, ps_pessoas d
       where ((ge.cod_unidade > 0 and ge.cod_unidade < 2000) or
             (ge.cod_unidade > 7000 and ge.cod_unidade < 8000))
         and d.cod_pessoa = ge.cod_unidade
         and ge.cod_emp = 1
         and ge.cod_grupo in (910, 930, 940, 950, 970)
         and ge.cod_unidade between pi_uni_ini and pi_uni_fim
         and ge.cod_nivel2 in (810, 830, 840, 850, 870)
            --and ge.cod_unidade < 1000
         and d.ind_inativo = 0
         and (d.dta_afastamento is null or
             d.dta_afastamento >= wDataMovimento)
         and not exists
       (select 1
                from grz_lojas_unificadas_cia c
               where c.cod_emp_para = substr(ge.cod_nivel2, 2, 2)
                 and c.cod_unidade_para = ge.cod_unidade)
       order by ge.cod_unidade;
    r_insereUnidade c_insereUnidade%ROWTYPE;

    CURSOR c_unidades IS
      select a.cod_emp,
             a.cod_unidade,
             a.des_fantasia,
             b.cod_quebra as cod_regiao,
             sum(a.vlr_descontos) vlr_descontos,
             sum(nvl(a.vlr_bonus_ret, 0)) vlr_bonus_ret,
             sum(nvl(a.vlr_promo_qtd, 0)) vlr_promo_qtd,
             sum(nvl(a.vlr_desc_func, 0)) vlr_desc_func,
             sum(a.qtd_cupons) qtd_cupons,
             sum(a.qtd_cupons_canc) qtd_cupons_canc,
             sum(a.qtd_itens) qtd_itens,
             sum(a.qtd_itens_canc) qtd_itens_canc,
             sum(a.qtd_cupons_canc_meio_venda) qtd_cupons_canc_meio_venda,
             sum(a.vlr_venda_liq) vlr_venda_liq,
             sum(a.vlr_falta_invent) vlr_falta_invent,
             sum(a.vlr_venda_bruta) vlr_venda_bruta,
             sum(a.vlr_devolucoes) vlr_devolucoes,
             sum(a.vlr_venda_liq_ant) vlr_venda_liq_ant,
             sum(a.vlr_desconto_f4) vlr_desconto_f4,
             --case when wDataMovimento < '01/09/2021' then
             --     case when SUM(A.VLR_COMPROMETIDO_LP) > 0 then round((sum(a.Vlr_Cred_Lp) * 100)/SUM(A.VLR_COMPROMETIDO_LP) ,2) else 0 end
             --else
             sum(nvl(a.per_lp_cred, 0)) crediario -- indice grava calculado nesta coluna
      --end crediario
        from grz_nao_conformidades_valores2 a, ge_grupos_unidades b
       where a.cod_unidade = b.cod_unidade
         and a.cod_emp in (10, 30, 40, 50, 70)
         and a.cod_unidade between pi_uni_ini and pi_uni_fim
         and a.dta_movimento = wDataMovimento
         and b.cod_grupo in (910, 930, 940, 950, 970)
         and not exists
       (select 1
                from grz_lojas_unificadas_cia cia
               where cia.cod_emp_para = a.cod_emp
                 and cia.cod_unidade_para = a.cod_unidade)
       group by a.cod_emp, a.cod_unidade, a.des_fantasia, b.cod_quebra
       ORDER BY a.COD_UNIDADE;
    r_unidades c_unidades%ROWTYPE;

    CURSOR c_regioes IS
      select a.cod_emp,
             b.cod_quebra as cod_regiao,
             sum(a.vlr_descontos) vlr_descontos,
             sum(a.vlr_bonus_ret) vlr_bonus_ret,
             sum(a.vlr_promo_qtd) vlr_promo_qtd,
             sum(a.vlr_desc_func) vlr_desc_func,
             sum(a.qtd_cupons) qtd_cupons,
             sum(a.qtd_cupons_canc) qtd_cupons_canc,
             sum(a.qtd_cupons_canc_meio_venda) qtd_cupons_canc_meio_venda,
             sum(a.qtd_itens) qtd_itens,
             sum(a.qtd_itens_canc) qtd_itens_canc,
             sum(a.vlr_venda_liq) vlr_venda_liq,
             SUM(A.VLR_FALTA_INVENT) VLR_FALTA_INVENT,
             SUM(A.VLR_VENDA_BRUTA) VLR_VENDA_BRUTA,
             SUM(A.VLR_DEVOLUCOES) VLR_DEVOLUCOES,
             SUM(A.VLR_VENDA_LIQ_ANT) VLR_VENDA_LIQ_ANT,
             sum(a.vlr_desconto_f4) vlr_desconto_f4,
             case
               when SUM(A.VLR_COMPROMETIDO_LP) > 0 then
                round((sum(a.Vlr_Cred_Lp) * 100) /
                      SUM(A.VLR_COMPROMETIDO_LP),
                      2)
               else
                0
             end crediario
        from grz_nao_conformidades_valores2 a, ge_grupos_unidades b
       where a.cod_unidade = b.cod_unidade
         and a.cod_emp in (10, 30, 40, 50, 70)
         and a.cod_unidade between pi_uni_ini and pi_uni_fim
         and a.dta_movimento = wDataMovimento
         and b.cod_grupo in (910, 930, 940, 950, 970)
       group by a.cod_emp, b.cod_quebra
       ORDER BY b.cod_quebra;
    R_regioes c_regioes%ROWTYPE;

    CURSOR c_rede IS
      select a.cod_emp,
             sum(a.vlr_descontos) vlr_descontos,
             sum(a.vlr_bonus_ret) vlr_bonus_ret,
             sum(a.vlr_promo_qtd) vlr_promo_qtd,
             sum(a.vlr_desc_func) vlr_desc_func,
             sum(a.qtd_cupons) qtd_cupons,
             sum(a.qtd_cupons_canc) qtd_cupons_canc,
             sum(a.qtd_cupons_canc_meio_venda) qtd_cupons_canc_meio_venda,
             sum(a.qtd_itens) qtd_itens,
             sum(a.qtd_itens_canc) qtd_itens_canc,
             sum(a.vlr_venda_liq) vlr_venda_liq,
             SUM(A.VLR_FALTA_INVENT) VLR_FALTA_INVENT,
             SUM(A.VLR_VENDA_BRUTA) VLR_VENDA_BRUTA,
             SUM(A.VLR_DEVOLUCOES) VLR_DEVOLUCOES,
             SUM(A.VLR_VENDA_LIQ_ANT) VLR_VENDA_LIQ_ANT,
             sum(a.vlr_desconto_f4) vlr_desconto_f4,
             case
               when SUM(A.VLR_COMPROMETIDO_LP) > 0 then
                round((sum(a.Vlr_Cred_Lp) * 100) /
                      SUM(A.VLR_COMPROMETIDO_LP),
                      2)
               else
                0
             end crediario
        from grz_nao_conformidades_valores2 a
       where a.cod_emp in (10, 30, 40, 50, 70)
         and a.cod_unidade between pi_uni_ini and pi_uni_fim
         and a.dta_movimento = wDataMovimento
       group by a.cod_emp;
    r_rede c_rede%ROWTYPE;

  begin

    wDataMovimento := to_date((pi_data), 'dd/mm/yyyy');

    /**** Limpa a tabela temporaria ****/
    DELETE FROM sislogweb.GRZ_NAO_CONFORMIDADES_INDICES
     WHERE DTA_MOVIMENTO = wDataMovimento;
    COMMIT;

    /*insere as unidades*/
    open c_insereUnidade;
    fetch c_insereUnidade
      into r_insereUnidade;
    while c_insereUnidade%found loop
      begin

        begin
          select inventario_max
            into wpi_inventario_max
            from grz_nao_conformidades_param
           where rede = r_insereUnidade.cod_rede
             and ano = substr(wDataMovimento, 7, 4);
		EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 wpi_inventario_max := 0;
        end;

        Begin
          wPer_Inventario_Max := wpi_inventario_max;
        end;

        INSERT INTO sislogweb.GRZ_NAO_CONFORMIDADES_INDICES
          (COD_EMP,
           COD_UNIDADE,
           DES_FANTASIA,
           COD_REGIAO,
           DTA_MOVIMENTO,
           CUP_CANC,
           CUP_CANC_ACUMULADO,
           ITE_CANC,
           ITE_CANC_ACUMULADO,
           F4,
           F4_ACUMULADO,
           DES_USUARIO,
           TIPO_UNIDADE,
           INVENT,
           INVENT_ACUMULADO,
           DEVOL,
           DEVOL_ACUMULADO,
           CRES,
           CRES_ACUMULADO,
           CREDIARIO,
           CREDIARIO_ACUMULADO,
           RANK,
           IND_REDE,
           INVENT_MAX)
        VALUES
          (r_insereUnidade.cod_rede,
           r_insereUnidade.cod_unidade,
           r_insereUnidade.des_fantasia,
           r_insereUnidade.regiao,
           wDataMovimento,
           0,
           0,
           0,
           0,
           0,
           0,
           pi_usuario,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           wPer_Inventario_Max);

        commit;
      end;
      fetch c_insereUnidade
        into r_insereUnidade;
    end loop;
    close c_insereUnidade;

    --WHILE wDataMovimento <= pi_dta_fim LOOP

    /*valores por regioes*/
    open c_regioes;
    fetch c_regioes
      into r_regioes;
    while c_regioes%found loop
      begin

        wPer_CuponsCanc  := 0;
        wPerc_itens_canc := 0;
        wSoma_Desc       := 0;
        wDesc_F4         := 0;
        wPer_Desc_F4     := 0;
        wPer_Inventario  := 0;
        wPer_Devolucao   := 0;
        wPer_Cres_Vda    := 0;

        begin
          select dev_vendas,
                 inventario,
                 crediario,
                 cupom_canc,
                 item_canc,
                 desc_F4,
                 inventario_max
            into wpi_dev_vendas,
                 wpi_inventario,
                 wpi_perda_crediario,
                 wpi_cupom_canc,
                 wpi_item_canc,
                 wpi_desc_f4,
                 wpi_inventario_max
            from grz_nao_conformidades_param
           where rede = r_regioes.cod_emp
             and ano = substr(wDataMovimento, 7, 4);
        end;

        Begin
          wPer_CuponsCanc := ((r_regioes.QTD_CUPONS_CANC * 100) /
                             (r_regioes.QTD_CUPONS +
                             r_regioes.qtd_cupons_canc_meio_venda));
        exception
          when zero_divide then
            wPer_CuponsCanc := 0;
        end;
        Begin
          wPerc_itens_canc := (r_regioes.QTD_ITENS_CANC * 100) /
                              r_regioes.QTD_ITENS;
        exception
          when zero_divide then
            wPerc_itens_canc := 0;
        end;
        wSoma_Desc := (r_regioes.VLR_PROMO_QTD + r_regioes.VLR_BONUS_RET +
                      r_regioes.VLR_DESC_FUNC);
        --wDesc_F4   := (r_regioes.VLR_DESCONTOS - wSoma_Desc);
        wDesc_F4 := r_regioes.vlr_desconto_f4;

        if wDesc_F4 < 0 then
          wDesc_F4 := 0;
        end if;

        Begin
          wPer_Desc_F4 := ROUND((wDesc_F4 * 100) / ((r_regioes.VLR_VENDA_BRUTA -
                                r_regioes.VLR_DEVOLUCOES) +
                                r_regioes.VLR_DESCONTOS),
                                2);
        exception
          when zero_divide then
            wPer_Desc_F4 := 0;
        end;
        Begin
          wPer_Inventario := (r_regioes.VLR_FALTA_INVENT * 100) /
                             r_regioes.VLR_VENDA_LIQ;
        exception
          when zero_divide then
            wPer_Inventario := 0;
        end;
        Begin
          wPer_Devolucao := (r_regioes.VLR_DEVOLUCOES * 100) /
                            r_regioes.VLR_VENDA_BRUTA;
        exception
          when zero_divide then
            wPer_Devolucao := 0;
        end;
        Begin
          wPer_Cres_Vda := ROUND(((r_regioes.VLR_VENDA_LIQ -
                                 r_regioes.VLR_VENDA_LIQ_ANT) * 100) /
                                 r_regioes.VLR_VENDA_LIQ_ANT);
        exception
          when zero_divide then
            wPer_Cres_Vda := 0;
        end;
        Begin
          wPer_Inventario_Max := wpi_inventario_max;
        end;

        Begin
          SELECT des_quebra
            Into wDescricao
            FROM GE_GRUPOS_QUEBRA
           WHERE COD_EMP = 1
             AND COD_GRUPO = '9' || r_regioes.cod_emp
             and COD_QUEBRA = r_regioes.cod_regiao;
        End;

        --if wColuna = 1 then
        INSERT INTO sislogweb.GRZ_NAO_CONFORMIDADES_INDICES
          (COD_EMP,
           COD_UNIDADE,
           DES_FANTASIA,
           COD_REGIAO,
           DTA_MOVIMENTO,
           CUP_CANC,
           CUP_CANC_ACUMULADO,
           ITE_CANC,
           ITE_CANC_ACUMULADO,
           F4,
           F4_ACUMULADO,
           DES_USUARIO,
           TIPO_UNIDADE,
           INVENT,
           INVENT_ACUMULADO,
           DEVOL,
           DEVOL_ACUMULADO,
           CRES,
           CRES_ACUMULADO,
           CREDIARIO,
           CREDIARIO_ACUMULADO,
           RANK,
           IND_REDE,
           INVENT_MAX)
        VALUES
          (r_regioes.cod_emp,
           r_regioes.cod_regiao,
           wDescricao,
           r_regioes.cod_regiao,
           wDataMovimento,
           wPer_CuponsCanc,
           0,
           wPerc_itens_canc,
           0,
           wPer_Desc_F4,
           0,
           pi_usuario,
           1,
           wPer_Inventario,
           0,
           wPer_Devolucao,
           0,
           wPer_Cres_Vda,
           0,
           r_regioes.crediario,
           0,
           2,
           0,
           wPer_Inventario_Max);
        COMMIT;

      end;
      fetch c_regioes
        into r_regioes;
    end loop;
    close c_regioes;

    /* monta valores por rede*/
    open c_rede;
    fetch c_rede
      into r_rede;
    while c_rede%found loop
      begin

        wPer_CuponsCanc     := 0;
        wPerc_itens_canc    := 0;
        wSoma_Desc          := 0;
        wDesc_F4            := 0;
        wPer_Desc_F4        := 0;
        wPer_Inventario     := 0;
        wPer_Devolucao      := 0;
        wPer_Cres_Vda       := 0;
        wpi_dev_vendas      := 0;
        wpi_inventario      := 0;
        wpi_perda_crediario := 0;
        wpi_cupom_canc      := 0;
        wpi_item_canc       := 0;
        wpi_desc_f4         := 0;

        begin
          select dev_vendas,
                 inventario,
                 crediario,
                 cupom_canc,
                 item_canc,
                 desc_F4,
                 inventario_max
            into wpi_dev_vendas,
                 wpi_inventario,
                 wpi_perda_crediario,
                 wpi_cupom_canc,
                 wpi_item_canc,
                 wpi_desc_f4,
                 wpi_inventario_max
            from grz_nao_conformidades_param
           where rede = r_rede.cod_emp
             and ano = substr(wDataMovimento, 7, 4);
        end;

        --  Begin wPer_CuponsCanc := (( r_rede.QTD_CUPONS_CANC * 100) / (r_rede.QTD_CUPONS + r_rede.QTD_CUPONS_CANC)); exception when zero_divide then wPer_CuponsCanc:= 0; end;
        Begin
          wPer_CuponsCanc := wpi_cupom_canc;
        end;
        --  Begin wPerc_itens_canc:= (r_rede.QTD_ITENS_CANC * 100) / r_rede.QTD_ITENS; exception when zero_divide then wPerc_itens_canc:= 0; end;
        Begin
          wPerc_itens_canc := wpi_item_canc;
        end;
        wSoma_Desc := (r_rede.VLR_PROMO_QTD + r_rede.VLR_BONUS_RET +
                      r_rede.VLR_DESC_FUNC);
        --wDesc_F4   := (r_rede.VLR_DESCONTOS - wSoma_Desc);
        wDesc_F4 := r_rede.vlr_desconto_f4;
        -- Begin wPer_Desc_F4  := ROUND((wDesc_F4 * 100) / ((r_rede.VLR_VENDA_BRUTA - r_rede.VLR_DEVOLUCOES)+ r_rede.VLR_DESCONTOS ),1); exception when zero_divide then wPer_Desc_F4:= 0; end;
        Begin
          wPer_Desc_F4 := wpi_desc_f4;
        end;
        --  Begin wPer_Inventario := ((r_rede.VLR_FALTA_INVENT + wVlr_Falta_invent_distrib) * 100)/ r_rede.VLR_VENDA_LIQ; exception when zero_divide then wPer_Inventario:= 0; end;
        Begin
          wPer_Inventario := wpi_inventario;
        end;
        Begin
          wPer_Inventario_Max := wpi_inventario_max;
        end;
        Begin
          wPer_Devolucao := wpi_dev_vendas;
        end;
        --Begin wPer_Devolucao := (r_rede.VLR_DEVOLUCOES * 100)/ r_rede.VLR_VENDA_BRUTA; exception when zero_divide then wPer_Devolucao:= 0; end;
        Begin
          wPer_Cres_Vda := ROUND(((r_rede.VLR_VENDA_LIQ -
                                 r_rede.VLR_VENDA_LIQ_ANT) * 100) /
                                 r_rede.VLR_VENDA_LIQ_ANT);
        exception
          when zero_divide then
            wPer_Cres_Vda := 0;
        end;

        IF r_rede.cod_emp = 10 THEN
          wDescricao := 'REDE GRAZZIOTIN';
        END IF;
        IF r_rede.cod_emp = 30 THEN
          wDescricao := 'REDE POR MENOS';
        END IF;
        IF r_rede.cod_emp = 40 THEN
          wDescricao := 'REDE FRANCO GIORGI';
        END IF;
        IF r_rede.cod_emp = 50 THEN
          wDescricao := 'REDE TOTTAL';
        END IF;
        IF r_rede.cod_emp = 70 THEN
          wDescricao := 'REDE UNIFICADA';
        END IF;

        --if wColuna = 1 then
        INSERT INTO sislogweb.GRZ_NAO_CONFORMIDADES_INDICES
          (COD_EMP,
           COD_UNIDADE,
           DES_FANTASIA,
           COD_REGIAO,
           DTA_MOVIMENTO,
           CUP_CANC,
           CUP_CANC_ACUMULADO,
           ITE_CANC,
           ITE_CANC_ACUMULADO,
           F4,
           F4_ACUMULADO,
           DES_USUARIO,
           TIPO_UNIDADE,
           INVENT,
           INVENT_ACUMULADO,
           DEVOL,
           DEVOL_ACUMULADO,
           CRES,
           CRES_ACUMULADO,
           CREDIARIO,
           CREDIARIO_ACUMULADO,
           RANK,
           IND_REDE,
           INVENT_MAX)
        VALUES
          (r_rede.cod_emp,
           '999', -- '9'||r_rede.cod_emp,
           wDescricao,
           '9' || r_rede.cod_emp,
           wDataMovimento,
           wPer_CuponsCanc,
           0,
           wPerc_itens_canc,
           0,
           wPer_Desc_F4,
           0,
           pi_usuario,
           2,
           wPer_Inventario,
           0,
           wPer_Devolucao,
           0,
           wPer_Cres_Vda,
           0,
           wpi_perda_crediario,
           0,
           2,
           1,
           wPer_Inventario_Max);

        COMMIT;

      end;
      fetch c_rede
        into r_rede;
    end loop;
    close c_rede;

    /* monta valores por loja*/
    open c_unidades;
    fetch c_unidades
      into r_unidades;
    while c_unidades%found loop
      begin

        wPer_CuponsCanc       := 0;
        wPerc_itens_canc      := 0;
        wSoma_Desc            := 0;
        wDesc_F4              := 0;
        wPer_Desc_F4          := 0;
        wPer_Inventario       := 0;
        wPer_Devolucao        := 0;
        wPer_Cres_Vda         := 0;
        wDevolucao_loja       := 0;
        wInventario_loja      := 0;
        wPerdas_clientes_loja := 0;
        wCup_canc_loja        := 0;
        wIte_canc_loja        := 0;
        wDesconto_loja        := 0;

        if r_unidades.QTD_CUPONS > 0 then
          Begin
            wPer_CuponsCanc := ((r_unidades.QTD_CUPONS_CANC * 100) /
                               (r_unidades.QTD_CUPONS +
                               r_unidades.qtd_cupons_canc_meio_venda));
          exception
            when zero_divide then
              wPer_CuponsCanc := 0;
          end;
        end if;
        Begin
          wPerc_itens_canc := (r_unidades.QTD_ITENS_CANC * 100) /
                              r_unidades.QTD_ITENS;
        exception
          when zero_divide then
            wPerc_itens_canc := 0;
        end;
        wSoma_Desc := (r_unidades.VLR_PROMO_QTD + r_unidades.VLR_BONUS_RET +
                      r_unidades.VLR_DESC_FUNC);
        wDesc_F4   := r_unidades.vlr_desconto_f4;
        --wDesc_F4   := (r_unidades.VLR_DESCONTOS - wSoma_Desc);

        if wDesc_F4 < 0 then
          wDesc_F4 := 0;
        end if;

        Begin
          wPer_Desc_F4 := ROUND((wDesc_F4 * 100) /
                                ((r_unidades.VLR_VENDA_BRUTA -
                                r_unidades.VLR_DEVOLUCOES) +
                                r_unidades.VLR_DESCONTOS),
                                2);
        exception
          when zero_divide then
            wPer_Desc_F4 := 0;
        end;
        Begin
          wPer_Inventario := (r_unidades.VLR_FALTA_INVENT * 100) /
                             r_unidades.VLR_VENDA_LIQ;
        exception
          when zero_divide then
            wPer_Inventario := 0;
        end;
        Begin
          wPer_Devolucao := (r_unidades.VLR_DEVOLUCOES * 100) /
                            r_unidades.VLR_VENDA_BRUTA;
        exception
          when zero_divide then
            wPer_Devolucao := 0;
        end;
        if r_unidades.VLR_VENDA_LIQ > 0 then
          Begin
            wPer_Cres_Vda := ROUND(((r_unidades.VLR_VENDA_LIQ -
                                   r_unidades.VLR_VENDA_LIQ_ANT) * 100) /
                                   r_unidades.VLR_VENDA_LIQ_ANT);
          exception
            when zero_divide then
              wPer_Cres_Vda := 0;
          end;
        end if;

        --olhar essa parte com o KlÃ©ber
        begin
          select devolucao,
                 inventario,
                 perdas_clientes,
                 cup_canc,
                 ite_canc,
                 desconto,
                 inventario_max
            into wDevolucao_loja,
                 wInventario_loja,
                 wPerdas_clientes_loja,
                 wCup_canc_loja,
                 wIte_canc_loja,
                 wDesconto_loja,
                 wpi_inventario_max_loja
            from sislogweb.Grz_Ind_Conformidades
           where cod_unidade = r_unidades.cod_unidade;
        exception
          when no_data_found then
            wDevolucao_loja := 999;
        end;

        if (wDevolucao_loja <> 999) then
          --if wColuna = 1 then
          update sislogweb.GRZ_NAO_CONFORMIDADES_INDICES
             set CUP_CANC  = wCup_canc_loja,
                 ITE_CANC  = wIte_canc_loja,
                 F4        = wDesconto_loja,
                 INVENT    = wInventario_loja,
                 DEVOL     = wDevolucao_loja,
                 CRES      = wPerdas_clientes_loja,
                 CREDIARIO = r_unidades.CREDIARIO
           where cod_emp = r_unidades.cod_emp
             and cod_unidade = r_unidades.cod_unidade
             and cod_regiao = r_unidades.cod_regiao
             and DTA_MOVIMENTO = wDataMovimento
             and tipo_unidade = 0;
          COMMIT;

          wRank := 0;
          --Devolucao de vendas
          if wPer_Devolucao > wDevolucao_loja then
            wRank := wRank + 1;
          end if;
          --inventario
          if (wPer_Inventario < wInventario_loja) or
             (wPer_Inventario > wpi_inventario_max_loja) then
            wRank := wRank + 1;
          end if;
          --CUPONS CANCELADOS
          if wPer_CuponsCanc > wCup_canc_loja then
            wRank := wRank + 1;
          end if;
          --itens CANCELADOS
          if wPerc_itens_canc > wIte_canc_loja then
            wRank := wRank + 1;
          end if;
          --F4
          if wPer_Desc_F4 > wDesconto_loja then
            wRank := wRank + 1;
          end if;
          --CREDIARIO
          if r_unidades.CREDIARIO > wPerdas_clientes_loja then
            wRank := wRank + 1;
          end if;
          --end if;
        else
          --if wColuna = 1 then
          update sislogweb.GRZ_NAO_CONFORMIDADES_INDICES
             set CUP_CANC  = wPer_CuponsCanc,
                 ITE_CANC  = wPerc_itens_canc,
                 F4        = wPer_Desc_F4,
                 INVENT    = wPer_Inventario,
                 DEVOL     = wPer_Devolucao,
                 CRES      = wPer_Cres_Vda,
                 CREDIARIO = r_unidades.CREDIARIO
           where cod_emp = r_unidades.cod_emp
             and cod_unidade = r_unidades.cod_unidade
             and cod_regiao = r_unidades.cod_regiao
             and DTA_MOVIMENTO = wDataMovimento
             and tipo_unidade = 0;
          COMMIT;

          begin
            select cup_canc,
                   ite_canc,
                   f4,
                   devol,
                   invent,
                   crediario,
                   invent_max
              into wCup_Canc_rede,
                   wIte_Canc_Rede,
                   wF4_Rede,
                   wpi_dev_vendas,
                   wpi_inventario,
                   wpi_perda_crediario,
                   wpi_inventario_max
              from sislogweb.GRZ_NAO_CONFORMIDADES_INDICES
             where DTA_MOVIMENTO = wDataMovimento
               and cod_emp = r_unidades.cod_emp
               and tipo_unidade = 2;
          end;

          wRank := 0;
          --Devolucao de vendas
          if wPer_Devolucao > wpi_dev_vendas then
            wRank := wRank + 1;
          end if;
          --inventario
          if (wPer_Inventario < wpi_inventario) or
             (wPer_Inventario > wpi_inventario_max) then
            wRank := wRank + 1;
          end if;
          --CUPONS CANCELADOS
          if wPer_CuponsCanc > wCup_Canc_rede then
            wRank := wRank + 1;
          end if;
          --itens CANCELADOS
          if wPerc_itens_canc > wIte_Canc_Rede then
            wRank := wRank + 1;
          end if;
          --F4
          if wPer_Desc_F4 > wF4_Rede then
            wRank := wRank + 1;
          end if;
          --CREDIARIO
          if r_unidades.CREDIARIO > wpi_perda_crediario then
            wRank := wRank + 1;
          end if;
          --end if;
        end if;

        update sislogweb.GRZ_NAO_CONFORMIDADES_INDICES
           set CUP_CANC  = wPer_CuponsCanc,
               ITE_CANC  = wPerc_itens_canc,
               F4        = wPer_Desc_F4,
               INVENT    = wPer_Inventario,
               DEVOL     = wPer_Devolucao,
               CRES      = wPer_Cres_Vda,
               CREDIARIO = r_unidades.CREDIARIO,
               rank      = wRank
         where cod_emp = r_unidades.cod_emp
           and cod_unidade = r_unidades.cod_unidade
           and cod_regiao = r_unidades.cod_regiao
           and DTA_MOVIMENTO = wDataMovimento
           and tipo_unidade = 0;

        COMMIT;

      end;
      fetch c_unidades
        into r_unidades;
    end loop;
    close c_unidades;

  END;

END GRZ_NAO_CONFORMIDADES_INDC_SP;
