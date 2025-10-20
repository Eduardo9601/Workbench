/***SCRIP VERIFICA BLOQUEIOS/TRAVAMENTOS DE SEÇÕES NO BANCO DE DADOS***/

/*
VERSÃO ORIGINAL
Consulta simples usando GV$LOCK + V$SESSION para identificar bloqueadores e bloqueados, mas com custo maior devido ao IN com subquery.
*/
SELECT SUBSTR(DECODE(L.REQUEST, 0, 'BLOQUEADOR: ', '  -  BLOQUEADO: ') ||
              L.SID || ' ' || S.MACHINE,
              1,
              45) SESSAO,
       --ID1, ID2, LMODE, REQUEST, TYPE,
       L.INST_ID INSTANCE,
       L.CTIME
  FROM GV$LOCK L, V$SESSION S
 WHERE L.SID = S.SID
   AND (L.ID1, L.ID2, L.TYPE) IN
       (SELECT ID1, ID2, TYPE FROM GV$LOCK WHERE REQUEST > 0)
 ORDER BY ID1, REQUEST;




/*
VERSÃO 2 COM MAIS INFORMAÇÕES
Traz detalhes de sessões (usuário, máquina, programa, evento) usando GV$SESSION e blocking_session, 
mais leve e direto para identificar travamentos.
*/
SELECT S.INST_ID,
       S.SID,
       S.SERIAL#,
       S.USERNAME,
       S.MACHINE,
       S.PROGRAM,
       S.EVENT,
       S.STATE,
       S.SECONDS_IN_WAIT,
       S.BLOCKING_INSTANCE,
       S.BLOCKING_SESSION,
       BS.SERIAL# AS BLOCKER_SERIAL#,
       BS.USERNAME AS BLOCKER_USER,
       BS.MACHINE AS BLOCKER_MACHINE
  FROM GV$SESSION S
  LEFT JOIN GV$SESSION BS ON BS.INST_ID = S.BLOCKING_INSTANCE
                         AND BS.SID = S.BLOCKING_SESSION
 WHERE S.BLOCKING_SESSION IS NOT NULL
   AND S.WAIT_CLASS <> 'IDLE'
 ORDER BY S.SECONDS_IN_WAIT DESC;



/*
VERSÃO 3 EM FORMATO DE CTE
Reestrutura a lógica com CTEs e JOINs entre “waiters” e “blockers”, 
eliminando o IN e deixando a consulta mais clara e performática.
*/
WITH WAITS AS (
  SELECT WL.INST_ID, WL.SID, WL.ID1, WL.ID2, WL.TYPE, WL.CTIME
    FROM GV$LOCK WL
   WHERE WL.REQUEST > 0
), 

BLOCKS AS (
  SELECT BL.INST_ID, BL.SID, BL.ID1, BL.ID2, BL.TYPE
    FROM GV$LOCK BL
   WHERE BL.REQUEST = 0
     AND BL.LMODE > 0
)
SELECT CASE
         WHEN B.SID IS NULL THEN
          'BLOQUEADOR: '
         ELSE
          '  -  BLOQUEADO: '
       END || S.SID || ' ' || S.MACHINE AS SESSAO,
       S.INST_ID AS INSTANCE,
       W.CTIME
  FROM WAITS W
  JOIN GV$SESSION S ON S.INST_ID = W.INST_ID
                   AND S.SID = W.SID
  LEFT JOIN BLOCKS B ON B.ID1 = W.ID1
                    AND B.ID2 = W.ID2
                    AND B.TYPE = W.TYPE
 ORDER BY W.ID1,
          (CASE
            WHEN B.SID IS NULL THEN
             0
            ELSE
             1
          END),
          W.CTIME DESC;




/*
VERSÃO 4 CTE COM MAIS INFORMAÇÕES
Expande a CTE, mostrando tanto bloqueadores quanto bloqueados com dados completos de ambas as sessões 
(SQL, programa, máquina), útil para análise detalhada em RAC.
*/
WITH WAITS AS (
  SELECT WL.INST_ID,
         WL.SID AS WAITER_SID,
         WL.ID1,
         WL.ID2,
         WL.TYPE,
         WL.CTIME AS WAIT_SECONDS
    FROM GV$LOCK WL
   WHERE WL.REQUEST > 0
),
BLOCKS AS (
  SELECT BL.INST_ID, BL.SID AS BLOCKER_SID, BL.ID1, BL.ID2, BL.TYPE
  FROM   GV$LOCK BL
  WHERE  BL.REQUEST = 0
    AND  BL.LMODE   > 0
),
PAIRS AS (
  SELECT W.INST_ID,
         W.ID1,
         W.ID2,
         W.TYPE,
         W.WAITER_SID,
         B.BLOCKER_SID,
         W.WAIT_SECONDS
    FROM WAITS W
    JOIN BLOCKS B ON B.ID1 = W.ID1
                 AND B.ID2 = W.ID2
                 AND B.TYPE = W.TYPE
)
SELECT P.INST_ID,
       P.ID1,
       P.ID2,
       P.TYPE,
       P.WAIT_SECONDS,
       -- WAITER (BLOQUEADO)
       SW.SID      AS WAITER_SID,
       SW.SERIAL#  AS WAITER_SERIAL#,
       SW.USERNAME AS WAITER_USER,
       SW.MACHINE  AS WAITER_MACHINE,
       SW.PROGRAM  AS WAITER_PROGRAM,
       SW.EVENT    AS WAITER_EVENT,
       SW.SQL_ID   AS WAITER_SQL_ID,
       -- BLOCKER (BLOQUEADOR)
       SB.SID      AS BLOCKER_SID,
       SB.SERIAL#  AS BLOCKER_SERIAL#,
       SB.USERNAME AS BLOCKER_USER,
       SB.MACHINE  AS BLOCKER_MACHINE,
       SB.PROGRAM  AS BLOCKER_PROGRAM,
       SB.SQL_ID   AS BLOCKER_SQL_ID
  FROM PAIRS P
  JOIN GV$SESSION SW ON SW.INST_ID = P.INST_ID
                    AND SW.SID = P.WAITER_SID
  JOIN GV$SESSION SB ON SB.INST_ID = P.INST_ID
                    AND SB.SID = P.BLOCKER_SID
 WHERE SW.WAIT_CLASS <> 'IDLE'
 ORDER BY P.WAIT_SECONDS DESC;