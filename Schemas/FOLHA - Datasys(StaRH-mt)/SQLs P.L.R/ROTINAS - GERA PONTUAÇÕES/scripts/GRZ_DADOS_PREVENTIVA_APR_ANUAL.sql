CREATE OR REPLACE PROCEDURE NL.GRZ_PREVENTIVA_APR_ANUAL_SP (
    PI_OPCAO IN VARCHAR2
) IS
    /**** parâmetros de entrada ****/
    PI_CODEMP   NUMBER;
    PI_CODREDE  VARCHAR2(02);
    PI_CODGRUPO NUMBER;
    PI_INDICE   NUMBER;
    PI_DATA_REF DATE;

    Wi                         NUMBER;
    Wf                         NUMBER;
    wPer_Preventiva            NUMBER;
    wQtd_Pontos_Preventiva_CRE NUMBER;
    wRegiao                    NUMBER;
    v_cur                      INTEGER;
    v_result                   INTEGER;

    SAIDA EXCEPTION;

    /******************************************************************
      CURSOR PRINCIPAL
      AJUSTE APLICADO:
      - CONSOLIDA POR MÊS
      - SOMA VALORES DO MESMO MÊS
      - QTD_MESES = CONTAGEM DE MESES DISTINTOS COM VALOR > 0
      - FILTRO DE REDE/REGIÃO NA MESMA IDEIA DA ROTINA NOVA
    ******************************************************************/

