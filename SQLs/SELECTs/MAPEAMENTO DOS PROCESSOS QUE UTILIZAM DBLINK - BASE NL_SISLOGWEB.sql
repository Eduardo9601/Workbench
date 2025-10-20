/*MAPEAMENTO DOS PROCESSOS QUE UTILIZAM DBLINK - BASE NL/SISLOGWEB*/


WITH
  /*dep AS (
    -- Todas as dependências que usam o DBLink (inclui MATERIALIZED VIEW, VIEW, FUNCTION, PACKAGE, TRIGGER etc.)
    SELECT distinct
           OWNER,
           NAME,
           TYPE
      FROM ALL_DEPENDENCIES
     WHERE REFERENCED_LINK_NAME IN ('GRZFOLHA','GZTPROD')
  ),*/
  src AS (
    -- Procura referências ao DBLink em código-fonte (procedures, packages, etc.)
    SELECT DISTINCT OWNER,
                    NAME,
                    TYPE
      FROM ALL_SOURCE
     WHERE UPPER(TEXT) LIKE '%@GRZFOLHA%'
        OR UPPER(TEXT) LIKE '%@GZTPROD%'
        OR UPPER(TEXT) LIKE '%@NLGZT%'
        OR UPPER(TEXT) LIKE '%@GRZFOLHAS%'
  ),
  vws AS (
    -- Views cuja definição faz referência ao DBLink
    SELECT OWNER,
           VIEW_NAME AS NAME,
           'VIEW'    AS TYPE
      FROM ALL_VIEWS
     WHERE UPPER(TEXT_VC) LIKE '%@GRZFOLHA%'
        OR UPPER(TEXT_VC) LIKE '%@GZTPROD%'
        OR UPPER(TEXT_VC) LIKE '%@NLGZT%'
  ),
/*  trg AS (
    -- Triggers que usam o DBLink
    SELECT OWNER,
           TRIGGER_NAME AS NAME,
           'TRIGGER'    AS TYPE
      FROM ALL_TRIGGERS
     WHERE UPPER(NVL(TRIGGER_BODY,' ')) LIKE '%@GRZFOLHA%'
        OR UPPER(NVL(TRIGGER_BODY,' ')) LIKE '%@GZTPROD%'
  ),*/
  dj AS (
    -- Jobs antigos (DBMS_JOB) que contém o DBLink
    SELECT USER      AS OWNER,
           JOB       AS NAME,
           'DBMS_JOB' AS TYPE
      FROM USER_JOBS
     WHERE UPPER(NVL(WHAT,' ')) LIKE '%@GRZFOLHA%'
        OR UPPER(NVL(WHAT,' ')) LIKE '%@GZTPROD%'
        OR UPPER(NVL(WHAT,' ')) LIKE '%@NLGZT%'
  ),
  /*sch AS (
    -- Scheduler jobs que fazem referência ao DBLink
    SELECT OWNER,
           JOB_NAME AS NAME,
           'SCHEDULER_JOB' AS TYPE
      FROM ALL_SCHEDULER_JOBS
     WHERE UPPER(NVL(JOB_ACTION,' ')) LIKE '%@GRZFOLHA%'
        OR UPPER(NVL(JOB_ACTION,' ')) LIKE '%@GZTPROD%'
  ),*/
  sch_args AS (
    -- Argumentos de scheduler que podem conter o DBLink
    SELECT OWNER,
           JOB_NAME AS NAME,
           'SCHEDULER_JOB_ARG' AS TYPE
      FROM ALL_SCHEDULER_JOB_ARGS
     WHERE UPPER(NVL(VALUE,' ')) LIKE '%@GRZFOLHA%'
        OR UPPER(NVL(VALUE,' ')) LIKE '%@GZTPROD%'
        OR UPPER(NVL(VALUE,' ')) LIKE '%@@NLGZT%'
  ),
  syn AS (
    -- Sinônimos que apontam explicitamente para o DBLink
    SELECT OWNER,
           SYNONYM_NAME AS NAME,
           'SYNONYM'     AS TYPE
      FROM ALL_SYNONYMS
     WHERE DB_LINK IN ('GRZFOLHA','GZTPROD', 'NLGZT')
  )
SELECT OWNER,
       TYPE        AS OBJECT_TYPE,
       NAME        AS OBJECT_NAME
  FROM (
         /*SELECT * FROM dep
    UNION ALL*/ SELECT * FROM src
    UNION ALL SELECT * FROM vws
    --UNION ALL SELECT * FROM trg
    --UNION ALL SELECT * FROM dj
    --UNION ALL SELECT * FROM sch
    --UNION ALL SELECT * FROM sch_args
    --UNION ALL SELECT * FROM syn
       )
 ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME;
 
 

