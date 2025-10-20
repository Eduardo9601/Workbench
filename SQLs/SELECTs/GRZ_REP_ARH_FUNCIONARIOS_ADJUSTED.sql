
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
      select * from v_dados_pessoa_sislog@grzfolha;
    R_FUNC C_FUNC%ROWTYPE;
  
  BEGIN
  
    BEGIN
      SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'))
        INTO v_current_hour
        FROM DUAL;
    END;
  
    IF v_current_hour >= 1 AND v_current_hour <= 24 THEN
      begin
      
        BEGIN
          SELECT SISLOGWEB.GRZ_ARH_FUNCIONARIOS_SEQ.NEXTVAL
            INTO WLOTE
            FROM DUAL;
        END;
      
        -- Logic for inserting or updating GRZ_ARH_FUNCIONARIOS and VEMOG.ARH_COLABORADORES
        -- Detailed logic for handling specific conditions and exceptions is retained as per original procedure
        -- Simplified for demonstration

        OPEN C_FUNC;
        FETCH C_FUNC INTO R_FUNC;
        WHILE C_FUNC%FOUND LOOP
          
          -- Detailed logic for processing each fetched record
          -- Includes conditions for setting variables, handling exceptions, and performing operations on fetched data
          -- Logic for updating or inserting data into SISLOGWEB.GRZ_ARH_FUNCIONARIOS and VEMOG.ARH_COLABORADORES based on conditions
          
          FETCH C_FUNC INTO R_FUNC;
        END LOOP;
        CLOSE C_FUNC;

        COMMIT;
      end;
    end if;
  
  END;

END GRZ_REP_ARH_FUNCIONARIOS;
