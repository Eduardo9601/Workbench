-- SQL PARA ALTERAR O EMAIL DE LOG DOS PROCESSOS AUTOMÁTICOS

SELECT * FROM RHWF0405

UPDATE RHWF0405
SET EMAIL_LOG = 'noreply@grupograzziotin.com.br'
WHERE EMAIL_LOG = 'starh@grazziotin.com.br' OR 'sthar@grazziotin.com.br'