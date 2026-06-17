BANCO DE DADOS
Principais comandos em Oracle

01) TO_CHAR

Converte valores em texto, o || serve para concatenar strings

SELECT ‘R$ ‘ || TO_CHAR(12.7+13.5) AS PRECOFROM DUAL;


SELECT TO_CHAR(SYSDATE,‘DD/MM/YYYY HH24:MI:SS D DY DAY’) AS HOJEFROM DUAL;

===============================================================================================================================

02) TO_DATE

Converte texto em Data-Hora

SELECT TO_DATE(’21/08/2013 14:30:00', ‘DD/MM/YYYY HH24:MI:SS’) AS DIAFROM DUAL;

===============================================================================================================================

03) TO_NUMBER

Converte texto em número

SELECT TO_NUMBER(‘34,47’) AS VALORFROM DUAL;

===============================================================================================================================

04) INITCAP

Deixa o primeiro caracter da string em maiúsculo

===============================================================================================================================SELECT INITCAP(‘DANIEL ATILIO’) AS NOMEFROM DUAL;

05) LOWER

Deixa todos os caracteres da string em minúsculo

SELECT LOWER(‘DANIEL ATILIO’) AS NOMEFROM DUAL;

===============================================================================================================================
06) UPPER

Deixa todos os caracteres da string em maiúsculo

SELECT UPPER(‘daniel atilio’) AS NOMEFROM DUAL;
UPPER

===============================================================================================================================

07) LPAD

Adiciona caracteres a esquerda com um tamanho definido, ou quebra a string atual com um tamanho pré-determinado

SELECT LPAD(‘Daniel’,3) AS APELIDOFROM DUAL;


Abaixo um exemplo utilizando traço

SELECT LPAD(‘Daniel’,7,‘-‘) AS NOMEFROM DUAL;

===============================================================================================================================

08) RPAD

Adiciona caracteres a direita com um tamanho definido, ou quebra a string atual com um tamanho pré-determinado

SELECT RPAD(‘Daniel’,3) AS APELIDOFROM DUAL;


Abaixo um exemplo utilizando traço

SELECT RPAD(‘Daniel’,7,‘-‘) AS NOMEFROM DUAL;

===============================================================================================================================

09) LTRIM

Retira espaços da esquerda da string

SELECT   LTRIM(‘    Daniel    ‘) AS NOMEFROM DUAL;

===============================================================================================================================

10) RTRIM

Retira espaços da direita da string

SELECT   RTRIM(‘    Daniel    ‘) AS NOMEFROM DUAL;

===============================================================================================================================

11) TRIM

Retira espaços da esquerda e da direita da string

SELECT   TRIM(‘    Daniel    ‘) AS NOMEFROM DUAL; 

===============================================================================================================================

12) SUBSTR

Pega uma parte da string, uma substring, através da posição inicial e do total de caracteres

SELECT   SUBSTR(‘Daniel Atilio’,8,6) AS SOBRENOMEFROM DUAL;

===============================================================================================================================

13) INSTR

Retorna a posição da substring procurada, conforme posição inicial e o número de vezes encontrado

SELECT   INSTR(‘DANIEL ATILIO’,‘I’,1,2) AS NOMEFROM DUAL;

===============================================================================================================================

14) REPLACE

Troca uma parte da string por outra

SELECT   REPLACE(‘DANIEL ATILIO’,‘ATILIO’,‘HUDSON’) AS NOMEFROM DUAL;

===============================================================================================================================

15) TRANSLATE

Traduz uma String, conforme caracteres buscados e suas respectivas conversões

SELECT   TRANSLATE(‘DANIEL ATILIO’, ‘AIOED’, ‘4103>’) AS TRADUCAOFROM DUAL;
TRANSLATE

===============================================================================================================================

16) LENGTH

Retorna o tamanho da String

SELECT   LENGTH(‘DANIEL ATILIO’) AS TAMANHOFROM DUAL;

===============================================================================================================================

