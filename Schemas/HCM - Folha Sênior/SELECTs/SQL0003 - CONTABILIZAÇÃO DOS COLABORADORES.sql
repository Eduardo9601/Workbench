/* ============================================================================
   CONCILIA FOLHA 1.2.1 - OPERACAO HCM - CARGA OFICIAL
   FONTE REAL: CONTABILIZACAO NOVA R048CTB

   SOMENTE SELECT.
   Esta versao inclui as contas efetivamente geradas na contabilizacao:
   CONDEB / CONCRE e as contas reduzidas REDDEB / REDCRE.
   ============================================================================ */
WITH PARAMETROS AS
(
    SELECT
        8 AS NUMEMP,
        TO_DATE('01/08/2026','DD/MM/YYYY') AS DATA_INICIAL,
        LAST_DAY(TO_DATE('01/08/2026','DD/MM/YYYY')) AS DATA_FINAL
    FROM DUAL
)
SELECT
    C.NUMEMP,
    C.TIPCOL,
    C.NUMCAD,
    F.NOMFUN,
    C.DATLAN,
    C.OPCCTB,
    C.ORICTB,
    C.TABEVE,
    C.CODCLC,
    L.NOMCON,
    L.TIPLAN,
    L.CODTCL,
    C.DEBCRE,

    /* Contas realmente geradas pela contabilizacao */
    C.CONDEB,
    C.REDDEB,
    C.CONCRE,
    C.REDCRE,
    C.HISPAD,
    C.CPLHIS,

    C.CODCCU,
    CC.NOMCCU,
    C.CCURAT,
    C.CODRAT,
    C.PERRAT,
    C.TABORG,
    C.NUMLOC,
    C.LOCRAT,
    C.NATDES,
    C.CLCPDB,
    C.VALLAN
FROM R048CTB C
LEFT JOIN R048CLC L
  ON L.TABEVE = C.TABEVE
 AND L.CODCLC = C.CODCLC
LEFT JOIN R018CCU CC
  ON CC.NUMEMP = C.NUMEMP
 AND CC.CODCCU = C.CODCCU
LEFT JOIN R034FUN F
  ON F.NUMEMP = C.NUMEMP
 AND F.TIPCOL = C.TIPCOL
 AND F.NUMCAD = C.NUMCAD
JOIN PARAMETROS P
  ON P.NUMEMP = C.NUMEMP
WHERE C.DATLAN >= P.DATA_INICIAL
  AND C.DATLAN < P.DATA_FINAL + 1
ORDER BY
    C.CODCLC,
    C.CODCCU,
    C.NUMCAD,
    C.DEBCRE,
    C.CONDEB,
    C.CONCRE,
    C.DATLAN;