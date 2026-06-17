/*FUNÇÃO PARA PERCORRER HIERARQUIA DO ORGANOGRAMA DO CONTRATO*/

1. Remoção dos Tipos e Função Anteriormente Criados
Antes de recriar os tipos e a função, você removeu os tipos e a função anteriores para evitar conflitos:

DROP TYPE T_ORGANOGRAMA_HIERARQUIA_TABLE;
DROP FUNCTION F_OBTER_HIERARQUIA_ORG;
DROP TYPE T_ORGANOGRAMA_HIERARQUIA;

--========================================

2. Criação do Tipo de Objeto T_ORGANOGRAMA_NIVEL
Este tipo de objeto (OBJECT) representa um nível específico na hierarquia do organograma. Ele contém três atributos:

COD_ORGANOGRAMA: O código único do organograma.
EDICAO_ORG: A edição do organograma.
NOME_ORGANOGRAMA: O nome do organograma.

CREATE OR REPLACE TYPE T_ORGANOGRAMA_NIVEL AS OBJECT (
    COD_ORGANOGRAMA NUMBER(15),
    EDICAO_ORG VARCHAR2(10),
    NOME_ORGANOGRAMA VARCHAR2(1000)
);


--========================================

3. Criação do Tipo de Objeto T_ORGANOGRAMA_HIERARQUIA
Este tipo de objeto é uma coleção de oito objetos T_ORGANOGRAMA_NIVEL. Cada atributo representa um nível da hierarquia:

NIVEL1 a NIVEL8: Cada um desses níveis armazena um objeto T_ORGANOGRAMA_NIVEL.

CREATE OR REPLACE TYPE T_ORGANOGRAMA_HIERARQUIA AS OBJECT (
    NIVEL1 T_ORGANOGRAMA_NIVEL,
    NIVEL2 T_ORGANOGRAMA_NIVEL,
    NIVEL3 T_ORGANOGRAMA_NIVEL,
    NIVEL4 T_ORGANOGRAMA_NIVEL,
    NIVEL5 T_ORGANOGRAMA_NIVEL,
    NIVEL6 T_ORGANOGRAMA_NIVEL,
    NIVEL7 T_ORGANOGRAMA_NIVEL,
    NIVEL8 T_ORGANOGRAMA_NIVEL
);


--==========================================

4. Criação do Tipo de Tabela T_ORGANOGRAMA_HIERARQUIA_TABLE
Este tipo de tabela é uma coleção de objetos T_ORGANOGRAMA_HIERARQUIA. Ele permite que a função retorne múltiplas linhas de hierarquia em uma tabela.

CREATE OR REPLACE TYPE T_ORGANOGRAMA_HIERARQUIA_TABLE AS TABLE OF T_ORGANOGRAMA_HIERARQUIA;


--===========================================

5. Criação da Função F_OBTER_HIERARQUIA_ORG
Esta função PL/SQL é uma função PIPELINED que retorna uma tabela de hierarquias organizacionais, cada uma composta por até oito níveis.

Componentes Principais:
Parâmetro de Entrada:

p_cod_org: O código do organograma a partir do qual a hierarquia será derivada.
Variáveis Internas:

v_cod_org, v_edicao_org, v_nome_org: Armazenam temporariamente as informações de cada nível.
v_cod_org_sub: Armazena o código do organograma subordinado (nível superior).
v_nivel: Um contador para acompanhar o nível atual.
v_nivel1 a v_nivel8: Objetos T_ORGANOGRAMA_NIVEL para armazenar as informações de cada nível da hierarquia.
Lógica da Função:

A função começa preenchendo o nível mais específico (nível 6), que é o organograma diretamente relacionado ao código fornecido.
A função então itera através da hierarquia de organogramas, subindo até 8 níveis. A cada iteração, preenche as variáveis correspondentes aos níveis superiores (do mais específico ao mais genérico).
Ao final do loop, a função retorna os objetos preenchidos através de PIPE ROW.


