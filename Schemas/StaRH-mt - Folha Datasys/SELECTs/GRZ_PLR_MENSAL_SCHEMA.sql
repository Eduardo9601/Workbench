
-- =========================================================
-- PLR MENSAL - NOVA ESTRUTURA (NÃO IMPACTA O QUE EXISTE)
-- Autor: ChatGPT (assistente)
-- Data: 18/09/2025
-- Observação: este script cria novas TABELAS e PROCEDURES
-- para cálculo mensal de PLR por loja (e agregados).
-- =========================================================

-- =========================================================
-- 0) OBJETIVO / PADRÃO DE PARÂMETROS
-- =========================================================
-- Todas as procedures abaixo aceitam PI_OPCAO como string no padrão:
--   'CODEMP#CODREDE#CODGRUPO#COD_ORCAMENTO#DATA_REF#'
-- ou conforme a necessidade de cada módulo (ver cabeçalho de cada proc).
-- DATA_REF determina a competência alvo (mês) via TRUNC(DATA_REF,'MM')..LAST_DAY(DATA_REF).
-- IMPORTANTE: Nada do que já existe (ANUAL) é alterado. Tudo novo tem sufixo _PLR_MENSAL.
-- =========================================================

/*------------------------------------------------------------------
  1) TABELAS DE SUPORTE (CONFIGURAÇÃO DE PONTOS MENSAL)
  ------------------------------------------------------------------*/
BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE GRZ_CAD_CALCULO_PLR_MENSAL (
      ANO            NUMBER(4)      NOT NULL,
      MES            NUMBER(2)      NOT NULL,
      COD_REDE       VARCHAR2(2)    NOT NULL,
      COD_CALCULO    NUMBER(2)      NOT NULL,
      QTD_PONTOS     NUMBER(10,2)   NOT NULL,
      VALOR1         NUMBER(18,4),
      VALOR2         NUMBER(18,4),
      OBS            VARCHAR2(2000),
      DTA_CAD        DATE DEFAULT SYSDATE,
      CONSTRAINT PK_GRZ_CAD_CALC_PLR_MEN PRIMARY KEY (ANO, MES, COD_REDE, COD_CALCULO, QTD_PONTOS)
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN RAISE; END IF; -- ignora "table already exists"
END;
/

/*------------------------------------------------------------------
  2) FATO LOJA-MÊS (MÉTRICAS E PONTOS)
  ------------------------------------------------------------------*/
BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE GRZ_PLR_MENSAL (
      ANO                    NUMBER(4)    NOT NULL,
      MES                    NUMBER(2)    NOT NULL,
      COD_EMP                NUMBER(3)    NOT NULL,
      COD_REDE               VARCHAR2(2)  NOT NULL,
      COD_GRUPO              NUMBER(6)    NOT NULL,
      COD_UNIDADE            NUMBER(6)    NOT NULL,
      REGIAO                 NUMBER(6),
      -- MÉTRICAS FINANCEIRAS DO MÊS
      VLR_VENDA_ORC          NUMBER(18,2),
      VLR_VENDA_REAL         NUMBER(18,2),
      VLR_VENDA_LIQ          NUMBER(18,2),
      VLR_MARGEM_ORC         NUMBER(18,2),
      VLR_MARGEM_REAL        NUMBER(18,2),
      VLR_LUCRO              NUMBER(18,2),
      VLR_FALTA_INVENTARIO   NUMBER(18,2),
      VLR_CUSTO_FOLHA        NUMBER(18,2),
      VLR_DEVOLUCAO          NUMBER(18,2),
      -- OUTRAS MÉTRICAS DO MÊS
      VALE_TRANSP            NUMBER(18,2),
      HORAS_TRAB             NUMBER(18,2),
      -- PERMANÊNCIA (12 MESES ATÉ DATA_REF)
      VLR_PERM_CUSTO_12M     NUMBER(18,2),
      VLR_PERM_ESTMED_12M    NUMBER(18,2),
      -- PREVENTIVA (MÊS)
      VLR_PREVENTIVA_MES     NUMBER(18,2),
      -- RH / TURNOVER (MÊS)
      DEMISSOES_MES          NUMBER(18,2),
      EFETIVO_INI_MES        NUMBER(18,2),
      TURNOVER_MES           NUMBER(18,2),
      -- TREINAMENTO (MÊS)
      G10_MES                NUMBER(18,2),
      TPD_MES                NUMBER(18,2),
      SEG_PESSOA_MES         NUMBER(18,2),
      TRAINEE_MES            NUMBER(18,2),
      -- PERCENTUAIS CALCULADOS
      PER_LUCRO              NUMBER(9,2),
      PER_INVENTARIO         NUMBER(9,2),
      PER_DESP_TRANS         NUMBER(9,2),
      PER_DESP_FOLHA         NUMBER(9,2),
      -- PONTOS CALCULADOS
      PT_ORCADO              NUMBER(10,2),
      PT_MARGEM              NUMBER(10,2),
      PT_LUCRO               NUMBER(10,2),
      PT_INVENTARIO          NUMBER(10,2),
      PT_PREVENTIVA          NUMBER(10,2),
      PT_PERMANENCIA         NUMBER(10,2),
      PT_VALE_TRANSP         NUMBER(10,2),
      PT_PRODUTIVIDADE       NUMBER(10,2),
      PT_FOLHA               NUMBER(10,2),
      PT_TURNOVER            NUMBER(10,2),
      PT_TREINAMENTO         NUMBER(10,2),
      PT_OUTROS              NUMBER(10,2),
      TOTAL_PONTOS           NUMBER(12,2),
      DTA_CALC               DATE DEFAULT SYSDATE,
      CONSTRAINT PK_GRZ_PLR_MENSAL PRIMARY KEY (ANO, MES, COD_EMP, COD_REDE, COD_GRUPO, COD_UNIDADE)
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

/*------------------------------------------------------------------
  3) AGREGADO POR REGIÃO-MÊS
  ------------------------------------------------------------------*/
BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE GRZ_PLR_MENSAL_REGIOES (
      ANO                    NUMBER(4)    NOT NULL,
      MES                    NUMBER(2)    NOT NULL,
      COD_EMP                NUMBER(3)    NOT NULL,
      COD_REDE               VARCHAR2(2)  NOT NULL,
      COD_GRUPO              NUMBER(6)    NOT NULL,
      REGIAO                 NUMBER(6)    NOT NULL,
      -- SOMA DE MÉTRICAS
      VLR_VENDA_ORC          NUMBER(18,2),
      VLR_VENDA_REAL         NUMBER(18,2),
      VLR_VENDA_LIQ          NUMBER(18,2),
      VLR_MARGEM_ORC         NUMBER(18,2),
      VLR_MARGEM_REAL        NUMBER(18,2),
      VLR_LUCRO              NUMBER(18,2),
      VLR_FALTA_INVENTARIO   NUMBER(18,2),
      VLR_CUSTO_FOLHA        NUMBER(18,2),
      VLR_DEVOLUCAO          NUMBER(18,2),
      VALE_TRANSP            NUMBER(18,2),
      HORAS_TRAB             NUMBER(18,2),
      VLR_PERM_CUSTO_12M     NUMBER(18,2),
      VLR_PERM_ESTMED_12M    NUMBER(18,2),
      VLR_PREVENTIVA_MES     NUMBER(18,2),
      DEMISSOES_MES          NUMBER(18,2),
      EFETIVO_INI_MES        NUMBER(18,2),
      TURNOVER_MES           NUMBER(18,2),
      G10_MES                NUMBER(18,2),
      TPD_MES                NUMBER(18,2),
      SEG_PESSOA_MES         NUMBER(18,2),
      TRAINEE_MES            NUMBER(18,2),
      -- PONTOS (SOMADOS OU REGRAS ESPECÍFICAS)
      TOTAL_PONTOS           NUMBER(12,2),
      DTA_CALC               DATE DEFAULT SYSDATE,
      CONSTRAINT PK_GRZ_PLR_MENSAL_REGIOES PRIMARY KEY (ANO, MES, COD_EMP, COD_REDE, COD_GRUPO, REGIAO)
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

/*------------------------------------------------------------------
  4) VIEW OPCIONAL (COMPETÊNCIA YYYYMM)
  ------------------------------------------------------------------*/
BEGIN
  EXECUTE IMMEDIATE '
    CREATE OR REPLACE VIEW VW_GRZ_PLR_MENSAL AS
    SELECT (ANO*100 + MES) AS COMPETENCIA,
           t.*
      FROM GRZ_PLR_MENSAL t
  ';
END;
/

/*------------------------------------------------------------------
  5) FUNÇÃO DE APOIO: NORMALIZA COMPETÊNCIA
  ------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION GRZ_FN_COMPETENCIA (p_dt DATE) RETURN VARCHAR2 IS
BEGIN
  RETURN TO_CHAR(TRUNC(p_dt, ''MM''), ''YYYYMM'');
END;
/
SHOW ERRORS

/*------------------------------------------------------------------
  6) PROCEDURE: CARGA MÉTRICAS FINANCEIRAS (ORÇAMENTO / MARGEM / LUCRO / INVENTÁRIO / FOLHA)
      - Adaptação mensal de GRZ_ORCAMENTO_APR_ANUAL_SP
  ------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE GRZ_PLR_MENSAL_ORCAMENTO_SP (PI_OPCAO IN VARCHAR2) IS
  PI_CODEMP     NUMBER;
  PI_CODREDE    VARCHAR2(2);
  PI_CODGRUPO   NUMBER;
  PI_ORCAMENTO  NUMBER;
  PI_DATA_REF   DATE;

  v_ano   NUMBER(4);
  v_mes   NUMBER(2);
  v_dt_ini DATE;
  v_dt_fim DATE;

  Wi NUMBER; Wf NUMBER;

  CURSOR c_totais_orcamento IS
    SELECT a.cod_unidade,
           SUM(CASE a.des_chave WHEN ''01#01001'' THEN NVL(a.vlr_orcado,0)
                                 WHEN ''01#01003'' THEN NVL(a.vlr_orcado,0)
                                 WHEN ''01#01005'' THEN NVL(a.vlr_orcado,0)
                                 ELSE 0 END) AS Vlr_Venda_Orc,
           SUM(CASE a.des_chave WHEN ''01#01001'' THEN NVL(a.vlr_realizado,0)
                                 WHEN ''01#01003'' THEN NVL(a.vlr_realizado,0)
                                 WHEN ''01#01005'' THEN NVL(a.vlr_realizado,0)
                                 ELSE 0 END) AS Vlr_Venda_Real,
           SUM(CASE a.des_chave WHEN ''05#05001'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Venda_Liq,
           SUM(CASE a.des_chave WHEN ''09#09001'' THEN NVL(a.vlr_orcado,0)   ELSE 0 END) AS Vlr_Margem_Orc,
           SUM(CASE a.des_chave WHEN ''09#09001'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Margem_Real,
           SUM(CASE a.des_chave WHEN ''11#11001'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Falta_Inventario,
           SUM(CASE a.des_chave WHEN ''45#45001'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Lucro,
           SUM(CASE a.des_chave 
                 WHEN ''15#15001'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15005'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15010'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15015'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15020'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15025'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15030'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15035'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15040'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15045'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15049'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15050'' THEN NVL(a.vlr_realizado,0)
                 WHEN ''15#15055'' THEN NVL(a.vlr_realizado,0)
                 ELSE 0 END) AS Custo_Folha
      FROM or_valores a
      JOIN ge_grupos_unidades b ON b.cod_unidade = a.cod_unidade
     WHERE b.cod_grupo = ''8''||PI_CODREDE
       AND b.cod_emp   = PI_CODEMP
       AND a.cod_emp   = PI_CODEMP
       AND a.cod_orcamento = PI_ORCAMENTO
       AND a.dta_orcamento >= v_dt_ini
       AND a.dta_orcamento <= v_dt_fim
       AND a.cod_unidade BETWEEN 0 AND 9999
       AND a.cod_unidade NOT IN (818,848,858,838)
       AND a.des_chave IN (''01#01001'',''01#01003'',''01#01005'',''05#05001'',''09#09001'',''11#11001'',''45#45001'',
                           ''15#15001'',''15#15005'',''15#15010'',''15#15015'',''15#15020'',''15#15025'',
                           ''15#15030'',''15#15035'',''15#15040'',''15#15045'',''15#15049'',''15#15050'',''15#15055'')
     GROUP BY a.cod_unidade
    HAVING SUM(CASE a.des_chave WHEN ''01#01001'' THEN NVL(a.vlr_realizado,0)
                                WHEN ''01#01003'' THEN NVL(a.vlr_realizado,0)
                                WHEN ''01#01005'' THEN NVL(a.vlr_realizado,0)
                                ELSE 0 END) > 0
     ORDER BY a.cod_unidade;
  r c_totais_orcamento%ROWTYPE;

BEGIN
  -- Desmembrar PI_OPCAO
  Wi := INSTR(PI_OPCAO,'#',1,1);
  PI_CODEMP := TO_NUMBER(SUBSTR(PI_OPCAO,1,(Wi-1)));
  Wf := INSTR(PI_OPCAO,'#',1,2);
  PI_CODREDE := SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,3);
  PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,4);
  PI_ORCAMENTO := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,5);
  PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));

  v_ano := TO_NUMBER(TO_CHAR(PI_DATA_REF,'YYYY'));
  v_mes := TO_NUMBER(TO_CHAR(PI_DATA_REF,'MM'));
  v_dt_ini := TRUNC(PI_DATA_REF,'MM');
  v_dt_fim := LAST_DAY(PI_DATA_REF);

  -- Limpa base do mês alvo (idempotência)
  DELETE FROM GRZ_PLR_MENSAL
   WHERE ANO = v_ano AND MES = v_mes
     AND COD_EMP = PI_CODEMP
     AND COD_REDE = PI_CODREDE
     AND COD_GRUPO = PI_CODGRUPO;

  OPEN c_totais_orcamento;
  LOOP
    FETCH c_totais_orcamento INTO r; EXIT WHEN c_totais_orcamento%NOTFOUND;
    -- Derivados
    DECLARE
      v_per_lucro       NUMBER(9,2);
      v_per_inventario  NUMBER(9,2);
      v_per_desp_trans  NUMBER(9,2);
      v_per_desp_folha  NUMBER(9,2);
    BEGIN
      IF NVL(r.Vlr_Venda_Liq,0) > 0 THEN
        v_per_lucro      := ROUND((NVL(r.Vlr_Lucro,0) * 100) / r.Vlr_Venda_Liq, 2);
        v_per_inventario := ROUND((NVL(r.Vlr_Falta_Inventario,0) * 100) / r.Vlr_Venda_Liq, 2);
        v_per_desp_trans := NULL; -- preencher quando houver transporte no mês (ver proc de RH/Transporte)
        v_per_desp_folha := ROUND((NVL(r.Custo_Folha,0) * 100) / r.Vlr_Venda_Liq, 2);
      ELSE
        v_per_lucro := 0; v_per_inventario := 0; v_per_desp_trans := 0; v_per_desp_folha := 0;
      END IF;

      -- UPSERT (MERGE) NA FATO MENSAL
      MERGE INTO GRZ_PLR_MENSAL t
      USING (SELECT v_ano ANO, v_mes MES,
                    PI_CODEMP COD_EMP, PI_CODREDE COD_REDE, PI_CODGRUPO COD_GRUPO,
                    r.cod_unidade COD_UNIDADE FROM dual) s
      ON (t.ANO=s.ANO AND t.MES=s.MES AND t.COD_EMP=s.COD_EMP AND t.COD_REDE=s.COD_REDE
          AND t.COD_GRUPO=s.COD_GRUPO AND t.COD_UNIDADE=s.COD_UNIDADE)
      WHEN MATCHED THEN UPDATE SET
        VLR_VENDA_ORC        = r.Vlr_Venda_Orc,
        VLR_VENDA_REAL       = r.Vlr_Venda_Real,
        VLR_VENDA_LIQ        = r.Vlr_Venda_Liq,
        VLR_MARGEM_ORC       = r.Vlr_Margem_Orc,
        VLR_MARGEM_REAL      = r.Vlr_Margem_Real,
        VLR_FALTA_INVENTARIO = r.Vlr_Falta_Inventario,
        VLR_LUCRO            = r.Vlr_Lucro,
        VLR_CUSTO_FOLHA      = r.Custo_Folha,
        PER_LUCRO            = v_per_lucro,
        PER_INVENTARIO       = v_per_inventario,
        PER_DESP_FOLHA       = v_per_desp_folha,
        DTA_CALC             = SYSDATE
      WHEN NOT MATCHED THEN INSERT (
        ANO,MES,COD_EMP,COD_REDE,COD_GRUPO,COD_UNIDADE,
        VLR_VENDA_ORC,VLR_VENDA_REAL,VLR_VENDA_LIQ,VLR_MARGEM_ORC,VLR_MARGEM_REAL,
        VLR_FALTA_INVENTARIO,VLR_LUCRO,VLR_CUSTO_FOLHA,
        PER_LUCRO,PER_INVENTARIO,PER_DESP_FOLHA,DTA_CALC
      ) VALUES (
        v_ano,v_mes,PI_CODEMP,PI_CODREDE,PI_CODGRUPO,r.cod_unidade,
        r.Vlr_Venda_Orc,r.Vlr_Venda_Real,r.Vlr_Venda_Liq,r.Vlr_Margem_Orc,r.Vlr_Margem_Real,
        r.Vlr_Falta_Inventario,r.Vlr_Lucro,r.Custo_Folha,
        v_per_lucro,v_per_inventario,v_per_desp_folha,SYSDATE
      );
    END;
  END LOOP;
  CLOSE c_totais_orcamento;
END;
/
SHOW ERRORS

/*------------------------------------------------------------------
  7) PROCEDURE: PERMANÊNCIA (12 MESES ATÉ O MÊS ALVO)
      - Adaptação mensal de GRZ_PERMANENCIA_APR_ANUAL_SP
  ------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE GRZ_PLR_MENSAL_PERMANENCIA_SP (PI_OPCAO IN VARCHAR2) IS
  PI_CODEMP     NUMBER;
  PI_CODREDE    VARCHAR2(2);
  PI_CODGRUPO   NUMBER;
  PI_CODMASCARA NUMBER;
  PI_DATA_REF   DATE;

  v_ano   NUMBER(4);
  v_mes   NUMBER(2);
  v_dt_ini_12m DATE;
  v_dt_fim DATE;
  Wi NUMBER; Wf NUMBER;

  CURSOR c_unidades IS
    SELECT ge.cod_quebra regiao, ge.cod_unidade
      FROM ge_grupos_unidades ge
     WHERE ge.cod_grupo = PI_CODGRUPO
       AND ge.cod_emp   = PI_CODEMP
       AND ge.cod_unidade BETWEEN 0 AND 9999
     ORDER BY ge.cod_unidade;

  CURSOR c_perm (p_unidade NUMBER) IS
    SELECT SUM(NVL(A.VLR_CUSTO,0))                      AS VLR_CUSTO_PERM,
           SUM(NVL(A.VLR_ESTOQUE_ANT,0)+NVL(A.VLR_MEDIO_EMP,0)) AS VLR_EST_MEDIO_PERM
      FROM es_0124_ce_estmedio A
      JOIN ie_mascaras B ON B.cod_item = A.cod_item
      JOIN ie_itens    C ON C.cod_item = A.cod_item
     WHERE C.ind_avulso = 0
       AND B.cod_mascara = PI_CODMASCARA
       AND B.cod_niv0 = ''1''
       AND B.cod_niv1 = PI_CODREDE
       AND A.Cod_Unidade = p_unidade
       AND A.dta_mvto >= v_dt_ini_12m
       AND A.dta_mvto <= v_dt_fim;

BEGIN
  -- Desmembrar PI_OPCAO
  Wi := INSTR(PI_OPCAO,'#',1,1);
  PI_CODEMP := TO_NUMBER(SUBSTR(PI_OPCAO,1,(Wi-1)));
  Wf := INSTR(PI_OPCAO,'#',1,2);
  PI_CODREDE := SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,3);
  PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,4);
  PI_CODMASCARA := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,5);
  PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));

  v_ano := TO_NUMBER(TO_CHAR(PI_DATA_REF,'YYYY'));
  v_mes := TO_NUMBER(TO_CHAR(PI_DATA_REF,'MM'));
  v_dt_fim := LAST_DAY(PI_DATA_REF);
  v_dt_ini_12m := ADD_MONTHS(TRUNC(PI_DATA_REF,'MM'), -11); -- inclusive

  FOR r IN c_unidades LOOP
    FOR p IN c_perm(r.cod_unidade) LOOP
      MERGE INTO GRZ_PLR_MENSAL t
      USING (SELECT v_ano ANO, v_mes MES, PI_CODEMP COD_EMP, PI_CODREDE COD_REDE,
                    PI_CODGRUPO COD_GRUPO, r.cod_unidade COD_UNIDADE FROM dual) s
      ON (t.ANO=s.ANO AND t.MES=s.MES AND t.COD_EMP=s.COD_EMP AND t.COD_REDE=s.COD_REDE
          AND t.COD_GRUPO=s.COD_GRUPO AND t.COD_UNIDADE=s.COD_UNIDADE)
      WHEN MATCHED THEN UPDATE SET
        VLR_PERM_CUSTO_12M  = NVL(p.VLR_CUSTO_PERM,0),
        VLR_PERM_ESTMED_12M = NVL(p.VLR_EST_MEDIO_PERM,0),
        DTA_CALC            = SYSDATE
      WHEN NOT MATCHED THEN INSERT (
        ANO,MES,COD_EMP,COD_REDE,COD_GRUPO,COD_UNIDADE,
        VLR_PERM_CUSTO_12M,VLR_PERM_ESTMED_12M,DTA_CALC
      ) VALUES (
        v_ano,v_mes,PI_CODEMP,PI_CODREDE,PI_CODGRUPO,r.cod_unidade,
        NVL(p.VLR_CUSTO_PERM,0),NVL(p.VLR_EST_MEDIO_PERM,0),SYSDATE
      );
    END LOOP;
  END LOOP;
END;
/
SHOW ERRORS

/*------------------------------------------------------------------
  8) PROCEDURE: PREVENTIVA (MÊS)
      - Adaptação mensal de GRZ_PREVENTIVA_APR_ANUAL_SP
  ------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE GRZ_PLR_MENSAL_PREVENTIVA_SP (PI_OPCAO IN VARCHAR2) IS
  PI_CODEMP     NUMBER;
  PI_CODREDE    VARCHAR2(2);
  PI_CODGRUPO   NUMBER;
  PI_INDICE     NUMBER;
  PI_DATA_REF   DATE;

  v_ano   NUMBER(4);
  v_mes   NUMBER(2);
  v_dt_ini DATE;
  v_dt_fim DATE;
  Wi NUMBER; Wf NUMBER;

  CURSOR c_valores IS
    SELECT a.cod_unidade,
           SUM(NVL(a.vlr_preventivo,0)) AS vlr_preventiva
      FROM es_0124_cr_projecao a
      JOIN ge_grupos_unidades b ON b.cod_unidade = a.cod_unidade
     WHERE b.cod_grupo     = PI_CODGRUPO
       AND b.cod_emp       = PI_CODEMP
       AND a.dta_movimento >= v_dt_ini
       AND a.dta_movimento <= v_dt_fim
       AND a.cod_grupo_uni = ''9''||PI_CODREDE
       AND a.cod_quebra_lcto = PI_INDICE
     GROUP BY a.cod_unidade
     ORDER BY a.cod_unidade;

  r c_valores%ROWTYPE;
BEGIN
  -- Desmembrar PI_OPCAO
  Wi := INSTR(PI_OPCAO,'#',1,1);
  PI_CODEMP := TO_NUMBER(SUBSTR(PI_OPCAO,1,(Wi-1)));
  Wf := INSTR(PI_OPCAO,'#',1,2);
  PI_CODREDE := SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,3);
  PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,4);
  PI_INDICE := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,5);
  PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));

  v_ano := TO_NUMBER(TO_CHAR(PI_DATA_REF,'YYYY'));
  v_mes := TO_NUMBER(TO_CHAR(PI_DATA_REF,'MM'));
  v_dt_ini := TRUNC(PI_DATA_REF,'MM');
  v_dt_fim := LAST_DAY(PI_DATA_REF);

  OPEN c_valores;
  LOOP
    FETCH c_valores INTO r; EXIT WHEN c_valores%NOTFOUND;
    MERGE INTO GRZ_PLR_MENSAL t
    USING (SELECT v_ano ANO, v_mes MES, PI_CODEMP COD_EMP, PI_CODREDE COD_REDE,
                  PI_CODGRUPO COD_GRUPO, r.cod_unidade COD_UNIDADE FROM dual) s
    ON (t.ANO=s.ANO AND t.MES=s.MES AND t.COD_EMP=s.COD_EMP AND t.COD_REDE=s.COD_REDE
        AND t.COD_GRUPO=s.COD_GRUPO AND t.COD_UNIDADE=s.COD_UNIDADE)
    WHEN MATCHED THEN UPDATE SET
      VLR_PREVENTIVA_MES = NVL(r.vlr_preventiva,0),
      DTA_CALC           = SYSDATE
    WHEN NOT MATCHED THEN INSERT (
      ANO,MES,COD_EMP,COD_REDE,COD_GRUPO,COD_UNIDADE,
      VLR_PREVENTIVA_MES,DTA_CALC
    ) VALUES (
      v_ano,v_mes,PI_CODEMP,PI_CODREDE,PI_CODGRUPO,r.cod_unidade,
      NVL(r.vlr_preventiva,0),SYSDATE
    );
  END LOOP;
  CLOSE c_valores;
END;
/
SHOW ERRORS

/*------------------------------------------------------------------
  9) PROCEDURE: TREINAMENTO (MÊS)
      - Adaptação mensal de GRZ_TREINAMENTO_APR_ANUAL_SP
      - Se as fontes de G10/TPD/SEG_PESSOA/TRAINEE forem anuais, replicamos no mês.
  ------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE GRZ_PLR_MENSAL_TREINAMENTO_SP (PI_OPCAO IN VARCHAR2) IS
  PI_CODGRUPO NUMBER;
  PI_DATA_REF DATE;
  PI_REDE     NUMBER;

  v_ano   NUMBER(4);
  v_mes   NUMBER(2);
  v_dt_ini DATE;
  v_dt_fim DATE;
  Wi NUMBER; Wf NUMBER;

  CURSOR c_trein IS
    SELECT A.COD_UNIDADE,
           A.G10, A.TPD, A.SEG_PESSOA, A.TRAINEE
      FROM GRZ_PONTUACAO_APR_ANO A
      JOIN GE_GRUPOS_UNIDADES GE ON GE.COD_UNIDADE = A.COD_UNIDADE
     WHERE A.ANO = v_ano
       AND GE.COD_GRUPO = PI_CODGRUPO
       AND GE.COD_EMP   = 1
     ORDER BY A.COD_UNIDADE;
  r c_trein%ROWTYPE;
BEGIN
  -- Desmembrar PI_OPCAO -> 'PI_CODGRUPO#DATA_REF#PI_REDE#'
  Wi := INSTR(PI_OPCAO,'#',1,1);
  PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO,1,(Wi-1)));
  Wf := INSTR(PI_OPCAO,'#',1,2);
  PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,3);
  PI_REDE := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));

  v_ano := TO_NUMBER(TO_CHAR(PI_DATA_REF,'YYYY'));
  v_mes := TO_NUMBER(TO_CHAR(PI_DATA_REF,'MM'));
  v_dt_ini := TRUNC(PI_DATA_REF,'MM');
  v_dt_fim := LAST_DAY(PI_DATA_REF);

  OPEN c_trein;
  LOOP
    FETCH c_trein INTO r; EXIT WHEN c_trein%NOTFOUND;
    MERGE INTO GRZ_PLR_MENSAL t
    USING (SELECT v_ano ANO, v_mes MES, 1 COD_EMP, TO_CHAR(PI_REDE) COD_REDE,
                  PI_CODGRUPO COD_GRUPO, r.COD_UNIDADE COD_UNIDADE FROM dual) s
    ON (t.ANO=s.ANO AND t.MES=s.MES AND t.COD_EMP=s.COD_EMP AND t.COD_REDE=s.COD_REDE
        AND t.COD_GRUPO=s.COD_GRUPO AND t.COD_UNIDADE=s.COD_UNIDADE)
    WHEN MATCHED THEN UPDATE SET
      G10_MES        = NVL(r.G10,0),
      TPD_MES        = NVL(r.TPD,0),
      SEG_PESSOA_MES = NVL(r.SEG_PESSOA,0),
      TRAINEE_MES    = NVL(r.TRAINEE,0),
      DTA_CALC       = SYSDATE
    WHEN NOT MATCHED THEN INSERT (
      ANO,MES,COD_EMP,COD_REDE,COD_GRUPO,COD_UNIDADE,
      G10_MES,TPD_MES,SEG_PESSOA_MES,TRAINEE_MES,DTA_CALC
    ) VALUES (
      v_ano,v_mes,1,TO_CHAR(PI_REDE),PI_CODGRUPO,r.COD_UNIDADE,
      NVL(r.G10,0),NVL(r.TPD,0),NVL(r.SEG_PESSOA,0),NVL(r.TRAINEE,0),SYSDATE
    );
  END LOOP;
  CLOSE c_trein;
END;
/
SHOW ERRORS

/*------------------------------------------------------------------
  10) PROCEDURE: REGIÕES (MÊS) – AGREGAÇÃO
       - Adaptação mensal de GRZ_REGIOES_APR_ANUAL_SP
  ------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE GRZ_PLR_MENSAL_REGIOES_SP (PI_OPCAO IN VARCHAR2) IS
  PI_CODGRUPO NUMBER;
  PI_DATA_REF DATE;
  PI_CODREDE  NUMBER;

  v_ano   NUMBER(4);
  v_mes   NUMBER(2);
  Wi NUMBER; Wf NUMBER;
BEGIN
  -- Desmembrar PI_OPCAO -> 'CODGRUPO#DATA_REF#CODREDE#'
  Wi := INSTR(PI_OPCAO,'#',1,1);
  PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO,1,(Wi-1)));
  Wf := INSTR(PI_OPCAO,'#',1,2);
  PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,3);
  PI_CODREDE := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));

  v_ano := TO_NUMBER(TO_CHAR(PI_DATA_REF,'YYYY'));
  v_mes := TO_NUMBER(TO_CHAR(PI_DATA_REF,'MM'));

  -- Recarregar agregados de região para a competência
  DELETE FROM GRZ_PLR_MENSAL_REGIOES
   WHERE ANO = v_ano AND MES = v_mes
     AND COD_REDE = TO_CHAR(PI_CODREDE)
     AND COD_GRUPO = PI_CODGRUPO;

  INSERT INTO GRZ_PLR_MENSAL_REGIOES (
    ANO,MES,COD_EMP,COD_REDE,COD_GRUPO,REGIAO,
    VLR_VENDA_ORC,VLR_VENDA_REAL,VLR_VENDA_LIQ,VLR_MARGEM_ORC,VLR_MARGEM_REAL,
    VLR_LUCRO,VLR_FALTA_INVENTARIO,VLR_CUSTO_FOLHA,VLR_DEVOLUCAO,
    VALE_TRANSP,HORAS_TRAB,VLR_PERM_CUSTO_12M,VLR_PERM_ESTMED_12M,
    VLR_PREVENTIVA_MES,DEMISSOES_MES,EFETIVO_INI_MES,TURNOVER_MES,
    G10_MES,TPD_MES,SEG_PESSOA_MES,TRAINEE_MES,
    TOTAL_PONTOS,DTA_CALC
  )
  SELECT ANO,MES,COD_EMP,COD_REDE,COD_GRUPO,REGIAO,
         SUM(VLR_VENDA_ORC),SUM(VLR_VENDA_REAL),SUM(VLR_VENDA_LIQ),
         SUM(VLR_MARGEM_ORC),SUM(VLR_MARGEM_REAL),
         SUM(VLR_LUCRO),SUM(VLR_FALTA_INVENTARIO),SUM(VLR_CUSTO_FOLHA),SUM(VLR_DEVOLUCAO),
         SUM(VALE_TRANSP),SUM(HORAS_TRAB),SUM(VLR_PERM_CUSTO_12M),SUM(VLR_PERM_ESTMED_12M),
         SUM(VLR_PREVENTIVA_MES),SUM(DEMISSOES_MES),SUM(EFETIVO_INI_MES),SUM(TURNOVER_MES),
         SUM(G10_MES),SUM(TPD_MES),SUM(SEG_PESSOA_MES),SUM(TRAINEE_MES),
         SUM(NVL(TOTAL_PONTOS,0)), SYSDATE
    FROM GRZ_PLR_MENSAL
   WHERE ANO = v_ano AND MES = v_mes
     AND COD_REDE = TO_CHAR(PI_CODREDE)
     AND COD_GRUPO = PI_CODGRUPO
   GROUP BY ANO,MES,COD_EMP,COD_REDE,COD_GRUPO,REGIAO;
END;
/
SHOW ERRORS

/*------------------------------------------------------------------
  11) PROCEDURE: CIA (LOJAS UNIFICADAS) – MÊS
       - Adaptação mensal de GRZ_ORCAMENTO_APR_ANUAL_CIA_SP
  ------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE GRZ_PLR_MENSAL_CIA_SP (PI_OPCAO IN VARCHAR2) IS
  PI_CODEMP     NUMBER;
  PI_CODREDE    VARCHAR2(2);
  PI_CODGRUPO   NUMBER;
  PI_ORCAMENTO  NUMBER;
  PI_DATA_REF   DATE;

  v_ano   NUMBER(4);
  v_mes   NUMBER(2);
  v_dt_ini DATE;
  v_dt_fim DATE;
  Wi NUMBER; Wf NUMBER;

  CURSOR c_unif IS
    SELECT b.cod_unidade_para AS cod_unidade
      FROM grz_lojas_gzt_apr b;

  CURSOR c_totais (p_unidade NUMBER) IS
    SELECT
           SUM(CASE a.des_chave WHEN ''01#01001'' THEN NVL(a.vlr_orcado,0)
                                 WHEN ''01#01003'' THEN NVL(a.vlr_orcado,0)
                                 WHEN ''01#01005'' THEN NVL(a.vlr_orcado,0) ELSE 0 END) AS Vlr_Venda_Orc,
           SUM(CASE a.des_chave WHEN ''01#01001'' THEN NVL(a.vlr_realizado,0)
                                 WHEN ''01#01003'' THEN NVL(a.vlr_realizado,0)
                                 WHEN ''01#01005'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Venda_Real,
           SUM(CASE a.des_chave WHEN ''05#05001'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Venda_Liq,
           SUM(CASE a.des_chave WHEN ''09#09001'' THEN NVL(a.vlr_orcado,0) ELSE 0 END) AS Vlr_Margem_Orc,
           SUM(CASE a.des_chave WHEN ''09#09001'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Margem_Real,
           SUM(CASE a.des_chave WHEN ''11#11001'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Falta_Inventario,
           SUM(CASE a.des_chave WHEN ''45#45001'' THEN NVL(a.vlr_realizado,0) ELSE 0 END) AS Vlr_Lucro
      FROM or_valores a
      JOIN grz_lojas_gzt_apr b ON a.cod_unidade = b.cod_unidade_de
     WHERE b.cod_unidade_para = p_unidade
       AND a.cod_emp = PI_CODEMP
       AND a.cod_orcamento = PI_ORCAMENTO
       AND a.dta_orcamento >= v_dt_ini
       AND a.dta_orcamento <= v_dt_fim;

  r c_totais%ROWTYPE;
BEGIN
  -- Desmembrar PI_OPCAO
  Wi := INSTR(PI_OPCAO,'#',1,1);
  PI_CODEMP := TO_NUMBER(SUBSTR(PI_OPCAO,1,(Wi-1)));
  Wf := INSTR(PI_OPCAO,'#',1,2);
  PI_CODREDE := SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,3);
  PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,4);
  PI_ORCAMENTO := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,5);
  PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));

  v_ano := TO_NUMBER(TO_CHAR(PI_DATA_REF,'YYYY'));
  v_mes := TO_NUMBER(TO_CHAR(PI_DATA_REF,'MM'));
  v_dt_ini := TRUNC(PI_DATA_REF,'MM');
  v_dt_fim := LAST_DAY(PI_DATA_REF);

  -- Limpa base do mês alvo
  DELETE FROM GRZ_PLR_MENSAL
   WHERE ANO = v_ano AND MES = v_mes
     AND COD_EMP = PI_CODEMP
     AND COD_REDE = PI_CODREDE
     AND COD_GRUPO = PI_CODGRUPO
     AND COD_UNIDADE IN (SELECT cod_unidade_para FROM grz_lojas_gzt_apr);

  FOR u IN c_unif LOOP
    OPEN c_totais(u.cod_unidade);
    FETCH c_totais INTO r;
    CLOSE c_totais;

    MERGE INTO GRZ_PLR_MENSAL t
    USING (SELECT v_ano ANO, v_mes MES, PI_CODEMP COD_EMP, PI_CODREDE COD_REDE,
                  PI_CODGRUPO COD_GRUPO, u.cod_unidade COD_UNIDADE FROM dual) s
    ON (t.ANO=s.ANO AND t.MES=s.MES AND t.COD_EMP=s.COD_EMP AND t.COD_REDE=s.COD_REDE
        AND t.COD_GRUPO=s.COD_GRUPO AND t.COD_UNIDADE=s.COD_UNIDADE)
    WHEN MATCHED THEN UPDATE SET
      VLR_VENDA_ORC   = NVL(r.Vlr_Venda_Orc,0),
      VLR_VENDA_REAL  = NVL(r.Vlr_Venda_Real,0),
      VLR_VENDA_LIQ   = NVL(r.Vlr_Venda_Liq,0),
      VLR_MARGEM_ORC  = NVL(r.Vlr_Margem_Orc,0),
      VLR_MARGEM_REAL = NVL(r.Vlr_Margem_Real,0),
      VLR_FALTA_INVENTARIO = NVL(r.Vlr_Falta_Inventario,0),
      VLR_LUCRO       = NVL(r.Vlr_Lucro,0),
      DTA_CALC        = SYSDATE
    WHEN NOT MATCHED THEN INSERT (
      ANO,MES,COD_EMP,COD_REDE,COD_GRUPO,COD_UNIDADE,
      VLR_VENDA_ORC,VLR_VENDA_REAL,VLR_VENDA_LIQ,VLR_MARGEM_ORC,VLR_MARGEM_REAL,
      VLR_FALTA_INVENTARIO,VLR_LUCRO,DTA_CALC
    ) VALUES (
      v_ano,v_mes,PI_CODEMP,PI_CODREDE,PI_CODGRUPO,u.cod_unidade,
      NVL(r.Vlr_Venda_Orc,0),NVL(r.Vlr_Venda_Real,0),NVL(r.Vlr_Venda_Liq,0),
      NVL(r.Vlr_Margem_Orc,0),NVL(r.Vlr_Margem_Real,0),NVL(r.Vlr_Falta_Inventario,0),
      NVL(r.Vlr_Lucro,0),SYSDATE
    );
  END LOOP;
END;
/
SHOW ERRORS

/*------------------------------------------------------------------
  12) PROCEDURE: CÁLCULO DE PONTOS (aplica tabela GRZ_CAD_CALCULO_PLR_MENSAL)
  ------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE GRZ_PLR_MENSAL_CALC_PONTOS_SP (
  PI_CODEMP   IN NUMBER,
  PI_CODREDE  IN VARCHAR2,
  PI_CODGRUPO IN NUMBER,
  PI_DATA_REF IN DATE
) IS
  v_ano NUMBER(4) := TO_NUMBER(TO_CHAR(PI_DATA_REF,''YYYY''));
  v_mes NUMBER(2) := TO_NUMBER(TO_CHAR(PI_DATA_REF,''MM''));
BEGIN
  /*
    Regras de exemplo (ajuste conforme GRZ_CAD_CALCULO_PLR_MENSAL):
    - cod_calculo = 1: pontos por "per_lucro" (usa VALOR1 como corte mínimo)
    - cod_calculo = 2: pontos por PERMANÊNCIA (poderia ser DÍAS = 360 / (ESTMED/CUSTO) etc.)
    - cod_calculo = 3: preventiva (usa VALOR1 como teto)
    - cod_calculo = 4: margem (usar PER_MARGEM real calculado = VLR_MARGEM_REAL/VLR_VENDA_LIQ*100)
    - cod_calculo = 5: inventário (quanto menor melhor)
    - cod_calculo = 6: folha (% sobre venda líquida)
    - cod_calculo = 7: treinamento (G10/TPD/SEG_PESSOA/TRAINEE combinados)
  */

  -- Exemplo simples: PT_LUCRO baseado em PER_LUCRO
  MERGE INTO GRZ_PLR_MENSAL t
  USING (
    SELECT m.ANO, m.MES, m.COD_EMP, m.COD_REDE, m.COD_GRUPO, m.COD_UNIDADE,
           NVL(MAX(CASE WHEN c.COD_CALCULO = 1 AND m.PER_LUCRO >= NVL(c.VALOR1,0) THEN c.QTD_PONTOS ELSE 0 END),0) AS PT_LUCRO
      FROM GRZ_PLR_MENSAL m
      LEFT JOIN GRZ_CAD_CALCULO_PLR_MENSAL c
        ON c.ANO = m.ANO AND c.MES = m.MES AND c.COD_REDE = m.COD_REDE
     WHERE m.ANO = v_ano AND m.MES = v_mes
       AND m.COD_EMP = PI_CODEMP
       AND m.COD_REDE = PI_CODREDE
       AND m.COD_GRUPO = PI_CODGRUPO
     GROUP BY m.ANO, m.MES, m.COD_EMP, m.COD_REDE, m.COD_GRUPO, m.COD_UNIDADE
  ) s
  ON (t.ANO=s.ANO AND t.MES=s.MES AND t.COD_EMP=s.COD_EMP AND t.COD_REDE=s.COD_REDE
      AND t.COD_GRUPO=s.COD_GRUPO AND t.COD_UNIDADE=s.COD_UNIDADE)
  WHEN MATCHED THEN UPDATE SET
    t.PT_LUCRO = s.PT_LUCRO,
    t.TOTAL_PONTOS = NVL(t.PT_ORCADO,0)+NVL(t.PT_MARGEM,0)+NVL(s.PT_LUCRO,0)+NVL(t.PT_INVENTARIO,0)+
                     NVL(t.PT_PREVENTIVA,0)+NVL(t.PT_PERMANENCIA,0)+NVL(t.PT_VALE_TRANSP,0)+
                     NVL(t.PT_PRODUTIVIDADE,0)+NVL(t.PT_FOLHA,0)+NVL(t.PT_TURNOVER,0)+
                     NVL(t.PT_TREINAMENTO,0)+NVL(t.PT_OUTROS,0);

  -- OBS: Replicar MERGE acima para cada COD_CALCULO conforme suas fórmulas
  --      (margem, inventário, folha, preventiva, permanência, treinamento etc.).
END;
/
SHOW ERRORS

/*------------------------------------------------------------------
  13) PROCEDURE ORQUESTRADORA (EXECUTA TODAS AS ETAPAS PARA O MÊS)
  ------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE GRZ_PLR_MENSAL_FECHAMENTO_SP (PI_OPCAO IN VARCHAR2) IS
  -- Padrão esperado: 'CODEMP#CODREDE#CODGRUPO#COD_ORCAMENTO#DATA_REF#'
  PI_CODEMP     NUMBER;
  PI_CODREDE    VARCHAR2(2);
  PI_CODGRUPO   NUMBER;
  PI_ORCAMENTO  NUMBER;
  PI_DATA_REF   DATE;
  Wi NUMBER; Wf NUMBER;
BEGIN
  -- Parse
  Wi := INSTR(PI_OPCAO,'#',1,1);
  PI_CODEMP := TO_NUMBER(SUBSTR(PI_OPCAO,1,(Wi-1)));
  Wf := INSTR(PI_OPCAO,'#',1,2);
  PI_CODREDE := SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,3);
  PI_CODGRUPO := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,4);
  PI_ORCAMENTO := TO_NUMBER(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));
  Wi := Wf;
  Wf := INSTR(PI_OPCAO,'#',1,5);
  PI_DATA_REF := TO_DATE(SUBSTR(PI_OPCAO,(Wi+1),(Wf-Wi-1)));

  -- 1) Carga financeira por loja (mês)
  GRZ_PLR_MENSAL_ORCAMENTO_SP(PI_OPCAO);

  -- 2) Permanência (12 meses até PI_DATA_REF) – usar cod máscara 170 como padrão (ajuste se necessário)
  GRZ_PLR_MENSAL_PERMANENCIA_SP(PI_CODEMP||''#''||PI_CODREDE||''#''||PI_CODGRUPO||''#170#''||TO_CHAR(PI_DATA_REF,''DD/MM/YYYY'')||''#'');

  -- 3) Preventiva (índice parametrizável, exemplo 51) – ajuste PI_INDICE se necessário por rede
  GRZ_PLR_MENSAL_PREVENTIVA_SP(PI_CODEMP||''#''||PI_CODREDE||''#''||PI_CODGRUPO||''#51#''||TO_CHAR(PI_DATA_REF,''DD/MM/YYYY'')||''#'');

  -- 4) Treinamento (usa dados do ano para o mês)
  GRZ_PLR_MENSAL_TREINAMENTO_SP(PI_CODGRUPO||''#''||TO_CHAR(PI_DATA_REF,''DD/MM/YYYY'')||''#''||PI_CODREDE||''#'');

  -- 5) Cálculo de pontos (aplica tabela de parâmetros mensal)
  GRZ_PLR_MENSAL_CALC_PONTOS_SP(PI_CODEMP, PI_CODREDE, PI_CODGRUPO, PI_DATA_REF);

  -- 6) Agregado por Região
  GRZ_PLR_MENSAL_REGIOES_SP(PI_CODGRUPO||''#''||TO_CHAR(PI_DATA_REF,''DD/MM/YYYY'')||''#''||PI_CODREDE||''#'');
END;
/
SHOW ERRORS

-- FIM DO SCRIPT
