--====FORMULÁRIO DE IRREGULARIDADE INTERVALO -15MIN NO DIA====--



SELECT DISTINCT RHAF1123.COD_CONTRATO,
                VDP.DES_PESSOA,
                RHFP0401.EDICAO_ORG AS COD_UNIDADE,
                RHFP0401.EDICAO_ORG || ' - ' || RHFP0400.NOME_ORGANOGRAMA AS DES_UNIDADE,

                CASE
                  WHEN VDP.COD_GRUPO = 1 THEN
                   10
                  WHEN VDP.COD_GRUPO = 2 THEN
                   50
                  WHEN VDP.COD_GRUPO = 3 THEN
                   30
                  WHEN VDP.COD_GRUPO = 4 THEN
                   40
                  WHEN VDP.COD_GRUPO = 7 THEN
                   70
                  ELSE
                   NULL
                END AS COD_REDE,
                DECODE(CASE
                         WHEN VDP.COD_GRUPO = 1 THEN
                          10
                         WHEN VDP.COD_GRUPO = 2 THEN
                          50
                         WHEN VDP.COD_GRUPO = 3 THEN
                          30
                         WHEN VDP.COD_GRUPO = 4 THEN
                          40
                         WHEN VDP.COD_GRUPO = 7 THEN
                          70
                         ELSE
                          0
                       END,
                       10,
                       'GRAZZIOTIN',
                       50,
                       'TOTTAL',
                       30,
                       'PORMENOS',
                       40,
                       'FRANCO GIORGI',
                       70,
                       'GZT STORE') AS DES_REDE,

                RHAF1129.COD_OCORRENCIA,
                RHAF1129.NOME_OCORRENCIA,
                TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MONTH') AS NOME_MES,
                TRIM(TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'Month')) || '/' ||
                TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'YYYY') AS MES_OCORRENCIA,
                TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'DD/MM/YYYY') AS DATA_COMPLETA,
                RHAF1123.ORIGEM,

                /*COLUNA INTERV -15MIN*/
                CASE
                  WHEN RHAF1145.CARGA_HORARIA BETWEEN 165 AND 180 AND
                       RHAF1123.COD_OCORRENCIA = 2049 THEN
                   TO_CHAR(TRUNC(RHAF1123.NUM_HORAS)) || ':' ||
                   TO_CHAR(MOD(RHAF1123.NUM_HORAS * 60, 60), 'FM00')
                  ELSE
                   'SEM OCORRÊNCIA PARA O PERÍODO'
                END AS INTERVALOS_INFERIOR_15MIN,

                TRIM(TO_CHAR(SYSDATE, 'MONTH')) || '/' ||
                TO_CHAR(SYSDATE, 'YYYY') AS REFERENCIA,
                TO_CHAR(SYSDATE, 'DD') || ' de ' ||
                TRIM(TO_CHAR(SYSDATE, 'Month')) || ' de ' ||
                TO_CHAR(SYSDATE, 'YYYY') AS REF_COMPLETA,
                GER.DES_PESSOA AS GESTOR

  FROM RHAF1123       RHAF1123,
       RHAF1129       RHAF1129,
       RHAF1138       RHAF1138,
       RHAF1108       RHAF1108,
       RHAF1119       RHAF1119,
       RHAF1145       RHAF1145,
       RHFP0310       RHFP0310,
       RHFP0401       RHFP0401,
       RHFP0400       RHFP0400,
       V_DADOS_PESSOA VDP,
       V_SUPERIOR_IMEDIATO_AVT GER
 WHERE RHAF1123.COD_OCORRENCIA = RHAF1129.COD_OCORRENCIA
   AND RHAF1123.COD_CONTRATO = RHAF1108.COD_CONTRATO
   AND RHAF1123.COD_CONTRATO = RHAF1119.COD_CONTRATO
   AND RHAF1119.COD_TURNO = RHAF1145.COD_TURNO
   AND RHAF1123.COD_CONTRATO = RHFP0310.COD_CONTRATO
   AND RHFP0310.COD_ORGANOGRAMA = RHFP0401.COD_ORGANOGRAMA
   AND RHFP0401.COD_ORGANOGRAMA = RHFP0400.COD_ORGANOGRAMA
   AND VDP.COD_CONTRATO = RHAF1123.COD_CONTRATO
   AND RHAF1129.COD_MOTIVO_OCO = RHAF1138.COD_MOTIVO_OCO
   AND GER.COD_UNIDADE = VDP.COD_UNIDADE
   AND RHAF1123.DATA_OCORRENCIA BETWEEN RHAF1108.DATA_INICIO AND
       RHAF1108.DATA_FIM
   AND RHAF1123.DATA_OCORRENCIA BETWEEN ADD_MONTHS(SYSDATE, -6) AND SYSDATE
   AND RHAF1123.DATA_OCORRENCIA BETWEEN :DATA_INI_OCORR AND :DATA_FIM_OCORR
   AND :DATA_REFERENCIA BETWEEN RHFP0310.DATA_INICIO AND RHFP0310.DATA_FIM
   AND :DATA_REFERENCIA BETWEEN RHAF1119.DATA_INICIO AND RHAF1119.DATA_FIM
   AND /*COLUNA INTERV -15MIN*/
        RHAF1145.CARGA_HORARIA BETWEEN 165 AND 180 AND
        RHAF1123.COD_OCORRENCIA = 2049
   AND GER.TIPO = 'LOJA'
   AND GER.IND_RESP_UNI = 'S'
   AND (RHFP0401.EDICAO_ORG = :FILIAL OR :FILIAL = 0)
   AND (VDP.COD_GRUPO = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
 ORDER BY RHFP0401.EDICAO_ORG ASC, RHAF1123.COD_CONTRATO ASC

