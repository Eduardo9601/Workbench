CREATE OR REPLACE PROCEDURE GRZ_INSERE_WORKFLOW_SP(LOJA_INICIAL        IN NUMBER,
                                                   LOJA_FINAL          IN NUMBER,
                                                   RELATORIO           IN VARCHAR2,
                                                   DIA_EXECUCAO        IN NUMBER,
                                                   MES_EXECUCAO        IN NUMBER,
                                                   ANO_EXECUCAO        IN NUMBER,
                                                   HORA_EXECUCAO       IN NUMBER,
                                                   MINUTOS_EXECUCAO    IN NUMBER,
                                                   SEGUNDOS_EXECUCAO   IN NUMBER,
                                                   ULTIMO_COD_PROCESSO IN NUMBER) IS
  wArg          NUMBER;
  wDataHoraExec TIMESTAMP;
  SAIDA EXCEPTION;
  CURSOR c_workflow IS
    SELECT COD_UNIDADE,
           EMAIL,
           ORG_LOJA,
           SUBSTR(D.DESCRICAO, 1, 45) AS DESCRICAO
      FROM V_DADOS_LOJAS_AVT A, GRGE0010 D
     WHERE A.COD_UNIDADE BETWEEN LOJA_INICIAL AND LOJA_FINAL
       AND D.RELATORIO = RELATORIO
     ORDER BY A.COD_UNIDADE;
BEGIN
  wArg          := 0;
  wDataHoraExec := TO_TIMESTAMP(LPAD(TO_CHAR(DIA_EXECUCAO), 2, '0') || '-' ||
                                LPAD(TO_CHAR(MES_EXECUCAO), 2, '0') || '-' ||
                                TO_CHAR(ANO_EXECUCAO) || ' ' ||
                                LPAD(TO_CHAR(HORA_EXECUCAO), 2, '0') || ':' ||
                                LPAD(TO_CHAR(MINUTOS_EXECUCAO), 2, '0') || ':' ||
                                LPAD(TO_CHAR(SEGUNDOS_EXECUCAO), 2, '0'),
                                'DD-MM-YYYY HH24:MI:SS');

  FOR R1 IN c_workflow LOOP
    wArg          := wArg + 1;
    wDataHoraExec := wDataHoraExec + NUMTODSINTERVAL(2, 'MINUTE');
  
    -- A inserção na tabela RHWF0405
    INSERT INTO RHWF0405
      (COD_PROCESSO,
       NOME_PROCESSO,
       TIPO_PROCESSO,
       PASTA_LOG,
       EMAIL_LOG,
       DATA_AGENDAMENTO,
       ULT_EXECUCAO,
       PROX_EXECUCAO,
       PERIODICIDADE,
       IND_TERMINO,
       NRO_OCO_TERMINO,
       DATA_TERMINO,
       NRO_EXECUCOES,
       COD_PROGRAMA,
       COD_RELATORIO,
       IND_PDF,
       IND_EXCEL,
       PASTA_RESULT,
       DIA_INI,
       MES_INI,
       DIA_FIM,
       MES_FIM,
       DIA_REF,
       MES_REF,
       COD_EVENTO,
       COD_RELAT_GR,
       COD_ARQUIVO,
       SELECAO,
       MINUTOS,
       IND_ORIGEM,
       COD_MESTRE_EVENTO)
    VALUES
      (ULTIMO_COD_PROCESSO + wArg,
       R1.DESCRICAO || ' - ' || R1.COD_UNIDADE,
       'GR',
       'C:\Temp',
       'noreply@grupograzziotin.com.br',
       wDataHoraExec,
       NULL,
       wDataHoraExec,
       'M',
       'N',
       NULL,
       NULL,
       0,
       NULL,
       RELATORIO, -- Não precisa do ':' aqui porque é um parâmetro, não uma variável de bind
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
       RELATORIO,
       NULL,
       NULL,
       NULL,
       'D',
       NULL);
  
    -- A inserção na tabela RHWF0406
    INSERT INTO RHWF0406
      (COD_PROCESSO, COD_SEQ, TIPO_FILTRO, FILTRO_CTS, DESTINATARIOS)
    VALUES
      (ULTIMO_COD_PROCESSO + wArg, 1, 'O', R1.COD_UNIDADE, R1.EMAIL);
  
  -- Supondo que ULTIMO_COD_PROCESSO deve ser atualizado para refletir o último valor usado
  -- ULTIMO_COD_PROCESSO := ULTIMO_COD_PROCESSO + wArg;
  
  END LOOP;
EXCEPTION
  WHEN SAIDA THEN
    -- Tratar a exceção conforme necessário
    NULL;
END GRZ_INSERE_WORKFLOW_SP;