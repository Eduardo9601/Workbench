/*SQL EXEMPLO DE SAVEPOINT*/

--SAVEPOINT: Define um ponto dentro de uma transação para poder reverter até ele, se necessário.

SAVEPOINT before_delete;
DELETE FROM orders WHERE order_date < TO_DATE('2022-01-01', 'YYYY-MM-DD');
ROLLBACK TO before_delete;


/*SQL EXEMPLO DE CRIAÇÃO DE UM SAVEPOINT ANTES DE QUALQUER OPERAÇÃO QUE AFETE OS DADOS DE UMA TABELA*/

-- Verifique o estado original
SELECT * FROM employees WHERE department_id = 10;

-- Crie um savepoint
SAVEPOINT before_update_1;

-- Atualize dados
UPDATE employees SET salary = salary * 1.1 WHERE department_id = 10;

-- Verifique o resultado da atualização
SELECT * FROM employees WHERE department_id = 10;

-- Reverte para o savepoint
ROLLBACK TO before_update_1;

-- Verifique se os dados voltaram ao estado original
SELECT * FROM employees WHERE department_id = 10;
