/*SQL PLANO DE EXECUÇÃO EM VIEWS E TABELAS
O que é?

O plano de execução é uma ferramenta crucial no Oracle para entender como o banco de dados vai processar uma consulta SQL. 
Ele mostra a sequência de operações que serão realizadas, como junções (joins), varreduras de tabelas, uso de índices, ordenações, e muito mais. Compreender o plano de execução é essencial para otimizar consultas e melhorar o desempenho geral do banco de dados.

Como Usar?

Gerar o Plano de Execução:

Use o comando EXPLAIN PLAN FOR para gerar o plano de execução da consulta que deseja analisar.
Exemplo:*/

EXPLAIN PLAN FOR
SELECT * FROM V_DADOS_COLAB_AVT; --exemplo



/*Visualizar o Plano de Execução:

Para visualizar o plano gerado, utilize o comando SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);.
Exemplo:*/

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);



/*O que Analisar no Plano de Execução?

Operações de Acesso: Verifique como as tabelas são acessadas (via índices, full table scans, etc.).
Junções (Joins): Identifique o tipo de junções utilizadas (nested loops, hash joins, etc.).
Ordenações e Agrupamentos: Veja se há operações de ordenação ou agrupamento que possam ser otimizadas.
Uso de Índices: Certifique-se de que os índices adequados estão sendo utilizados.
Dicas para Otimização:

Índices: Verifique se as colunas usadas em joins e filtros estão devidamente indexadas.
Redução de Tabelas: Evite junções desnecessárias ou verifique a ordem das junções.
Substitua Nested Loops: Em conjuntos de dados grandes, considere usar hash joins ao invés de nested loops.*/