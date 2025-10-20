DECLARE
  wArg          number;
  wDiaExec      number;
  wMesExec      number;
  wAnoExec      number;
  wHoraExec     number;
  wMinutosExec  number;
  wSegundosExec number;
  wDoisPontos   string(1);
  wBarra        string(1);
  wDataHoraExec timestamp;
  saida exception;

  CURSOR C1 IS
    SELECT A.ORG_LOJA,
           A.UNIDADE AS UNIDADE,
           A.EMAIL AS EMAIL,
           SUBSTR(B.DESCRICAO, 1, 80) AS DESCRICAO
      FROM V_DADOS_LOJAS_AVT A, GRGE0010 B
     WHERE A.UNIDADE BETWEEN :UNIDADE_INI AND :UNIDADE_FIM
       AND A.EMPRESA = 008
       AND B.RELATORIO = 'PA-FM+2H';
  r1 C1%ROWTYPE;
BEGIN

  wArg        := 0;
  wDoisPontos := ':';
  wBarra      := '/';

  wDiaExec := :DIA_EXECUCAO;
  wMesExec := :MES_EXECUCAO;
  wAnoExec := :ANO_EXECUCAO;

  wHoraExec     := :HORA_EXECUCAO;
  wMinutosExec  := :MINUTOS_EXECUCAO;
  wSegundosExec := :SEGUNDOS_EXECUCAO;

  --wDataHoraExec := '01/02/2022 ' ||  '23:58:00';

  FOR R1 IN C1 LOOP

    wArg := wArg + 1;

    if wHoraExec <= 23 and wMinutosExec < 56 then
      wMinutosExec := wMinutosExec + 2;

    elsif wHoraExec < 23 and wMinutosExec = 56 then
      wMinutosExec  := 0;
      wSegundosExec := 0;
      wHoraExec     := wHoraExec + 1;

    elsif wHoraExec = 23 and wMinutosExec = 56 then

      wDiaExec      := wDiaExec + 1;
      wHoraExec     := 10;
      wMinutosExec  := 00;
      wSegundosExec := 00;
    end if;

    wDataHoraExec := wDiaExec || wBarra || wMesExec || wBarra || wAnoExec ||
                     wHoraExec || wDoisPontos || wMinutosExec ||
                     wDoisPontos || wSegundosExec;

    insert into RHWF0405
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
       IND_ORIGEM)

    values
      (:ULTIMO_COD_PROCESSO + wArg,
       r1.descricao || ' - ' || R1.ORG_LOJA,
       'GR',
       'C:\Temp',
       'noreply@grupograzziotin.com.br',
       wDataHoraExec,
       null,
       wDataHoraExec,
       'M',
       'N',
       null,
       null,
       0,
       null,
       null,
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
       :RELATORIO,
       null,
       null,
       null,
       'D');

    insert into RHWF0406
      (COD_PROCESSO, COD_SEQ, TIPO_FILTRO, FILTRO_CTS, DESTINATARIOS)

    values
      (:ULTIMO_COD_PROCESSO + wArg, 1, 'O', r1.ORG_LOJA, r1.email);

    COMMIT;

  END LOOP;

EXCEPTION
  WHEN SAIDA THEN
    NULL;

END;