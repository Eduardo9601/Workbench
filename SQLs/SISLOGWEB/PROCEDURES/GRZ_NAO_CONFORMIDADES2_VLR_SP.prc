CREATE OR REPLACE PROCEDURE NL.GRZ_NAO_CONFORMIDADES2_VLR_SP(PI_OPCAO VARCHAR2) IS
BEGIN
  DECLARE
    PI_EMPRESA                    NUMBER(02) := 1;
    PI_REDE                       NUMBER(04);
    PI_GRUPO                      NUMBER(04);
    PI_DTA_INI                    VARCHAR2(10);
    PI_DTA_FIM                    VARCHAR2(10);
    PI_USUARIO                    VARCHAR2(50);
    PI_UNI_INI                    NUMBER(04);
    PI_UNI_FIM                    NUMBER(04);
    WI                            NUMBER;
    WF                            NUMBER;
    WCOD_REGIAO                   NUMBER(05);
    WQTD_CUPONS                   NUMBER(12);
    WQTD_ITENS                    NUMBER(12);
    WQTD_ITENS_CANCEL             NUMBER(12);
    WQTD_ITENS_CANCEL_MEIO_VENDA  NUMBER(12);
    WQTD_CUPONS_CANCEL            NUMBER(12);
    WQTD_CUPONS_CANCEL_MEIO_VENDA NUMBER(12);
    WVLR_ITENS_CANCEL             NUMBER(18, 2);
    WVALOR_DESCONTOS              NUMBER(18, 2);
    WVLRCUPOMDEDESCONTO           NUMBER(18, 2);
    WDESCONTOPROMOCAO             NUMBER(18, 2);
    WVLR_BONUS_RETORNO            NUMBER(18, 2);
    WVLR_DESC_FUNC                NUMBER(18, 2);
    WVLR_DESC_PROMO_QTD           NUMBER(18, 2);
    WVLR_VENDA_LIQ                NUMBER(18, 2);
    WVLR_VENDA_LIQ_ANTERIOR       NUMBER(18, 2);
    WVLR_FALTA_INVENTARIO         NUMBER(18, 2);
    WVLR_VENDA_BRUTA              NUMBER(18, 2);
    WVLR_VENDA                    NUMBER(18, 2);
    WVLR_ICMS                     NUMBER(18, 2);
    WVLR_PIS                      NUMBER(18, 2);
    WVLR_COFINS                   NUMBER(18, 2);
    WVLR_DEVOLUCOES               NUMBER(18, 2);
    WVLRCREDLP                    NUMBER(18, 2);
    WVLRCOMPROMETIDO              NUMBER(18, 2);
    WVLR_DESCONTO_FUNC_DUPLICADO  NUMBER(18, 2);
    WVLR_DESCONTO_CUPOM_VV        NUMBER(18, 2);
    WDESCITEMMOTIVO11             NUMBER(18, 2);
    WDESCITEMMOTIVO13             NUMBER(18, 2);
    WDESCITEMMOTIVO1              NUMBER(18, 2);
    WDESCITEMMOTIVO14             NUMBER(18, 2);
    WDESCITEMMOTIVO10             NUMBER(18, 2);
    WDTA_INICIAL                  DATE;
    WDTA_FINAL                    DATE;

    /*cursor para percorrer todas as unidades*/
    CURSOR C_UNIDADES IS
      SELECT GE.COD_UNIDADE, GE.COD_NIVEL2, D.DES_FANTASIA
        FROM GE_UNIDADES GE, PS_PESSOAS D
       WHERE ((GE.COD_UNIDADE > 0 AND GE.COD_UNIDADE < 800) OR (GE.COD_UNIDADE > 7000 AND GE.COD_UNIDADE < 8000))
         AND D.COD_PESSOA = GE.COD_UNIDADE
         AND D.IND_INATIVO = 0
         AND (D.DTA_AFASTAMENTO IS NULL OR D.DTA_AFASTAMENTO >= WDTA_INICIAL)
         AND NOT EXISTS
       (SELECT 1 FROM GRZ_LOJAS_UNIFICADAS_CIA C
                WHERE C.COD_EMP_PARA = SUBSTR(GE.COD_NIVEL2, 2, 2)
                  AND C.COD_UNIDADE_PARA = GE.COD_UNIDADE)
         AND GE.COD_EMP = PI_EMPRESA
         AND GE.COD_NIVEL2 IN (810, 830, 840, 850, 870)
         AND GE.COD_NIVEL3 = GE.COD_UNIDADE
       ORDER BY GE.COD_UNIDADE;
    R_UNIDADES C_UNIDADES%ROWTYPE;
    --1#40#940#06/2017#380256#158#158#
  BEGIN

    WI         := INSTR(PI_OPCAO, '#', 1, 1);
    PI_EMPRESA := TO_NUMBER(SUBSTR(PI_OPCAO, 1, (WI - 1)));
    WF         := INSTR(PI_OPCAO, '#', 1, 2);
    PI_REDE    := TO_NUMBER(SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1)));
    WI         := WF;
    WF         := INSTR(PI_OPCAO, '#', 1, 3);
    PI_GRUPO   := TO_NUMBER(SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1)));
    WI         := WF;
    WF         := INSTR(PI_OPCAO, '#', 1, 4);
    PI_DTA_INI := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI         := WF;
    WF         := INSTR(PI_OPCAO, '#', 1, 5);
    PI_DTA_FIM := TO_DATE(SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1)));
    WI         := WF;
    WF         := INSTR(PI_OPCAO, '#', 1, 6);
    PI_USUARIO := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI         := WF;
    WF         := INSTR(PI_OPCAO, '#', 1, 7);
    PI_UNI_INI := TO_NUMBER(SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1)));
    WI         := WF;
    WF         := INSTR(PI_OPCAO, '#', 1, 8);
    PI_UNI_FIM := TO_NUMBER(SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1)));

    WDTA_INICIAL := TO_DATE(PI_DTA_INI, 'dd/mm/yyyy');
    WDTA_FINAL   := LAST_DAY(WDTA_INICIAL);

    DELETE FROM GRZ_NAO_CONFORMIDADES_VALORES2
     WHERE DTA_MOVIMENTO = WDTA_INICIAL;
    COMMIT;

    OPEN C_UNIDADES;
    FETCH C_UNIDADES
      INTO R_UNIDADES;
    WHILE C_UNIDADES%FOUND LOOP
      BEGIN
        /*pega a região da unidade*/
        PI_REDE     := SUBSTR(TO_CHAR(R_UNIDADES.COD_NIVEL2), 2, 2);
        WCOD_REGIAO := 0;

        BEGIN
          SELECT MIN(COD_QUEBRA)
            INTO WCOD_REGIAO
            FROM GE_GRUPOS_UNIDADES
           WHERE COD_EMP = PI_EMPRESA
             AND COD_GRUPO = '9' || PI_REDE
             AND COD_UNIDADE = R_UNIDADES.COD_UNIDADE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WCOD_REGIAO := 0;
        END;

        /*pega os cupons e itens cancelados*/
        WQTD_CUPONS      := 0;
        WVLR_VENDA_BRUTA := 0;
        BEGIN
          SELECT COUNT(DISTINCT A.NUM_SEQ), SUM(NVL(OPER.VLR_OPERACAO, 0))
            INTO WQTD_CUPONS, WVLR_VENDA_BRUTA
            FROM NS_NOTAS A, NS_NOTAS_OPERACOES OPER
           WHERE OPER.NUM_SEQ = A.NUM_SEQ
             AND OPER.COD_MAQUINA = A.COD_MAQUINA
             AND OPER.COD_OPER IN (300, 302, 305, 4300, 4302, 4305)
             AND A.COD_EMP = PI_EMPRESA
             AND (A.TIP_NOTA = 3 OR (A.TIP_NOTA = 2 AND A.NUM_MODELO = 65))
             AND A.IND_STATUS = 1
             AND A.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND A.DTA_EMISSAO >= WDTA_INICIAL
             AND A.DTA_EMISSAO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WQTD_CUPONS      := 0;
            WVLR_VENDA_BRUTA := 0;
        END;

        WQTD_ITENS        := 0;
        WQTD_ITENS_CANCEL := 0;
        WVLR_ITENS_CANCEL := 0;

        BEGIN
          SELECT NVL(SUM(DECODE(A.IND_CANCELADO, 1, 0, 1)), 0),
                 NVL(SUM(DECODE(A.IND_CANCELADO, 1, 0, DECODE(A.IND_CANCELADO_ITEM, 1, 1, 0))), 0),
                 NVL(SUM(DECODE(A.IND_CANCELADO, 1, 0, DECODE(A.IND_CANCELADO_ITEM, 1, (NVL(A.VLR_TOTAL, 0) + NVL(A.VLR_DESCONTO, 0) + NVL(A.VLR_DESCONTO_ITEM, 0)), 0))),0)
            INTO WQTD_ITENS, WQTD_ITENS_CANCEL, WVLR_ITENS_CANCEL
            FROM GRZ_LOJAS_CUPOM_ITENS A
           WHERE A.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND A.DTA_LANCAMENTO >= WDTA_INICIAL
             AND A.DTA_LANCAMENTO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WQTD_ITENS        := 0;
            WQTD_ITENS_CANCEL := 0;
            WVLR_ITENS_CANCEL := 0;
        END;

        WQTD_CUPONS_CANCEL := 0;

        BEGIN
          SELECT COUNT(DISTINCT A.NUM_SEQ)
            INTO WQTD_CUPONS_CANCEL
            FROM NS_NOTAS A
           WHERE /*NOT EXISTS
           (SELECT 1 FROM GRZ_LOJAS_CUPOM_ITENS B
                    WHERE B.COD_UNIDADE = A.COD_UNIDADE
                      AND B.NUM_CUPOM = A.NUM_NOTA
                      AND B.NUM_EQUIPAMENTO = A.NUM_EQUIPAMENTO
                      AND B.DTA_LANCAMENTO = A.DTA_EMISSAO
                      AND ((A.DTA_EMISSAO <= TO_DATE('31/01/2024', 'DD/MM/YYYY') AND B.COD_MOTIVO_CANCELAMENTO = 8)
                       OR (A.DTA_EMISSAO > TO_DATE('31/01/2024', 'DD/MM/YYYY') AND B.COD_MOTIVO_CANCELAMENTO IN (11))) -- a partir dia 01/02/2024 solicitado para incluir os codigos 10 e 11 se a dta_emissao for > 31/01/2024
                      AND B.IND_CANCELADO = 1) */ -- comentado em 27/11/2024, todo cancelamento deve ser considerado
             A.COD_EMP = PI_EMPRESA
             AND (A.TIP_NOTA = 3 OR (A.TIP_NOTA = 2 AND A.NUM_MODELO = 65))
             AND NVL(A.COD_RESULTADO_NFE, 100) <> '102'
             AND A.IND_STATUS = 2
             AND A.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND A.DTA_EMISSAO >= WDTA_INICIAL
             AND A.DTA_EMISSAO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WQTD_CUPONS_CANCEL := 0;
        END;

        /**** sql para pegar os cupons e itens cancelados no meio da venda ****/
        WQTD_ITENS_CANCEL_MEIO_VENDA := 0;
        BEGIN
          SELECT COUNT(DISTINCT(COD_EMP || COD_UNIDADE || NUM_EQUIPAMENTO || NUM_CUPOM || SEQ_CHAVE_CUPOM || DTA_MOVIMENTO))
            INTO WQTD_CUPONS_CANCEL_MEIO_VENDA
            FROM GRZ_LOJAS_CUPOM_CANCELADOS
           WHERE COD_EMP = PI_REDE
             AND COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND DTA_MOVIMENTO >= WDTA_INICIAL
             AND DTA_MOVIMENTO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WQTD_CUPONS_CANCEL_MEIO_VENDA := 0;
        END;
        /*Desconto F4*/
        WVLR_DESCONTO_CUPOM_VV := 0;
        /*    begin
        select nvl(sum(vlr_desconto) ,0)
            into wVlr_desconto_cupom_VV
         from grz_lojas_cupom_itens
         where cod_unidade = r_unidades.cod_unidade
            and dta_lancamento between '01/'||pi_dta_ini  and wUltimoDiaMes_aux
              and ind_cancelado = 0
                    and ind_cancelado_item = 0
                    and cod_desconto_item =0;
        exception
               WHEN NO_DATA_FOUND THEN
                  wVlr_desconto_cupom_VV :=0;
        end; */
        WVLRCUPOMDEDESCONTO := 0;

        BEGIN
          SELECT SUM(NVL(VALOR_DESCONTO, 0))
            INTO WVLRCUPOMDEDESCONTO
            FROM GRZ_LOJAS_CUPOM_DESCTO
           WHERE COD_EMP = PI_REDE
             AND COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND DTA_MOVIMENTO >= WDTA_INICIAL
             AND DTA_MOVIMENTO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLRCUPOMDEDESCONTO := 0;
        END;

        WDESCONTOPROMOCAO := 0;
        /* Begin
          select sum(nvl(vlr_desconto_item, 0))
            into wDescontoPromocao
            from grz_lojas_cupom_itens a
           where a.cod_unidade = r_unidades.cod_unidade
             and a.dta_lancamento >= wDta_inicial
             and a.dta_lancamento <= wDta_final
             and a.ind_cancelado = 0
             and a.ind_cancelado_item = 0
             and cod_desconto_item in (1, 14);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            wDescontoPromocao := 0;
        End;*/
        BEGIN
          SELECT NVL(SUM(DECODE(COD_DESCONTO_ITEM, 11, SUM(NVL(VLR_DESCONTO_ITEM, 0)), 0)), 0) DESCONTO_ITEM_11, --Mercadoria para uso na Empresa
                 NVL(SUM(DECODE(COD_DESCONTO_ITEM, 13, SUM(NVL(VLR_DESCONTO_ITEM, 0)), 0)), 0) DESCONTO_ITEM_13, --Baixa de produtos
                 NVL(SUM(DECODE(COD_DESCONTO_ITEM, 1, SUM(NVL(VLR_DESCONTO_ITEM, 0)), 0)), 0) DESCONTO_ITEM_1,
                 NVL(SUM(DECODE(COD_DESCONTO_ITEM, 14, SUM(NVL(VLR_DESCONTO_ITEM, 0)), 0)), 0) DESCONTO_ITEM_14,
                 NVL(SUM(DECODE(COD_DESCONTO_ITEM, 10, SUM(NVL(VLR_DESCONTO_ITEM, 0)), 0)), 0) DESCONTO_ITEM_10
            INTO WDESCITEMMOTIVO11,
                 WDESCITEMMOTIVO13,
                 WDESCITEMMOTIVO1,
                 WDESCITEMMOTIVO14,
                 WDESCITEMMOTIVO10
            FROM GRZ_LOJAS_CUPOM_ITENS
           WHERE COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND DTA_LANCAMENTO BETWEEN WDTA_INICIAL AND WDTA_FINAL
             AND COD_DESCONTO_ITEM IN (1, 14, 10, 11, 13)
             AND IND_CANCELADO = 0
             AND IND_CANCELADO_ITEM = 0
           GROUP BY COD_DESCONTO_ITEM;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WDESCITEMMOTIVO11 := 0;
            WDESCITEMMOTIVO13 := 0;
            WDESCITEMMOTIVO1  := 0;
            WDESCITEMMOTIVO14 := 0;
            WDESCITEMMOTIVO10 := 0;
        END;

        WDESCONTOPROMOCAO := WDESCITEMMOTIVO1 + WDESCITEMMOTIVO14;
        WVLR_VENDA        := 0;
        WVLR_ICMS         := 0;
        WVLR_PIS          := 0;
        WVLR_COFINS       := 0;
        WVALOR_DESCONTOS  := 0;

        BEGIN
          SELECT SUM(DECODE(CE.TIP_LANCAMENTO, 2, NVL(CE.VLR_TOTAL, 0), 1, ((NVL(CE.VLR_TOTAL, 0)) * -1), 0)),
                 SUM(DECODE(CE.TIP_LANCAMENTO, 2, NVL(CE.VLR_ICMS, 0), 1, (NVL(CE.VLR_ICMS, 0) * -1), 0)),
                 SUM(DECODE(CE.TIP_LANCAMENTO, 2, NVL(D.VLR_PIS, 0), 1, (NVL(CE.VLR_PIS, 0) * -1), 0)),
                 SUM(DECODE(CE.TIP_LANCAMENTO, 2, NVL(D.VLR_COFINS, 0), 1, (NVL(CE.VLR_COFINS, 0) * -1), 0)),
                 SUM(DECODE(CE.TIP_LANCAMENTO, 2, NVL(CE.VLR_DESCONTO, 0), 0))
            INTO WVLR_VENDA,
                 WVLR_ICMS,
                 WVLR_PIS,
                 WVLR_COFINS,
                 WVALOR_DESCONTOS
            FROM CE_DIARIOS CE, NS_ITENS D
           WHERE D.NUM_SEQ_CE(+) = CE.NUM_SEQ
             AND D.COD_MAQ_CE(+) = CE.COD_MAQUINA
             AND CE.COD_EMP = PI_EMPRESA
             AND CE.COD_OPER IN (106, 107, 300, 302, 305, 4106, 4107, 4300, 4302, 4305)
             AND CE.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND CE.DTA_LANCAMENTO >= WDTA_INICIAL
             AND CE.DTA_LANCAMENTO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVALOR_DESCONTOS := 0;
        END;

        WVLR_VENDA_LIQ   := NVL(WVLR_VENDA, 0) - (NVL(WVLR_ICMS, 0) + NVL(WVLR_PIS, 0) + NVL(WVLR_COFINS, 0));
        WVALOR_DESCONTOS := NVL(WVALOR_DESCONTOS, 0) - NVL(WVLRCUPOMDEDESCONTO, 0) - NVL(WVLR_DESCONTO_CUPOM_VV, 0) - NVL(WDESCITEMMOTIVO11, 0) - NVL(WDESCITEMMOTIVO13, 0);

        IF NVL(WDESCONTOPROMOCAO, 0) > NVL(WVALOR_DESCONTOS, 0) THEN
          WVALOR_DESCONTOS := NVL(WDESCONTOPROMOCAO, 0) - NVL(WVALOR_DESCONTOS, 0);
        ELSE
          WVALOR_DESCONTOS := NVL(WVALOR_DESCONTOS, 0) - NVL(WDESCONTOPROMOCAO, 0);
        END IF;
        WVLR_BONUS_RETORNO := 0;

        BEGIN
          SELECT SUM(NVL(BONUS.VLR_BONUS, 0))
            INTO WVLR_BONUS_RETORNO
            FROM NS_NOTAS B, GRZ_MVTO_BONUS BONUS
           WHERE BONUS.COD_EMP = PI_REDE
             AND BONUS.COD_UNIDADE = B.COD_UNIDADE
             AND BONUS.DTA_MOVIMENTO = B.DTA_EMISSAO
             AND BONUS.TIP_MOVIMENTO = 2
             AND BONUS.NUM_CUPOM = B.NUM_NOTA
             AND BONUS.NUM_EQUIPAMENTO = B.NUM_EQUIPAMENTO
             AND B.COD_EMP = PI_EMPRESA
             AND (B.TIP_NOTA = 3 OR (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
             AND B.IND_STATUS = 1
             AND B.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND B.DTA_EMISSAO >= WDTA_INICIAL
             AND B.DTA_EMISSAO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLR_BONUS_RETORNO := 0;
        END;

        --sql para solucionar problema de entrar vlr desconto promocao qtd em vlr desconto funcionario - 16/09/2019
        WVLR_DESCONTO_FUNC_DUPLICADO := 0;
        BEGIN
          /*SELECT sum(nvl(a.vlr_descto_prom_qtd, 0))
           into wVlr_desconto_func_duplicado
           from grz_lojas_cupons a
          where a.cod_unidade = r_unidades.cod_unidade
            and a.dta_lancamento >= wDta_inicial
            and a.dta_lancamento <= wDta_final
            and a.cod_cliente_milhagem is not null
            and a.vlr_descto_prom_qtd is not null;*/
          SELECT NVL(SUM(NVL(A.VLR_DESCTO_PROM_QTD, 0)), 0)
            INTO WVLR_DESCONTO_FUNC_DUPLICADO
            FROM NL.GRZ_LOJAS_CUPONS A
           WHERE A.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND A.DTA_LANCAMENTO >= WDTA_INICIAL
             AND A.DTA_LANCAMENTO <= WDTA_FINAL
             AND A.IND_CANCELADO = 0
             AND NVL(A.COD_CLIENTE_MILHAGEM, 0) > 0
             AND NVL(A.VLR_DESCTO_PROM_QTD, 0) > 0;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLR_DESCONTO_FUNC_DUPLICADO := 0;
        END;

        WVLR_DESC_FUNC      := 0;
        WVLR_DESC_PROMO_QTD := 0;

        BEGIN
          SELECT SUM(DECODE(NVL(A.COD_CLIENTE_MILHAGEM, 0), 0, 0, (NVL(OPER.VLR_DESCONTO1, 0) + NVL(OPER.VLR_DESCONTO2, 0)))),
                 SUM(DECODE(TO_NUMBER(NVL(D.VLR_COLUNA, '0')), 0, 0, TO_NUMBER(NVL(D.VLR_COLUNA, 0))))
            INTO WVLR_DESC_FUNC, WVLR_DESC_PROMO_QTD
            FROM NS_NOTAS A,
                 (SELECT B.NUM_SEQ,
                         B.COD_MAQUINA,
                         SUM(NVL(B.VLR_DESCONTO1, 0)) VLR_DESCONTO1,
                         SUM(NVL(B.VLR_DESCONTO2, 0)) VLR_DESCONTO2
                    FROM NS_NOTAS NS, NS_NOTAS_OPERACOES B
                   WHERE B.NUM_SEQ = NS.NUM_SEQ
                     AND B.COD_MAQUINA = NS.COD_MAQUINA
                     AND B.COD_OPER IN (300, 302, 305, 4300, 4302, 4305)
                     AND (NVL(B.VLR_DESCONTO1, 0) > 0 OR NVL(B.VLR_DESCONTO2, 0) > 0)
                     AND NS.COD_EMP = PI_EMPRESA
                     AND (NS.TIP_NOTA = 3 OR (NS.TIP_NOTA = 2 AND NS.NUM_MODELO = 65))
                     AND NS.IND_STATUS = 1
                     AND NS.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
                     AND NS.DTA_EMISSAO >= WDTA_INICIAL
                     AND NS.DTA_EMISSAO <= WDTA_FINAL
                   GROUP BY B.NUM_SEQ, B.COD_MAQUINA) OPER,
                 NS_NOTAS_COLUNAS D
           WHERE D.NUM_SEQ(+) = A.NUM_SEQ
             AND D.COD_MAQUINA(+) = A.COD_MAQUINA
             AND D.SEQ_COLUNA(+) = 32
             AND OPER.NUM_SEQ = A.NUM_SEQ
             AND OPER.COD_MAQUINA = A.COD_MAQUINA
             AND A.COD_EMP = PI_EMPRESA
             AND (A.TIP_NOTA = 3 OR (A.TIP_NOTA = 2 AND A.NUM_MODELO = 65))
             AND A.IND_STATUS = 1
             AND A.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND A.DTA_EMISSAO >= WDTA_INICIAL
             AND A.DTA_EMISSAO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLR_DESC_FUNC      := 0;
            WVLR_DESC_PROMO_QTD := 0;
        END;

        /*CRESC DE VENDA E INVENTARIO*/
        WVLR_FALTA_INVENTARIO := 0;
        BEGIN
          SELECT SUM(DECODE(CE.TIP_LANCAMENTO, 1, NVL(CE.VLR_MEDIO_EMP, 0), (NVL(CE.VLR_MEDIO_EMP, 0) * -1)))
            INTO WVLR_FALTA_INVENTARIO
            FROM CE_DIARIOS CE, IE_ITENS IE, GRZ_LOJAS_UNIFICADAS_CIA G
           WHERE IE.COD_ITEM = CE.COD_ITEM
             AND IE.IND_AVULSO = 0
             AND IE.COD_TIPO = '00'
             AND CE.COD_EMP = PI_EMPRESA
             AND CE.COD_OPER IN (20, 22)
             AND G.COD_UNIDADE_PARA(+) = CE.COD_UNIDADE
             AND CE.COD_UNIDADE = DECODE(G.COD_UNIDADE_DE, R_UNIDADES.COD_UNIDADE, G.COD_UNIDADE_PARA, R_UNIDADES.COD_UNIDADE)
             AND CE.DTA_LANCAMENTO >= WDTA_INICIAL
             AND CE.DTA_LANCAMENTO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLR_FALTA_INVENTARIO := 0;
        END;

        /*venda liquida do ano anterior*/
        WVLR_VENDA_LIQ_ANTERIOR := 0;
        BEGIN
          SELECT SUM(DECODE(A.DES_CHAVE, '05#05001', NVL(A.VLR_REALIZADO, 0), 0))
            INTO WVLR_VENDA_LIQ_ANTERIOR
            FROM OR_VALORES A
           WHERE A.COD_EMP = PI_EMPRESA
             AND A.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND A.COD_ORCAMENTO = 400
             AND A.DTA_ORCAMENTO = ADD_MONTHS(WDTA_INICIAL, -12)
             AND A.DES_CHAVE = '05#05001';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLR_VENDA_LIQ_ANTERIOR := 0;
        END;

        /*valor de devolucoes*/
        WVLR_DEVOLUCOES := 0;
        BEGIN
          SELECT SUM(NVL(B.VLR_OPERACAO, 0))
            INTO WVLR_DEVOLUCOES
            FROM NE_NOTAS A, NE_NOTAS_OPERACOES B, GRZ_LOJAS_NE_NOTAS GRZ
           WHERE GRZ.COD_UNIDADE = A.COD_UNIDADE
             AND GRZ.NUM_NOTA = A.NUM_NOTA
             AND TRUNC(GRZ.DTA_EMISSAO) = TRUNC(A.DTA_EMISSAO)
             AND B.NUM_SEQ = A.NUM_SEQ
             AND B.COD_MAQUINA = A.COD_MAQUINA
             AND B.COD_OPER IN (106, 107, 4106, 4107)
             AND A.COD_EMP = PI_EMPRESA
             AND A.IND_STATUS = 1
             AND A.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND A.DTA_RECEBIMENTO >= WDTA_INICIAL
             AND A.DTA_RECEBIMENTO <= WDTA_FINAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLR_DEVOLUCOES := 0;
        END;

        /*PERDA DE CREDIARIO*/
        --+ *100 / sum(a.vlr_comprometido),
        WVLRCREDLP       := 0;
        WVLRCOMPROMETIDO := 0;
        -- modificado em 02/02/2022
        /*Begin
            select sum(NVL(a.vlr_lp,0))
                ,sum(NVL(a.vlr_comprometido,0))
            into wVlrCredLp
                ,wVlrComprometido
                  from es_0124_crediario_saldos a
                 where a.cod_emp         = pi_empresa
             and a.cod_unidade     = r_unidades.cod_unidade
                   and a.dta_vencimento >= add_months(wDta_inicial,-6)
             and a.dta_vencimento <= add_months(wDta_final,-6)
                   and a.dta_lancamento <= wDta_final
                   and a.tip_titulo     in (1,50,56,70);
        EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        wVlrCredLp       := 0;
                wVlrComprometido := 0;
            End;*/
        BEGIN
          SELECT NVL(MAX(A.VLR_LP), 0)
            INTO WVLRCREDLP
            FROM ES_0124_CR_PROJECAO A
           WHERE A.COD_UNIDADE = R_UNIDADES.COD_UNIDADE
             AND A.DTA_MOVIMENTO >= WDTA_INICIAL
             AND A.DTA_MOVIMENTO <= WDTA_FINAL
             AND A.COD_GRUPO_UNI >= 8701
             AND A.COD_GRUPO_UNI <= 8725
             AND A.COD_UNIDADE <> 0
             AND A.COD_GRUPO_LCTO = 57
             AND A.COD_QUEBRA_LCTO = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLRCREDLP := 0;
        END;

        INSERT INTO GRZ_NAO_CONFORMIDADES_VALORES2
          (COD_EMP,
           COD_UNIDADE,
           DES_FANTASIA,
           COD_REGIAO,
           DTA_MOVIMENTO,
           VLR_DESCONTOS,
           VLR_BONUS_RET,
           VLR_PROMO_QTD,
           VLR_DESC_FUNC,
           QTD_CUPONS,
           QTD_CUPONS_CANC,
           QTD_ITENS,
           QTD_ITENS_CANC,
           VLR_VENDA_LIQ,
           VLR_FALTA_INVENT,
           VLR_VENDA_BRUTA,
           VLR_DEVOLUCOES,
           VLR_VENDA_LIQ_ANT,
           DTA_SISTEMA,
           DES_USUARIO,
           VLR_CRED_LP,
           VLR_COMPROMETIDO_LP,
           PER_LP_CRED,
           VLR_DESCONTO_F4,
           QTD_CUPONS_CANC_MEIO_VENDA)
        VALUES
          (PI_REDE,
           R_UNIDADES.COD_UNIDADE,
           R_UNIDADES.DES_FANTASIA,
           NVL(WCOD_REGIAO, 0),
           WDTA_INICIAL,
           NVL(WVALOR_DESCONTOS, 0),
           NVL(WVLR_BONUS_RETORNO, 0),
           NVL(WVLR_DESC_PROMO_QTD, 0),
           NVL(WVLR_DESC_FUNC, 0) - NVL(WVLR_DESCONTO_FUNC_DUPLICADO, 0),
           NVL(WQTD_CUPONS, 0),
           NVL(WQTD_CUPONS_CANCEL, 0) +
           NVL(WQTD_CUPONS_CANCEL_MEIO_VENDA, 0),
           NVL(WQTD_ITENS, 0),
           NVL(WQTD_ITENS_CANCEL, 0) + NVL(WQTD_ITENS_CANCEL_MEIO_VENDA, 0),
           NVL(WVLR_VENDA_LIQ, 0),
           NVL(WVLR_FALTA_INVENTARIO, 0),
           NVL(WVLR_VENDA_BRUTA, 0),
           NVL(WVLR_DEVOLUCOES, 0),
           NVL(WVLR_VENDA_LIQ_ANTERIOR, 0),
           SYSDATE,
           PI_USUARIO,
           0,
           NVL(WVLRCOMPROMETIDO, 0),
           NVL(WVLRCREDLP, 0),
           NVL(WDESCITEMMOTIVO10, 0) + NVL(WDESCITEMMOTIVO11, 0),
           NVL(WQTD_CUPONS_CANCEL_MEIO_VENDA, 0));
      END;
      FETCH C_UNIDADES
        INTO R_UNIDADES;
    END LOOP;
    CLOSE C_UNIDADES;

    COMMIT;
    -- deleta unidades que nao devem aparecer
    /*delete from grz_nao_conformidades_valores2
    where COD_EMP = pi_rede
    AND DTA_MOVIMENTO = '01/'||pi_dta_ini
    AND QTD_CUPONS = 0;
    COMMIT;*/
    SISLOGWEB.GRZ_NAO_CONFORMIDADES_INDC_SP(TO_DATE(WDTA_INICIAL));
  END;
END GRZ_NAO_CONFORMIDADES2_VLR_SP;
/
