--========================================================================================================--
--UPDATE UTILIZADO PARA ALTERAR A DATA DO PERIODO AQUISITIVO AO QUAL FOI CADASTRADO AS FÉRIAS ERRADO
--NO MÊS 06/2022 COM MESTRE JÁ ENCERRADO
--========================================================================================================--
SELECT * FROM RHFP0328
WHERE COD_CONTRATO = 376885;

UPDATE RHFP0328
SET DATA_INICIO_PERIODO = '03/10/2020'
WHERE DATA_INICIO_PERIODO = '03/10/2021'
AND COD_CONTRATO = 376885
AND DATA_PREVISTA_FERIAS = '01/06/2022'

--========================================================================================================--