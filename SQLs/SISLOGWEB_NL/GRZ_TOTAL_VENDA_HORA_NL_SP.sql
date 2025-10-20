CREATE OR REPLACE PROCEDURE NL.GRZ_TOTAL_VENDA_HORA_NL_SP(PI_OPCAO IN VARCHAR2) IS
BEGIN
  DECLARE

    /**** Parametros de entrada ****/

    PI_COD_GRUPO NUMBER;
    PI_DATA_INI  VARCHAR2(10);
    PI_DATA_FIM  VARCHAR2(10);
    PI_UNI_INI   NUMBER;
    PI_UNI_FIM   NUMBER;
    PI_USUARIO   VARCHAR2(30);
    PI_HORA_INI1 VARCHAR2(10);
    PI_HORA_FIM1 VARCHAR2(10);
    PI_HORA_INI2 VARCHAR2(10);
    PI_HORA_FIM2 VARCHAR2(10);
    PI_HORA_INI3 VARCHAR2(10);
    PI_HORA_FIM3 VARCHAR2(10);
    PI_HORA_INI4 VARCHAR2(10);
    PI_HORA_FIM4 VARCHAR2(10);

    PI_HORA_INI5  VARCHAR2(10);
    PI_HORA_FIM5  VARCHAR2(10);
    PI_HORA_INI6  VARCHAR2(10);
    PI_HORA_FIM6  VARCHAR2(10);
    PI_HORA_INI7  VARCHAR2(10);
    PI_HORA_FIM7  VARCHAR2(10);
    PI_HORA_INI8  VARCHAR2(10);
    PI_HORA_FIM8  VARCHAR2(10);
    PI_HORA_INI9  VARCHAR2(10);
    PI_HORA_FIM9  VARCHAR2(10);
    PI_HORA_INI10 VARCHAR2(10);
    PI_HORA_FIM10 VARCHAR2(10);
    PI_HORA_INI11 VARCHAR2(10);
    PI_HORA_FIM11 VARCHAR2(10);
    PI_HORA_INI12 VARCHAR2(10);
    PI_HORA_FIM12 VARCHAR2(10);

    PI_DIA_SEMANA VARCHAR2(20);

    WI                    NUMBER;
    WF                    NUMBER;
    WCOD_REDE             NUMBER;
    WVLR_DIFERENCA        NUMBER(18, 2);
    WDES_UNIDADE          VARCHAR2(50);
    WDES_REDE             VARCHAR2(50);
    WVLR_LIQUIDO          NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO1 NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO2 NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO3 NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO4 NUMBER(18, 2);
    WVLR_REDUCAOZ         NUMBER(18, 2);
    WPERCENT              NUMBER(18, 2);

    WVLR_LIQUIDO_HORARIO5  NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO6  NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO7  NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO8  NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO9  NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO10 NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO11 NUMBER(18, 2);
    WVLR_LIQUIDO_HORARIO12 NUMBER(18, 2);

    /**** Cursor para ler o valor das operacoes e liquido da reducao z ****/
    CURSOR C_CUPOM_OPERACOES IS
      SELECT C.COD_GRUPO,
             C.COD_QUEBRA,
             B.COD_UNIDADE,
             B.DTA_EMISSAO,
             TO_CHAR(B.DTA_EMISSAO, 'DAY') AS DIA,
             NVL(SUM(A.VLR_PRODUTOS), 0) AS VLR_PRODUTOS,
             NVL(SUM(A.VLR_ACRESCIMO), 0) AS VLR_ACRESCIMO,
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO,
             COUNT(B.NUM_NOTA) AS QTD_CUPOM
        FROM NS_NOTAS_OPERACOES A, NS_NOTAS B, GE_GRUPOS_UNIDADES C
       WHERE A.NUM_SEQ = B.NUM_SEQ
         AND A.COD_MAQUINA = B.COD_MAQUINA
         AND B.COD_EMP = 1
         AND (B.TIP_NOTA = 3 OR (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
         AND B.IND_STATUS = 1
         AND A.COD_OPER IN (300,4300,302,4302,305,4305)
         AND B.COD_UNIDADE = C.COD_UNIDADE
         AND C.COD_GRUPO = PI_COD_GRUPO
         AND B.COD_UNIDADE >= PI_UNI_INI
         AND B.COD_UNIDADE <= PI_UNI_FIM
         AND B.DTA_EMISSAO >= TO_DATE(PI_DATA_INI, 'dd/mm/yyyy')
         AND B.DTA_EMISSAO <= TO_DATE(PI_DATA_FIM, 'dd/mm/yyyy')
         AND (INSTR(',' || PI_DIA_SEMANA || ',',
                    ',' || TO_CHAR(B.DTA_EMISSAO, 'D') || ',') > 0)
         AND NOT EXISTS
       (SELECT 1
                FROM V_UNIDADES VUNI
               INNER JOIN PS_JURIDICAS PSJ ON PSJ.NUM_CGC = VUNI.NUM_CGC
               INNER JOIN V_UNIDADES VUN ON VUN.COD_UNIDADE = PSJ.COD_PESSOA
               WHERE PSJ.COD_PESSOA = B.COD_UNIDADE
                 AND VUNI.REDE = 70
                 AND VUN.REDE <> 70)
       GROUP BY C.COD_GRUPO, C.COD_QUEBRA, B.COD_UNIDADE, B.DTA_EMISSAO;

    R_CUPOM_OPERACOES C_CUPOM_OPERACOES%ROWTYPE;

    /**** Inicio da procedure principal ****/
  BEGIN
    /**** Desmembra a opcao recebida ****/
    WI           := INSTR(PI_OPCAO, '#', 1, 1);
    PI_COD_GRUPO := TO_NUMBER(SUBSTR(PI_OPCAO, 1, (WI - 1)));
    WF           := INSTR(PI_OPCAO, '#', 1, 2);
    PI_DATA_INI  := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 3);
    PI_DATA_FIM  := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 4);
    PI_UNI_INI   := TO_NUMBER(SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1)));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 5);
    PI_UNI_FIM   := TO_NUMBER(SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1)));

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 6);
    PI_HORA_INI1 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 7);
    PI_HORA_FIM1 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 8);
    PI_HORA_INI2 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 9);
    PI_HORA_FIM2 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 10);
    PI_HORA_INI3 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 11);
    PI_HORA_FIM3 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 12);
    PI_HORA_INI4 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 13);
    PI_HORA_FIM4 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI            := WF;
    WF            := INSTR(PI_OPCAO, '#', 1, 14);
    PI_DIA_SEMANA := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI            := WF;
    WF            := INSTR(PI_OPCAO, '#', 1, 15);
    PI_USUARIO    := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    --fth

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 16);
    PI_HORA_INI5 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 17);
    PI_HORA_FIM5 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 18);
    PI_HORA_INI6 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 19);
    PI_HORA_FIM6 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 20);
    PI_HORA_INI7 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 21);
    PI_HORA_FIM7 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 22);
    PI_HORA_INI8 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 23);
    PI_HORA_FIM8 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 24);
    PI_HORA_INI9 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI           := WF;
    WF           := INSTR(PI_OPCAO, '#', 1, 25);
    PI_HORA_FIM9 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI            := WF;
    WF            := INSTR(PI_OPCAO, '#', 1, 26);
    PI_HORA_INI10 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI            := WF;
    WF            := INSTR(PI_OPCAO, '#', 1, 27);
    PI_HORA_FIM10 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI            := WF;
    WF            := INSTR(PI_OPCAO, '#', 1, 28);
    PI_HORA_INI11 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI            := WF;
    WF            := INSTR(PI_OPCAO, '#', 1, 29);
    PI_HORA_FIM11 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    WI            := WF;
    WF            := INSTR(PI_OPCAO, '#', 1, 30);
    PI_HORA_INI12 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));
    WI            := WF;
    WF            := INSTR(PI_OPCAO, '#', 1, 31);
    PI_HORA_FIM12 := SUBSTR(PI_OPCAO, (WI + 1), (WF - WI - 1));

    /**** Limpa a tabela temporaria ****/
    WVLR_LIQUIDO_HORARIO1 := 0;
    WVLR_LIQUIDO_HORARIO2 := 0;
    WVLR_LIQUIDO_HORARIO3 := 0;
    WVLR_LIQUIDO_HORARIO4 := 0;

    WVLR_LIQUIDO_HORARIO5  := 0;
    WVLR_LIQUIDO_HORARIO6  := 0;
    WVLR_LIQUIDO_HORARIO7  := 0;
    WVLR_LIQUIDO_HORARIO8  := 0;
    WVLR_LIQUIDO_HORARIO9  := 0;
    WVLR_LIQUIDO_HORARIO10 := 0;
    WVLR_LIQUIDO_HORARIO11 := 0;
    WVLR_LIQUIDO_HORARIO12 := 0;

    DELETE FROM GRZW_REL_LOJAS_CUPONS
     WHERE UPPER(DES_USUARIO) = UPPER(PI_USUARIO);
    COMMIT;

    BEGIN
      SELECT DES_GRUPO
        INTO WDES_REDE
        FROM GE_GRUPOS
       WHERE COD_GRUPO = PI_COD_GRUPO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        WDES_REDE := 'GRUPO INVALIDO';
    END;

    /**** Abre o cursor de redes ****/
    OPEN C_CUPOM_OPERACOES;
    FETCH C_CUPOM_OPERACOES
      INTO R_CUPOM_OPERACOES;
    WHILE C_CUPOM_OPERACOES%FOUND LOOP
      BEGIN

        BEGIN
          SELECT SUM(NVL(A.VLR_OPERACAO, 0)) AS VLR_OPERACAO
            INTO WVLR_LIQUIDO
            FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
           WHERE A.NUM_SEQ = B.NUM_SEQ
             AND A.COD_MAQUINA = B.COD_MAQUINA
             AND B.COD_EMP = 1
             AND B.TIP_NOTA = 4
             AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
             AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WVLR_LIQUIDO := 0;

        END;

        IF PI_HORA_INI1 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO1
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.IND_STATUS = 1
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI1)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM1);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO1 := 0;
          END;
        END IF;
        IF PI_HORA_INI2 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO2
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI2)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM2);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO2 := 0;
          END;
        END IF;

        IF PI_HORA_INI3 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO3
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI3)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM3);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO3 := 0;
          END;

        END IF;

        IF PI_HORA_INI4 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO4
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI4)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM4);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO4 := 0;
          END;

        END IF;

        IF PI_HORA_INI5 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO5
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI5)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM5);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO5 := 0;
          END;
        END IF;

        IF PI_HORA_INI6 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO6
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI6)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM6);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO6 := 0;
          END;
        END IF;

        IF PI_HORA_INI7 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO7
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI7)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM7);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO7 := 0;
          END;
        END IF;

        IF PI_HORA_INI8 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO8
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI8)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM8);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO8 := 0;
          END;
        END IF;

        IF PI_HORA_INI9 <> '  :  :  ' THEN
          BEGIN
            SELECT -- count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO9
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI9)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM9);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO9 := 0;
          END;
        END IF;

        IF PI_HORA_INI10 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO10
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI10)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM10);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO10 := 0;
          END;
        END IF;

        IF PI_HORA_INI11 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO11
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI11)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM11);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO11 := 0;
          END;
        END IF;

        IF PI_HORA_INI12 <> '  :  :  ' THEN
          BEGIN
            SELECT --count(b.num_nota)
             NVL(SUM(A.VLR_OPERACAO), 0) AS VLR_OPERACAO
              INTO WVLR_LIQUIDO_HORARIO12
              FROM NS_NOTAS_OPERACOES A, NS_NOTAS B
             WHERE A.NUM_SEQ = B.NUM_SEQ
               AND A.COD_MAQUINA = B.COD_MAQUINA
               AND B.COD_EMP = 1
               AND (B.TIP_NOTA = 3 OR
                   (B.TIP_NOTA = 2 AND B.NUM_MODELO = 65))
               AND B.IND_STATUS = 1
               AND A.COD_OPER IN (300,4300,302,4302,305,4305)
               AND B.COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE
               AND B.DTA_EMISSAO = R_CUPOM_OPERACOES.DTA_EMISSAO
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') >=
                   TO_CHAR(PI_HORA_INI12)
               AND TO_CHAR(B.DTH_FIM_VENDA, 'hh24:MI:SS') <=
                   TO_CHAR(PI_HORA_FIM12);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              WVLR_LIQUIDO_HORARIO12 := 0;
          END;
        END IF;

        WPERCENT := (WVLR_LIQUIDO_HORARIO1 / R_CUPOM_OPERACOES.VLR_OPERACAO) * 100;
        WPERCENT := TRUNC(WPERCENT, 2);

        WVLR_REDUCAOZ := NVL(WVLR_LIQUIDO, 0);

        WVLR_DIFERENCA := WVLR_REDUCAOZ -
                          NVL(R_CUPOM_OPERACOES.VLR_OPERACAO, 0);

        BEGIN
          SELECT DES_NOME
            INTO WDES_UNIDADE
            FROM GE_UNIDADES
           WHERE COD_UNIDADE = R_CUPOM_OPERACOES.COD_UNIDADE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            WDES_UNIDADE := 'SEM DESCRICAO';
        END;

        INSERT INTO GRZW_REL_LOJAS_CUPONS
          (DES_USUARIO,
           COD_UNIDADE,
           DES_UNIDADE,
           NUM_REDE,
           DES_REDE,
           DTA_LANCAMENTO,
           VLR_PRODUTOS,
           VLR_ACRESCIMO,
           VLR_TOTAL,
           VLR_REDUCAOZ,
           VLR_DIFERENCA,
           VLR_VENDA_HORARIO,
           PERCENT_HORA,
           DES_DIA_SEMANA,
           VLR_VENDA_HORARIO2,
           VLR_VENDA_HORARIO3,
           VLR_VENDA_HORARIO4,
           NUM_REGIAO,
           VLR_VENDA_HORARIO5,
           VLR_VENDA_HORARIO6,
           VLR_VENDA_HORARIO7,
           VLR_VENDA_HORARIO8,
           VLR_VENDA_HORARIO9,
           VLR_VENDA_HORARIO10,
           VLR_VENDA_HORARIO11,
           VLR_VENDA_HORARIO12)
        VALUES
          (PI_USUARIO,
           R_CUPOM_OPERACOES.COD_UNIDADE,
           WDES_UNIDADE,
           PI_COD_GRUPO,
           WDES_REDE,
           R_CUPOM_OPERACOES.DTA_EMISSAO,
           R_CUPOM_OPERACOES.VLR_PRODUTOS,
           R_CUPOM_OPERACOES.VLR_ACRESCIMO,
           R_CUPOM_OPERACOES.VLR_OPERACAO --qtd_cupom
          ,
           WVLR_REDUCAOZ,
           WVLR_DIFERENCA,
           WVLR_LIQUIDO_HORARIO1,
           WPERCENT,
           R_CUPOM_OPERACOES.DIA,
           WVLR_LIQUIDO_HORARIO2,
           WVLR_LIQUIDO_HORARIO3,
           WVLR_LIQUIDO_HORARIO4,
           R_CUPOM_OPERACOES.COD_QUEBRA,
           WVLR_LIQUIDO_HORARIO5,
           WVLR_LIQUIDO_HORARIO6,
           WVLR_LIQUIDO_HORARIO7,
           WVLR_LIQUIDO_HORARIO8,
           WVLR_LIQUIDO_HORARIO9,
           WVLR_LIQUIDO_HORARIO10,
           WVLR_LIQUIDO_HORARIO11,
           WVLR_LIQUIDO_HORARIO12);
      END;
      FETCH C_CUPOM_OPERACOES
        INTO R_CUPOM_OPERACOES;
    END LOOP;
    CLOSE C_CUPOM_OPERACOES;
    COMMIT;
  END;
END GRZ_TOTAL_VENDA_HORA_NL_SP;


