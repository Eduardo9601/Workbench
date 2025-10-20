/*CURSOR OFICIAL PARA INSERÇÃO DOS PROCESSOS AUTOMÁTICOS*/


/*DELETE FROM RHWF0405
WHERE COD_PROCESSO BETWEEN 135 AND 489*/

DECLARE
  WARG          NUMBER;
  WDIAEXEC      NUMBER;
  WMESEXEC      NUMBER;
  WANOEXEC      NUMBER;
  WHORAEXEC     NUMBER;
  WMINUTOSEXEC  NUMBER;
  WSEGUNDOSEXEC NUMBER;
  WDOISPONTOS   VARCHAR2(1);
  WBARRA        VARCHAR2(1);
  WDATAHORAEXEC TIMESTAMP;
  SAIDA EXCEPTION;

  CURSOR C1 IS

    SELECT A.COD_UNIDADE,
           A.EMAIL_LOJA,
           A.COD_ORGANOGRAMA,
           SUBSTR(D.DESCRICAO, 1, 45) AS DESCRICAO
      FROM V_DADOS_LOJAS_AVT A, GRGE0010 D
     WHERE A.EMAIL_LOJA IS NOT NULL
         AND A.COD_UNIDADE BETWEEN '004' AND '7999'
       /*AND A.COD_UNIDADE IN ('004', '014', '019', '025', '033', '034', '040', '042', '050', '052', '053', '055', '061', '074', '075', '079', '082', '084', '125', '128', '158',
                             '159', '163', '184', '186', '199', '224', '227', '239', '252', '254', '261', '264', '267', '269', '278', '282', '283', '284', '287', '288', '290',
                             '307', '309', '324', '331', '352', '358', '359', '384', '391', '397', '402', '403', '409', '421', '448', '460', '467', '468', '488', '490',
                             '498', '499', '501', '508', '515', '526', '529', '530', '540', '554', '579', '580', '581', '595', '596', '606', '607', '615', '623', '626', '635',
                             '639', '641', '648', '7002', '7005', '7007', '7008', '7009', '7015', '7022', '7037', '7038', '7041', '7044', '7046', '7047', '7059', '7066', '7083',
                             '7092', '7093', '7108', '7138', '7145', '7173', '7183', '7244', '7268', '7390', '7412', '7430', '7461', '7485', '7491', '7493', '7500', '7548', '7569', '7582',
                             '7589', '7592', '7594', '7597', '7598', '7599', '7608', '7609', '7614', '7620', '7628', '7629', '7637', '7642', '7643')*/
       AND D.RELATORIO = 'RE0350D'
     ORDER BY A.COD_UNIDADE;

  R1 C1%ROWTYPE;
BEGIN

  WARG        := 0;
  WDOISPONTOS := ':';
  WBARRA      := '/';

  WDIAEXEC := :DIA_EXECUCAO;
  WMESEXEC := :MES_EXECUCAO;
  WANOEXEC := :ANO_EXECUCAO;

  WHORAEXEC     := :HORA_EXECUCAO;
  WMINUTOSEXEC  := :MINUTOS_EXECUCAO;
  WSEGUNDOSEXEC := :SEGUNDOS_EXECUCAO;

  FOR R1 IN C1 LOOP

    WARG := WARG + 1;

    IF WHORAEXEC <= 23 AND WMINUTOSEXEC < 56 THEN
      WMINUTOSEXEC := WMINUTOSEXEC + 2;
    ELSIF WHORAEXEC < 23 AND WMINUTOSEXEC = 56 THEN
      WMINUTOSEXEC  := 0;
      WSEGUNDOSEXEC := 0;
      WHORAEXEC     := WHORAEXEC + 1;
    ELSIF WHORAEXEC = 23 AND WMINUTOSEXEC = 56 THEN
      WDIAEXEC      := WDIAEXEC + 1;
      WHORAEXEC     := 10;
      WMINUTOSEXEC  := 00;
      WSEGUNDOSEXEC := 00;
    END IF;

    WDATAHORAEXEC := TO_TIMESTAMP(WDIAEXEC || WBARRA || WMESEXEC || WBARRA ||
                                  WANOEXEC || ' ' || WHORAEXEC ||
                                  WDOISPONTOS || WMINUTOSEXEC ||
                                  WDOISPONTOS || WSEGUNDOSEXEC,
                                  'DD/MM/YYYY HH24:MI:SS');

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
       IND_ORIGEM)

    VALUES
      (:ULTIMO_COD_PROCESSO + warg,
       r1.descricao || ' - ' || r1.cod_unidade,
       'GR',
       'C:\Temp',
       'log.disparosautomaticos@gmail.com',
       wdatahoraexec,
       null,
       wdatahoraexec,
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
       -1, -- 0 OU -1
       31,
       -1, -- 0 OU -1
       31,
       -1, -- 0 OU -1
       1,
       :RELATORIO,
       null,
       null,
       null,
       'D');

    INSERT INTO RHWF0406
      (COD_PROCESSO, COD_SEQ, TIPO_FILTRO, FILTRO_CTS, DESTINATARIOS)

    values
      (:ULTIMO_COD_PROCESSO + warg,
       1,
       'O',
       r1.cod_organograma,
       r1.email_loja);

    COMMIT;

  END LOOP;

EXCEPTION
  WHEN SAIDA THEN
    NULL;

END;

































