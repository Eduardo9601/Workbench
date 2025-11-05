CREATE OR REPLACE FUNCTION SPLIT_VARIABLES(p_input IN VARCHAR2)
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
END SPLIT_VARIABLES;
/
