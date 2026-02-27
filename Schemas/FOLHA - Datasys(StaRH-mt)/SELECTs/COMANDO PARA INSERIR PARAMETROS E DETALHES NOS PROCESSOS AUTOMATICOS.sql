--===COMANDO PARA INSERIR PARAMETROS E DETALHES NOS PROCESSOS AUTOMATICOS


WITH Unidades AS (
  SELECT DISTINCT COD_UNIDADE
  FROM V_DADOS_LOJAS_AVT
  WHERE COD_UNIDADE = '004'
),
Numerado AS (
  SELECT COD_UNIDADE, 
         ROW_NUMBER() OVER (ORDER BY COD_UNIDADE) AS seq
  FROM Unidades
),
Base AS (
  SELECT 1050 AS primeiro_cod_processo, -- Assumindo que 1049 é o último e começaremos de 1050
         TO_TIMESTAMP('11/03/2024 17:00:00', 'DD/MM/YYYY HH24:MI:SS') AS data_base
  FROM DUAL
)
SELECT (B.primeiro_cod_processo + N.seq - 1) AS COD_PROCESSO,
       'DECLRACA' || ' - ' ||  'AUTODECLARAÇÃO DE ETINIA/RAÇA' || ' - ' || N.COD_UNIDADE AS NOME_PROCESSO,
       'GR' AS TIPO_PROCESSO,
       'C:\Temp' AS PASTA_LOG,
       'log.disparosautomaticos@gmail.com' AS EMAIL_LOG,
       CAST(B.data_base AS DATE) + (N.seq - 1) * INTERVAL '2' MINUTE AS DATA_AGENDAMENTO, -- Ajuste aqui
       NULL AS ULT_EXECUCAO,
       NULL AS PROX_EXECUCAO,
       'M' AS PERIODICIDADE,
       'N' AS IND_TERMINO,
       NULL AS NRO_OCO_TERMINO,
       NULL AS DATA_TERMINO,
       1 AS NRO_EXECUCOES,
       NULL AS COD_PROGRAMA,
       NULL AS COD_RELATORIO,
       'S' AS IND_PDF,
       'N' AS IND_EXCEL,
       'C:\Temp' AS PASTA_RESULT,
       1 AS DIA_INI,
       0 AS MES_INI,
       31 AS DIA_FIM,
       0 AS MES_FIM,
       31 AS DIA_REF,
       0 AS MES_REF,
       1 AS COD_EVENTO,
       'DECLRACA' AS COD_RELAT_GR,
       NULL AS COD_ARQUIVO,
       NULL AS SELECAO,
       NULL AS MINUTOS,
       'D' AS IND_ORIGEM,
       NULL AS COD_MESTRE_EVENTO
FROM Numerado N, Base B
ORDER BY N.COD_UNIDADE;


--=============


