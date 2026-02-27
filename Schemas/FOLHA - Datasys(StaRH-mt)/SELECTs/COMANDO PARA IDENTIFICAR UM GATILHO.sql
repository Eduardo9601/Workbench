--==COMANDO PARA IDENTIFICAR UM GATILHO==--
SELECT trigger_name, table_name, trigger_type, triggering_event, status
FROM all_triggers
WHERE trigger_name = 'RHDP2142_HIS';

--==COMANDO PARA IDENTIFICAR A ESTRUTURA DE UM GATILHO==--
SELECT text
FROM all_source
WHERE name = 'RHDP2142_HIS'
AND type = 'TRIGGER'
ORDER BY line;