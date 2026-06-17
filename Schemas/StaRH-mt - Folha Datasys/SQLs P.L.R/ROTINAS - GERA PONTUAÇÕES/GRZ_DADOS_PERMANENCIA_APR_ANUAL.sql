CREATE OR REPLACE PROCEDURE GRZ_PERMANENCIA_APR_ANUAL_SP
(
    PI_OPCAO IN VARCHAR2
) IS
    /**** parâmetros de entrada ****/
    PI_CODEMP      NUMBER;
    PI_CODREDE     VARCHAR2(02);
    PI_CODGRUPO    NUMBER;
    PI_CODMASCARA  NUMBER;
    PI_DATA_REF    DATE;

    WI             NUMBER;
    WF             NUMBER;

    V_REF_MM       DATE;
    V_DTA_INI      DATE;
    V_DTA_FIM_EXC  DATE;

    wVlrPerm            NUMBER;
    wVlrCustoPerm       NUMBER;
    wVlrEstMedPerm      NUMBER;
    wQtd_Pontos_Perm    NUMBER;
    wRegiao             NUMBER;

    v_cur               INTEGER;
    v_result            INTEGER;

    SAIDA EXCEPTION;

    /**** unidades da rede/grupo ****/
    CURSOR c_totais_unidades IS
        SELECT ge.cod_quebra AS regiao,
               ge.cod_unidade,
               g.des_nome
          FROM ge_grupos_unidades ge
          JOIN ge_unidades g
            ON g.cod_emp     = ge.cod_emp
           AND g.cod_unidade = ge.cod_unidade
          JOIN ge_grupos_quebra d
            ON d.cod_emp     = ge.cod_emp
           AND d.cod_grupo   = ge.cod_grupo
           AND d.cod_quebra  = ge.cod_quebra
         WHERE ge.cod_grupo = PI_CODGRUPO
           AND ge.cod_emp   = PI_CODEMP
           AND ge.cod_unidade BETWEEN 0 AND 9999
         ORDER BY ge.cod_unidade;

    r_totais_unidades c_totais_unidades%ROWTYPE;

    /**** totais anuais vindos da base mensal já validada ****/
    CURSOR c_totais IS
        SELECT
            SUM(NVL(t.vlr_custo, 0))         AS vlr_custo_perm,
            SUM(NVL(t.vlr_estmedio_perm, 0)) AS vlr_est_medio_perm
        FROM sislogweb.grz_indice_permanencia_tb t
        WHERE t.cod_unidade     = r_totais_unidades.cod_unidade
          AND t.dta_referencia >= V_DTA_INI
          AND t.dta_referencia <  V_DTA_FIM_EXC;

    r_totais c_totais%ROWTYPE;

    /**** tratamento especial rede 70, preservando a lógica antiga de unificação ****/
    CURSOR c_totais_cia IS
        SELECT
            SUM(NVL(t.vlr_custo, 0))         AS vlr_custo_perm,
            SUM(NVL(t.vlr_estmedio_perm, 0)) AS vlr_est_medio_perm
        FROM sislogweb.grz_indice_permanencia_tb t
        JOIN grz_lojas_unificadas_cia cia
          ON cia.cod_unidade_para = t.cod_unidade
        WHERE cia.cod_unidade_de  = r_totais_unidades.cod_unidade
          AND t.dta_referencia   >= V_DTA_INI
          AND t.dta_referencia   <  V_DTA_FIM_EXC;

    r_totais_cia c_totais_cia%ROWTYPE;

    /**** cursor registro dados APR ****/
    CURSOR c_apr IS
        SELECT *
          FROM grz_dados_calculo_apr_anual
         WHERE cod_unidade = r_totais_unidades.cod_unidade
           AND ano         = TO_CHAR(PI_DATA_REF, 'YYYY');

    r_apr c_apr%ROWTYPE;

    CURSOR c_apr_regiao IS
        SELECT *
          FROM grz_valores_regioes_apr_anual
         WHERE cod_unidade = r_totais_unidades.cod_unidade
           AND ano         = TO_CHAR(PI_DATA_REF, 'YYYY');

    r_apr_regiao c_apr_regiao%ROWTYPE;

    CURSOR c_calc IS
        SELECT *
          FROM grz_cad_calculo_apr_anual
         WHERE cod_rede    = PI_CODREDE
           AND ano         = TO_CHAR(PI_DATA_REF, 'YYYY')
           AND cod_calculo IN (2)
         ORDER BY cod_calculo, qtd_pontos;

    r_calc c_calc%ROWTYPE;

