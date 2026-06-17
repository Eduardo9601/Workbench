---TABELAS REFERENTE AS PESQUISAS NO MÓDULO CARGOS E SALÁRIOS

SELECT * FROM RHCS0915; -- PRIMEIRA A DELETAR
 
DELETE 
FROM RHCS0915
WHERE COD_IDENT_PESQUISA IN (1, 2, 3, 4)

---------------------------------------------------------------

SELECT * FROM RHCS0930;  --SEGUNDA A DELETAR
     
DELETE 
FROM RHCS0930
WHERE COD_AREA_AVALIACAO = 1

--------------------------------------------------------------

SELECT * FROM RHCS0920;  --TERCEIRA A DELETAR

DELETE 
FROM RHCS0920
WHERE COD_AREA_AVALIACAO IN (1, 2)

--------------------------------------------------------------

SELECT * FROM RHCS0890;  -- QUARTA A DELETAR

DELETE 
FROM RHCS0890
WHERE IDENTIFICACAO = 1

--------------------------------------------------------------

SELECT * FROM RHCS0910; -- QUINTA A DELETAR
 
DELETE 
FROM RHCS0910
WHERE SITUACAO IN (1, 2)

--------------------------------------------------------------

SELECT * FROM RHCS0900; --SEXTA A DELETAR

DELETE 
FROM RHCS0900
WHERE COD_PESQUISA_OPINIAO IN (1, 2)

--------------------------------------------------------------

SELECT * FROM RHCS0880; -- SÉTIMA A DELETAR

DELETE 
FROM RHCS0880
WHERE COD_PESQUISA_OPINIAO IN (1, 2, 3)

--------------------------------------------------------------

SELECT * FROM RHCS0870; -- OITAVA A DELETAR 

DELETE 
FROM RHCS0870
WHERE COD_PESQUISA_OPINIAO IN (1, 2, 3)