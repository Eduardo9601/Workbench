--ORIGINAL

SELECT COD_PROCESSO,
       NOME_PROCESSO,
       DECODE(TIPO_PROCESSO,
              'GR',
              'Gerador de Relatórios',
              'RE',
              'Relatório do Sistema',
              'SE',
              'Seleção',
              'AS',
              'Arquivo do Sistema',
              'Processo Não Identificado') AS TIPO_PROCESSO,
       DATA_AGENDAMENTO,
       ULT_EXECUCAO,
       PROX_EXECUCAO,
       DECODE(PERIODICIDADE,
              'M',
              'Mensal',
              'D',
              'Diário',
              'S',
              'Semanal',
              'N',
              'Sem Repetição') AS PERIODICIDADE,
       (CASE
         WHEN PROX_EXECUCAO > SYSDATE AND
              TO_CHAR(ULT_EXECUCAO, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY') THEN
          'Enviado'
         ELSE
          'Não Enviado'
       END) IND_ENVIADO
  FROM RHWF0405
 WHERE COD_RELAT_GR IN ('RE0350D', 'RE0050')
 ORDER BY COD_PROCESSO ASC