INSERT INTO RHWF0405 (
  COD_PROCESSO, NOME_PROCESSO, TIPO_PROCESSO, PASTA_LOG, EMAIL_LOG,
  DATA_AGENDAMENTO, ULT_EXECUCAO, PROX_EXECUCAO, PERIODICIDADE,
  IND_TERMINO, NRO_OCO_TERMINO, DATA_TERMINO, NRO_EXECUCOES, COD_PROGRAMA,
  COD_RELATORIO, IND_PDF, IND_EXCEL, PASTA_RESULT, DIA_INI, MES_INI,
  DIA_FIM, MES_FIM, DIA_REF, MES_REF, COD_EVENTO, COD_RELAT_GR, COD_ARQUIVO,
  SELECAO, MINUTOS, IND_ORIGEM, COD_MESTRE_EVENTO
)
WITH Unidades AS (
  SELECT DISTINCT COD_UNIDADE
  FROM V_DADOS_LOJAS_AVT
  --WHERE COD_UNIDADE = '004'
),
Numerado AS (
  SELECT COD_UNIDADE, 
         ROW_NUMBER() OVER (ORDER BY COD_UNIDADE) AS seq
  FROM Unidades
),
Base AS (
  SELECT 1050 AS primeiro_cod_processo, -- Assumindo que 1049 é o último e começaremos de 1050
         TO_TIMESTAMP('11/03/2024 18:00:00', 'DD/MM/YYYY HH24:MI:SS') AS data_base
  FROM DUAL
)
SELECT (B.primeiro_cod_processo + N.seq - 1) AS COD_PROCESSO,
       'DECLRACA' || ' - ' ||  'AUTODECLARAÇÃO DE ETINIA/RAÇA' || ' - ' || N.COD_UNIDADE AS NOME_PROCESSO,
       'GR' AS TIPO_PROCESSO,
       'C:\Temp' AS PASTA_LOG,
       'log.disparosautomaticos@gmail.com' AS EMAIL_LOG,
       CAST(B.data_base AS DATE) + (N.seq - 1) * INTERVAL '2' MINUTE AS DATA_AGENDAMENTO, -- Ajuste aqui
       NULL AS ULT_EXECUCAO,
       NULL AS PROX_EXECUCAO,
       'M' AS PERIODICIDADE,
       'N' AS IND_TERMINO,
       NULL AS NRO_OCO_TERMINO,
       NULL AS DATA_TERMINO,
       1 AS NRO_EXECUCOES,
       NULL AS COD_PROGRAMA,
       NULL AS COD_RELATORIO,
       'S' AS IND_PDF,
       'N' AS IND_EXCEL,
       'C:\Temp' AS PASTA_RESULT,
       1 AS DIA_INI,
       0 AS MES_INI,
       31 AS DIA_FIM,
       0 AS MES_FIM,
       31 AS DIA_REF,
       0 AS MES_REF,
       1 AS COD_EVENTO,
       'DECLRACA' AS COD_RELAT_GR,
       NULL AS COD_ARQUIVO,
       NULL AS SELECAO,
       NULL AS MINUTOS,
       'D' AS IND_ORIGEM,
       NULL AS COD_MESTRE_EVENTO
FROM Numerado N, Base B
ORDER BY N.COD_UNIDADE;


--==================================--


--===INSERT PARA INSERIR PROCESSOS AUTOMÁTICOS
--DETALHES DOS PROCESSOS

WITH Unidades AS (
  SELECT DISTINCT ORG_LOJA, EMAIL
  FROM V_DADOS_LOJAS_AVT
),
Numerado AS (
  SELECT ORG_LOJA, EMAIL, 
         ROW_NUMBER() OVER (ORDER BY ORG_LOJA) AS seq
  FROM Unidades
),
Base AS (
  SELECT 1050 AS primeiro_cod_processo, -- Começando de 1050 conforme especificado
         'O' AS tipo_filtro, -- Assumindo um valor fixo para exemplo
         1 AS cod_seq -- Assumindo um valor fixo para exemplo
  FROM DUAL
)
SELECT (B.primeiro_cod_processo + N.seq - 1) AS COD_PROCESSO,
       B.cod_seq AS COD_SEQ,
       B.tipo_filtro AS TIPO_FILTRO,
       N.ORG_LOJA AS FILTRO_CTS,
       N.EMAIL AS DESTINATARIOS
FROM Numerado N, Base B


--========


INSERT INTO RHWF0406 (COD_PROCESSO, COD_SEQ, TIPO_FILTRO, FILTRO_CTS, DESTINATARIOS)
WITH Unidades AS (
  SELECT DISTINCT ORG_LOJA, EMAIL
  FROM V_DADOS_LOJAS_AVT
),
Numerado AS (
  SELECT ORG_LOJA, EMAIL, 
         ROW_NUMBER() OVER (ORDER BY ORG_LOJA) AS seq
  FROM Unidades
),
Base AS (
  SELECT 1050 AS primeiro_cod_processo, -- Começando de 1050 conforme especificado
         'O' AS tipo_filtro, -- Assumindo um valor fixo para exemplo
         1 AS cod_seq -- Assumindo um valor fixo para exemplo
  FROM DUAL
)
SELECT (B.primeiro_cod_processo + N.seq - 1) AS COD_PROCESSO,
       B.cod_seq AS COD_SEQ,
       B.tipo_filtro AS TIPO_FILTRO,
       N.ORG_LOJA AS FILTRO_CTS,
       N.EMAIL AS DESTINATARIOS
FROM Numerado N, Base B;
