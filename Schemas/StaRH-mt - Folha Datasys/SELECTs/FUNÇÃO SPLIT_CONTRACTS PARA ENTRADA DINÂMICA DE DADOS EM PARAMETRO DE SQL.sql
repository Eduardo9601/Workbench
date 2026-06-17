/*

--CRIAÇÃO DE FUNÇÃO QUE POSSA TRATAR A DINÂMICA DE ENTRADA DE DADOS EM PARAMETRO.
----Q NESSE CASO SERIA A ENTRADA DINÂMICA DE CONTRATOS PARA O RETORNO DO RESULTADO

DROP FUNCTION SPLIT_CONTRACTS


SELECT * FROM USER_TAB_PRIVS WHERE TABLE_NAME = 'SPLIT_CONTRACTS'

SELECT OBJECT_NAME, STATUS
FROM USER_OBJECTS
WHERE OBJECT_TYPE = 'FUNCTION' AND OBJECT_NAME = 'SPLIT_CONTRACTS'


SELECT * FROM TABLE(SPLIT_CONTRACTS(:COD_CONTRATO))


CREATE OR REPLACE FUNCTION SPLIT_CONTRACTS(p_input IN VARCHAR2)
    RETURN SYS.ODCINUMBERLIST PIPELINED
IS
    l_value VARCHAR2(4000);
    l_pos   NUMBER;
    l_input VARCHAR2(4000); -- Variável local para armazenar e manipular o p_input
BEGIN
    l_input := p_input; -- Atribuindo o valor do parâmetro de entrada à variável local
    l_pos := INSTR(l_input, ',');

    WHILE l_pos > 0 LOOP
        l_value := TRIM(SUBSTR(l_input, 1, l_pos - 1));
        PIPE ROW(TO_NUMBER(l_value));
        l_input := SUBSTR(l_input, l_pos + 1);
        l_pos := INSTR(l_input, ',');
    END LOOP;

    -- Adicionando o último valor
    PIPE ROW(TO_NUMBER(TRIM(l_input)));

    RETURN;
END SPLIT_CONTRACTS;

*/