CREATE OR REPLACE FUNCTION F_OBTER_HIERARQUIA_ORG (
    p_cod_org IN NUMBER
) RETURN T_ORGANOGRAMA_HIERARQUIA_TABLE PIPELINED IS
    v_cod_org NUMBER(15);
    v_edicao_org VARCHAR2(10);
    v_nome_org VARCHAR2(1000);
    v_cod_org_sub NUMBER;
    v_nivel NUMBER := 1;

    -- Variáveis para os níveis
    v_nivel1 T_ORGANOGRAMA_NIVEL := T_ORGANOGRAMA_NIVEL(NULL, NULL, NULL);
    v_nivel2 T_ORGANOGRAMA_NIVEL := T_ORGANOGRAMA_NIVEL(NULL, NULL, NULL);
    v_nivel3 T_ORGANOGRAMA_NIVEL := T_ORGANOGRAMA_NIVEL(NULL, NULL, NULL);
    v_nivel4 T_ORGANOGRAMA_NIVEL := T_ORGANOGRAMA_NIVEL(NULL, NULL, NULL);
    v_nivel5 T_ORGANOGRAMA_NIVEL := T_ORGANOGRAMA_NIVEL(NULL, NULL, NULL);
    v_nivel6 T_ORGANOGRAMA_NIVEL := T_ORGANOGRAMA_NIVEL(NULL, NULL, NULL);
    v_nivel7 T_ORGANOGRAMA_NIVEL := T_ORGANOGRAMA_NIVEL(NULL, NULL, NULL);
    v_nivel8 T_ORGANOGRAMA_NIVEL := T_ORGANOGRAMA_NIVEL(NULL, NULL, NULL);

BEGIN
    -- Inicializar com o nome do organograma inicial
    SELECT R1.COD_ORGANOGRAMA, R2.EDICAO_ORG, R1.NOME_ORGANOGRAMA, R2.COD_ORGANOGRAMA_SUB
    INTO v_cod_org, v_edicao_org, v_nome_org, v_cod_org_sub
    FROM RHFP0400 R1
    INNER JOIN RHFP0401 R2 ON R1.COD_ORGANOGRAMA = R2.COD_ORGANOGRAMA
    WHERE R1.COD_ORGANOGRAMA = p_cod_org
    AND ROWNUM = 1; -- Garantir que só pegue uma linha

    -- Atribuir ao nível correspondente, começando do mais específico
    v_nivel6 := T_ORGANOGRAMA_NIVEL(v_cod_org, v_edicao_org, v_nome_org);

    -- Loop para percorrer a hierarquia do organograma
    LOOP
        EXIT WHEN v_cod_org_sub IS NULL OR v_nivel >= 8;

        v_nivel := v_nivel + 1;

        SELECT R1.COD_ORGANOGRAMA, R2.EDICAO_ORG, R1.NOME_ORGANOGRAMA, R2.COD_ORGANOGRAMA_SUB
        INTO v_cod_org, v_edicao_org, v_nome_org, v_cod_org_sub
        FROM RHFP0400 R1
        INNER JOIN RHFP0401 R2 ON R1.COD_ORGANOGRAMA = R2.COD_ORGANOGRAMA
        WHERE R1.COD_ORGANOGRAMA = v_cod_org_sub
        AND ROWNUM = 1; -- Garantir que só pegue uma linha

        CASE v_nivel
            WHEN 2 THEN v_nivel5 := T_ORGANOGRAMA_NIVEL(v_cod_org, v_edicao_org, v_nome_org);
            WHEN 3 THEN v_nivel4 := T_ORGANOGRAMA_NIVEL(v_cod_org, v_edicao_org, v_nome_org);
            WHEN 4 THEN v_nivel3 := T_ORGANOGRAMA_NIVEL(v_cod_org, v_edicao_org, v_nome_org);
            WHEN 5 THEN v_nivel2 := T_ORGANOGRAMA_NIVEL(v_cod_org, v_edicao_org, v_nome_org);
            WHEN 6 THEN v_nivel1 := T_ORGANOGRAMA_NIVEL(v_cod_org, v_edicao_org, v_nome_org);
            WHEN 7 THEN v_nivel7 := T_ORGANOGRAMA_NIVEL(v_cod_org, v_edicao_org, v_nome_org);
            WHEN 8 THEN v_nivel8 := T_ORGANOGRAMA_NIVEL(v_cod_org, v_edicao_org, v_nome_org);
        END CASE;
    END LOOP;

    PIPE ROW (T_ORGANOGRAMA_HIERARQUIA(v_nivel1, v_nivel2, v_nivel3, v_nivel4, v_nivel5, v_nivel6, v_nivel7, v_nivel8));