BEGIN
    v_cur := dbms_sql.open_cursor;
    dbms_sql.parse(
        v_cur,
        'alter session set nls_date_format = ''dd/mm/rrrr''',
        dbms_sql.native
    );
    v_result := dbms_sql.execute(v_cur);
    dbms_sql.close_cursor(v_cur);

    /**** desmembra a opção recebida ****/
    WI := INSTR(PI_OPCAO, '#', 1, 1);
    PI_CODEMP := TO_NUMBER(SUBSTR(PI_OPCAO, 1, WI - 1));

    WF := INSTR(PI_OPCAO, '#', 1, 2);
    PI_CODREDE := SUBSTR(PI_OPCAO, WI + 1, WF - WI - 1);

    WI := WF;
    WF := INSTR(PI_OPCAO, '#', 1, 3);
    PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO, WI + 1, WF - WI - 1));

    WI := WF;
    WF := INSTR(PI_OPCAO, '#', 1, 4);
    PI_CODMASCARA := TO_NUMBER(SUBSTR(PI_OPCAO, WI + 1, WF - WI - 1));

    WI := WF;
    WF := INSTR(PI_OPCAO, '#', 1, 5);
    PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO, WI + 1, WF - WI - 1), 'DD/MM/YYYY');

    /**** mantido só por compatibilidade com a assinatura original ****/
    PI_CODMASCARA := 170;

    /**** janela anual: 12 meses até a referência informada ****/
    V_REF_MM      := TRUNC(PI_DATA_REF, 'MM');
    V_DTA_INI     := ADD_MONTHS(V_REF_MM, -11);
    V_DTA_FIM_EXC := ADD_MONTHS(V_REF_MM, 1);

    OPEN c_totais_unidades;
    FETCH c_totais_unidades INTO r_totais_unidades;

    WHILE c_totais_unidades%FOUND LOOP
        wVlrCustoPerm    := 0;
        wVlrEstMedPerm   := 0;
        wVlrPerm         := 0;
        wQtd_Pontos_Perm := 0;
        wRegiao          := 0;

        IF PI_CODREDE <> '70' THEN
            OPEN c_totais;
            FETCH c_totais INTO r_totais;

            IF c_totais%FOUND THEN
                wVlrCustoPerm  := NVL(r_totais.vlr_custo_perm, 0);
                wVlrEstMedPerm := NVL(r_totais.vlr_est_medio_perm, 0);
            END IF;

            CLOSE c_totais;
        ELSE
            OPEN c_totais_cia;
            FETCH c_totais_cia INTO r_totais_cia;

            IF c_totais_cia%FOUND THEN
                wVlrCustoPerm  := NVL(r_totais_cia.vlr_custo_perm, 0);
                wVlrEstMedPerm := NVL(r_totais_cia.vlr_est_medio_perm, 0);
            END IF;

            CLOSE c_totais_cia;
        END IF;

        /**** cálculo anual correto da permanência ****/
        IF NVL(wVlrCustoPerm, 0) = 0 OR wVlrEstMedPerm IS NULL OR NVL(wVlrEstMedPerm, 0) = 0 THEN
            wVlrPerm := 0;
        ELSE
            wVlrPerm := ROUND(
                            360 / (wVlrCustoPerm / (wVlrEstMedPerm / 365.25)),
                            0
                        );
        END IF;

        IF wVlrPerm > 9999 THEN
            wVlrPerm := 9999;
        END IF;

        IF wVlrPerm < 0 THEN
            wVlrPerm := 0;
        END IF;

        /**** pontuação pela faixa parametrizada ****/
        OPEN c_calc;
        FETCH c_calc INTO r_calc;

        WHILE c_calc%FOUND LOOP
            IF r_calc.cod_calculo = 2 THEN
                IF wVlrPerm >= r_calc.valor1
                   AND wVlrPerm <= r_calc.valor2 THEN
                    wQtd_Pontos_Perm := r_calc.qtd_pontos;
                END IF;
            END IF;

            FETCH c_calc INTO r_calc;
        END LOOP;

        CLOSE c_calc;

        BEGIN
            SELECT cod_quebra
              INTO wRegiao
              FROM ge_grupos_unidades
             WHERE cod_unidade = r_totais_unidades.cod_unidade
               AND cod_grupo   = PI_CODGRUPO;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                wRegiao := 0;
        END;

        /**** grava pontuação anual ****/
        OPEN c_apr;
        FETCH c_apr INTO r_apr;

        IF c_apr%FOUND THEN
            UPDATE grz_dados_calculo_apr_anual
               SET permanencia    = wQtd_Pontos_Perm,
                   tip_unidade    = 1,
                   cod_rede       = PI_CODREDE,
                   regiao         = wRegiao,
                   data_referencia = PI_DATA_REF
             WHERE cod_unidade = r_totais_unidades.cod_unidade
               AND ano         = TO_CHAR(PI_DATA_REF, 'YYYY');
        ELSE
            INSERT INTO grz_dados_calculo_apr_anual
                (cod_unidade,
                 permanencia,
                 cod_rede,
                 tip_unidade,
                 regiao,
                 ano,
                 data_referencia)
            VALUES
                (r_totais_unidades.cod_unidade,
                 wQtd_Pontos_Perm,
                 PI_CODREDE,
                 1,
                 wRegiao,
                 TO_CHAR(PI_DATA_REF, 'YYYY'),
                 PI_DATA_REF);
        END IF;

        CLOSE c_apr;

        /**** grava valores-base usados no cálculo anual ****/
        OPEN c_apr_regiao;
        FETCH c_apr_regiao INTO r_apr_regiao;

        IF c_apr_regiao%FOUND THEN
            UPDATE grz_valores_regioes_apr_anual
               SET vlr_custo_perm     = wVlrCustoPerm,
                   vlr_est_medio_perm = wVlrEstMedPerm,
                   regiao             = wRegiao,
                   cod_rede           = PI_CODREDE
             WHERE cod_unidade = r_totais_unidades.cod_unidade
               AND ano         = TO_CHAR(PI_DATA_REF, 'YYYY');
        ELSE
            INSERT INTO grz_valores_regioes_apr_anual
                (cod_unidade,
                 vlr_custo_perm,
                 vlr_est_medio_perm,
                 regiao,
                 cod_rede,
                 ano)
            VALUES
                (r_totais_unidades.cod_unidade,
                 wVlrCustoPerm,
                 wVlrEstMedPerm,
                 wRegiao,
                 PI_CODREDE,
                 TO_CHAR(PI_DATA_REF, 'YYYY'));
        END IF;

        CLOSE c_apr_regiao;

        FETCH c_totais_unidades INTO r_totais_unidades;
    END LOOP;

    CLOSE c_totais_unidades;

    COMMIT;

EXCEPTION
    WHEN SAIDA THEN
        NULL;
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END GRZ_PERMANENCIA_APR_ANUAL_SP;
