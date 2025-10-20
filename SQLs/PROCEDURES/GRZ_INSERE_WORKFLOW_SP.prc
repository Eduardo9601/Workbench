CREATE OR REPLACE PROCEDURE GRZ_INSERE_WORKFLOW_SP (
  p_unidade_ini         IN VARCHAR2,
  p_unidade_fim         IN VARCHAR2,
  p_data_agend          IN DATE,
  p_hora_agend          IN VARCHAR2,
  p_relatorio           IN VARCHAR2, -- Código do relatório
  p_ultimo_cod_processo IN NUMBER -- Último código de processo
) AS
  v_data_hora_agend TIMESTAMP;
  v_descricao       VARCHAR2(4000); -- Para armazenar a descrição do relatório
  v_cod_unidade     VARCHAR2(10);   -- Para armazenar o código da unidade no formato correto
BEGIN
 
  -- Combinando data e hora em um TIMESTAMP
v_data_hora_agend := TO_TIMESTAMP(
    TO_CHAR(p_data_agend, 'DD/MM/YYYY') || ' ' || p_hora_agend,
    'DD/MM/YYYY HH24:MI:SS'
  );


  -- Buscar a descrição do relatório informado
  SELECT DESCRICAO INTO v_descricao FROM GRGE0010 WHERE RELATORIO = p_relatorio;

  FOR r IN (
    SELECT 
      TO_NUMBER(COD_UNIDADE) AS NUMERIC_COD_UNIDADE, 
      COD_UNIDADE, 
      EMAIL_LOJA, 
      (p_ultimo_cod_processo + ROW_NUMBER() OVER (ORDER BY TO_NUMBER(COD_UNIDADE))) AS COD_PROCESSO
    FROM V_DADOS_LOJAS_AVT
    WHERE TO_NUMBER(COD_UNIDADE) BETWEEN TO_NUMBER(p_unidade_ini) AND TO_NUMBER(p_unidade_fim)
  ) LOOP
    -- Formatar o código da unidade corretamente
    v_cod_unidade := LPAD(r.COD_UNIDADE, LENGTH(r.NUMERIC_COD_UNIDADE), '0');

    INSERT INTO RHWF0405 (
      COD_PROCESSO, NOME_PROCESSO, TIPO_PROCESSO, PASTA_LOG, EMAIL_LOG,
      DATA_AGENDAMENTO, ULT_EXECUCAO, PROX_EXECUCAO, PERIODICIDADE,
      IND_TERMINO, NRO_OCO_TERMINO, DATA_TERMINO, NRO_EXECUCOES, COD_PROGRAMA,
      COD_RELATORIO, IND_PDF, IND_EXCEL, PASTA_RESULT, DIA_INI, MES_INI,
      DIA_FIM, MES_FIM, DIA_REF, MES_REF, COD_EVENTO, COD_RELAT_GR, COD_ARQUIVO,
      SELECAO, MINUTOS, IND_ORIGEM, COD_MESTRE_EVENTO
    ) VALUES (
      r.COD_PROCESSO, 
      p_relatorio || ' - ' ||  v_descricao || ' - ' || v_cod_unidade,
      'GR',
      'C:\Temp',
      'log.disparosautomaticos@gmail.com',
      v_data_hora_agend,
      NULL,
      NULL,
      'M',
      'N',
      NULL,
      NULL,
      1,
      NULL,
      p_relatorio,
      'S',
      'N',
      'C:\Temp',
      1,
      0,
      31,
      0,
      31,
      0,
      1,
      p_relatorio,
      NULL,
      NULL,
      NULL,
      'D',
      NULL
    );
  END
LOOP;

--COMMIT;
EXCEPTION
WHEN NO_DATA_FOUND THEN
RAISE_APPLICATION_ERROR(-20001, 'Descrição de relatório não encontrada para o código fornecido.');
WHEN OTHERS THEN
RAISE;
END GRZ_INSERE_WORKFLOW_SP;
/
