
--Processo utilizado para atualizar a situação da programação de férias de uma colaboradora reintegrada,
  --processo necessário para alterar um período aquisitivo ao qual o colaborador não tirou as férias
  --e aparece como QUITADO na situação em período aquisitivo, com isso realizando esse processo, atualiza a
  --situação para que se encontre como VENCIDO.

SELECT a.*, rowid FROM RHFP0328 a --0325 e 0327
WHERE a.COD_CONTRATO = 390418;