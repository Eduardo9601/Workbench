--SELECT  PARA ENCONTRAR TABELAS PELA CONSTRAINT

--VERSÃO 1
SELECT owner, table_name
FROM all_constraints
WHERE constraint_name = 'NOME_DA_CONSTRAINT';


--VERSÃO 2
SELECT acc.owner, acc.table_name, acc.column_name
FROM all_cons_columns acc
JOIN all_constraints ac ON acc.constraint_name = ac.constraint_name AND acc.owner = ac.owner
WHERE ac.constraint_name = 'NOME_DA_CONSTRAINT';