CURSOR c_valores IS
    SELECT
        X.COD_UNIDADE,
        MIN(X.MES)           AS DTA_INICIAL,
        MAX(LAST_DAY(X.MES)) AS DTA_FINAL,
        SUM(X.VLR_PREV_MES)  AS VLR_PREVENTIVA,
        COUNT(CASE
                WHEN X.VLR_PREV_MES > 0 THEN 1
              END)           AS QTD_MESES
    FROM (
        SELECT
            TRUNC(A.DTA_MOVIMENTO, 'MM') AS MES,
            A.COD_UNIDADE,
            SUM(NVL(A.VLR_PREVENTIVO, 0)) AS VLR_PREV_MES
        FROM ES_0124_CR_PROJECAO A
        JOIN GE_GRUPOS_UNIDADES B
          ON B.COD_UNIDADE = A.COD_UNIDADE
         AND B.COD_GRUPO   = PI_CODGRUPO
         AND B.COD_EMP     = PI_CODEMP
        WHERE A.DTA_MOVIMENTO >= TRUNC(PI_DATA_REF, 'YYYY')
          AND A.DTA_MOVIMENTO <= PI_DATA_REF
          AND A.COD_GRUPO_LCTO = PI_INDICE
          AND A.COD_QUEBRA_LCTO = 1
          AND A.COD_UNIDADE <> 0
          AND TO_CHAR(A.COD_GRUPO_UNI) LIKE '%8%'
          AND TO_CHAR(A.COD_QUEBRA_UNI) NOT LIKE '%8%'
          AND TO_CHAR(A.COD_QUEBRA_UNI) = PI_CODREDE
        GROUP BY
            TRUNC(A.DTA_MOVIMENTO, 'MM'),
            A.COD_UNIDADE
    ) X
    GROUP BY X.COD_UNIDADE
    ORDER BY X.COD_UNIDADE;

    r_valores c_valores%ROWTYPE;

    /******************************************************************
      CURSOR CIA/REDE 70
      MANTIDO NO MESMO FORMATO DA ROTINA ANTIGA, MAS COM A MESMA
      CORREÇÃO DE CONSOLIDAÇÃO MENSAL
    ******************************************************************/
    CURSOR c_valores_cia IS
        SELECT
            X.COD_UNIDADE,
            MIN(X.MES)                AS DTA_INICIAL,
            MAX(LAST_DAY(X.MES))      AS DTA_FINAL,
            SUM(X.VLR_PREV_MES)       AS VLR_PREVENTIVA,
            COUNT(CASE
                    WHEN X.VLR_PREV_MES > 0 THEN 1
                  END)                AS QTD_MESES
        FROM (
            SELECT
                TRUNC(A.DTA_MOVIMENTO, 'MM') AS MES,
                A.COD_UNIDADE,
                SUM(NVL(A.VLR_PREVENTIVO, 0)) AS VLR_PREV_MES
            FROM ES_0124_CR_PROJECAO A
            JOIN GE_GRUPOS_UNIDADES B
              ON B.COD_UNIDADE = A.COD_UNIDADE
             AND B.COD_GRUPO   = PI_CODGRUPO
             AND B.COD_EMP     = PI_CODEMP
            WHERE A.DTA_MOVIMENTO >= TRUNC(PI_DATA_REF, 'YYYY')
              AND A.DTA_MOVIMENTO <= PI_DATA_REF
              AND A.COD_GRUPO_LCTO = PI_INDICE
              AND A.COD_QUEBRA_LCTO = 1
              AND A.COD_UNIDADE <> 0
              AND CASE
                    WHEN TO_CHAR(A.COD_GRUPO_UNI) LIKE '%8%' THEN 1
                  END = 1
              AND CASE
                    WHEN TO_CHAR(A.COD_QUEBRA_UNI) NOT LIKE '%8%' THEN TO_CHAR(A.COD_QUEBRA_UNI)
                  END = PI_CODREDE
            GROUP BY
                TRUNC(A.DTA_MOVIMENTO, 'MM'),
                A.COD_UNIDADE
        ) X
        GROUP BY X.COD_UNIDADE
        ORDER BY X.COD_UNIDADE;

    r_valores_cia c_valores_cia%ROWTYPE;

    /**** cursor registro dados APR ****/
    CURSOR c_apr IS
        SELECT *
          FROM GRZ_DADOS_CALCULO_APR_ANUAL
         WHERE COD_UNIDADE = r_valores.COD_UNIDADE
           AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY');
    r_apr c_apr%ROWTYPE;

    CURSOR c_apr_cia IS
        SELECT *
          FROM GRZ_DADOS_CALCULO_APR_ANUAL
         WHERE COD_UNIDADE = r_valores_cia.COD_UNIDADE
           AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY');
    r_apr_cia c_apr_cia%ROWTYPE;

    CURSOR c_apr_regiao_cia IS
        SELECT *
          FROM GRZ_VALORES_REGIOES_APR_ANUAL
         WHERE COD_UNIDADE = r_valores_cia.COD_UNIDADE
           AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY');
    r_apr_regiao_cia c_apr_regiao_cia%ROWTYPE;

    CURSOR c_calc_cia IS
        SELECT *
          FROM GRZ_CAD_CALCULO_APR_ANUAL
         WHERE COD_REDE = PI_CODREDE
           AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY')
           AND COD_CALCULO IN (3)
         ORDER BY COD_CALCULO, QTD_PONTOS;
    r_calc_cia c_calc_cia%ROWTYPE;

    CURSOR c_apr_regiao IS
        SELECT *
          FROM GRZ_VALORES_REGIOES_APR_ANUAL
         WHERE COD_UNIDADE = r_valores.COD_UNIDADE
           AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY');
    r_apr_regiao c_apr_regiao%ROWTYPE;

    CURSOR c_calc IS
        SELECT *
          FROM GRZ_CAD_CALCULO_APR_ANUAL
         WHERE COD_REDE = PI_CODREDE
           AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY')
           AND COD_CALCULO IN (3)
         ORDER BY COD_CALCULO, QTD_PONTOS;
    r_calc c_calc%ROWTYPE;

