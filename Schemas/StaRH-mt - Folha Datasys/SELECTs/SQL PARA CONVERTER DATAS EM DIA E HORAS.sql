--COMANDO PARA CONVERTER DATAS EM DIAS E HORAS.


SELECT DATA_FIM,DATA_INICIO, DATA_FIM - DATA_INICIO DIAS,
       TRUNC(24 * (DATA_FIM - DATA_INICIO)) HORAS
FROM RHFP0306;


====

SELECT DATA_FIM,data_inicio, DATA_FIM - data_inicio dias,
       trunc(24 * (DATA_FIM - DATA_INICIO)) horas
FROM RHFP0306;


============================================================================================
ou
============================================================================================

select to_char(sysdate,'cc dd/mm/yyyy hh24:mi:ss') data from dual;


SELECT ROUND(((TO_NUMBER(TO_DATE('02/06/2006 11:00','DD/MM/RRRR HH24:MI') - 
                         TO_DATE('01/06/2006 10:30','DD/MM/RRRR HH24:MI')) * 1440))/60)||':'||
            ROUND((TO_NUMBER(TO_DATE('02/06/2006 11:00','DD/MM/RRRR HH24:MI') - 
                         TO_DATE('01/06/2006 10:30','DD/MM/RRRR HH24:MI')) * 1440) -1440)
FROM DUAL



============================================================================================
ou
============================================================================================



SELECT ROUND(TO_NUMBER(TO_DATE(DATA_INICIO, 'dd/mm/yyyy') - TO_DATE(DATA_FIM, 'dd/mm/yyyy'))) *24 AS DATEDIFF 
FROM RHFP0306
WHERE COD_CONTRATO = 273236

==

SELECT ROUND((24 * TO_NUMBER(TO_DATE(DATA_INICIO, 'dd/mm/yyyy') - TO_DATE(DATA_FIM, 'dd/mm/yyyy')))) 
FROM RHFP0306
WHERE COD_CONTRATO = 273236





============================================================================================
ou
============================================================================================