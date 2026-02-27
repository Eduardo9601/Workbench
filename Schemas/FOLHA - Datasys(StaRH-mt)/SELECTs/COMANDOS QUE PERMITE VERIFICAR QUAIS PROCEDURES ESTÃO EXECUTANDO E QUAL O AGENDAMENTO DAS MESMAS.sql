/*COMANDOS QUE PERMITE VERIFICAR QUAIS PROCEDURES ESTÃO EXECUTANDO E QUAL O AGENDAMENTO DAS MESMAS
SOMENTE QUEM TEM PRIVILÉGIOS CONSEGUE VISUALIZAR*/

DBA_SCHEDULER_JOBS: Esta view exibe todos os jobs do Scheduler.
USER_SCHEDULER_JOBS: Esta view exibe os jobs do Scheduler pertencentes ao usuário atual.
ALL_SCHEDULER_JOBS: Esta view exibe os jobs do Scheduler visíveis ao usuário atual.


--SQL PARA VERIFICAR 

SELECT job_name, enabled, last_start_date, next_run_date
FROM USER_SCHEDULER_JOBS
WHERE job_action LIKE '%GRZ_MOAVI_COLABORADORES_SP%';


--SQL PARA VERIFICAR SE A PROCEDURE ESTÁ OU NÃO ATIVA/EXECUTANDO

SELECT s.sid, s.serial#, s.status, s.username, s.schemaname, s.osuser, s.machine,
       s.terminal, s.program, s.module, s.action,s.sql_exec_start, s.last_call_et, s.logon_time, q.executions,
       q.sql_text
FROM   v$session s
JOIN   v$sql q
ON     q.address = s.sql_address
AND    q.hash_value = s.sql_hash_value
WHERE  q.sql_text LIKE '%GRZ_MOAVI_COLABORADORES_SP%'
ORDER  BY s.sid;


-- Sessões atualmente executando a procedure
-- Use DBA_* se tiver privilégio; troque por USER_* se não tiver
WITH jobs AS (
  SELECT j.owner,
         j.job_name,
         j.enabled,
         j.state,
         j.next_run_date,
         COALESCE(
           j.job_action,
           (SELECT p.program_action
              FROM dba_scheduler_programs p
             WHERE p.owner = j.program_owner
               AND p.program_name = j.program_name)
         ) AS action_text
  FROM   dba_scheduler_jobs j
),
last_run AS (
  SELECT r.owner,
         r.job_name,
         r.status,
         r.req_start_date,       -- horário agendado da última execução
         r.actual_start_date,    -- horário real de início
         r.run_duration,
         ROW_NUMBER() OVER (PARTITION BY r.owner, r.job_name ORDER BY r.log_id DESC) AS rn
  FROM   dba_scheduler_job_run_details r
)
SELECT j.owner,
       j.job_name,
       j.enabled,
       j.state,
       -- Próxima execução (no fuso da sessão):
       CAST(j.next_run_date      AT TIME ZONE SESSIONTIMEZONE AS TIMESTAMP) AS next_run_local,
       -- Última execução:
       CAST(lr.req_start_date    AT TIME ZONE SESSIONTIMEZONE AS TIMESTAMP) AS last_scheduled_local,
       CAST(lr.actual_start_date AT TIME ZONE SESSIONTIMEZONE AS TIMESTAMP) AS last_actual_start_local,
       lr.status  AS last_status,
       lr.run_duration
FROM   jobs j
LEFT JOIN last_run lr
       ON lr.owner = j.owner
      AND lr.job_name = j.job_name
      AND lr.rn = 1
WHERE  LOWER(j.action_text) LIKE LOWER('%grz_moavi_colaboradores_sp%')
ORDER  BY j.owner, j.job_name;




--SQL PARA VERIFICAR SE HÁ ALGUM PROCEDIMENTO ATUALIZANDO ALGUMA TABELA

SELECT 
    OWNER, 
    NAME, 
    TYPE 
FROM 
    ALL_SOURCE 
WHERE 
    UPPER(TEXT) LIKE '%MDL_USUARIO%'
    AND TYPE IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'TRIGGER')
ORDER BY 
    OWNER, 
    NAME, 
    TYPE;


--VERSÃO 2
SELECT NAME, TYPE
FROM ALL_SOURCE
WHERE UPPER(TEXT) LIKE '%MDL_USUARIO%'
AND TYPE IN ('PROCEDURE', 'FUNCTION', 'PACKAGE');



--SQL QUE MAPEIA AS DEPENCIAS DE UMA TABELA

SELECT NAME, TYPE, REFERENCED_NAME, REFERENCED_TYPE
FROM ALL_DEPENDENCIES
WHERE REFERENCED_NAME = 'MDL_USUARIO'
AND REFERENCED_TYPE = 'TABLE'
AND TYPE IN ('PROCEDURE', 'FUNCTION', 'TRIGGER', 'PACKAGE', 'VIEW');