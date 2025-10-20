--Esta consulta SQL tem como objetivo copiar as permissões do perfil 1 e do módulo 'FP' para o perfil 48 na tabela RHUS0020. 
--A consulta utiliza a cláusula MERGE para sincronizar as informações entre os dois perfis, atualizando registros existentes, 
  --se necessário, e inserindo novos registros, caso não existam correspondências.

Em resumo, a consulta assegura que o perfil 48 tenha as mesmas permissões que o perfil 1 para o módulo 'FP' na tabela RHUS0020.    
    
MERGE INTO RHUS0020 TARGET
USING (
    SELECT
        48 AS COD_PERFIL,
        COD_PRODUTO,
        COD_MODULO,
        COD_MENU,
        LIB_FUNCAO
    FROM
        RHUS0020
    WHERE
        COD_PERFIL = 1 AND
        COD_MODULO = 'FP'
) SOURCE
ON (
    TARGET.COD_PERFIL = SOURCE.COD_PERFIL AND
    TARGET.COD_PRODUTO = SOURCE.COD_PRODUTO AND
    TARGET.COD_MODULO = SOURCE.COD_MODULO AND
    TARGET.COD_MENU = SOURCE.COD_MENU
)
WHEN MATCHED THEN
    UPDATE SET TARGET.LIB_FUNCAO = SOURCE.LIB_FUNCAO
WHEN NOT MATCHED THEN
    INSERT (COD_PERFIL, COD_PRODUTO, COD_MODULO, COD_MENU, LIB_FUNCAO)
    VALUES (SOURCE.COD_PERFIL, SOURCE.COD_PRODUTO, SOURCE.COD_MODULO, SOURCE.COD_MENU, SOURCE.LIB_FUNCAO);





--=====================================================================================================================---


--SQL QUE SERVE DESS VEZ PARA COPIAR DE UM PERFIL ESPECÍFICO UM DETERMINADO MENU DE UM DETERMINADO MÓDULO

MERGE INTO RHUS0020 target
USING (
    SELECT
        48 AS COD_PERFIL, -- novo valor para COD_PERFIL
        COD_PRODUTO,
        COD_MODULO,
        COD_MENU,
        LIB_FUNCAO
    FROM
        RHUS0020
    WHERE
        COD_PERFIL = 1 AND -- perfil de origem
        COD_MODULO = 'FP' AND -- módulo de origem
        COD_MENU = 'menu_desejado' -- menu específico que você deseja copiar
) source
ON (
    target.COD_PERFIL = source.COD_PERFIL AND
    target.COD_PRODUTO = source.COD_PRODUTO AND
    target.COD_MODULO = source.COD_MODULO AND
    target.COD_MENU = source.COD_MENU
)
WHEN MATCHED THEN
    UPDATE SET target.LIB_FUNCAO = source.LIB_FUNCAO
WHEN NOT MATCHED THEN
    INSERT (COD_PERFIL, COD_PRODUTO, COD_MODULO, COD_MENU, LIB_FUNCAO)
    VALUES (source.COD_PERFIL, source.COD_PRODUTO, source.COD_MODULO, source.COD_MENU, source.LIB_FUNCAO);
