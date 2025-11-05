
CREATE OR REPLACE PROCEDURE GRZ_REP_CAD_ESTOQUE_SP(
    PI_CODEMP NUMBER,
    PI_CODREDE VARCHAR2,
    PI_CODGRUPO NUMBER,
    PI_CODMASCARA NUMBER,
    PI_UNIDADE_INICIAL NUMBER,
    PI_UNIDADE_FINAL NUMBER,
    PI_DTA_INICIAL DATE,
    PI_DTA_FINAL DATE,
    PI_INATIVO_INI NUMBER,
    PI_INATIVO_FIM NUMBER,
    PI_LIMPA NUMBER,
    PI_DTA_REFERENCIA DATE
) IS
    v_result INTEGER;
    v_cur INTEGER;

    Wi NUMBER;
    Wf NUMBER;
    wQtde NUMBER;
    wVlr_Medio_Unit NUMBER;
    wVlr_Ult_Compra NUMBER;
    wQtd_Est_Loja NUMBER;
    wQtd_Venda_Dia NUMBER;
    wDta_Ult_Movimento DATE;
    wDta_Atualiz_Loja DATE;

    wControle VARCHAR2(03);
    wRede VARCHAR2(02);
    wUnidade VARCHAR2(04);
    wCodigo VARCHAR2(07);
    wQtde_Fisica VARCHAR2(12);
    wVlr_Medio VARCHAR2(15);
    wVlrUltCompra VARCHAR2(15);
    wDtaUltAtual VARCHAR2(10);
    wDtaGeraAdm VARCHAR2(10);
    wErro VARCHAR2(01);
    ERROR_MESSAGE VARCHAR2(100);

    SAIDA EXCEPTION;

    CURSOR c_unidades IS
        SELECT substr(cod_grupo,2,2) cod_rede, cod_unidade
        FROM Ge_Grupos_Unidades
        WHERE Cod_Emp + 0 = PI_CODEMP
            AND Cod_Grupo = PI_CODGRUPO
            AND Cod_Unidade >= PI_UNIDADE_INICIAL
            AND Cod_Unidade <= PI_UNIDADE_FINAL
        ORDER BY Cod_Unidade;

    CURSOR c_cad_estoque IS
        SELECT a.cod_item,
               nvl(c.qtd_estoque, 0) qtd_estoque,
               c.dta_ult_movimento,
               NL.ES_0124_RETORNA_QTD_VENDA_SP(c.cod_emp, c.cod_unidade, c.cod_item, trunc(sysdate)) qtd_venda
        FROM ie_itens a, ie_mascaras b, ce_estoques c, t5_itens_grupo grp
        WHERE a.Cod_Gu + 0 = PI_CODEMP
            AND a.ind_avulso = 0
            AND a.ind_inativo >= PI_INATIVO_INI
            AND a.ind_inativo <= PI_INATIVO_FIM
            AND a.cod_item = b.cod_item
            AND b.cod_mascara = PI_CODMASCARA
            AND a.cod_gu + 0 = c.cod_emp
            AND a.cod_item = c.cod_ITEM
            AND c.Cod_Unidade = r_unidades.Cod_Unidade
            AND b.cod_mascara = grp.cod_mascara
            AND grp.cod_gr_prod = pi_codrede
            AND grp.cod_niv0_ini = '1'
            AND b.cod_completo BETWEEN grp.cod_inicial AND grp.cod_final
        ORDER BY a.cod_item;

BEGIN
    v_cur := dbms_sql.open_cursor;
    dbms_sql.parse(v_cur, 'ALTER SESSION SET NLS_DATE_FORMAT= ''DD/MM/YYYY''', dbms_sql.native);
    v_result := dbms_sql.execute(v_cur);
    dbms_sql.close_cursor(v_cur);

    OPEN c_unidades;
    FETCH c_unidades INTO r_unidades.c_unidades%ROWTYPE;
    WHILE c_unidades%FOUND LOOP
        wDta_Atualiz_Loja := PI_DTA_REFERENCIA;

        OPEN c_cad_estoque;
        FETCH c_cad_estoque INTO r_cad_estoque.c_cad_estoque%ROWTYPE;
        WHILE c_cad_estoque%FOUND LOOP
            -- Processamento do estoque e vendas

            FETCH c_cad_estoque INTO r_cad_estoque;
        END LOOP;
        CLOSE c_cad_estoque;

        FETCH c_unidades INTO r_unidades;
    END LOOP;
    CLOSE c_unidades;

    COMMIT;

EXCEPTION
    WHEN SAIDA THEN
        NULL;
END;