17) ABS

Retorna o valor absoluto do número

SELECT   ABS(-37.42) AS ABSOLUTOFROM DUAL;

===============================================================================================================================

18) CEIL

Retorna o maior número inteiro através de um número passado

SELECT   CEIL(5.99) AS INTEIROFROM DUAL;
CEIL

===============================================================================================================================

Também é possível utilizar com números negativos

SELECT   CEIL(-5.30) AS INTEIROFROM DUAL;

===============================================================================================================================

19) FLOOR

Retorna o menor número inteiro através de um número passado

SELECT   FLOOR(5.99) AS INTEIROFROM DUAL;

===============================================================================================================================

Também é possível utilizar com números negativos

SELECT   FLOOR(-5.30) AS INTEIROFROM DUAL;

===============================================================================================================================

20) MOD

Retorna o resto de uma divisão

SELECT   MOD (15,4) AS RESTOFROM DUAL;

===============================================================================================================================

21) TRUNC

Retorna um valor truncado com casas decimais

SELECT   TRUNC(125.8154, 2) AS VALORFROM DUAL;

===============================================================================================================================

22) SYSDATE

Retorna o dia atual

SELECT SYSDATE AS HOJEFROM DUAL;

===============================================================================================================================

23) POWER

Retorna um valor em sua potencia, por exemplo 2 elevado a 5

SELECT  POWER(2,5) AS POTENCIAFROM DUAL;

===============================================================================================================================

24) SQRT

Retorna a raíz quadrada de um valor

SELECT   SQRT(144) AS RAIZFROM DUAL;



25) ROUND

Retorna um valor arredondado, conforme casas decimais passadas por referência

SELECT   ROUND(15.194,1) AS ARREDONDADOFROM DUAL;


Abaixo um exemplo com duas casas decimais

SELECT   ROUND(15.194,2) AS ARREDONDADOFROM DUAL;

===============================================================================================================================

26) LAST_DAY

Retorna o último dia do mês corrente

SELECT  LAST_DAY(SYSDATE) AS ULTIMO_DIAFROM DUAL;

===============================================================================================================================

27) NEXT_DAY

Retorna o próxima dia conforme parâmetros (por exemplo, a próxima terça-feira)

SELECT   NEXT_DAY(’22-AGO-2013',‘TERCA-FEIRA’) AS PROXIMO_DIAFROM DUAL;

===============================================================================================================================

28) ADD_MONTHS

Retorna a data somando um número de meses

SELECT   ADD_MONTHS(SYSDATE,2) AS DOIS_MESESFROM DUAL;

===============================================================================================================================

29) MONTHS_BETWEEN

Retorna a quantidade de meses entre duas datas

SELECT   MONTHS_BETWEEN (’22/08/2013', ’22/12/2013' ) AS ENTREFROM DUAL;

===============================================================================================================================

30) DECODE

Semelhante ao IF/ELSE, onde é testado um bloco de código, os possíveis resultados, e as strings que serão mostradas

SELECT   DECODE(TRUNC (10/5),0, ‘ 0/5 = 0’,1, ‘ 5/5 = 1’,
2, ’10/5 = 2',

===============================================================================================================================

31) NVL

Se a string estiver vazia, retorna um texto passado por parâmetro

SELECT   NVL(”,‘STRING VAZIA’) AS RESULTADOFROM DUAL;


Abaixo um exemplo com string não vazia

SELECT   NVL(‘DANIEL’,‘STRING VAZIA’) AS RESULTADOFROM DUAL;

=============================================================================================================================
=============================================================================================================================

-- Configura formato de data padrão
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

-- Verificar as constraints de uma tabela
SELECT * FROM ALL_CONSTRAINTS WHERE TABLE_NAME = '<TABELA>'

-- Alterando o valor atual de uma sequence
alter sequence <SEQUENCE> increment by 64711;
select <SEQUENCE>.NEXTVAL from dual;
alter sequence <SEQUENCE> increment by 1;