BEGIN
    v_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(
        v_cur,
        'alter session set nls_date_format = ''dd/mm/rrrr''',
        DBMS_SQL.NATIVE
    );
    v_result := DBMS_SQL.EXECUTE(v_cur);
    DBMS_SQL.CLOSE_CURSOR(v_cur);

    /**** desmembra a opção recebida ****/
    Wi          := INSTR(PI_OPCAO, '#', 1, 1);
    PI_CODEMP   := TO_NUMBER(SUBSTR(PI_OPCAO, 1, (Wi - 1)));

    Wf          := INSTR(PI_OPCAO, '#', 1, 2);
    PI_CODREDE  := SUBSTR(PI_OPCAO, (Wi + 1), (Wf - Wi - 1));

    Wi          := Wf;
    Wf          := INSTR(PI_OPCAO, '#', 1, 3);
    PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO, (Wi + 1), (Wf - Wi - 1)));

    Wi          := Wf;
    Wf          := INSTR(PI_OPCAO, '#', 1, 4);
    PI_INDICE   := TO_NUMBER(SUBSTR(PI_OPCAO, (Wi + 1), (Wf - Wi - 1)));

    Wi          := Wf;
    Wf          := INSTR(PI_OPCAO, '#', 1, 5);
    PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO, (Wi + 1), (Wf - Wi - 1)), 'DD/MM/YYYY');

    /**** mantém o comportamento legado da rotina ****/
    PI_INDICE := 57;

    IF PI_CODREDE = '70' THEN
        OPEN c_valores_cia;
        FETCH c_valores_cia INTO r_valores_cia;

        WHILE c_valores_cia%FOUND LOOP
            IF r_valores_cia.QTD_MESES > 0 THEN
                wPer_Preventiva := TRUNC(r_valores_cia.VLR_PREVENTIVA / r_valores_cia.QTD_MESES, 1);

                wQtd_Pontos_Preventiva_CRE := 0;
                OPEN c_calc_cia;
                FETCH c_calc_cia INTO r_calc_cia;

                WHILE c_calc_cia%FOUND LOOP
                    IF r_calc_cia.COD_CALCULO = 3 THEN
                        IF wPer_Preventiva <= r_calc_cia.VALOR1 THEN
                            wQtd_Pontos_Preventiva_CRE := r_calc_cia.QTD_PONTOS;
                        END IF;
                    END IF;

                    FETCH c_calc_cia INTO r_calc_cia;
                END LOOP;
                CLOSE c_calc_cia;

                BEGIN
                    wRegiao := 0;
                    SELECT COD_QUEBRA
                      INTO wRegiao
                      FROM GE_GRUPOS_UNIDADES
                     WHERE COD_UNIDADE = r_valores_cia.COD_UNIDADE
                       AND COD_GRUPO IN (PI_CODGRUPO);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        wRegiao := 0;
                END;

                OPEN c_apr_cia;
                FETCH c_apr_cia INTO r_apr_cia;

                IF c_apr_cia%FOUND THEN
                    UPDATE GRZ_DADOS_CALCULO_APR_ANUAL
                       SET PREVENTIVA      = wQtd_Pontos_Preventiva_CRE,
                           TIP_UNIDADE     = 1,
                           COD_REDE        = PI_CODREDE,
                           REGIAO          = wRegiao,
                           DATA_REFERENCIA = PI_DATA_REF
                     WHERE COD_UNIDADE = r_valores_cia.COD_UNIDADE
                       AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY');
                ELSE
                    INSERT INTO GRZ_DADOS_CALCULO_APR_ANUAL
                        (COD_UNIDADE,
                         PREVENTIVA,
                         COD_REDE,
                         TIP_UNIDADE,
                         REGIAO,
                         ANO,
                         DATA_REFERENCIA)
                    VALUES
                        (r_valores_cia.COD_UNIDADE,
                         wQtd_Pontos_Preventiva_CRE,
                         PI_CODREDE,
                         1,
                         wRegiao,
                         TO_CHAR(PI_DATA_REF, 'YYYY'),
                         PI_DATA_REF);
                END IF;

                CLOSE c_apr_cia;
            END IF;

            OPEN c_apr_regiao_cia;
            FETCH c_apr_regiao_cia INTO r_apr_regiao_cia;

            IF c_apr_regiao_cia%FOUND THEN
                UPDATE GRZ_VALORES_REGIOES_APR_ANUAL
                   SET VLR_PREVENTIVA = r_valores_cia.VLR_PREVENTIVA,
                       QTD_MESES      = r_valores_cia.QTD_MESES,
                       REGIAO         = wRegiao,
                       COD_REDE       = PI_CODREDE
                 WHERE COD_UNIDADE = r_valores_cia.COD_UNIDADE
                   AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY');
            ELSE
                INSERT INTO GRZ_VALORES_REGIOES_APR_ANUAL
                    (COD_UNIDADE,
                     VLR_PREVENTIVA,
                     QTD_MESES,
                     REGIAO,
                     COD_REDE,
                     ANO)
                VALUES
                    (r_valores_cia.COD_UNIDADE,
                     r_valores_cia.VLR_PREVENTIVA,
                     r_valores_cia.QTD_MESES,
                     wRegiao,
                     PI_CODREDE,
                     TO_CHAR(PI_DATA_REF, 'YYYY'));
            END IF;

            CLOSE c_apr_regiao_cia;

            FETCH c_valores_cia INTO r_valores_cia;
        END LOOP;

        CLOSE c_valores_cia;

    ELSE
        OPEN c_valores;
        FETCH c_valores INTO r_valores;

        WHILE c_valores%FOUND LOOP
            IF r_valores.QTD_MESES > 0 THEN
                wPer_Preventiva := TRUNC(r_valores.VLR_PREVENTIVA / r_valores.QTD_MESES, 1);

                wQtd_Pontos_Preventiva_CRE := 0;
                OPEN c_calc;
                FETCH c_calc INTO r_calc;

                WHILE c_calc%FOUND LOOP
                    IF r_calc.COD_CALCULO = 3 THEN
                        IF wPer_Preventiva <= r_calc.VALOR1 THEN
                            wQtd_Pontos_Preventiva_CRE := r_calc.QTD_PONTOS;
                        END IF;
                    END IF;

                    FETCH c_calc INTO r_calc;
                END LOOP;
                CLOSE c_calc;

                BEGIN
                    wRegiao := 0;
                    SELECT COD_QUEBRA
                      INTO wRegiao
                      FROM GE_GRUPOS_UNIDADES
                     WHERE COD_UNIDADE = r_valores.COD_UNIDADE
                       AND COD_GRUPO IN (PI_CODGRUPO);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        wRegiao := 0;
                END;

                OPEN c_apr;
                FETCH c_apr INTO r_apr;

                IF c_apr%FOUND THEN
                    UPDATE GRZ_DADOS_CALCULO_APR_ANUAL
                       SET PREVENTIVA      = wQtd_Pontos_Preventiva_CRE,
                           TIP_UNIDADE     = 1,
                           COD_REDE        = PI_CODREDE,
                           REGIAO          = wRegiao,
                           DATA_REFERENCIA = PI_DATA_REF
                     WHERE COD_UNIDADE = r_valores.COD_UNIDADE
                       AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY');
                ELSE
                    INSERT INTO GRZ_DADOS_CALCULO_APR_ANUAL
                        (COD_UNIDADE,
                         PREVENTIVA,
                         COD_REDE,
                         TIP_UNIDADE,
                         REGIAO,
                         ANO,
                         DATA_REFERENCIA)
                    VALUES
                        (r_valores.COD_UNIDADE,
                         wQtd_Pontos_Preventiva_CRE,
                         PI_CODREDE,
                         1,
                         wRegiao,
                         TO_CHAR(PI_DATA_REF, 'YYYY'),
                         PI_DATA_REF);
                END IF;

                CLOSE c_apr;
            END IF;

            OPEN c_apr_regiao;
            FETCH c_apr_regiao INTO r_apr_regiao;

            IF c_apr_regiao%FOUND THEN
                UPDATE GRZ_VALORES_REGIOES_APR_ANUAL
                   SET VLR_PREVENTIVA = r_valores.VLR_PREVENTIVA,
                       QTD_MESES      = r_valores.QTD_MESES,
                       REGIAO         = wRegiao,
                       COD_REDE       = PI_CODREDE
                 WHERE COD_UNIDADE = r_valores.COD_UNIDADE
                   AND ANO = TO_CHAR(PI_DATA_REF, 'YYYY');
            ELSE
                INSERT INTO GRZ_VALORES_REGIOES_APR_ANUAL
                    (COD_UNIDADE,
                     VLR_PREVENTIVA,
                     QTD_MESES,
                     REGIAO,
                     COD_REDE,
                     ANO)
                VALUES
                    (r_valores.COD_UNIDADE,
                     r_valores.VLR_PREVENTIVA,
                     r_valores.QTD_MESES,
                     wRegiao,
                     PI_CODREDE,
                     TO_CHAR(PI_DATA_REF, 'YYYY'));
            END IF;

            CLOSE c_apr_regiao;

            FETCH c_valores INTO r_valores;
        END LOOP;

        CLOSE c_valores;
    END IF;

    COMMIT;

EXCEPTION
    WHEN SAIDA THEN
        NULL;
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END GRZ_PREVENTIVA_APR_ANUAL_SP;
