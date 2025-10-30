--SEQUENCIA DE AUTO-INCREMENTO

CREATE SEQUENCE seq_cod_lotacao
START WITH 15
INCREMENT BY 1
NOCACHE
NOCYCLE;



create sequence SEQ_COD_LOTACAO
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache


--=============

--procedimento para deletar e criar novamente a sequencia em caso de precisar alterar o 
--número da sequencia a ser inserido

DROP SEQUENCE seq_cod_lotacao

CREATE SEQUENCE seq_cod_lotacao
START WITH 23 -- ou o número que segue o maior COD_LOTACAO na sua tabela
INCREMENT BY 1
NOCACHE
NOCYCLE