-- Verifica se existe espaço disponível no arquivo de dados (datafiles) e se eles são extensíveis 
select
a.file_id,
b.file_name,
b.autoextensible,
b.bytes/1024/1024 t1,
sum(a.bytes)/1024/1024 t2
from dba_extents a , dba_data_files b
where a.file_id=b.file_id
group by
a.file_id,b.file_name, autoextensible, b.bytes/1024/1024


-- Mostra quem está lockando o que
select 
  oracle_username
  os_user_name,
  locked_mode,
  object_name,
  object_type
from 
  v$locked_object a,dba_objects b
where 
  a.object_id = b.object_id

-- Comentários no oracle
SELECT * FROM ALL_COL_COMMENTS WHERE TABLE_NAME = '<NOME_DA_TABELA>'

-- Recupera select em formato XML
select dbms_xmlgen.getxml('select employee_id, first_name,2 last_name, phone_number from employees where rownum < 6') from dual

-- Procura todas as referências a uma tabela
select *
from dba_dependencies
where referenced_name = '<TABELA>' and owner = '<owner>'
order by referenced_owner, TYPE, NAME;


-- Verifica quem está bloqueando
select s1.username || '@' || s1.machine
|| ' ( SID=' || s1.sid || ' )  is blocking '
|| s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid and s2.sid=l2.sid
and l1.BLOCK=1 and l2.request > 0
and l1.id1 = l2.id1
and l2.id2 = l2.id2 ;


-- Mostra todos os usuários logados
SELECT LPAD(' ', (level-1)*2, ' ') || NVL(s.username, '(oracle)') AS username,
s.osuser,
s.sid,
s.serial#,
s.lockwait,
s.status,
s.module,
s.machine,
s.program,
TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM v$session s
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL;


-- Mostra objetos locados
select 
distinct to_name object_locked
from 
v$object_dependency 
where 
to_address in
(
select /*+ ordered */
w.kgllkhdl address
from 
dba_kgllock w, 
dba_kgllock h, 
v$session w1, 
v$session h1
where
(((h.kgllkmod != 0) and (h.kgllkmod != 1)
and ((h.kgllkreq = 0) or (h.kgllkreq = 1)))
and
(((w.kgllkmod = 0) or (w.kgllkmod= 1))
and ((w.kgllkreq != 0) and (w.kgllkreq != 1))))
and w.kgllktype = h.kgllktype
and w.kgllkhdl = h.kgllkhdl
and w.kgllkuse = w1.saddr
and h.kgllkuse = h1.saddr
);


-- Busca por conexões lentas
select
   b.machine         host,
   b.username        username,
   b.server,
   b.osuser          os_user,
   b.program         program,
   a.tablespace_name ts_name,
   row_wait_file#    file_nbr,
   row_wait_block#   block_nbr,
   c.owner,
   c.segment_name,
   c.segment_type
from
   dba_data_files a,
   v$session      b,
   dba_extents    c 
where b.row_wait_file# = a.file_id
and c.file_id = row_wait_file#
and row_wait_block#  between c.block_id and c.block_id + c.blocks - 1
and row_wait_file# <> 0
and type='USER';



-- Recuperar todos os privilégios sobre um objeto
SELECT table_name, grantee,
MAX(DECODE(privilege, 'SELECT', 'SELECT')) AS select_priv,
MAX(DECODE(privilege, 'DELETE', 'DELETE')) AS delete_priv,
MAX(DECODE(privilege, 'UPDATE', 'UPDATE')) AS update_priv,
MAX(DECODE(privilege, 'INSERT', 'INSERT')) AS insert_priv
FROM dba_tab_privs
WHERE table_name = '<TABLE_NAME>' and grantee IN (
  SELECT role
  FROM dba_roles)
GROUP BY table_name, grantee;

-- Backup de banco de dados apenas os metadados
expdp backup/backup content=metadata_only directory=expdp dumpfile=expdp_metadata.dmp logfile=expdpmetadata.log