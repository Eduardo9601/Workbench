CREATE OR REPLACE PROCEDURE GRZ_TOTAL_ADVERT_PONTO(PI_OPCAO IN VARCHAR2) IS
BEGIN
  DECLARE
    /**** Parametros de entrada ****/
    pi_data_inicial DATE;
    pi_data_final   DATE;
  
    /**** Variaveis da Procedure ****/
    wi NUMBER;
    wf NUMBER;
  
    --EXEC GRZ_REL_KPI_ANO_SP('0#10#0#9999#01/03/2023#30/05/2023#')
  
    cursor c_tot_ponto IS
      SELECT A.EDICAO_ORG       EDICAO_ORG,
             A.NOME_ORGANOGRAMA NOME_ORGANOGRAMA,
             A.MES_OCORRENCIA   MES_OCORRENCIA,
             A.ORIGEM           ORIGEM,
             A.TOTAL_HORAS_HM   AS HORAS_EXTRAS_MAIS_2HRS,
             B.TOTAL_HORAS_HM   AS INTERVALOS_INFERIOR_1H,
             C.TOTAL_HORAS_HM   AS OCORRENCIAS_INFORMADAS,
             D.TOTAL_HORAS_HM   AS HORAS_EXTRAS_MAIS_10HRS,
             E.TOTAL_HORAS_HM   AS INTERVALOS_INFERIOR_15MIN,
             F.TOTAL_HORAS_HM   AS OCORR_INTRAJORNADA_INFE_11HRS
        FROM (SELECT RHFP0401.EDICAO_ORG,
                     RHFP0400.NOME_ORGANOGRAMA,
                     TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY') AS MES_OCORRENCIA,
                     RHAF1123.ORIGEM,
                     TO_CHAR(SUM(TRUNC(RHAF1123.NUM_HORAS)) +
                             TRUNC(SUM((RHAF1123.NUM_HORAS -
                                       TRUNC(RHAF1123.NUM_HORAS)) * 60) / 60),
                             'FM9900') || ':' ||
                     TO_CHAR(MOD(SUM((RHAF1123.NUM_HORAS -
                                     TRUNC(RHAF1123.NUM_HORAS)) * 60),
                                 60),
                             'FM00') AS TOTAL_HORAS_HM
                FROM RHAF1123 RHAF1123
                JOIN RHAF1129 RHAF1129 ON RHAF1123.COD_OCORRENCIA =
                                          RHAF1129.COD_OCORRENCIA
                LEFT JOIN RHAF1108 RHAF1108 ON RHAF1123.COD_CONTRATO =
                                               RHAF1108.COD_CONTRATO
                JOIN RHFP0310 RHFP0310 ON RHAF1123.COD_CONTRATO =
                                          RHFP0310.COD_CONTRATO
                JOIN RHFP0400 RHFP0400 ON RHFP0310.COD_ORGANOGRAMA =
                                          RHFP0400.COD_ORGANOGRAMA
                JOIN RHFP0401 RHFP0401 ON RHFP0400.COD_ORGANOGRAMA =
                                          RHFP0401.COD_ORGANOGRAMA
                LEFT JOIN RHAF1138 RHAF1138 ON RHAF1129.COD_MOTIVO_OCO =
                                               RHAF1138.COD_MOTIVO_OCO
               WHERE RHAF1123.DATA_OCORRENCIA BETWEEN pi_data_inicial AND
                     pi_data_final
                 AND RHAF1123.DATA_OCORRENCIA BETWEEN RHAF1108.DATA_INICIO AND
                     RHAF1108.DATA_FIM
                 AND RHFP0310.DATA_FIM = '31/12/2999'
                 AND RHFP0401.COD_NIVEL2 = 8
                 AND RHFP0401.EDICAO_NIVEL3 NOT IN ('013', '001')
                 AND ROUND(RHAF1123.NUM_HORAS, 2) > 2
                 AND RHAF1123.COD_OCORRENCIA IN
                     (203, 204, 207, 208, 209, 210, 211, 212, 213, 214, 2022, 2023, 2026, 2029, 2036, 2041, 2043)
               GROUP BY RHFP0401.EDICAO_ORG,
                        RHFP0400.NOME_ORGANOGRAMA,
                        TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY'),
                        RHAF1123.ORIGEM
               ORDER BY RHFP0401.EDICAO_ORG ASC) A
        LEFT JOIN (SELECT RHFP0401.EDICAO_ORG,
                          RHFP0400.NOME_ORGANOGRAMA,
                          TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY') AS MES_OCORRENCIA,
                          RHAF1123.ORIGEM,
                          TO_CHAR(SUM(TRUNC(RHAF1123.NUM_HORAS)) +
                                  TRUNC(SUM((RHAF1123.NUM_HORAS -
                                            TRUNC(RHAF1123.NUM_HORAS)) * 60) / 60),
                                  'FM9900') || ':' ||
                          TO_CHAR(MOD(SUM((RHAF1123.NUM_HORAS -
                                          TRUNC(RHAF1123.NUM_HORAS)) * 60),
                                      60),
                                  'FM00') AS TOTAL_HORAS_HM
                     FROM RHAF1123 RHAF1123
                     JOIN RHAF1129 RHAF1129 ON RHAF1123.COD_OCORRENCIA =
                                               RHAF1129.COD_OCORRENCIA
                     LEFT JOIN RHAF1108 RHAF1108 ON RHAF1123.COD_CONTRATO =
                                                    RHAF1108.COD_CONTRATO
                     JOIN RHAF1119 ON RHAF1123.COD_CONTRATO =
                                      RHAF1119.COD_CONTRATO
                     JOIN RHAF1145 ON RHAF1119.COD_TURNO =
                                      RHAF1145.COD_TURNO
                     JOIN RHFP0310 RHFP0310 ON RHAF1123.COD_CONTRATO =
                                               RHFP0310.COD_CONTRATO
                     JOIN RHFP0400 RHFP0400 ON RHFP0310.COD_ORGANOGRAMA =
                                               RHFP0400.COD_ORGANOGRAMA
                     JOIN RHFP0401 RHFP0401 ON RHFP0400.COD_ORGANOGRAMA =
                                               RHFP0401.COD_ORGANOGRAMA
                     LEFT JOIN RHAF1138 RHAF1138 ON RHAF1129.COD_MOTIVO_OCO =
                                                    RHAF1138.COD_MOTIVO_OCO
                    WHERE RHAF1123.DATA_OCORRENCIA BETWEEN pi_data_inicial AND
                          pi_data_final
                      AND RHAF1123.DATA_OCORRENCIA BETWEEN
                          RHAF1108.DATA_INICIO AND RHAF1108.DATA_FIM
                      AND RHFP0310.DATA_FIM = '31/12/2999'
                      AND RHAF1145.CARGA_HORARIA BETWEEN 195 AND 220
                      AND RHAF1123.COD_OCORRENCIA = 2048
                      AND RHFP0401.COD_NIVEL2 = 8
                      AND RHFP0401.EDICAO_NIVEL3 NOT IN ('013', '001')
                    GROUP BY RHFP0401.EDICAO_ORG,
                             RHFP0400.NOME_ORGANOGRAMA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY'),
                             RHAF1123.ORIGEM
                    ORDER BY RHFP0401.EDICAO_ORG ASC) B ON A.EDICAO_ORG =
                                                           B.EDICAO_ORG
                                                       AND A.NOME_ORGANOGRAMA =
                                                           B.NOME_ORGANOGRAMA
                                                       AND A.MES_OCORRENCIA =
                                                           B.MES_OCORRENCIA
                                                       AND A.ORIGEM =
                                                           B.ORIGEM
        LEFT JOIN (SELECT RHFP0401.EDICAO_ORG,
                          RHFP0400.NOME_ORGANOGRAMA,
                          TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY') AS MES_OCORRENCIA,
                          RHAF1123.ORIGEM,
                          TO_CHAR(SUM(TRUNC(RHAF1123.NUM_HORAS)) +
                                  TRUNC(SUM((RHAF1123.NUM_HORAS -
                                            TRUNC(RHAF1123.NUM_HORAS)) * 60) / 60),
                                  'FM9900') || ':' ||
                          TO_CHAR(MOD(SUM((RHAF1123.NUM_HORAS -
                                          TRUNC(RHAF1123.NUM_HORAS)) * 60),
                                      60),
                                  'FM00') AS TOTAL_HORAS_HM
                     FROM RHAF1123 RHAF1123
                     JOIN RHAF1129 RHAF1129 ON RHAF1123.COD_OCORRENCIA =
                                               RHAF1129.COD_OCORRENCIA
                     LEFT JOIN RHAF1108 RHAF1108 ON RHAF1123.COD_CONTRATO =
                                                    RHAF1108.COD_CONTRATO
                     JOIN RHFP0310 RHFP0310 ON RHAF1123.COD_CONTRATO =
                                               RHFP0310.COD_CONTRATO
                     JOIN RHFP0400 RHFP0400 ON RHFP0310.COD_ORGANOGRAMA =
                                               RHFP0400.COD_ORGANOGRAMA
                     JOIN RHFP0401 RHFP0401 ON RHFP0400.COD_ORGANOGRAMA =
                                               RHFP0401.COD_ORGANOGRAMA
                     LEFT JOIN RHAF1138 RHAF1138 ON RHAF1129.COD_MOTIVO_OCO =
                                                    RHAF1138.COD_MOTIVO_OCO
                    WHERE RHAF1123.DATA_OCORRENCIA BETWEEN pi_data_inicial AND
                          pi_data_final
                      AND RHAF1123.DATA_OCORRENCIA BETWEEN
                          RHAF1108.DATA_INICIO AND RHAF1108.DATA_FIM
                      AND RHFP0310.DATA_FIM = '31/12/2999'
                      AND RHAF1123.ORIGEM = 'I'
                      AND RHFP0401.COD_NIVEL2 = 8
                      AND RHFP0401.EDICAO_NIVEL3 NOT IN ('013', '001')
                    GROUP BY RHFP0401.EDICAO_ORG,
                             RHFP0400.NOME_ORGANOGRAMA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY'),
                             RHAF1123.ORIGEM
                    ORDER BY RHFP0401.EDICAO_ORG ASC) C ON A.EDICAO_ORG =
                                                           C.EDICAO_ORG
                                                       AND A.NOME_ORGANOGRAMA =
                                                           C.NOME_ORGANOGRAMA
                                                       AND A.MES_OCORRENCIA =
                                                           C.MES_OCORRENCIA
                                                       AND A.ORIGEM =
                                                           C.ORIGEM
        LEFT JOIN (SELECT RHFP0401.EDICAO_ORG,
                          RHFP0400.NOME_ORGANOGRAMA,
                          TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY') AS MES_OCORRENCIA,
                          RHAF1123.ORIGEM,
                          TO_CHAR(SUM(TRUNC(RHAF1123.NUM_HORAS)) +
                                  TRUNC(SUM((RHAF1123.NUM_HORAS -
                                            TRUNC(RHAF1123.NUM_HORAS)) * 60) / 60),
                                  'FM9900') || ':' ||
                          TO_CHAR(MOD(SUM((RHAF1123.NUM_HORAS -
                                          TRUNC(RHAF1123.NUM_HORAS)) * 60),
                                      60),
                                  'FM00') AS TOTAL_HORAS_HM
                     FROM RHAF1123 RHAF1123
                     JOIN RHAF1129 RHAF1129 ON RHAF1123.COD_OCORRENCIA =
                                               RHAF1129.COD_OCORRENCIA
                     LEFT JOIN RHAF1108 RHAF1108 ON RHAF1123.COD_CONTRATO =
                                                    RHAF1108.COD_CONTRATO
                     JOIN RHAF1119 ON RHAF1123.COD_CONTRATO =
                                      RHAF1119.COD_CONTRATO
                     JOIN RHAF1145 ON RHAF1119.COD_TURNO =
                                      RHAF1145.COD_TURNO
                     JOIN RHFP0310 RHFP0310 ON RHAF1123.COD_CONTRATO =
                                               RHFP0310.COD_CONTRATO
                     JOIN RHFP0400 RHFP0400 ON RHFP0310.COD_ORGANOGRAMA =
                                               RHFP0400.COD_ORGANOGRAMA
                     JOIN RHFP0401 RHFP0401 ON RHFP0400.COD_ORGANOGRAMA =
                                               RHFP0401.COD_ORGANOGRAMA
                     LEFT JOIN RHAF1138 RHAF1138 ON RHAF1129.COD_MOTIVO_OCO =
                                                    RHAF1138.COD_MOTIVO_OCO
                    WHERE RHAF1123.DATA_OCORRENCIA BETWEEN pi_data_inicial AND
                          pi_data_final
                      AND RHAF1123.DATA_OCORRENCIA BETWEEN
                          RHAF1108.DATA_INICIO AND RHAF1108.DATA_FIM
                      AND RHFP0310.DATA_FIM = '31/12/2999'
                      AND RHAF1123.COD_OCORRENCIA = 2
                      AND RHAF1123.NUM_HORAS > 10
                      AND RHFP0401.COD_NIVEL2 = 8
                      AND RHFP0401.EDICAO_NIVEL3 NOT IN ('013', '001')
                    GROUP BY RHFP0401.EDICAO_ORG,
                             RHFP0400.NOME_ORGANOGRAMA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY'),
                             RHAF1123.ORIGEM
                    ORDER BY RHFP0401.EDICAO_ORG ASC) D ON A.EDICAO_ORG =
                                                           D.EDICAO_ORG
                                                       AND A.NOME_ORGANOGRAMA =
                                                           D.NOME_ORGANOGRAMA
                                                       AND A.MES_OCORRENCIA =
                                                           D.MES_OCORRENCIA
                                                       AND A.ORIGEM =
                                                           D.ORIGEM
        LEFT JOIN (SELECT RHFP0401.EDICAO_ORG,
                          RHFP0400.NOME_ORGANOGRAMA,
                          TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY') AS MES_OCORRENCIA,
                          RHAF1123.ORIGEM,
                          TO_CHAR(SUM(TRUNC(RHAF1123.NUM_HORAS)) +
                                  TRUNC(SUM((RHAF1123.NUM_HORAS -
                                            TRUNC(RHAF1123.NUM_HORAS)) * 60) / 60),
                                  'FM9900') || ':' ||
                          TO_CHAR(MOD(SUM((RHAF1123.NUM_HORAS -
                                          TRUNC(RHAF1123.NUM_HORAS)) * 60),
                                      60),
                                  'FM00') AS TOTAL_HORAS_HM
                     FROM RHAF1123 RHAF1123
                     JOIN RHAF1129 RHAF1129 ON RHAF1123.COD_OCORRENCIA =
                                               RHAF1129.COD_OCORRENCIA
                     LEFT JOIN RHAF1108 RHAF1108 ON RHAF1123.COD_CONTRATO =
                                                    RHAF1108.COD_CONTRATO
                     JOIN RHAF1119 ON RHAF1123.COD_CONTRATO =
                                      RHAF1119.COD_CONTRATO
                     JOIN RHAF1145 ON RHAF1119.COD_TURNO =
                                      RHAF1145.COD_TURNO
                     JOIN RHFP0310 RHFP0310 ON RHAF1123.COD_CONTRATO =
                                               RHFP0310.COD_CONTRATO
                     JOIN RHFP0400 RHFP0400 ON RHFP0310.COD_ORGANOGRAMA =
                                               RHFP0400.COD_ORGANOGRAMA
                     JOIN RHFP0401 RHFP0401 ON RHFP0400.COD_ORGANOGRAMA =
                                               RHFP0401.COD_ORGANOGRAMA
                     LEFT JOIN RHAF1138 RHAF1138 ON RHAF1129.COD_MOTIVO_OCO =
                                                    RHAF1138.COD_MOTIVO_OCO
                    WHERE RHAF1123.DATA_OCORRENCIA BETWEEN pi_data_inicial AND
                          pi_data_final
                      AND RHAF1123.DATA_OCORRENCIA BETWEEN
                          RHAF1108.DATA_INICIO AND RHAF1108.DATA_FIM
                      AND RHFP0310.DATA_FIM = '31/12/2999'
                      AND RHAF1145.CARGA_HORARIA BETWEEN 165 AND 180
                      AND RHAF1123.COD_OCORRENCIA = 2049
                      AND RHFP0401.COD_NIVEL2 = 8
                      AND RHFP0401.EDICAO_NIVEL3 NOT IN ('013', '001')
                    GROUP BY RHFP0401.EDICAO_ORG,
                             RHFP0400.NOME_ORGANOGRAMA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY'),
                             RHAF1123.ORIGEM
                    ORDER BY RHFP0401.EDICAO_ORG ASC) E ON A.EDICAO_ORG =
                                                           E.EDICAO_ORG
                                                       AND A.NOME_ORGANOGRAMA =
                                                           E.NOME_ORGANOGRAMA
                                                       AND A.MES_OCORRENCIA =
                                                           E.MES_OCORRENCIA
                                                       AND A.ORIGEM =
                                                           E.ORIGEM
        LEFT JOIN (SELECT RHFP0401.EDICAO_ORG,
                          RHFP0400.NOME_ORGANOGRAMA,
                          TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY') AS MES_OCORRENCIA,
                          RHAF1123.ORIGEM,
                          TO_CHAR(SUM(TRUNC(RHAF1123.NUM_HORAS)) +
                                  TRUNC(SUM((RHAF1123.NUM_HORAS -
                                            TRUNC(RHAF1123.NUM_HORAS)) * 60) / 60),
                                  'FM9900') || ':' ||
                          TO_CHAR(MOD(SUM((RHAF1123.NUM_HORAS -
                                          TRUNC(RHAF1123.NUM_HORAS)) * 60),
                                      60),
                                  'FM00') AS TOTAL_HORAS_HM
                     FROM RHAF1123 RHAF1123
                     JOIN RHAF1129 RHAF1129 ON RHAF1123.COD_OCORRENCIA =
                                               RHAF1129.COD_OCORRENCIA
                     LEFT JOIN RHAF1108 RHAF1108 ON RHAF1123.COD_CONTRATO =
                                                    RHAF1108.COD_CONTRATO
                     JOIN RHAF1119 ON RHAF1123.COD_CONTRATO =
                                      RHAF1119.COD_CONTRATO
                     JOIN RHAF1145 ON RHAF1119.COD_TURNO =
                                      RHAF1145.COD_TURNO
                     JOIN RHFP0310 RHFP0310 ON RHAF1123.COD_CONTRATO =
                                               RHFP0310.COD_CONTRATO
                     JOIN RHFP0400 RHFP0400 ON RHFP0310.COD_ORGANOGRAMA =
                                               RHFP0400.COD_ORGANOGRAMA
                     JOIN RHFP0401 RHFP0401 ON RHFP0400.COD_ORGANOGRAMA =
                                               RHFP0401.COD_ORGANOGRAMA
                     LEFT JOIN RHAF1138 RHAF1138 ON RHAF1129.COD_MOTIVO_OCO =
                                                    RHAF1138.COD_MOTIVO_OCO
                    WHERE RHAF1123.DATA_OCORRENCIA BETWEEN pi_data_inicial AND
                          pi_data_final
                      AND RHAF1123.DATA_OCORRENCIA BETWEEN
                          RHAF1108.DATA_INICIO AND RHAF1108.DATA_FIM
                      AND RHFP0310.DATA_FIM = '31/12/2999'
                      AND RHAF1123.COD_OCORRENCIA = 901
                      AND RHFP0401.COD_NIVEL2 = 8
                      AND RHFP0401.EDICAO_NIVEL3 NOT IN ('013', '001')
                    GROUP BY RHFP0401.EDICAO_ORG,
                             RHFP0400.NOME_ORGANOGRAMA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MM/YYYY'),
                             RHAF1123.ORIGEM
                    ORDER BY RHFP0401.EDICAO_ORG ASC) F ON A.EDICAO_ORG =
                                                           F.EDICAO_ORG
                                                       AND A.NOME_ORGANOGRAMA =
                                                           F.NOME_ORGANOGRAMA
                                                       AND A.MES_OCORRENCIA =
                                                           F.MES_OCORRENCIA
                                                       AND A.ORIGEM =
                                                           F.ORIGEM
       ORDER BY A.EDICAO_ORG ASC;
  
    r_tot_ponto c_tot_ponto%ROWTYPE;
  
    /**** Inicio da procedure principal ****/
  BEGIN
    wi              := INSTR(pi_opcao, '#', 1, 1);
    pi_data_inicial := TO_DATE(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)),
                               'DD/MM/YYYY');
    wi              := wf;
    wf              := INSTR(pi_opcao, '#', 1, 2);
    pi_data_final   := TO_DATE(SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1)),
                               'DD/MM/YYYY');
    wi              := wf;
  
    DELETE FROM TOTAL_PONTO;
  
    OPEN c_tot_ponto;
    FETCH c_tot_ponto
      INTO r_tot_ponto;
    WHILE c_tot_ponto%FOUND LOOP
    
      BEGIN
        INSERT INTO TOTAL_PONTO
          (EDICAO_ORG,
           NOME_ORGANOGRAMA,
           ORIGEM,
           MES_OCORRENCIA,
           HORAS_EXTRAS_MAIS_2HRS,
           INTERVALOS_INFERIOR_1H,
           OCORRENCIAS_INFORMADAS,
           HORAS_EXTRAS_MAIS_10HRS,
           INTERVALOS_INFERIOR_15MIN,
           OCORR_INTRAJORNADA_INFE_11HRS)
        VALUES
          (r_tot_ponto.EDICAO_ORG,
           r_tot_ponto.NOME_ORGANOGRAMA,
           r_tot_ponto.ORIGEM,
           r_tot_ponto.MES_OCORRENCIA,
           r_tot_ponto.HORAS_EXTRAS_MAIS_2HRS,
           r_tot_ponto.INTERVALOS_INFERIOR_1H,
           r_tot_ponto.OCORRENCIAS_INFORMADAS,
           r_tot_ponto.HORAS_EXTRAS_MAIS_10HRS,
           r_tot_ponto.INTERVALOS_INFERIOR_15MIN,
           r_tot_ponto.OCORR_INTRAJORNADA_INFE_11HRS);
      
      END;
    
      FETCH c_tot_ponto
        INTO r_tot_ponto;
    END LOOP;
    CLOSE c_tot_ponto;
  
    COMMIT;
  
  END;
END GRZ_TOTAL_ADVERT_PONTO;