=====================================
==========PROCEDURE ANTIGA===========

CREATE OR REPLACE PROCEDURE GRZ_FOLHA_INATIVA_REQ_E_MOV
AS
BEGIN

DECLARE
wDataAtual DATE;

 -- CURSOR DE LIBERAÇÕES DOS USUÁRIOS
 CURSOR C1 IS
    SELECT COD_OPERADOR, COD_CLIENTE, COD_EMPRESA, COD_PRODUTO, COD_MODULO, COD_MENU, LIB_FUNCAO
    FROM OPERMENU
    WHERE COD_MENU IN ('miWC255', 'miWC257');
 r1   C1%ROWTYPE;

  BEGIN
  
  wDataAtual := TRUNC(SYSDATE);
  
      FOR R1 IN C1 LOOP
      
      IF(wDataAtual) >= TO_DATE('20/'||TO_CHAR(TRUNC(SYSDATE),'MM/YYYY')) AND (wDataAtual) <= LAST_DAY(TRUNC(SYSDATE)) THEN
         UPDATE OPERMENU 
         SET LIB_FUNCAO = 17 -- PERMISSÃO SOMENTE DE CONSULTAS
         WHERE COD_MENU IN ('miWC255', 'miWC257'); 
      ELSE
         UPDATE OPERMENU 
         SET LIB_FUNCAO = 31 -- PERMISSÃO DE CONSULTAR, INSERIR, DELETAR E EDITAR
         WHERE COD_MENU IN ('miWC255', 'miWC257');  
      END IF;
  
      END LOOP;
   -- COMMIT;
  END;

END GRZ_FOLHA_INATIVA_REQ_E_MOV;

==================================================================================================================================================
==================================================================================================================================================
==================================================================================================================================================
==================================================================================================================================================

=========================================
==========PROCEDURE ATUALIZADA===========

CREATE OR REPLACE PROCEDURE GRZ_FOLHA_INATIVA_MOV
AS
BEGIN

DECLARE
wDataAtual DATE;

 -- CURSOR DE LIBERAÇÕES DOS USUÁRIOS
 CURSOR C1 IS
    SELECT OP.COD_OPERADOR, OP.COD_CLIENTE, OP.COD_EMPRESA, OP.COD_PRODUTO, OP.COD_MODULO, OP.COD_MENU, OP.LIB_FUNCAO
    FROM OPERMENU OP, OPERADOR OPER
    WHERE OPER.COD_OPERADOR = OP.COD_OPERADOR
      AND OPER.COD_PERFIL = 21
      AND OP.COD_MENU = 'miWC257';
 r1   C1%ROWTYPE;

  BEGIN

  wDataAtual := TRUNC(SYSDATE);

      FOR R1 IN C1 LOOP

      IF(wDataAtual) > TO_DATE('20/'||TO_CHAR(TRUNC(SYSDATE),'MM/YYYY')) AND (wDataAtual) <= LAST_DAY(TRUNC(SYSDATE)) THEN
         UPDATE OPERMENU
         SET LIB_FUNCAO = 17 -- PERMISSÃO DE SOMENTE DE CONSULTAS
         WHERE COD_MENU = 'miWC257'
		   AND COD_OPERADOR = r1.COD_OPERADOR;
      ELSE
         UPDATE OPERMENU
         SET LIB_FUNCAO = 31 -- PERMISSÃO DE CONSULTAR, INSERIR, DELETAR E EDITAR
         WHERE COD_MENU = 'miWC257'
		   AND COD_OPERADOR = r1.COD_OPERADOR;
      END IF;

      END LOOP;
   -- COMMIT;
  END;

END GRZ_FOLHA_INATIVA_MOV;