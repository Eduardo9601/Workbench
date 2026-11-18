/* ============================================================================
   HCM SENIOR | QUANTITATIVO ATUAL POR FILIAL E SUBDIVISÃO (LOCAL)
   Banco: Oracle | Data-base: hoje (TRUNC(SYSDATE))

   Um registro por EMPRESA + FILIAL + ORGANOGRAMA + LOCAL.
   Abertura nos locais reais do HCM, inclusive administrativo/logística.
   O código de local para o usuário vem da R016HIE.CODLOC vigente hoje;
   NUMLOC é a chave interna, e NOMLOC, a descrição do local.

   Mesma população e mesmo cálculo de indicadores do SQL por filial.
   QTD_GERENTES = cargos superiores: GERENTE, COMPRADOR,
   SUPERVISOR ou DIRETOR, excluindo títulos com DIRETORIA.
   A soma de todos os locais de uma filial deve coincidir com o SQL 01.
   Indicadores:
   QTD_COLABORADORES = empregados que NAO pertencem ao perfil gerencial.
   QTD_GERENTES      = empregados do perfil gerencial/superior.
   QTD_MASCULINO     = todos os empregados masculinos (inclusive gerenciais).
   QTD_FEMININO      = todos os empregados femininos (inclusive gerenciais).
   TOTAL_COLABORADORES = todos os empregados do agrupamento.
   Conferencia: QTD_COLABORADORES + QTD_GERENTES = TOTAL_COLABORADORES.
   
   ============================================================================ */

WITH COLABORADORES_ATIVOS AS (
    SELECT
        F.NUMEMP,
        F.CODFIL,
        F.TIPCOL,
        F.NUMCAD,
        F.TABORG,
        F.NUMLOC,
        F.TIPSEX,
        C.TITRED AS DESCRICAO_CARGO,
        CASE
            WHEN (
                    UPPER(C.TITRED) LIKE '%GERENTE%'
                 OR UPPER(C.TITRED) LIKE '%COMPRADOR%'
                 OR UPPER(C.TITRED) LIKE '%SUPERVISOR%'
                 OR UPPER(C.TITRED) LIKE '%DIRETOR%'
                 )
             AND UPPER(C.TITRED) NOT LIKE '%DIRETORIA%'
            THEN 1 ELSE 0
        END AS FLG_PERFIL_GERENCIAL
    FROM R034FUN F
    INNER JOIN R010SIT S
        ON S.CODSIT = F.SITAFA
    LEFT JOIN R024CAR C
        ON C.ESTCAR = F.ESTCAR
       AND C.CODCAR = F.CODCAR
    WHERE F.TIPCOL = 1
      AND F.DATADM <= TRUNC(SYSDATE)
      AND S.TIPSIT <> 7
      -- S.TIPSIT <> 7 exclui desligados; afastados permanecem.
      -- AND F.NUMEMP = 8  -- opcional: restringir à empresa 8
)
SELECT
    B.NUMEMP                                  AS COD_EMPRESA,
    FIL.CODFIL                                AS COD_FILIAL,
    FIL.NOMFIL                                AS NOME_FILIAL,
    B.TABORG                                  AS COD_ORGANOGRAMA,
    B.NUMLOC                                  AS NUM_LOCAL_INTERNO,
    HIE.CODLOC                                AS COD_LOCAL,
    NVL(LOC.NOMLOC, 'LOCAL NÃO CADASTRADO')   AS NOME_LOCAL,
    SUM(CASE WHEN B.FLG_PERFIL_GERENCIAL = 0 THEN 1 ELSE 0 END)
                                              AS QTD_COLABORADORES,
    SUM(B.FLG_PERFIL_GERENCIAL)               AS QTD_GERENTES,
    SUM(CASE WHEN B.TIPSEX = 'M' THEN 1 ELSE 0 END)
                                              AS QTD_MASCULINO,
    SUM(CASE WHEN B.TIPSEX = 'F' THEN 1 ELSE 0 END)
                                              AS QTD_FEMININO,
    COUNT(*)                                  AS TOTAL_COLABORADORES
FROM COLABORADORES_ATIVOS B
INNER JOIN R030FIL FIL
    ON FIL.NUMEMP = B.NUMEMP
   AND FIL.CODFIL = B.CODFIL
LEFT JOIN R016ORN LOC
    ON LOC.TABORG = B.TABORG
   AND LOC.NUMLOC = B.NUMLOC
LEFT JOIN R016HIE HIE
    ON HIE.TABORG = B.TABORG
   AND HIE.NUMLOC = B.NUMLOC
   AND HIE.DATINI = (
       SELECT MAX(H2.DATINI)
       FROM R016HIE H2
       WHERE H2.TABORG = B.TABORG
         AND H2.NUMLOC = B.NUMLOC
         AND H2.DATINI <= TRUNC(SYSDATE)
   )
GROUP BY
    B.NUMEMP,
    FIL.CODFIL,
    FIL.NOMFIL,
    B.TABORG,
    B.NUMLOC,
    HIE.CODLOC,
    LOC.NOMLOC
ORDER BY
    B.NUMEMP,
    FIL.CODFIL,
    B.TABORG,
    HIE.CODLOC,
    B.NUMLOC;
