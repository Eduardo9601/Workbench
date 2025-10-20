CREATE OR REPLACE PROCEDURE GRZ_GERA_PEDIDO_TRANSF_COP_EDU (PI_OPCAO in VARCHAR2) IS
BEGIN
  DECLARE

    --variaveis para controle da letra das notas (cod_serie) ex.: 'A01', 'B01'
    wSeq_item      NUMBER := 0;
    wExiste        NUMBER;
    wErro          NUMBER;
    wNum_Pedido    NUMBER;
    wQtd_Ped       NUMBER := 0;
    wQtd_Ped_Itens NUMBER := 0;
    wQtd_Ped_Nao   NUMBER := 0;
    wTabela        VARCHAR2(2000);
    wSqlcode       VARCHAR2(2000);
    wCod_Cliente   NUMBER(07);
    wCod_Desconto  NUMBER(04);
    wCod_Completo  VARCHAR2(50);
    wInd_Alterado  NUMBER(01);
    --wCod_atendente NUMBER(07);
    wi                 NUMBER;
    wf                 NUMBER;
    wItem              NUMBER;
    wLocal             NUMBER;
    wCodOper           NUMBER;
    wCod_UF            VARCHAR2(2);
    pi_cd              number;
    pi_lista           NUMBER;
    pi_UnidadeDestino  number;
    pi_cod_pessoa_forn number;
    pi_num_nota        number;
    pi_data_emissao    date;
    pi_Operacao        number;

    /**** Cursor para ler os pedidos de representantes nao processados ****/
    CURSOR c_notas IS
      select distinct (n.num_nota) num_nota,
                      op.cod_oper,
                      n.num_seq,
                      n.cod_maquina,
                      n.cod_unidade,
                      n.dta_emissao,
                      n.cod_serie
        from ne_notas n, ne_itens i, ce_diarios c, ne_notas_operacoes op
       where n.num_seq = i.num_seq
         and n.cod_maquina = i.cod_maquina
         and n.num_seq = op.num_seq
         and n.cod_maquina = op.cod_maquina
         and i.num_seq_ce = c.num_seq
         and i.cod_maq_ce = c.cod_maquina
         and n.num_nota in (pi_num_nota)
         and n.cod_serie in ('50', '55', '52')
         and n.dta_emissao = pi_data_emissao
         and n.cod_unidade = pi_cd
         and n.cod_pessoa_forn in (pi_cod_pessoa_forn)
         and not exists (select 1
                from grz_controle_pedido_web t
               where t.num_seq = n.num_seq
                 and t.cod_unidade = n.cod_unidade
                 and t.num_nota = n.num_nota
                 and t.cod_serie = n.cod_serie);
    r_notas c_notas%ROWTYPE;

    CURSOR c_pedido_itens IS
      select c.cod_item, c.qtd_lancamento QTD_ITENS
        from ne_notas n, ne_itens i, ce_diarios c
       where n.num_seq = i.num_seq
         and n.cod_maquina = i.cod_maquina
         and i.num_seq_ce = c.num_seq
         and i.cod_maq_ce = c.cod_maquina
         and n.num_seq = r_notas.num_seq
         and n.cod_maquina = r_notas.cod_maquina;
    r_pedido_itens c_pedido_itens%ROWTYPE;

    /**** Inicio da procedure principal ****/
  BEGIN
    --858#50#5493#5491#4805#04/05/2020#

    wi                 := INSTR(pi_opcao, '#', 1, 1);
    pi_cd              := TO_NUMBER(SUBSTR(pi_opcao, 1, (wi - 1)));
    wf                 := INSTR(pi_opcao, '#', 1, 2);
    pi_lista           := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 3);
    pi_cod_pessoa_forn := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 4);
    pi_UnidadeDestino  := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 5);
    pi_num_nota        := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 6);
    pi_data_emissao    := TO_DATE(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)),
                                  'dd/mm/yyyy');
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 7);
    pi_Operacao        := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));

    /**** Abre o cursor das notas ****/
    OPEN c_notas;
    FETCH c_notas
      INTO r_notas;
    WHILE c_notas%FOUND LOOP
      BEGIN
        wErro   := 0;
        wExiste := 1;

        -- Busca o codigo do atendente

        wNum_Pedido := pe_prox_num_ped_sp(1, pi_cd);
        wQtd_Ped    := wQtd_Ped + 1;
        wSeq_item   := 1;

        begin
          update grz_confirmacao_notas_web
             set num_pedido = wNum_Pedido
           where num_seq = r_notas.num_seq
             and cod_maquina = r_notas.cod_maquina;
        end;

        BEGIN
          INSERT INTO AI_PE_PEDIDOS
            (COD_EMP,
             COD_UNIDADE,
             NUM_PEDIDO,
             COD_COMPL,
             DTA_EMISSAO,
             DTA_DIGITACAO,
             DTA_PRECO,
             DTA_VALIDADE,
             TIP_FRETE,
             IND_DESTAQUE_FRETE,
             IND_IMP_ROMANEIO,
             NUM_COPIAS_IMP,
             --COD_ATENDENTE,
             COD_CLIENTE,
             COD_OPER,
             IND_CONSUMIDOR,
             IND_REJEITADA,
             COD_SITUACAO,
             COD_LISTA,
             IND_DEPOSITO,
             COD_SITUACAO_ORIG,
             IND_MERC_ENTREGUE,
             NUM_PRIORIDADE_EMBARQUE,
             IND_EMBARQUE,
             IND_MANUTENCAO,
             IND_VENDA,
             IND_ALTERACAO,
             IND_EMISSAO_NF,
             dta_transacao,
             tip_transacao,
             tip_status_transacao)
          VALUES
            (1,
             pi_cd,
             wNum_Pedido,
             3,
             sysdate,
             sysdate,
             sysdate,
             sysdate + 30,
             1,
             1,
             0,
             0,
             --             wCod_atendente,
             pi_UnidadeDestino,
             pi_Operacao,
             0,
             0,
             1,
             pi_lista,
             0,
             1,
             0,
             0,
             1,
             0,
             0,
             0,
             0,
             sysdate,
             1,
             1);
        EXCEPTION
          WHEN OTHERS THEN
            wErro    := 1;
            wTabela  := 'AI_PE_PEDIDOS -' || ' Registro: ' ||
                        r_notas.COD_UNIDADE || '-' || r_notas.NUM_SEQ || '-' ||
                        r_notas.COD_UNIDADE;
            wSqlcode := SQLCODE || '-' || substr(SQLERRM, 1, 2000);
            salva_wpesquisa('GZT_Repres',
                            -1,
                            'Erro: ' || wTabela || '. SQLCODE: ' ||
                            wSqlcode,
                            3);

        END;
        if wErro = 0 then
          /**** Abre o cursor dos itens do pedido ****/
          OPEN c_pedido_itens;
          FETCH c_pedido_itens
            INTO r_pedido_itens;
          WHILE c_pedido_itens%FOUND LOOP
            BEGIN
              if wErro = 0 then
                -- busca valor item
                /*  BEGIN
                          select vlr_item
                            into wItem
                            from lp_precos
                     where cod_emp = 1
                       and cod_lista = pi_lista
                       and cod_item = r_pedido_itens.cod_item
                       and dta_fim is null
                      and rownum <2
                     order by dta_inicio desc;
                       EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                           wItem := 0;
                end; */

                begin
                  select t.cod_uf
                    Into wCod_UF
                    from ps_pessoas a, g1_cidades t
                   where a.cod_cidade = t.cod_cidade
                     and a.cod_pessoa = r_notas.cod_unidade
                     and a.ind_inativo = 0;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    wCod_UF := '';
                end;

                if (wCod_UF = '') or (wCod_UF = 'RS') then
                  -- busca valor item
                  BEGIN
                    select vlr_item
                      into wItem
                      from lp_precos
                     where cod_emp = 1
                       and cod_lista = pi_lista
                       and cod_item = r_pedido_itens.cod_item
                       and dta_fim is null
                       and rownum < 2
                     order by dta_inicio desc;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      wItem := 0;
                  end;

                  wItem := wItem * 0.75;

                else

                  -- alterado em 12/09/2017
                  begin
                    select nvl(Vlr_Ult_Compra, 0.01)
                      into wItem
                      from ce_estoques
                     where cod_emp = 1
                       and cod_unidade = 0
                       and cod_item = r_pedido_itens.cod_item;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      wItem := 0;
                  end;

                  if (wItem <= 0.01) then
                    begin
                      select nvl(vlr_medio_unitario, 0.01)
                        into wItem
                        from ce_estoques
                       where cod_emp = 1
                         and cod_unidade = 0
                         and cod_item = r_pedido_itens.cod_item;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        wItem := 0;
                    end;
                  end if;
                end if;

                if (r_notas.cod_oper = 314) then
                  wLocal := 107500;
				end if;
               /* else
                  wLocal := 107000; --Removido a pedido do fabio
                end if;*/

                wQtd_Ped_Itens := wQtd_Ped_Itens + 1;
                --wItem :=  wItem * 0.75;
                wItem := trunc(wItem, 2);
                BEGIN
                  INSERT INTO AI_PE_ITENS
                    (COD_EMP,
                     COD_UNIDADE,
                     NUM_PEDIDO,
                     COD_COMPL,
                     NUM_ITEM,
                     COD_ITEM,
                     QTD_NEGOCIADA,
                     QTD_ORIGINAL,
                     COD_RESERVA,
                     VLR_UNI_BRUTO,
                     IND_IMPRESSAO_QTD,
                     COD_UNIDADE_RETIRA,
                     COD_LISTA,
                     TIP_PER_REP,
                     TIP_PER_AT,
                     VLR_GARANTIA,
                     IND_RECEITA,
                     IND_ORDEM_COMPRA,
                     TIP_RESERVA_ITEM,
                     TIP_RESERVA_FORCADA,
                     DTH_INCLUSAO_ITEM,
                     dta_transacao,
                     tip_transacao,
                     tip_status_transacao,
                     per_desconto,
                     per_acrescimo,
                     qtd_reservada,
                     ind_vlr_alterado,
                     ind_rejeitada,
                     cod_local)
                  VALUES
                    (1,
                     pi_cd,
                     wNum_Pedido,
                     3,
                     wSeq_item,
                     r_pedido_itens.cod_item,
                     r_pedido_itens.qtd_itens,
                     r_pedido_itens.qtd_itens,
                     19,
                     wItem,
                     1,
                     pi_cd,
                     pi_lista,
                     1,
                     1,
                     0,
                     0,
                     0,
                     1,
                     1,
                     sysdate,
                     sysdate,
                     1,
                     1,
                     0,
                     0,
                     r_pedido_itens.qtd_itens,
                     0,
                     0,
                     wLocal);
                EXCEPTION
                  WHEN OTHERS THEN
                    wErro    := 1;
                    wTabela  := 'AI_PE_ITENS.' || ' Registro: ' ||
                                r_pedido_itens.COD_ITEM;
                    wSqlcode := SQLCODE || '-' || substr(SQLERRM, 1, 2000);
                    salva_wpesquisa('GRZ_cd',
                                    -1,
                                    'Erro: ' || wTabela || '. SQLCODE: ' ||
                                    wSqlcode,
                                    4);

                END;
                wSeq_item := wSeq_item + 1;
              end if;
            END;
            FETCH c_pedido_itens
              INTO r_pedido_itens;
          END LOOP;
          CLOSE c_pedido_itens;
        end if;

        if wErro = 0 then
          begin
            insert into AI_PE_OBSERVACOES
              (COD_EMP,
               COD_UNIDADE,
               NUM_PEDIDO,
               COD_COMPL,
               NUM_SEQ,
               TXT_OBS,
               IND_PEDIDO,
               IND_NF,
               IND_REGISTRO,
               IND_CR,
               DTA_TRANSACAO,
               TIP_TRANSACAO,
               TIP_STATUS_TRANSACAO)
            values
              (1,
               pi_cd,
               wNum_Pedido,
               3,
               0,
               'Referente a nota fiscal ' || r_notas.num_nota || r_notas.cod_unidade,
               1,
               1,
               0,
               0,
               SYSDATE,
               1,
               1);
          exception
            WHEN OTHERS THEN
              wErro    := 1;
              wTabela  := 'PE_OBSERVACOES -' || ' Registro: ';
              wSqlcode := SQLCODE || '-' || substr(SQLERRM, 1, 2000);
          end;

        end if;

        -- else
        wQtd_Ped_Nao := wQtd_Ped_Nao + 1;
        --end if;
        if wErro = 0 then
          BEGIN
            INSERT INTO grz_controle_pedido_web
              (NUM_SEQ, COD_UNIDADE, NUM_NOTA, COD_SERIE, DTA_EMISSAO)
            VALUES
              (r_notas.NUM_SEQ,
               r_notas.COD_UNIDADE,
               r_notas.NUM_NOTA,
               r_notas.COD_SERIE,
               r_notas.dta_emissao);
          END;
          ---AI_NS_GERA_TABELA_SP(1,r_notas.cod_unidade,r_notas.num_cupom,wCod_Serie,wCod_Serie,0,1);
          COMMIT;
        elsif wErro = 1 then
          ROLLBACK;
        else
          ROLLBACK;
        end if;
      END;
      FETCH c_notas
        INTO r_notas;
    END LOOP;
    CLOSE c_notas;

  END;
