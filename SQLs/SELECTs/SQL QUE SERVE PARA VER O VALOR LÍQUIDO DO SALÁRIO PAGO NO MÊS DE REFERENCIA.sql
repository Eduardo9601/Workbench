--====================================================================================================--


--SQL QUE SERVE PARA VER O VALOR LÍQUIDO DO SALÁRIO PAGO NO MÊS DE REFERENCIA

SELECT *--TO_CHAR(SUM(VALOR_VD), '9G999G999G990D00') AS VALOR 
FROM RHFP1005 -- RHFP1006
WHERE COD_CONTRATO = 389622
AND COD_VD = 1003;


--VDs E O QUE SÃO CADA 1

--950 > REM SALARIO
--907 BASE DE FERIAS PROVISOES
--1006 Total Líquido

SELECT * FROM RHFP1000
WHERE COD_VD = 1003



--====================================================================================================--