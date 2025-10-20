CREATE OR REPLACE PROCEDURE GRZ_KPI_AVALIACAO_PLR_SP(P_DTA_REF IN VARCHAR2) IS
  V_REF   DATE; -- 1º DIA DO MÊS DE REFERÊNCIA
  V_D_INI DATE; -- INÍCIO DO PERÍODO (1º DIA)
  V_D_FIM DATE; -- FIM DO PERÍODO (LAST_DAY)
  V_OK    NUMBER;
BEGIN
  --------------------------------------------------------------------
  -- 1) NORMALIZA A DATA DE REFERÊNCIA (SEMPRE O 1º DIA DO MÊS)
  --------------------------------------------------------------------
  IF P_DTA_REF IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000,
                            'INFORME P_DTA_REF NO FORMATO DD/MM/YYYY.');
  END IF;

  V_REF   := TRUNC(TO_DATE(P_DTA_REF, 'DD/MM/YYYY'), 'MM');
  V_D_INI := V_REF;
  V_D_FIM := LAST_DAY(V_REF);

  --------------------------------------------------------------------
  -- 2) GATE DE FECHAMENTO DO ORÇADO (FECHA NO MÊS ATUAL, PORÉM IRREGULAR)
  --    CRITÉRIO SIMPLES E ROBUSTO: SÓ RODA SE JÁ EXISTIR DADOS PÓS-FECHAMENTO
  --    EM NL.GRZ_DRE_CENTRO_CUSTOS PARA DTA_ORCAMENTO = V_REF.
  --------------------------------------------------------------------
  BEGIN
    SELECT 1
      INTO V_OK
      FROM NL.GRZ_DRE_CENTRO_CUSTOS@NLGRZ
     WHERE DTA_ORCAMENTO = V_REF
       AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- SOFT GATE: FECHAMENTO DO ORÇADO AINDA NÃO DISPONÍVEL ? SAI SILENCIOSAMENTE.
      -- SE PREFERIR FALHAR, TROQUE POR: RAISE_APPLICATION_ERROR(-20001, 'FECHAMENTO DO ORÇADO AINDA NÃO DISPONÍVEL.');
      RETURN;
  END;

  /* -- ALTERNATIVA: USAR LOG DO ORÇADO (TROCAR NOME_TABELA_LOG E COLUNA CONFORME SEU AMBIENTE)
  BEGIN
    SELECT 1
      INTO V_OK
      FROM NL.NOME_TABELA_LOG_ORCADO L
     WHERE TRUNC(L.DTA_SISTEMA, 'MM') = TRUNC(ADD_MONTHS(V_REF, 1), 'MM')
       AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN; -- OU RAISE_APPLICATION_ERROR(...)
  END;
  */

  --------------------------------------------------------------------
  -- 3) IDEMPOTÊNCIA: REMOVE CARGA ANTERIOR DO MESMO PERÍODO
  --------------------------------------------------------------------
  /*DELETE FROM GRZ_KPI_AVALIACAO_PLR_TB T
  WHERE T.DTA_INI = V_D_INI
    AND T.DTA_FIM = V_D_FIM;*/

  --------------------------------------------------------------------

  INSERT INTO GRZ_KPI_AVALIACAO_PLR_TB
    (COD_UNIDADE,
     DES_UNIDADE,
     REDE,
     REGIAO,
     VLR_ORCADO_VENDAS,
     VLR_REALIZADO,
     VLR_VENDA_LIQUIDA,
     VLR_LUCRO,
     LUCRATIVIDADE,
     VLR_MARGEM_ORC,
     VLR_MARGEM_REAL,
     MARGEM,
     VLR_FALTA_INVENTARIO,
     INVENTARIO,
     VLR_PREVENTIVA,
     QTD_MESES_PREV,
     PREVENTIVA,
     VLR_CUSTO_PERM,
     VLR_ESTOQUE_ANT_PERM,
     VLR_MEDIO_EMP_PERM,
     VLR_ESTMEDIO_PERM,
     PERMANENCIA,
     VLR_CUSTO_FOLHA,
     FOLHA,
     VLR_VENDA_LOJA,
     VLR_VDA_DOMINGO,
     TOTAL_HRS,
     PRODUTIVIDADE,
     EFETIVO_INICIAL,
     EFETIVO_FINAL,
     EFETIVO_MEDIO,
     TURNOVER,
     ATIVOS_PERIODO,
     ADMITIDOS,
     DEMITIDOS,
     DTA_INI,
     DTA_FIM,
     QTD_MESES_REF)
  
  WITH
  /* MAPEIA AS UNIDADES ATIVAS E SEUS GRUPOS E REGIOES */
  GRUPOS AS
    (SELECT A.COD_EMP,
            A.COD_UNIDADE,
            A.DES_FANTASIA AS DES_UNIDADE,
            A.REDE,
            B.COD_GRUPO,
            B.COD_QUEBRA AS REGIAO
       FROM SISLOGWEB.V_UNIDADES_ATIVAS@NLGRZ A
       LEFT JOIN NL.GE_GRUPOS_UNIDADES@NLGRZ B ON A.COD_UNIDADE =
                                                  B.COD_UNIDADE
                                              AND B.COD_GRUPO IN
                                                  (910, 930, 940, 950, 970)
      WHERE A.COD_UNIDADE NOT IN (7549, 900)
     --AND A.COD_UNIDADE = 4
     ),
  
  /* BLOCO PARA ENTRADA DE PARÂMETROS (DINÂMICO POR PERÍODO) */
  PARAMS AS
    (
     
     /*VERSÃO PARA USAR NO PL/SQL*/
     /*SELECT TO_DATE('&DATA_INICIO', 'DD/MM/YYYY') AS D_INI,
                      TO_DATE('&DATA_FIM', 'DD/MM/YYYY') AS D_FIM
                 FROM DUAL*/
     
     SELECT V_D_INI AS D_INI, V_D_FIM AS D_FIM
       FROM DUAL
     
     /*VERSÃO PARA USAR NO SAPINHO E DENTRO DA FOLHA*/
     /*SELECT :DATA_INICIO AS D_INI, :DATA_FIM AS D_FIM FROM DUAL*/
     
     ),
  
  /*CALENDÁRIO MENSAL DINÂMICO A PARTIR DOS PARÂMTROS ACIMA (PARAMS)*/
  DATAS_REF AS
    (SELECT
     /* MÊS I INICIANDO NO 1º DIA DO MÊS DE D_INI */
      ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1) AS DTA_INI,
      LAST_DAY(ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1)) AS DTA_FIM,
      TO_CHAR(ADD_MONTHS(TRUNC(P.D_INI, 'MM'), LEVEL - 1), 'MM/YYYY') AS MES_ANO,
      /* ÍNDICE DO MÊS DENTRO DO PERÍODO */
      LEVEL AS IDX_MES,
      /* QUANTIDADE TOTAL DE MESES DO PERÍODO (MESMA EM TODAS AS LINHAS) */
      MONTHS_BETWEEN(ADD_MONTHS(TRUNC(P.D_FIM, 'MM'), 1),
                     TRUNC(P.D_INI, 'MM')) AS QTD_MESES
       FROM PARAMS P
     CONNECT BY LEVEL <= MONTHS_BETWEEN(ADD_MONTHS(TRUNC(P.D_FIM, 'MM'), 1),
                                        TRUNC(P.D_INI, 'MM'))
     
     ),
  
  /* ===========================================================================
         ==== INÍCIO DO BLOCO DA RELAÇÃO DOS KPIS MAIS RELEVANTES - POR UNIDADE ====
         =========================================================================== */
  
  /* =================================================================================================
         === 1) KPI 1 - VENDAS/ORÇADO (VALORES) = ORÇADO/REALIZADO/LUCRO/MARGEM/INVENTÁRIO/CUSTO FOLHA ===
         ================================================================================================= */
  
  ORCADO AS
    (SELECT A.COD_UNIDADE,
            SUM(DECODE(A.DES_CHAVE,
                       '01#01001',
                       NVL(A.VLR_ORCADO, 0),
                       '01#01003',
                       NVL(A.VLR_ORCADO, 0),
                       '01#01005',
                       NVL(A.VLR_ORCADO, 0),
                       0)) VLR_VENDA_ORC,
            SUM(DECODE(A.DES_CHAVE,
                       '01#01001',
                       NVL(A.VLR_REALIZADO, 0),
                       '01#01003',
                       NVL(A.VLR_REALIZADO, 0),
                       '01#01005',
                       NVL(A.VLR_REALIZADO, 0),
                       0)) VLR_VENDA_REAL,
            SUM(DECODE(A.DES_CHAVE, '05#05001', NVL(A.VLR_REALIZADO, 0), 0)) VLR_VENDA_LIQUIDA,
            SUM(DECODE(A.DES_CHAVE, '09#09001', NVL(A.VLR_ORCADO, 0), 0)) VLR_MARGEM_ORC,
            SUM(DECODE(A.DES_CHAVE, '09#09001', NVL(A.VLR_REALIZADO, 0), 0)) VLR_MARGEM_REAL,
            SUM(DECODE(A.DES_CHAVE, '11#11001', NVL(A.VLR_REALIZADO, 0), 0)) VLR_FALTA_INVENTARIO,
            SUM(DECODE(A.DES_CHAVE, '45#45001', NVL(A.VLR_REALIZADO, 0), 0)) VLR_LUCRO,
            SUM(DECODE(A.DES_CHAVE,
                       '15#15001',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15005',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15010',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15015',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15020',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15025',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15030',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15035',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15040',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15045',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15049',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15050',
                       NVL(A.VLR_REALIZADO, 0),
                       '15#15055',
                       NVL(A.VLR_REALIZADO, 0),
                       0)) CUSTO_FOLHA
       FROM NL.OR_VALORES@NLGRZ A
       JOIN GRUPOS B ON A.COD_UNIDADE = B.COD_UNIDADE
      CROSS JOIN PARAMS P
      WHERE B.COD_EMP = 1
        AND A.COD_EMP = 1
        AND A.COD_ORCAMENTO = 400
           --AND B.COD_GRUPO = 999
        AND A.DTA_ORCAMENTO >= P.D_INI
        AND A.DTA_ORCAMENTO <= P.D_FIM
           /*AND A.DTA_ORCAMENTO >= '01/01/' || SUBSTR(PI_DATA_REF, 7, 4)
                                            AND A.DTA_ORCAMENTO <= '01/' || SUBSTR(PI_DATA_REF, 4, 7)*/
           --AND A.COD_UNIDADE BETWEEN 4 AND 4
        AND A.COD_UNIDADE NOT IN (818, 848, 858, 838)
        AND (A.DES_CHAVE = '01#01001' OR A.DES_CHAVE = '01#01003' OR
            A.DES_CHAVE = '01#01005' OR A.DES_CHAVE = '05#05001' OR
            A.DES_CHAVE = '09#09001' OR A.DES_CHAVE = '11#11001' OR
            A.DES_CHAVE = '45#45001' OR A.DES_CHAVE = '15#15001' OR
            A.DES_CHAVE = '15#15005' OR A.DES_CHAVE = '15#15010' OR
            A.DES_CHAVE = '15#15015' OR A.DES_CHAVE = '15#15020' OR
            A.DES_CHAVE = '15#15025' OR A.DES_CHAVE = '15#15030' OR
            A.DES_CHAVE = '15#15035' OR A.DES_CHAVE = '15#15040' OR
            A.DES_CHAVE = '15#15045' OR A.DES_CHAVE = '15#15049' OR
            A.DES_CHAVE = '15#15050' OR A.DES_CHAVE = '15#15055')
     --  AND EXISTS(SELECT 1 FROM GE_GRUPOS_UNIDADES  WHERE COD_UNIDADE = A.COD_UNIDADE AND COD_GRUPO IN (PI_GRUPO_ANTIGO))
      HAVING SUM(DECODE(A.DES_CHAVE,
                       '01#01001',
                       NVL(A.VLR_REALIZADO, 0),
                       '01#01003',
                       NVL(A.VLR_REALIZADO, 0),
                       '01#01005',
                       NVL(A.VLR_REALIZADO, 0),
                       0)) > 0
      GROUP BY A.COD_UNIDADE
      ORDER BY A.COD_UNIDADE
     
     ),
  
  KPI_ORCADO AS
    (SELECT O.COD_UNIDADE,
            O.VLR_VENDA_ORC,
            O.VLR_VENDA_REAL,
            O.VLR_VENDA_LIQUIDA,
            
            /*KPI MARGEM*/
            O.VLR_MARGEM_ORC,
            O.VLR_MARGEM_REAL,
            CASE
              WHEN O.VLR_VENDA_LIQUIDA <> 0 THEN
               ROUND((O.VLR_MARGEM_REAL * 100) / O.VLR_VENDA_LIQUIDA, 2)
              ELSE
               0
            END AS MARGEM,
            
            /*KPI INVENTÁRIO*/
            O.VLR_FALTA_INVENTARIO,
            CASE
              WHEN O.VLR_VENDA_LIQUIDA <> 0 THEN
               ROUND((O.VLR_FALTA_INVENTARIO * 100) / O.VLR_VENDA_LIQUIDA, 2)
              ELSE
               0
            END AS INVENTARIO,
            
            /*KPI LUCRATIVIDADE*/
            O.VLR_LUCRO,
            CASE
              WHEN O.VLR_VENDA_LIQUIDA <> 0 THEN
               ROUND((O.VLR_LUCRO * 100) / O.VLR_VENDA_LIQUIDA, 2)
              ELSE
               0
            END AS LUCRATIVIDADE,
            
            /*KPI FOLHA*/
            O.CUSTO_FOLHA,
            CASE
              WHEN O.CUSTO_FOLHA <> 0 THEN
               ROUND(((O.CUSTO_FOLHA * 100) / O.VLR_VENDA_LIQUIDA), 2)
              ELSE
               0
            END AS FOLHA
       FROM ORCADO O
     
     ),
  
  /* MAPEIA OS CONTRATOS POR LOJA PARA: TURNOVER, PRODUTIVIDADE E ABSENTEÍSMO(ESSE ÚLTIMO AINDA DECIDINDO SE IRÁ TER OU NÃO) */
  CONTRATOS AS
    (SELECT DISTINCT CT.STATUS,
                     CT.COD_CONTRATO,
                     CT.DES_PESSOA,
                     CT.DATA_NASCIMENTO,
                     CT.DATA_ADMISSAO,
                     CT.DATA_DEMISSAO,
                     FN.COD_FUNCAO,
                     FN.DES_FUNCAO,
                     FN.DATA_INI_CLH,
                     FN.DATA_FIM_CLH,
                     HR.HR_BASE_MES,
                     HR.DATA_INI_HR,
                     HR.DATA_FIM_HR,
                     CT.IND_DEFICIENCIA,
                     CT.SEXO,
                     ORG.COD_EMP,
                     ORG.EDICAO_EMP,
                     ORG.DES_EMP,
                     ORG.COD_ORGANOGRAMA,
                     ORG.COD_UNIDADE,
                     ORG.DES_UNIDADE,
                     ORG.DATA_INI_ORG,
                     ORG.DATA_FIM_ORG,
                     CASE
                       WHEN ORG.COD_TIPO = 2 THEN
                        ORG.EDICAO_ORG_3
                       WHEN ORG.COD_TIPO = 3 THEN
                        ORG.EDICAO_ORG_3
                       ELSE
                        ORG.COD_UNIDADE
                     END AS COD_FILIAL,
                     CASE
                       WHEN ORG.COD_TIPO = 2 THEN
                        ORG.NOME3
                       WHEN ORG.COD_TIPO = 3 THEN
                        ORG.NOME3
                       ELSE
                        ORG.DES_UNIDADE
                     END AS DES_FILIAL,
                     CASE
                       WHEN ORG.COD_TIPO = 2 THEN
                        ORG.EDICAO_ORG_4
                       WHEN ORG.COD_TIPO = 3 THEN
                        ORG.EDICAO_ORG_4
                       ELSE
                        ORG.COD_UNIDADE
                     END AS COD_DIVISAO,
                     CASE
                       WHEN ORG.COD_TIPO = 2 THEN
                        ORG.NOME4
                       WHEN ORG.COD_TIPO = 3 THEN
                        ORG.NOME4
                       ELSE
                        ORG.DES_UNIDADE
                     END AS DES_DIVISAO,
                     ORG.COD_REDE,
                     ORG.DES_REDE,
                     ORG.COD_TIPO,
                     ORG.DES_TIPO
       FROM V_DADOS_CONTRATO_AVT CT
       JOIN VH_EST_ORG_CONTRATO_AVT ORG ON CT.COD_CONTRATO =
                                           ORG.COD_CONTRATO
       JOIN VH_HIST_HORAS_COLAB_AVT HR ON CT.COD_CONTRATO = HR.COD_CONTRATO
       JOIN VH_CARGO_CONTRATO_AVT FN ON CT.COD_CONTRATO = FN.COD_CONTRATO
      CROSS JOIN DATAS_REF M
      CROSS JOIN PARAMS P
      WHERE -- CONTRATOS ATIVOS EM QUALQUER DIA DO MÊS
      CT.DATA_ADMISSAO <= M.DTA_FIM
  AND NVL(CT.DATA_DEMISSAO, DATE '2999-12-31') >= M.DTA_INI
     /*VERSÕES ALTERNATIVAS DE FILTRAR POR DATA
               (('31/03/2025' BETWEEN CT.DATA_ADMISSAO AND CT.DATA_DEMISSAO) OR
                       (CT.DATA_ADMISSAO <= '31/03/2025' AND CT.DATA_DEMISSAO IS NULL))
               AND (CT.DATA_ADMISSAO <= TO_DATE('31/07/2025','DD/MM/YYYY'))
                  AND (CT.DATA_DEMISSAO IS NULL OR CT.DATA_DEMISSAO >= TO_DATE('01/07/2025','DD/MM/YYYY'))
               AND (CT.DATA_DEMISSAO IS NULL OR
                      CT.DATA_DEMISSAO >= '01/07/2025')*/
     
  AND P.D_FIM BETWEEN ORG.DATA_INI_ORG AND ORG.DATA_FIM_ORG
  AND P.D_FIM BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH
  AND P.D_FIM BETWEEN HR.DATA_INI_HR AND HR.DATA_FIM_HR
  AND ORG.COD_EMP = 8
  AND ORG.COD_TIPO = 1
  AND ORG.EDICAO_ORG_4 IS NOT NULL
     --AND ORG.COD_UNIDADE NOT IN (014, 050, 615, 7586, 7608)
     --AND ORG.COD_UNIDADE = 004
      ORDER BY CT.COD_CONTRATO),
  
  /*MAPEIA TODOS OS COLABORADORES MAS TAMBÉM COM INFO DE AFASTAMENTO*/
  STATUS_AFASTADOS AS
    (SELECT DISTINCT ORG.COD_EMP,
                     CT.COD_CONTRATO,
                     ORG.COD_ORGANOGRAMA,
                     ORG.COD_UNIDADE,
                     NVL(AF.COD_CAUSA_AFAST, 0) AS STATUS_AFAST,
                     AF.DATA_INICIO AS DATA_INI_AFAST,
                     AF.DATA_FIM AS DATA_FIM_AFAST
       FROM RHFP0306                AF,
            RHFP0300                CT,
            VH_EST_ORG_CONTRATO_AVT ORG,
            VH_CARGO_CONTRATO_AVT   FN,
            DATAS_REF               M,
            PARAMS                  P
      WHERE CT.COD_CONTRATO = AF.COD_CONTRATO(+)
        AND CT.COD_CONTRATO = ORG.COD_CONTRATO(+)
        AND CT.COD_CONTRATO = FN.COD_CONTRATO(+)
        AND CT.DATA_INICIO <= M.DTA_FIM
        AND NVL(CT.DATA_FIM, DATE '2999-12-31') >= M.DTA_INI
           /* AND (CT.DATA_INICIO <= '31/03/2025')
                                          AND (CT.DATA_INICIO IS NULL OR CT.DATA_FIM >= '01/01/2025')*/
        AND P.D_FIM BETWEEN AF.DATA_INICIO(+) AND AF.DATA_FIM(+)
        AND P.D_FIM BETWEEN ORG.DATA_INI_ORG(+) AND ORG.DATA_FIM_ORG(+)
        AND P.D_FIM BETWEEN AF.DATA_INICIO(+) AND
            NVL(AF.DATA_FIM(+), DATE '2999-12-31')
        AND ORG.COD_EMP = 8
        AND ORG.COD_TIPO = 1
     --AND ORG.COD_UNIDADE NOT IN (014, 050, 615, 7586, 7608)
     
     ),
  
  /* ======================================================
         === 2) KPI 2 - PRODUTIVIDADE =========================
         ====================================================== */
  
  VENDAS AS
    (SELECT GE.COD_QUEBRA REGIAO,
            DECODE(A.COD_UNIDADE,
                   7022,
                   22,
                   7047,
                   47,
                   7065,
                   65,
                   7138,
                   138,
                   7140,
                   140,
                   7183,
                   183,
                   7244,
                   244,
                   7353,
                   353,
                   7386,
                   386,
                   7412,
                   412,
                   7430,
                   430,
                   7442,
                   442,
                   7461,
                   461,
                   7466,
                   466,
                   7491,
                   491,
                   7543,
                   543,
                   7555,
                   555,
                   7570,
                   570,
                   7577,
                   653,
                   7587,
                   587,
                   7588,
                   588,
                   7592,
                   592,
                   7597,
                   597,
                   7601,
                   601,
                   7602,
                   608,
                   7620,
                   620,
                   7500,
                   651,
                   7051,
                   652,
                   7066,
                   654,
                   A.COD_UNIDADE) COD_UNIDADE,
            GE.COD_GRUPO,
            MIN(D.DES_FANTASIA) DES_FANTASIA, -- USA MIN PARA "UNIFICAR"
            MIN(D.DTA_CADASTRO) DTA_CADASTRO, -- IDEM
            MIN(A.DTA_EMISSAO) DTA_ATUALIZACAO,
            SUM(OPER.VLR_OPERACAO) VALOR_VENDA_LOJA,
            SUM(CASE
                  WHEN TO_CHAR(A.DTA_EMISSAO, 'D') = 1 THEN
                   NVL(OPER.VLR_OPERACAO, 0)
                  ELSE
                   0
                END) VDA_DOMINGO
       FROM NL.NS_NOTAS@NLGRZ A
       JOIN NL.NS_NOTAS_OPERACOES@NLGRZ OPER ON A.NUM_SEQ = OPER.NUM_SEQ
                                            AND A.COD_MAQUINA =
                                                OPER.COD_MAQUINA
       JOIN NL.GE_GRUPOS_UNIDADES@NLGRZ GE ON A.COD_UNIDADE =
                                              GE.COD_UNIDADE
       JOIN NL.PS_PESSOAS@NLGRZ D ON A.COD_UNIDADE = D.COD_PESSOA
      CROSS JOIN DATAS_REF M
      WHERE A.DTA_EMISSAO BETWEEN M.DTA_INI AND M.DTA_FIM
        AND GE.COD_GRUPO = 999
        AND GE.COD_EMP = 1
           --AND (A.COD_UNIDADE = :UNIDADE OR :UNIDADE = 0)
           --AND A.COD_UNIDADE >= 0
           --AND A.COD_UNIDADE <= 999
        AND A.IND_STATUS = 1
        AND A.TIP_NOTA = 4
        AND D.IND_INATIVO = 0
      GROUP BY GE.COD_QUEBRA,
               DECODE(A.COD_UNIDADE,
                      7022,
                      22,
                      7047,
                      47,
                      7065,
                      65,
                      7138,
                      138,
                      7140,
                      140,
                      7183,
                      183,
                      7244,
                      244,
                      7353,
                      353,
                      7386,
                      386,
                      7412,
                      412,
                      7430,
                      430,
                      7442,
                      442,
                      7461,
                      461,
                      7466,
                      466,
                      7491,
                      491,
                      7543,
                      543,
                      7555,
                      555,
                      7570,
                      570,
                      7577,
                      653,
                      7587,
                      587,
                      7588,
                      588,
                      7592,
                      592,
                      7597,
                      597,
                      7601,
                      601,
                      7602,
                      608,
                      7620,
                      620,
                      7500,
                      651,
                      7051,
                      652,
                      7066,
                      654,
                      A.COD_UNIDADE),
               GE.COD_GRUPO
      ORDER BY GE.COD_QUEBRA, COD_UNIDADE, DES_FANTASIA
     
     ),
  
  TOTAL_HORAS AS
    (SELECT A.COD_ORGANOGRAMA,
            A.COD_UNIDADE,
            A.COD_TIPO,
            SUM(CASE
                  WHEN A.IND_DEFICIENCIA = 'S' THEN
                   0
                  ELSE
                   TO_NUMBER(A.HR_BASE_MES)
                END) AS TOTAL_HRS
       FROM CONTRATOS A
       LEFT JOIN STATUS_AFASTADOS B ON A.COD_CONTRATO = B.COD_CONTRATO
      CROSS JOIN DATAS_REF M
      CROSS JOIN PARAMS P
      WHERE NVL(B.STATUS_AFAST, 0) IN (0, 6, 7, 107)
        AND A.COD_FUNCAO NOT IN (74, 75, 310, 409, 68)
           --AND A.COD_TIPO = 1
        AND A.DATA_ADMISSAO <= LAST_DAY(M.DTA_FIM)
        AND (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO >= M.DTA_FIM)
        AND P.D_FIM BETWEEN A.DATA_INI_ORG AND A.DATA_FIM_ORG
        AND P.D_FIM BETWEEN A.DATA_INI_CLH AND A.DATA_FIM_CLH
        AND P.D_FIM BETWEEN A.DATA_INI_HR AND A.DATA_FIM_HR
      GROUP BY A.COD_ORGANOGRAMA, A.COD_UNIDADE, A.COD_TIPO),
  
  PRODUTIVIDADE AS
    (SELECT A.COD_UNIDADE,
            TT.COD_TIPO,
            MIN(A.DES_FANTASIA) AS DES_FANTASIA,
            A.VALOR_VENDA_LOJA AS VLR_VENDA_LOJA,
            A.VDA_DOMINGO AS VLR_VDA_DOMINGO, --PODE SER COLOCADO NA TABELA DOS KPIS
            TT.TOTAL_HRS,
            TRUNC(A.VALOR_VENDA_LOJA / NULLIF(TT.TOTAL_HRS, 0)) AS PRODUTIVIDADE
       FROM VENDAS A
       LEFT JOIN TOTAL_HORAS TT ON A.COD_UNIDADE = TT.COD_UNIDADE
      GROUP BY A.COD_UNIDADE,
               A.VALOR_VENDA_LOJA,
               A.VDA_DOMINGO,
               TT.TOTAL_HRS,
               TT.COD_TIPO
     
     ),
  
  /* ======================================================
         === 3) KPI 3 - TURNOVER ==============================
         ====================================================== */
  
  EFETIVO_INICIAL_TUR AS
    (SELECT CTR.COD_ORGANOGRAMA,
            CTR.COD_UNIDADE,
            CTR.COD_TIPO,
            P.D_INI,
            COUNT(DISTINCT CTR.COD_CONTRATO) AS EFETIVO_INICIAL
       FROM CONTRATOS CTR
      CROSS JOIN PARAMS P
      WHERE ('01/' || TO_CHAR(P.D_INI, 'MM/YYYY')) BETWEEN
            CTR.DATA_ADMISSAO AND NVL(CTR.DATA_DEMISSAO, '31/12/9999')
        AND ('01/' || TO_CHAR(P.D_INI, 'MM/YYYY')) BETWEEN CTR.DATA_INI_ORG AND
            NVL(CTR.DATA_FIM_ORG, '31/12/9999')
        AND (UPPER(CTR.DES_FUNCAO) NOT LIKE '%ESTAGIARIO%' AND
            UPPER(CTR.DES_FUNCAO) NOT LIKE '%APRENDIZ%' AND
            UPPER(CTR.DES_FUNCAO) NOT LIKE '%TEMPORARIO%')
     
      GROUP BY CTR.COD_ORGANOGRAMA, CTR.COD_UNIDADE, P.D_INI, CTR.COD_TIPO), EFETIVO_FINAL_TUR AS
    (SELECT CTR.COD_ORGANOGRAMA,
            CTR.COD_UNIDADE,
            CTR.COD_TIPO,
            P.D_FIM,
            COUNT(DISTINCT CTR.COD_CONTRATO) AS EFETIVO_FINAL
       FROM CONTRATOS CTR
      CROSS JOIN PARAMS P
      WHERE LAST_DAY(TO_DATE('' || TO_CHAR(P.D_FIM, 'DD/MM/YYYY'))) BETWEEN
            CTR.DATA_ADMISSAO AND NVL(CTR.DATA_DEMISSAO, '31/12/9999')
        AND LAST_DAY(TO_DATE('' || TO_CHAR(P.D_FIM, 'DD/MM/YYYY'))) BETWEEN
            CTR.DATA_INI_ORG AND NVL(CTR.DATA_FIM_ORG, '31/12/9999')
        AND (UPPER(CTR.DES_FUNCAO) NOT LIKE '%ESTAGIARIO%' AND
             UPPER(CTR.DES_FUNCAO) NOT LIKE '%APRENDIZ%' AND
             UPPER(CTR.DES_FUNCAO) NOT LIKE '%TEMPORARIO%')
      GROUP BY CTR.COD_ORGANOGRAMA, CTR.COD_UNIDADE, P.D_FIM, CTR.COD_TIPO),
  
  DEMITIDOS_TUR AS
    (SELECT A.COD_ORGANOGRAMA,
            A.COD_UNIDADE,
            A.DES_UNIDADE,
            A.COD_TIPO,
            P.D_INI,
            P.D_FIM,
            COUNT(DISTINCT CASE
                    WHEN A.DATA_DEMISSAO BETWEEN P.D_INI AND P.D_FIM THEN
                     A.COD_CONTRATO
                  END) AS DEMITIDOS
       FROM CONTRATOS A
      CROSS JOIN PARAMS P
      WHERE (UPPER(A.DES_FUNCAO) NOT LIKE '%ESTAGIARIO%' AND
            UPPER(A.DES_FUNCAO) NOT LIKE '%APRENDIZ%' AND
            UPPER(A.DES_FUNCAO) NOT LIKE '%TEMPORARIO%')
      GROUP BY A.COD_ORGANOGRAMA,
               A.COD_UNIDADE,
               A.DES_UNIDADE,
               A.COD_TIPO,
               P.D_INI,
               P.D_FIM
     
     ),
  
  DATAMETRICS AS
    (SELECT A.COD_ORGANOGRAMA,
            A.COD_UNIDADE,
            A.DES_UNIDADE,
            A.COD_REDE,
            A.COD_EMP,
            A.COD_TIPO,
            M.DTA_INI,
            M.DTA_FIM,
            
            /*COUNT(DISTINCT CASE
                                                   WHEN A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO > M.DTA_FIM THEN
                                                    A.COD_CONTRATO
                                                 END) AS ATIVOS_ATUAIS,*/
            COUNT(DISTINCT A.COD_CONTRATO) AS ATIVOS_ATUAIS,
            
            COUNT(DISTINCT CASE
                    WHEN A.DATA_ADMISSAO <= M.DTA_FIM AND
                         (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO >= M.DTA_FIM) THEN
                     A.COD_CONTRATO
                  END) AS ATIVOS_PERIODO,
            
            COUNT(DISTINCT CASE
                    WHEN B.DATA_INI_AFAST <= M.DTA_FIM AND
                         (B.DATA_FIM_AFAST IS NULL OR
                         B.DATA_FIM_AFAST >= M.DTA_INI) AND
                        /*B.DATA_FIM_AFAST <> TO_DATE('31/12/2999', 'DD/MM/YYYY') AND*/
                         B.STATUS_AFAST <> 7 THEN
                     A.COD_CONTRATO
                  END) AS AFAST_PERIODO,
            
            COUNT(DISTINCT CASE
                    WHEN A.DATA_ADMISSAO BETWEEN M.DTA_INI AND M.DTA_FIM THEN
                     A.COD_CONTRATO
                  END) AS ADMITIDOS,
            
            COUNT(DISTINCT CASE
                    WHEN A.DATA_DEMISSAO BETWEEN M.DTA_INI AND M.DTA_FIM THEN
                     A.COD_CONTRATO
                  END) AS DEMITIDOS
     
       FROM CONTRATOS A
       LEFT JOIN STATUS_AFASTADOS B ON A.COD_CONTRATO = B.COD_CONTRATO
      CROSS JOIN DATAS_REF M
      WHERE (UPPER(A.DES_FUNCAO) NOT LIKE '%ESTAGIARIO%' AND
            UPPER(A.DES_FUNCAO) NOT LIKE '%APRENDIZ%' AND
            UPPER(A.DES_FUNCAO) NOT LIKE '%TEMPORARIO%')
      GROUP BY A.COD_ORGANOGRAMA,
               A.COD_UNIDADE,
               A.DES_UNIDADE,
               A.COD_REDE,
               A.COD_EMP,
               A.COD_TIPO,
               M.DTA_INI,
               M.DTA_FIM
      ORDER BY A.COD_UNIDADE
     
     ),
  
  CALC_TURNOVER AS
    (SELECT A.COD_ORGANOGRAMA,
            A.COD_UNIDADE,
            A.DES_UNIDADE,
            A.COD_REDE,
            A.DES_REDE,
            A.COD_TIPO,
            DM.DEMITIDOS,
            EI.EFETIVO_INICIAL,
            EF.EFETIVO_FINAL,
            (EI.EFETIVO_INICIAL + EF.EFETIVO_FINAL) / 2 AS EFETIVO_MEDIO,
            ROUND(CASE
                    WHEN (NVL(EI.EFETIVO_INICIAL, 0) + NVL(EF.EFETIVO_FINAL, 0)) / 2 = 0 THEN
                     0
                    ELSE
                     (NVL(DM.DEMITIDOS, 0) * 100) /
                     ((NVL(EI.EFETIVO_INICIAL, 0) + NVL(EF.EFETIVO_FINAL, 0)) / 2)
                  END,
                  2) AS TURNOVER
       FROM (SELECT DISTINCT COD_ORGANOGRAMA,
                             COD_UNIDADE,
                             DES_UNIDADE,
                             COD_REDE,
                             DES_REDE,
                             COD_TIPO
               FROM CONTRATOS) A
       LEFT JOIN EFETIVO_INICIAL_TUR EI ON A.COD_ORGANOGRAMA =
                                           EI.COD_ORGANOGRAMA
       LEFT JOIN EFETIVO_FINAL_TUR EF ON A.COD_ORGANOGRAMA =
                                         EF.COD_ORGANOGRAMA
       LEFT JOIN DEMITIDOS_TUR DM ON A.COD_ORGANOGRAMA = DM.COD_ORGANOGRAMA
     /*WHERE (A.COD_UNIDADE = :UNIDADE OR :UNIDADE = 0)
                   AND (A.COD_REDE = :REDE OR :REDE = 0)*/
     --AND (A.COD_TIPO = :TIPO OR :TIPO = 0)
     
     ),
  
  TURNOVER AS
    (SELECT B.COD_ORGANOGRAMA,
            A.COD_UNIDADE,
            A.ATIVOS_PERIODO,
            A.ADMITIDOS,
            A.DEMITIDOS,
            B.EFETIVO_INICIAL,
            B.EFETIVO_FINAL,
            B.EFETIVO_MEDIO,
            B.TURNOVER
       FROM DATAMETRICS A
       JOIN CALC_TURNOVER B ON A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA
     
     ),
  
  /* ======================================================
         === 4) KPI 3 - PREVENTIVA ============================
         ====================================================== */
  
  DADOS_PREVENTIVA AS
    (SELECT LAST_DAY(MES) AS DTA_MOVIMENTO, -- OU TRUNC(MES,'MM') SE PREFERIR 01/MM
            COD_UNIDADE,
            MAX(REGIAO) AS REGIAO, -- COLAPSA PARA UM VALOR POR MÊS
            MAX(REDE) AS REDE, -- IDEM
            VLR_PREV_MES AS VLR_PREVENTIVA,
            SUM(CASE
                  WHEN X.VLR_PREV_MES > 0 THEN
                   1
                  ELSE
                   0
                END) OVER(PARTITION BY X.COD_UNIDADE) AS QTD_MESES
       FROM (SELECT TRUNC(A.DTA_MOVIMENTO, 'MM') AS MES,
                    A.COD_UNIDADE,
                    /* MESMAS REGRAS QUE VOCÊ USOU */
                    CASE
                      WHEN TO_CHAR(A.COD_GRUPO_UNI) LIKE '%8%' THEN
                       A.COD_GRUPO_UNI
                    END AS REGIAO,
                    CASE
                      WHEN TO_CHAR(A.COD_QUEBRA_UNI) NOT LIKE '%8%' THEN
                       A.COD_QUEBRA_UNI
                    END AS REDE,
                    NVL(A.VLR_PREVENTIVO, 0) AS VLR_PREV_MES
               FROM NL.ES_0124_CR_PROJECAO@NLGRZ A
              CROSS JOIN DATAS_REF M
              WHERE A.DTA_MOVIMENTO >= M.DTA_INI
                AND A.DTA_MOVIMENTO <= M.DTA_FIM -- INCLUI TODO 31/03
                AND A.COD_QUEBRA_LCTO = 1
                AND A.COD_UNIDADE <> 0
             --AND A.COD_UNIDADE = 592
             ) X
      WHERE REGIAO IS NOT NULL
        AND REDE IS NOT NULL
      GROUP BY MES, COD_UNIDADE, VLR_PREV_MES
      ORDER BY COD_UNIDADE, MES
     
     ),
  
  CALC_PREVENTIVA AS
    (SELECT A.COD_UNIDADE,
            A.REGIAO,
            A.REDE,
            SUM(NVL(A.VLR_PREVENTIVA, 0)) AS VLR_PREVENTIVA,
            A.QTD_MESES
       FROM DADOS_PREVENTIVA A
       JOIN GRUPOS B ON B.COD_UNIDADE = A.COD_UNIDADE
      GROUP BY A.COD_UNIDADE, A.QTD_MESES, A.REGIAO, A.REDE
     
     ),
  
  KPI_PREVENTIVA AS
    (SELECT COD_UNIDADE,
            VLR_PREVENTIVA,
            QTD_MESES AS QTD_MESES_PREV,
            CASE
              WHEN QTD_MESES > 0 THEN
               TRUNC(VLR_PREVENTIVA / QTD_MESES, 2)
              ELSE
               0
            END AS PREVENTIVA
       FROM CALC_PREVENTIVA
     --WHERE REGIAO = 8708
     --AND REDE = 10
      ORDER BY COD_UNIDADE
     
     ),
  
  /* ======================================================
         === 5) KPI 5 - PERMANENCIA ===========================
         ====================================================== */
  
  --(AJUSTANDO A LÓGICA POIS AINDA NÃO SEI SE ESTÁ CORRETO E TAMBÉM MUITO PESADO A EXECUÇÃO)
  
  DADOS_PERMANENCIA AS
    (SELECT A.COD_UNIDADE,
            A.DES_UNIDADE,
            B.REDE,
            B.COD_GRUPO,
            B.REGIAO,
            A.VLR_CUSTO AS VLR_CUSTO_PERM,
            A.VLR_ESTOQUE_ANT AS VLR_ESTOQUE_ANT_PERM,
            A.VLR_MEDIO_EMP AS VLR_MEDIO_EMP_PERM,
            A.VLR_ESTMEDIO_PERM,
            A.PERMANENCIA
       FROM SISLOGWEB.GRZ_INDICE_PERMANENCIA_TB@NLGRZ A
       JOIN GRUPOS B ON A.COD_UNIDADE = B.COD_UNIDADE
      CROSS JOIN DATAS_REF M
      WHERE A.DTA_REFERENCIA BETWEEN M.DTA_INI AND M.DTA_FIM
      ORDER BY A.COD_UNIDADE, A.DTA_REFERENCIA
     
     ),
  
  KPI_PERMANENCIA AS
    (SELECT COD_UNIDADE,
            VLR_CUSTO_PERM,
            VLR_ESTOQUE_ANT_PERM,
            VLR_MEDIO_EMP_PERM,
            VLR_ESTMEDIO_PERM,
            PERMANENCIA
       FROM DADOS_PERMANENCIA
     
     ),
  
  /* ===========================================================
         ====== VISÃO GERAL CONSOLIDADA DOS KPIS POR UNIDADE =======
         =========================================================== */
  
  KPIS AS
    (SELECT G.COD_UNIDADE,
            G.DES_UNIDADE,
            G.REDE,
            G.REGIAO,
            O.VLR_VENDA_ORC AS VLR_ORCADO_VENDAS,
            O.VLR_VENDA_REAL AS VLR_REALIZADO,
            O.VLR_VENDA_LIQUIDA,
            O.VLR_LUCRO AS VLR_LUCRO,
            O.LUCRATIVIDADE,
            O.VLR_MARGEM_ORC,
            O.VLR_MARGEM_REAL,
            O.MARGEM,
            O.VLR_FALTA_INVENTARIO,
            O.INVENTARIO,
            PV.VLR_PREVENTIVA,
            PV.QTD_MESES_PREV,
            PV.PREVENTIVA,
            PE.VLR_CUSTO_PERM,
            PE.VLR_ESTOQUE_ANT_PERM,
            PE.VLR_MEDIO_EMP_PERM,
            PE.VLR_ESTMEDIO_PERM,
            PE.PERMANENCIA,
            O.CUSTO_FOLHA AS VLR_CUSTO_FOLHA,
            O.FOLHA,
            PD.VLR_VENDA_LOJA,
            PD.VLR_VDA_DOMINGO,
            PD.TOTAL_HRS,
            PD.PRODUTIVIDADE,
            TU.EFETIVO_INICIAL,
            TU.EFETIVO_FINAL,
            TU.EFETIVO_MEDIO,
            TU.TURNOVER,
            TU.ATIVOS_PERIODO,
            TU.ADMITIDOS,
            TU.DEMITIDOS,
            M.DTA_INI,
            M.DTA_FIM,
            M.QTD_MESES
       FROM (SELECT DISTINCT COD_UNIDADE,
                             DES_UNIDADE,
                             COD_REDE,
                             DES_REDE,
                             COD_TIPO,
                             COD_ORGANOGRAMA
               FROM CONTRATOS) A
       JOIN GRUPOS G ON A.COD_UNIDADE = G.COD_UNIDADE
       LEFT JOIN KPI_ORCADO O ON O.COD_UNIDADE = G.COD_UNIDADE
       LEFT JOIN KPI_PREVENTIVA PV ON PV.COD_UNIDADE = G.COD_UNIDADE
       LEFT JOIN PRODUTIVIDADE PD ON PD.COD_UNIDADE = G.COD_UNIDADE
       LEFT JOIN TURNOVER TU ON TU.COD_ORGANOGRAMA = A.COD_ORGANOGRAMA
       LEFT JOIN KPI_PERMANENCIA PE ON PE.COD_UNIDADE = G.COD_UNIDADE
      CROSS JOIN DATAS_REF M
     
     )
  
  /* ================================================================
         ====================== RESULTADO FINAL =========================
         ================================================================ */
    SELECT COD_UNIDADE,
           DES_UNIDADE,
           REDE,
           REGIAO,
           VLR_ORCADO_VENDAS,
           VLR_REALIZADO,
           VLR_VENDA_LIQUIDA,
           VLR_LUCRO,
           LUCRATIVIDADE,
           VLR_MARGEM_ORC,
           VLR_MARGEM_REAL,
           MARGEM,
           VLR_FALTA_INVENTARIO,
           INVENTARIO,
           VLR_PREVENTIVA,
           QTD_MESES_PREV,
           PREVENTIVA,
           VLR_CUSTO_PERM,
           VLR_ESTOQUE_ANT_PERM,
           VLR_MEDIO_EMP_PERM,
           VLR_ESTMEDIO_PERM,
           PERMANENCIA,
           VLR_CUSTO_FOLHA,
           FOLHA,
           VLR_VENDA_LOJA,
           VLR_VDA_DOMINGO,
           TOTAL_HRS,
           PRODUTIVIDADE,
           EFETIVO_INICIAL,
           EFETIVO_FINAL,
           EFETIVO_MEDIO,
           TURNOVER,
           ATIVOS_PERIODO,
           ADMITIDOS,
           DEMITIDOS,
           DTA_INI,
           DTA_FIM,
           QTD_MESES
      FROM (SELECT COD_UNIDADE,
                   DES_UNIDADE,
                   REDE,
                   REGIAO,
                   NVL(VLR_ORCADO_VENDAS, 0) AS VLR_ORCADO_VENDAS,
                   NVL(VLR_REALIZADO, 0) AS VLR_REALIZADO,
                   NVL(VLR_VENDA_LIQUIDA, 0) AS VLR_VENDA_LIQUIDA,
                   /*LUCRATIVIDADE*/
                   NVL(VLR_LUCRO, 0) AS VLR_LUCRO,
                   NVL(LUCRATIVIDADE, 0) AS LUCRATIVIDADE,
                   /*MARGEM*/
                   NVL(VLR_MARGEM_ORC, 0) AS VLR_MARGEM_ORC,
                   NVL(VLR_MARGEM_REAL, 0) AS VLR_MARGEM_REAL,
                   NVL(MARGEM, 0) AS MARGEM,
                   /*INVENTÁRIO*/
                   NVL(VLR_FALTA_INVENTARIO, 0) AS VLR_FALTA_INVENTARIO,
                   NVL(INVENTARIO, 0) AS INVENTARIO,
                   /*PREVENTIVA*/
                   NVL(VLR_PREVENTIVA, 0) AS VLR_PREVENTIVA,
                   QTD_MESES_PREV,
                   NVL(PREVENTIVA, 0) AS PREVENTIVA,
                   /*PERMANÊNCIA*/
                   NVL(VLR_CUSTO_PERM, 0) AS VLR_CUSTO_PERM,
                   NVL(VLR_ESTOQUE_ANT_PERM, 0) AS VLR_ESTOQUE_ANT_PERM,
                   NVL(VLR_MEDIO_EMP_PERM, 0) AS VLR_MEDIO_EMP_PERM,
                   NVL(VLR_ESTMEDIO_PERM, 0) AS VLR_ESTMEDIO_PERM,
                   NVL(PERMANENCIA, 0) AS PERMANENCIA,
                   /*CUSTO FOLHA*/
                   NVL(VLR_CUSTO_FOLHA, 0) AS VLR_CUSTO_FOLHA,
                   NVL(FOLHA, 0) AS FOLHA,
                   /*PRODUTIVIDADE*/
                   NVL(VLR_VENDA_LOJA, 0) AS VLR_VENDA_LOJA,
                   NVL(VLR_VDA_DOMINGO, 0) AS VLR_VDA_DOMINGO,
                   TOTAL_HRS,
                   NVL(PRODUTIVIDADE, 0) AS PRODUTIVIDADE,
                   /*TURNOVER*/
                   NVL(EFETIVO_INICIAL, 0) AS EFETIVO_INICIAL,
                   NVL(EFETIVO_FINAL, 0) AS EFETIVO_FINAL,
                   NVL(EFETIVO_MEDIO, 0) AS EFETIVO_MEDIO,
                   NVL(TURNOVER, 0) AS TURNOVER,
                   ATIVOS_PERIODO,
                   ADMITIDOS,
                   DEMITIDOS,
                   /*REFERENCIA*/
                   DTA_INI,
                   DTA_FIM,
                   QTD_MESES
              FROM KPIS
            --WHERE COD_UNIDADE = 4
            )
    
     ORDER BY COD_UNIDADE;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END GRZ_KPI_AVALIACAO_PLR_SP;