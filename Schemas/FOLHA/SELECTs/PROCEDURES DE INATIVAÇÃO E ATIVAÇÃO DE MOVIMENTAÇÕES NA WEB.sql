--PROCEDURES DE INATIVAÇÃO E ATIVAÇÃO DE MOVIMENTAÇÕES PARA OPERADORES COM PERFIL DE ACESSO 21


--Procedure de INATIVAÇÃO

CREATE OR REPLACE PROCEDURE GRZ_FOLHA_INATIVA_MOV AS

  /******************************************/
  /******************************************/
  /****   VERSÃO: 1.0                    ****/
  /****   CRIADO POR: EDUARDO            ****/
  /****   ANTERADO POR: EDUARDO          ****/
  /****   DATA DA ALTERAÇÃO: 02/05/2023  ****/
  /******************************************/
  /******************************************/

  wDataAtual DATE;

  CURSOR C1 IS
    SELECT OP.COD_OPERADOR,
           OP.COD_CLIENTE,
           OP.COD_EMPRESA,
           OP.COD_PRODUTO,
           OP.COD_MODULO,
           OP.COD_MENU,
           OP.LIB_FUNCAO
      FROM OPERMENU OP, OPERADOR OPER
     WHERE OPER.COD_OPERADOR = OP.COD_OPERADOR
       AND OPER.COD_PERFIL = 21
       AND OP.COD_MENU = 'miWC257';
  r1 C1%ROWTYPE;

BEGIN
  wDataAtual := TRUNC(SYSDATE);

  IF TO_CHAR(wDataAtual, 'DD') = '20' THEN
    FOR R1 IN C1 LOOP
      UPDATE OPERMENU
         SET LIB_FUNCAO = 17 -- PERMISSÃO SOMENTE DE CONSULTAS
       WHERE COD_MENU = 'miWC257'
         AND COD_OPERADOR = r1.COD_OPERADOR;
    END LOOP;
  END IF;
  -- COMMIT;
END GRZ_FOLHA_INATIVA_MOV;


--============================================================================--
--============================================================================--


--Procedure de ATIVAÇÃO

CREATE OR REPLACE PROCEDURE GRZ_FOLHA_ATIVA_MOV AS

  /******************************************/
  /******************************************/
  /****   VERSÃO: 1.0                    ****/
  /****   CRIADO POR: EDUARDO            ****/
  /****   ANTERADO POR: EDUARDO          ****/
  /****   DATA DA ALTERAÇÃO: 02/05/2023  ****/
  /******************************************/
  /******************************************/
  
  wDataAtual DATE;

  CURSOR C1 IS
    SELECT OP.COD_OPERADOR,
           OP.COD_CLIENTE,
           OP.COD_EMPRESA,
           OP.COD_PRODUTO,
           OP.COD_MODULO,
           OP.COD_MENU,
           OP.LIB_FUNCAO
      FROM OPERMENU OP, OPERADOR OPER
     WHERE OPER.COD_OPERADOR = OP.COD_OPERADOR
       AND OPER.COD_PERFIL = 21
       AND OP.COD_MENU = 'miWC257';
  r1 C1%ROWTYPE;

BEGIN
  wDataAtual := TRUNC(SYSDATE);

  IF TO_CHAR(wDataAtual, 'DD') = '01' THEN
    FOR R1 IN C1 LOOP
      UPDATE OPERMENU
         SET LIB_FUNCAO = 31 -- PERMISSÃO DE CONSULTAR, INSERIR, DELETAR E EDITAR
       WHERE COD_MENU = 'miWC257'
         AND COD_OPERADOR = r1.COD_OPERADOR;
    END LOOP;
  END IF;
  -- COMMIT;
END GRZ_FOLHA_ATIVA_MOV;