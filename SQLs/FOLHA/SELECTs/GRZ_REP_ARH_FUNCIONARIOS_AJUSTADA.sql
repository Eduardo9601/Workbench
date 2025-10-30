
CREATE OR REPLACE PROCEDURE GRZ_REP_ARH_FUNCIONARIOS IS
BEGIN
  DECLARE
    WLOTE              NUMBER(18);
    WFOUNDINF          NUMBER(1);
    WFOUNDAUD          NUMBER(1);
    WIND_GESTOR        NUMBER(2);
    WCPF_GESTOR        VARCHAR2(20);
    WCIDADE            VARCHAR2(150);
    WEMAIL             VARCHAR2(150);
    WIND_UNIDADE       NUMBER(2);
    WCOD_AREA          NUMBER(7);
    WUNIDADE_GESTOR    NUMBER(5);
    WUNIDADE_CONTABIL  NUMBER(5);
    v_current_hour     NUMBER;
    WCOD_FUNC_ANTERIOR NUMBER(18);
    WGESTOR_TBM NUMBER(5);
  
    CURSOR C_FUNC IS
      SELECT * FROM v_dados_pessoa_sislog@grzfolha;
    R_FUNC C_FUNC%ROWTYPE;
  
  BEGIN
    SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) INTO v_current_hour FROM DUAL;
  
    IF v_current_hour >= 1 AND v_current_hour <= 24 THEN
      SELECT SISLOGWEB.GRZ_ARH_FUNCIONARIOS_SEQ.NEXTVAL INTO WLOTE FROM DUAL;
  
      -- Processamento específico omitido para simplificação
  
      -- Loop principal para processar informações dos funcionários
      OPEN C_FUNC;
      FETCH C_FUNC INTO R_FUNC;
      WHILE C_FUNC%FOUND LOOP
        -- Lógica específica de processamento para cada funcionário
        
        FETCH C_FUNC INTO R_FUNC;
      END LOOP;
      CLOSE C_FUNC;
  
      COMMIT;
    END IF;
  END;
END GRZ_REP_ARH_FUNCIONARIOS;