/*MAPEIA AS TABELAS/VIEWS INCOPRADAS NO CORPO DO CÓDIGO DOS BLOCOS PL/SQLs NESSE SCHEMA*/ 

WITH cte1 AS (
  -- 1) traz todo o source e já calcula UPPER(TEXT)
  SELECT distinct
    OWNER,
    NAME,
    TYPE,
    LINE,
    TEXT,
    UPPER(TEXT) AS UTEXT
  FROM   ALL_SOURCE
),
cte2 AS (
  -- 2) filtra usando UTEXT (já existente)
  SELECT *
  FROM   cte1
  WHERE  UTEXT LIKE '%@GRZFOLHA%'
     OR UTEXT LIKE '%@GZTPROD%'
     OR UTEXT LIKE '%@NLGZT%'
),
cte3 AS (
  -- 3) extrai o par objeto@dblink e também só o objeto
  SELECT
    OWNER,
    NAME            AS local_object,
    TYPE            AS local_type,
    LINE            AS line_number,
    -- captura "SCHEMA.OBJETO@GZTPROD" ou "OBJETO@NLGZT"
    REGEXP_SUBSTR(
      UTEXT,
      '[A-Z0-9_$.]+@(GRZFOLHA|GZTPROD|NLGZT)',
      1, 1, 'i'
    )               AS obj_and_link,
    -- remove "@..." deixando só "SCHEMA.OBJETO" ou "OBJETO"
    REGEXP_REPLACE(
      REGEXP_SUBSTR(
        UTEXT,
        '[A-Z0-9_$.]+@(GRZFOLHA|GZTPROD|NLGZT)',
        1, 1, 'i'
      ),
      '@.*$',
      ''
    )               AS remote_obj,
    -- qual dblink foi usado
    REGEXP_SUBSTR(
      UTEXT,
      '@(GRZFOLHA|GZTPROD|NLGZT)',
      1, 1, 'i'
    )               AS used_dblink
  FROM cte2
)
SELECT DISTINCT
       OWNER           AS local_schema,
       local_object,
       local_type,
       line_number,
       remote_obj      AS referenced_remote_object,
       used_dblink     AS dblink_used
FROM cte3
WHERE remote_obj IS NOT NULL
ORDER BY
       local_schema,
       local_object,
       referenced_remote_object;

       
       
/*MAPEIA AS TABELAS/VIEWS USADAS NO CORPO DAS VIEWS DESSE SCHEMA*/   
       
WITH cte1 AS (
  -- 1) puxa todas as views e sua definição em TEXT_VC
  SELECT
    OWNER,
    VIEW_NAME,
    TEXT_VC
  FROM  ALL_VIEWS
),
cte2 AS (
  -- 2) filtra só as views que usam um dos DBLinks
  SELECT
    OWNER,
    VIEW_NAME,
    TEXT_VC
  FROM   cte1
  WHERE UPPER(TEXT_VC) LIKE '%@GRZFOLHA%'
    OR UPPER(TEXT_VC) LIKE '%@GZTPROD%'
    OR UPPER(TEXT_VC) LIKE '%@NLGZT%'
),
cte3 AS (
  -- 3) extrai o par objeto@DBLINK, só objeto e qual link
  SELECT
    OWNER                           AS local_schema,
    VIEW_NAME                       AS local_object,
    'VIEW'                          AS local_type,
    -- captura "SCHEMA.OBJETO@DBLINK" ou "OBJETO@DBLINK"
    REGEXP_SUBSTR(
      TEXT_VC,
      '[A-Z0-9_$.]+@(GRZFOLHA|GZTPROD|NLGZT)',
      1, 1, 'i'
    )                                AS obj_and_link,
    -- remove "@...", ficando só com "SCHEMA.OBJETO" ou "OBJETO"
    REGEXP_REPLACE(
      REGEXP_SUBSTR(
        TEXT_VC,
        '[A-Z0-9_$.]+@(GRZFOLHA|GZTPROD|NLGZT)',
        1, 1, 'i'
      ),
      '@.*$',''
    )                                AS referenced_remote_object,
    -- qual DBLink foi usado
    REGEXP_SUBSTR(
      TEXT_VC,
      '@(GRZFOLHA|GZTPROD|NLGZT)',
      1, 1, 'i'
    )                                AS dblink_used
  FROM cte2
)
SELECT DISTINCT
       local_schema,
       local_object,
       local_type,
       obj_and_link,
       referenced_remote_object,
       dblink_used
FROM cte3
ORDER BY local_schema,
         local_object,
         referenced_remote_object;