end GRZ_GERA_PEDIDO_TRANSF_COP_EDU;CREATE OR REPLACE PROCEDURE NL."GRZ_GERA_PEDIDO_TRANSF_SP"(PI_OPCAO in VARCHAR2) IS
BEGIN
  DECLARE

    --variaveis para controle da letra das notas (cod_serie) ex.: 'A01', 'B01'
    wSeq_item      NUMBER := 0;
    wExiste        NUMBER;
    wErro          NUMBER;
    wNum_Pedido    NUMBER;
    wQtd_Ped       NUMBER := 0;
    wQtd_Ped_Itens NUMBER := 0;
    wQtd_Ped_Nao   NUMBER := 0;
    wTabela        VARCHAR2(2000);
    wSqlcode       VARCHAR2(2000);
    wCod_Cliente   NUMBER(07);
    wCod_Desconto  NUMBER(04);
    wCod_Completo  VARCHAR2(50);
    wInd_Alterado  NUMBER(01);
    --wCod_atendente NUMBER(07);
    wi                 NUMBER;
    wf                 NUMBER;
    wItem              NUMBER;
    wLocal             NUMBER;
    wCodOper           NUMBER;
    wCod_UF            VARCHAR2(2);
    pi_cd              number;
    pi_lista           NUMBER;
    pi_UnidadeDestino  number;
    pi_cod_pessoa_forn number;
    pi_num_nota        number;
    pi_data_emissao    date;
    pi_Operacao        number;

    /**** Cursor para ler os pedidos de representantes nao processados ****/
    CURSOR c_notas IS
      select distinct (n.num_nota) num_nota,
                      op.cod_oper,
                      n.num_seq,
                      n.cod_maquina,
                      n.cod_unidade,
                      n.dta_emissao,
                      n.cod_serie
        from ne_notas n, ne_itens i, ce_diarios c, ne_notas_operacoes op
       where n.num_seq = i.num_seq
         and n.cod_maquina = i.cod_maquina
         and n.num_seq = op.num_seq
         and n.cod_maquina = op.cod_maquina
         and i.num_seq_ce = c.num_seq
         and i.cod_maq_ce = c.cod_maquina
         and n.num_nota in (pi_num_nota)
         and n.cod_serie in ('50', '55', '52')
         and n.dta_emissao = pi_data_emissao
         and n.cod_unidade = pi_cd
         and n.cod_pessoa_forn in (pi_cod_pessoa_forn)
         and not exists (select 1
                from grz_controle_pedido_web t
               where t.num_seq = n.num_seq
                 and t.cod_unidade = n.cod_unidade
                 and t.num_nota = n.num_nota
                 and t.cod_serie = n.cod_serie);
    r_notas c_notas%ROWTYPE;

    CURSOR c_pedido_itens IS
      select c.cod_item, c.qtd_lancamento QTD_ITENS
        from ne_notas n, ne_itens i, ce_diarios c
       where n.num_seq = i.num_seq
         and n.cod_maquina = i.cod_maquina
         and i.num_seq_ce = c.num_seq
         and i.cod_maq_ce = c.cod_maquina
         and n.num_seq = r_notas.num_seq
         and n.cod_maquina = r_notas.cod_maquina;
    r_pedido_itens c_pedido_itens%ROWTYPE;

    /**** Inicio da procedure principal ****/
  BEGIN
    --858#50#5493#5491#4805#04/05/2020#

    wi                 := INSTR(pi_opcao, '#', 1, 1);
    pi_cd              := TO_NUMBER(SUBSTR(pi_opcao, 1, (wi - 1)));
    wf                 := INSTR(pi_opcao, '#', 1, 2);
    pi_lista           := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 3);
    pi_cod_pessoa_forn := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 4);
    pi_UnidadeDestino  := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 5);
    pi_num_nota        := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 6);
    pi_data_emissao    := TO_DATE(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)),
                                  'dd/mm/yyyy');
    wi                 := wf;
    wf                 := INSTR(pi_opcao, '#', 1, 7);
    pi_Operacao        := TO_NUMBER(SUBSTR(pi_opcao,
                                           (wi + 1),
                                           (wf - wi - 1)));

    /**** Abre o cursor das notas ****/
    OPEN c_notas;
    FETCH c_notas
      INTO r_notas;
    WHILE c_notas%FOUND LOOP
      BEGIN
        wErro   := 0;
        wExiste := 1;

        -- Busca o codigo do atendente

        wNum_Pedido := pe_prox_num_ped_sp(1, pi_cd);
        wQtd_Ped    := wQtd_Ped + 1;
        wSeq_item   := 1;

        begin
          update grz_confirmacao_notas_web
             set num_pedido = wNum_Pedido
           where num_seq = r_notas.num_seq
             and cod_maquina = r_notas.cod_maquina;
        end;

        BEGIN
          INSERT INTO AI_PE_PEDIDOS
            (COD_EMP,
             COD_UNIDADE,
             NUM_PEDIDO,
             COD_COMPL,
             DTA_EMISSAO,
             DTA_DIGITACAO,
             DTA_PRECO,
             DTA_VALIDADE,
             TIP_FRETE,
             IND_DESTAQUE_FRETE,
             IND_IMP_ROMANEIO,
             NUM_COPIAS_IMP,
             --COD_ATENDENTE,
             COD_CLIENTE,
             COD_OPER,
             IND_CONSUMIDOR,
             IND_REJEITADA,
             COD_SITUACAO,
             COD_LISTA,
             IND_DEPOSITO,
             COD_SITUACAO_ORIG,
             IND_MERC_ENTREGUE,
             NUM_PRIORIDADE_EMBARQUE,
             IND_EMBARQUE,
             IND_MANUTENCAO,
             IND_VENDA,
             IND_ALTERACAO,
             IND_EMISSAO_NF,
             dta_transacao,
             tip_transacao,
             tip_status_transacao)
          VALUES
            (1,
             pi_cd,
             wNum_Pedido,
             3,
             sysdate,
             sysdate,
             sysdate,
             sysdate + 30,
             1,
             1,
             0,
             0,
             --             wCod_atendente,
             pi_UnidadeDestino,
             pi_Operacao,
             0,
             0,
             1,
             pi_lista,
             0,
             1,
             0,
             0,
             1,
             0,
             0,
             0,
             0,
             sysdate,
             1,
             1);
        EXCEPTION
          WHEN OTHERS THEN
            wErro    := 1;
            wTabela  := 'AI_PE_PEDIDOS -' || ' Registro: ' ||
                        r_notas.COD_UNIDADE || '-' || r_notas.NUM_SEQ || '-' ||
                        r_notas.COD_UNIDADE;
            wSqlcode := SQLCODE || '-' || substr(SQLERRM, 1, 2000);
            salva_wpesquisa('GZT_Repres',
                            -1,
                            'Erro: ' || wTabela || '. SQLCODE: ' ||
                            wSqlcode,
                            3);

        END;
        if wErro = 0 then
          /**** Abre o cursor dos itens do pedido ****/
          OPEN c_pedido_itens;
          FETCH c_pedido_itens
            INTO r_pedido_itens;
          WHILE c_pedido_itens%FOUND LOOP
            BEGIN
              if wErro = 0 then
                -- busca valor item
                /*  BEGIN
                          select vlr_item
                            into wItem
                            from lp_precos
                     where cod_emp = 1
                       and cod_lista = pi_lista
                       and cod_item = r_pedido_itens.cod_item
                       and dta_fim is null
                      and rownum <2
                     order by dta_inicio desc;
                       EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                           wItem := 0;
                end; */

                begin
                  select t.cod_uf
                    Into wCod_UF
                    from ps_pessoas a, g1_cidades t
                   where a.cod_cidade = t.cod_cidade
                     and a.cod_pessoa = r_notas.cod_unidade
                     and a.ind_inativo = 0;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    wCod_UF := '';
                end;

                if (wCod_UF = '') or (wCod_UF = 'RS') then
                  -- busca valor item
                  BEGIN
                    select vlr_item
                      into wItem
                      from lp_precos
                     where cod_emp = 1
                       and cod_lista = pi_lista
                       and cod_item = r_pedido_itens.cod_item
                       and dta_fim is null
                       and rownum < 2
                     order by dta_inicio desc;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      wItem := 0;
                  end;

                  wItem := wItem * 0.75;

                else

                  -- alterado em 12/09/2017
                  begin
                    select nvl(Vlr_Ult_Compra, 0.01)
                      into wItem
                      from ce_estoques
                     where cod_emp = 1
                       and cod_unidade = 0
                       and cod_item = r_pedido_itens.cod_item;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      wItem := 0;
                  end;

                  if (wItem <= 0.01) then
                    begin
                      select nvl(vlr_medio_unitario, 0.01)
                        into wItem
                        from ce_estoques
                       where cod_emp = 1
                         and cod_unidade = 0
                         and cod_item = r_pedido_itens.cod_item;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        wItem := 0;
                    end;
                  end if;
                end if;

                if (r_notas.cod_oper = 314) then
                  wLocal := 107500;
				end if;
               /* else
                  wLocal := 107000; --Removido a pedido do fabio
                end if;*/

                wQtd_Ped_Itens := wQtd_Ped_Itens + 1;
                --wItem :=  wItem * 0.75;
                wItem := trunc(wItem, 2);
                BEGIN
                  INSERT INTO AI_PE_ITENS
                    (COD_EMP,
                     COD_UNIDADE,
                     NUM_PEDIDO,
                     COD_COMPL,
                     NUM_ITEM,
                     COD_ITEM,
                     QTD_NEGOCIADA,
                     QTD_ORIGINAL,
                     COD_RESERVA,
                     VLR_UNI_BRUTO,
                     IND_IMPRESSAO_QTD,
                     COD_UNIDADE_RETIRA,
                     COD_LISTA,
                     TIP_PER_REP,
                     TIP_PER_AT,
                     VLR_GARANTIA,
                     IND_RECEITA,
                     IND_ORDEM_COMPRA,
                     TIP_RESERVA_ITEM,
                     TIP_RESERVA_FORCADA,
                     DTH_INCLUSAO_ITEM,
                     dta_transacao,
                     tip_transacao,
                     tip_status_transacao,
                     per_desconto,
                     per_acrescimo,
                     qtd_reservada,
                     ind_vlr_alterado,
                     ind_rejeitada,
                     cod_local)
                  VALUES
                    (1,
                     pi_cd,
                     wNum_Pedido,
                     3,
                     wSeq_item,
                     r_pedido_itens.cod_item,
                     r_pedido_itens.qtd_itens,
                     r_pedido_itens.qtd_itens,
                     19,
                     wItem,
                     1,
                     pi_cd,
                     pi_lista,
                     1,
                     1,
                     0,
                     0,
                     0,
                     1,
                     1,
                     sysdate,
                     sysdate,
                     1,
                     1,
                     0,
                     0,
                     r_pedido_itens.qtd_itens,
                     0,
                     0,
                     wLocal);
                EXCEPTION
                  WHEN OTHERS THEN
                    wErro    := 1;
                    wTabela  := 'AI_PE_ITENS.' || ' Registro: ' ||
                                r_pedido_itens.COD_ITEM;
                    wSqlcode := SQLCODE || '-' || substr(SQLERRM, 1, 2000);
                    salva_wpesquisa('GRZ_cd',
                                    -1,
                                    'Erro: ' || wTabela || '. SQLCODE: ' ||
                                    wSqlcode,
                                    4);

                END;
                wSeq_item := wSeq_item + 1;
              end if;
            END;
            FETCH c_pedido_itens
              INTO r_pedido_itens;
          END LOOP;
          CLOSE c_pedido_itens;
        end if;

        if wErro = 0 then
          begin
            insert into AI_PE_OBSERVACOES
              (COD_EMP,
               COD_UNIDADE,
               NUM_PEDIDO,
               COD_COMPL,
               NUM_SEQ,
               TXT_OBS,
               IND_PEDIDO,
               IND_NF,
               IND_REGISTRO,
               IND_CR,
               DTA_TRANSACAO,
               TIP_TRANSACAO,
               TIP_STATUS_TRANSACAO)
            values
              (1,
               pi_cd,
               wNum_Pedido,
               3,
               0,
               'Referente a nota fiscal ' || r_notas.num_nota || pi_cod_pessoa_forn,
               1,
               1,
               0,
               0,
               SYSDATE,
               1,
               1);
          exception
            WHEN OTHERS THEN
              wErro    := 1;
              wTabela  := 'PE_OBSERVACOES -' || ' Registro: ';
              wSqlcode := SQLCODE || '-' || substr(SQLERRM, 1, 2000);
          end;

        end if;

        -- else
        wQtd_Ped_Nao := wQtd_Ped_Nao + 1;
        --end if;
        if wErro = 0 then
          BEGIN
            INSERT INTO grz_controle_pedido_web
              (NUM_SEQ, COD_UNIDADE, NUM_NOTA, COD_SERIE, DTA_EMISSAO)
            VALUES
              (r_notas.NUM_SEQ,
               r_notas.COD_UNIDADE,
               r_notas.NUM_NOTA,
               r_notas.COD_SERIE,
               r_notas.dta_emissao);
          END;
          ---AI_NS_GERA_TABELA_SP(1,r_notas.cod_unidade,r_notas.num_cupom,wCod_Serie,wCod_Serie,0,1);
          COMMIT;
        elsif wErro = 1 then
          ROLLBACK;
        else
          ROLLBACK;
        end if;
      END;
      FETCH c_notas
        INTO r_notas;
    END LOOP;
    CLOSE c_notas;

  END;
end GRZ_GERA_PEDIDO_TRANSF_SP;