END;
/

--======================================


6. Utilização da Função no SQL Principal
Finalmente, a função é utilizada em um SELECT para recuperar os dados de contratos, juntamente com as informações de cada nível da hierarquia do organograma.

Componentes Principais:
Consultando o Contrato: A tabela RHFP0310 é consultada para obter os contratos.
Join com a Função F_OBTER_HIERARQUIA_ORG: A função é usada em um LEFT JOIN para obter as informações da hierarquia do organograma em colunas separadas.
Exibindo Níveis: Cada nível (NIVEL1 a NIVEL8) é exibido com seu respectivo COD_ORGANOGRAMA, EDICAO_ORG, e NOME_ORGANOGRAMA.


/*sql exemplo*/
SELECT 
    c.COD_CONTRATO,
    c.DATA_INICIO,
    c.DATA_FIM,
    o.NIVEL1.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_NIVEL1,
    o.NIVEL1.EDICAO_ORG AS EDICAO_ORG_NIVEL1,
    o.NIVEL1.NOME_ORGANOGRAMA AS NOME_NIVEL1,
    o.NIVEL2.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_NIVEL2,
    o.NIVEL2.EDICAO_ORG AS EDICAO_ORG_NIVEL2,
    o.NIVEL2.NOME_ORGANOGRAMA AS NOME_NIVEL2,
    o.NIVEL3.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_NIVEL3,
    o.NIVEL3.EDICAO_ORG AS EDICAO_ORG_NIVEL3,
    o.NIVEL3.NOME_ORGANOGRAMA AS NOME_NIVEL3,
    o.NIVEL4.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_NIVEL4,
    o.NIVEL4.EDICAO_ORG AS EDICAO_ORG_NIVEL4,
    o.NIVEL4.NOME_ORGANOGRAMA AS NOME_NIVEL4,
    o.NIVEL5.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_NIVEL5,
    o.NIVEL5.EDICAO_ORG AS EDICAO_ORG_NIVEL5,
    o.NIVEL5.NOME_ORGANOGRAMA AS NOME_NIVEL5,
    o.NIVEL6.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_NIVEL6,
    o.NIVEL6.EDICAO_ORG AS EDICAO_ORG_NIVEL6,
    o.NIVEL6.NOME_ORGANOGRAMA AS NOME_NIVEL6,
    o.NIVEL7.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_NIVEL7,
    o.NIVEL7.EDICAO_ORG AS EDICAO_ORG_NIVEL7,
    o.NIVEL7.NOME_ORGANOGRAMA AS NOME_NIVEL7,
    o.NIVEL8.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_NIVEL8,
    o.NIVEL8.EDICAO_ORG AS EDICAO_ORG_NIVEL8,
    o.NIVEL8.NOME_ORGANOGRAMA AS NOME_NIVEL8
FROM RHFP0310 c
LEFT JOIN TABLE(F_OBTER_HIERARQUIA_ORG(c.COD_ORGANOGRAMA)) o
ON 1 = 1
WHERE c.COD_CONTRATO = 389622;
















