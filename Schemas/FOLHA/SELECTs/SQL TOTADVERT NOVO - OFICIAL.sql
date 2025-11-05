SELECT COALESCE(A.COD_CONTRATO,
                B.COD_CONTRATO,
                C.COD_CONTRATO,
                D.COD_CONTRATO,
                E.COD_CONTRATO) AS COD_CONTRATO,
       COALESCE(A.DES_PESSOA,
                B.DES_PESSOA,
                C.DES_PESSOA,
                D.DES_PESSOA,
                E.DES_PESSOA) AS DES_PESSOA,
       COALESCE(A.COD_UNIDADE,
                B.COD_UNIDADE,
                C.COD_UNIDADE,
                D.COD_UNIDADE,
                E.COD_UNIDADE) AS COD_UNIDADE,
       COALESCE(A.DES_UNIDADE,
                B.DES_UNIDADE,
                C.DES_UNIDADE,
                D.DES_UNIDADE,
                E.DES_UNIDADE) AS DES_UNIDADE,
       COALESCE(A.MES_OCORRENCIA,
                B.MES_OCORRENCIA,
                C.MES_OCORRENCIA,
                D.MES_OCORRENCIA,
                E.MES_OCORRENCIA) AS MES_OCORRENCIA,
       COALESCE(A.ORIGEM, B.ORIGEM, C.ORIGEM, D.ORIGEM, E.ORIGEM) AS ORIGEM,
       COALESCE(A.NUM_HORAS_HM, 'SEM OCORRÊNCIAS') AS HORAS_EXTRAS_MAIS_2HRS,
       COALESCE(A.DATA_COMPLETA, 'SEM REGISTRO PARA O PERÍODO') AS DATA_OCORR_MAIS_2H,
       COALESCE(B.NUM_HORAS_HM, 'SEM OCORRÊNCIAS') AS INTERVALOS_INFERIOR_1H,
       COALESCE(B.DATA_COMPLETA, 'SEM REGISTRO PARA O PERÍODO') AS DATA_OCORR_INT_INFE_1H,
       COALESCE(C.NUM_HORAS_HM, 'SEM OCORRÊNCIAS') AS HORAS_EXTRAS_MAIS_10HRS,
       COALESCE(C.DATA_COMPLETA, 'SEM REGISTRO PARA O PERÍODO') AS DATA_OCORR_MAIS_10H,
       COALESCE(D.NUM_HORAS_HM, 'SEM OCORRÊNCIAS') AS INTERVALOS_INFERIOR_15MIN,
       COALESCE(D.DATA_COMPLETA, 'SEM REGISTRO PARA O PERÍODO') AS DATA_OCORR_INT_INFE_15MIN,
       COALESCE(E.NUM_HORAS_HM, 'SEM OCORRÊNCIAS') AS OCORR_INTRAJORNADA_INFE_11HRS,
       COALESCE(E.DATA_COMPLETA, 'SEM REGISTRO PARA O PERÍODO') AS DATA_OCORR_INTRAJOR_INFE_11H,
       COALESCE(A.REFERENCIA,
                B.REFERENCIA,
                C.REFERENCIA,
                D.REFERENCIA,
                E.REFERENCIA) AS REFERENCIA,
       COALESCE(A.REF_COMPLETA,
                B.REF_COMPLETA,
                C.REF_COMPLETA,
                D.REF_COMPLETA,
                E.REF_COMPLETA) AS REF_COMPLETA,
       COALESCE(A.GERENTE,
                B.GERENTE,
                C.GERENTE,
                D.GERENTE,
                E.GERENTE) AS GERENTE
  FROM (SELECT DISTINCT RHAF1123.COD_CONTRATO,
                        VDP.DES_PESSOA,
                        ORG.COD_UNIDADE,
                        ORG.DES_UNIDADE,
                        VDP.COD_GRUPO,
                        VDP.DES_GRUPO,
                        RHAF1129.COD_OCORRENCIA,
                        RHAF1129.NOME_OCORRENCIA,
                        TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MONTH') AS NOME_MES,
                        TRIM(TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'Month')) || '/' ||
                        TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'YYYY') AS MES_OCORRENCIA,
                        TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'DD/MM/YYYY') AS DATA_COMPLETA,
                        RHAF1123.ORIGEM,
                        TO_CHAR(TRUNC(RHAF1123.NUM_HORAS)) || ':' ||
                        TO_CHAR(MOD(RHAF1123.NUM_HORAS * 60, 60), 'FM00') AS NUM_HORAS_HM,
                        TRIM(TO_CHAR(SYSDATE, 'MONTH')) || '/' ||
                        TO_CHAR(SYSDATE, 'YYYY') AS REFERENCIA,
                        TO_CHAR(SYSDATE, 'DD') || ' de ' ||
                        TRIM(TO_CHAR(SYSDATE, 'Month')) || ' de ' ||
                        TO_CHAR(SYSDATE, 'YYYY') AS REF_COMPLETA,
                        GER.NOME_PESSOA AS GERENTE
          FROM RHAF1123                 RHAF1123,
               RHAF1129                 RHAF1129,
               RHAF1138                 RHAF1138,
               RHAF1108                 RHAF1108,
               RHAF1119                 RHAF1119,
               RHAF1145                 RHAF1145,
               RHFP0310                 RHFP0310,
               V_DADOS_ORGANOGRAMAS_AVT ORG,
               V_DADOS_PESSOA           VDP,
               V_GERENTES_LOJAS_AVT     GER
         WHERE RHAF1123.COD_OCORRENCIA = RHAF1129.COD_OCORRENCIA
           AND RHAF1123.COD_CONTRATO = RHAF1108.COD_CONTRATO(+)
           AND RHAF1123.COD_CONTRATO = RHAF1119.COD_CONTRATO
           AND RHAF1119.COD_TURNO = RHAF1145.COD_TURNO
           AND RHAF1123.COD_CONTRATO = RHFP0310.COD_CONTRATO
           AND RHFP0310.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
           AND VDP.COD_CONTRATO = RHAF1123.COD_CONTRATO
           AND GER.COD_UNIDADE = VDP.COD_UNIDADE
           AND RHAF1123.DATA_OCORRENCIA BETWEEN :DATA_INICIO_OCO AND
               :DATA_FIM_OCO
           AND RHAF1123.DATA_OCORRENCIA BETWEEN RHAF1108.DATA_INICIO AND
               RHAF1108.DATA_FIM
           AND RHAF1129.COD_MOTIVO_OCO = RHAF1138.COD_MOTIVO_OCO(+)
           AND GER.COD_CONTRATO NOT IN 387620
           AND RHFP0310.DATA_FIM = '31/12/2999'
           AND ORG.COD_EMP = 8
           AND (ORG.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
           AND (VDP.COD_GRUPO = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
           AND ORG.COD_REDE_LOCAL NOT IN ('013', '001')
           AND ROUND(RHAF1123.NUM_HORAS, 2) > 2
           AND RHAF1123.COD_OCORRENCIA IN
               (203, 204, 207, 208, 209, 210, 211, 212, 213, 214, 2022, 2023, 2026, 2029, 2036, 2041, 2043)
         ORDER BY ORG.COD_UNIDADE, RHAF1123.COD_CONTRATO ASC) A
  LEFT JOIN (SELECT DISTINCT RHAF1123.COD_CONTRATO,
                             VDP.DES_PESSOA,
                             ORG.COD_UNIDADE,
                             ORG.DES_UNIDADE,
                             VDP.COD_GRUPO,
                             VDP.DES_GRUPO,
                             RHAF1129.COD_OCORRENCIA,
                             RHAF1129.NOME_OCORRENCIA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MONTH') AS NOME_MES,
                             TRIM(TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'Month')) || '/' ||
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'YYYY') AS MES_OCORRENCIA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'DD/MM/YYYY') AS DATA_COMPLETA,
                             RHAF1123.ORIGEM,
                             TO_CHAR(TRUNC(RHAF1123.NUM_HORAS)) || ':' ||
                             TO_CHAR(MOD(RHAF1123.NUM_HORAS * 60, 60),
                                     'FM00') AS NUM_HORAS_HM,
                             TRIM(TO_CHAR(SYSDATE, 'MONTH')) || '/' ||
                             TO_CHAR(SYSDATE, 'YYYY') AS REFERENCIA,
                             TO_CHAR(SYSDATE, 'DD') || ' de ' ||
                             TRIM(TO_CHAR(SYSDATE, 'Month')) || ' de ' ||
                             TO_CHAR(SYSDATE, 'YYYY') AS REF_COMPLETA,
                             GER.NOME_PESSOA AS GERENTE
               FROM RHAF1123                 RHAF1123,
                    RHAF1129                 RHAF1129,
                    RHAF1138                 RHAF1138,
                    RHAF1108                 RHAF1108,
                    RHAF1119                 RHAF1119,
                    RHAF1145                 RHAF1145,
                    RHFP0310                 RHFP0310,
                    V_DADOS_ORGANOGRAMAS_AVT ORG,
                    V_DADOS_PESSOA           VDP,
                    V_GERENTES_LOJAS_AVT     GER
              WHERE RHAF1123.COD_OCORRENCIA = RHAF1129.COD_OCORRENCIA
                AND RHAF1123.COD_CONTRATO = RHAF1108.COD_CONTRATO(+)
                AND RHAF1123.COD_CONTRATO = RHAF1119.COD_CONTRATO
                AND RHAF1119.COD_TURNO = RHAF1145.COD_TURNO
                AND RHAF1123.COD_CONTRATO = RHFP0310.COD_CONTRATO
                AND RHAF1123.COD_CONTRATO = RHFP0310.COD_CONTRATO
                AND RHFP0310.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
                AND VDP.COD_CONTRATO = RHAF1123.COD_CONTRATO
                AND GER.COD_UNIDADE = VDP.COD_UNIDADE
                AND RHAF1123.DATA_OCORRENCIA BETWEEN :DATA_INICIO_OCO AND
                    :DATA_FIM_OCO
                AND RHAF1123.DATA_OCORRENCIA BETWEEN RHAF1108.DATA_INICIO AND
                    RHAF1108.DATA_FIM
                AND RHAF1129.COD_MOTIVO_OCO = RHAF1138.COD_MOTIVO_OCO(+)
                AND GER.COD_CONTRATO NOT IN 387620
                AND RHFP0310.DATA_FIM = '31/12/2999'
                AND ORG.COD_EMP = 8
                AND (ORG.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
                AND (VDP.COD_GRUPO = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
                AND ORG.COD_REDE_LOCAL NOT IN ('013', '001')
                AND RHAF1145.CARGA_HORARIA BETWEEN 195 AND 220
                AND RHAF1123.COD_OCORRENCIA = 2048
              ORDER BY ORG.COD_UNIDADE, RHAF1123.COD_CONTRATO ASC) B ON A.COD_CONTRATO =
                                                                        B.COD_CONTRATO
                                                                    AND A.COD_UNIDADE =
                                                                        B.COD_UNIDADE
                                                                    AND A.DES_UNIDADE =
                                                                        B.DES_UNIDADE
                                                                    AND A.MES_OCORRENCIA =
                                                                        B.MES_OCORRENCIA
                                                                    AND A.ORIGEM =
                                                                        B.ORIGEM
  LEFT JOIN (SELECT DISTINCT RHAF1123.COD_CONTRATO,
                             VDP.DES_PESSOA,
                             ORG.COD_UNIDADE,
                             ORG.DES_UNIDADE,
                             VDP.COD_GRUPO,
                             VDP.DES_GRUPO,
                             RHAF1129.COD_OCORRENCIA,
                             RHAF1129.NOME_OCORRENCIA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MONTH') AS NOME_MES,
                             TRIM(TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'Month')) || '/' ||
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'YYYY') AS MES_OCORRENCIA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'DD/MM/YYYY') AS DATA_COMPLETA,
                             RHAF1123.ORIGEM,
                             TO_CHAR(TRUNC(RHAF1123.NUM_HORAS)) || ':' ||
                             TO_CHAR(MOD(RHAF1123.NUM_HORAS * 60, 60),
                                     'FM00') AS NUM_HORAS_HM,
                             TRIM(TO_CHAR(SYSDATE, 'MONTH')) || '/' ||
                             TO_CHAR(SYSDATE, 'YYYY') AS REFERENCIA,
                             TO_CHAR(SYSDATE, 'DD') || ' de ' ||
                             TRIM(TO_CHAR(SYSDATE, 'Month')) || ' de ' ||
                             TO_CHAR(SYSDATE, 'YYYY') AS REF_COMPLETA,
                             GER.NOME_PESSOA AS GERENTE
               FROM RHAF1123                 RHAF1123,
                    RHAF1129                 RHAF1129,
                    RHAF1138                 RHAF1138,
                    RHAF1108                 RHAF1108,
                    RHAF1119                 RHAF1119,
                    RHAF1145                 RHAF1145,
                    RHFP0310                 RHFP0310,
                    V_DADOS_ORGANOGRAMAS_AVT ORG,
                    V_DADOS_PESSOA           VDP,
                    V_GERENTES_LOJAS_AVT     GER
              WHERE RHAF1123.COD_OCORRENCIA = RHAF1129.COD_OCORRENCIA
                AND RHAF1123.COD_CONTRATO = RHAF1108.COD_CONTRATO(+)
                AND RHAF1123.COD_CONTRATO = RHAF1119.COD_CONTRATO
                AND RHAF1119.COD_TURNO = RHAF1145.COD_TURNO
                AND RHAF1123.COD_CONTRATO = RHFP0310.COD_CONTRATO
                AND RHAF1123.COD_CONTRATO = RHFP0310.COD_CONTRATO
                AND RHFP0310.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
                AND VDP.COD_CONTRATO = RHAF1123.COD_CONTRATO
                AND GER.COD_UNIDADE = VDP.COD_UNIDADE
                AND RHAF1123.DATA_OCORRENCIA BETWEEN :DATA_INICIO_OCO AND
                    :DATA_FIM_OCO
                AND RHAF1123.DATA_OCORRENCIA BETWEEN RHAF1108.DATA_INICIO AND
                    RHAF1108.DATA_FIM
                AND RHAF1129.COD_MOTIVO_OCO = RHAF1138.COD_MOTIVO_OCO(+)
                AND GER.COD_CONTRATO NOT IN 387620
                AND RHFP0310.DATA_FIM = '31/12/2999'
                AND ORG.COD_EMP = 8
                AND (ORG.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
                AND (VDP.COD_GRUPO = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
                AND ORG.COD_REDE_LOCAL NOT IN ('013', '001')
                AND RHAF1123.COD_OCORRENCIA = 2
                AND RHAF1123.NUM_HORAS > 10
              ORDER BY ORG.COD_UNIDADE, RHAF1123.COD_CONTRATO ASC) C ON A.COD_CONTRATO =
                                                                        C.COD_CONTRATO
                                                                    AND A.COD_UNIDADE =
                                                                        C.COD_UNIDADE
                                                                    AND A.DES_UNIDADE =
                                                                        C.DES_UNIDADE
                                                                    AND A.MES_OCORRENCIA =
                                                                        C.MES_OCORRENCIA
                                                                    AND A.ORIGEM =
                                                                        C.ORIGEM
  LEFT JOIN (SELECT DISTINCT RHAF1123.COD_CONTRATO,
                             VDP.DES_PESSOA,
                             ORG.COD_UNIDADE,
                             ORG.DES_UNIDADE,
                             VDP.COD_GRUPO,
                             VDP.DES_GRUPO,
                             RHAF1129.COD_OCORRENCIA,
                             RHAF1129.NOME_OCORRENCIA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MONTH') AS NOME_MES,
                             TRIM(TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'Month')) || '/' ||
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'YYYY') AS MES_OCORRENCIA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'DD/MM/YYYY') AS DATA_COMPLETA,
                             RHAF1123.ORIGEM,
                             TO_CHAR(TRUNC(RHAF1123.NUM_HORAS)) || ':' ||
                             TO_CHAR(MOD(RHAF1123.NUM_HORAS * 60, 60),
                                     'FM00') AS NUM_HORAS_HM,
                             TRIM(TO_CHAR(SYSDATE, 'MONTH')) || '/' ||
                             TO_CHAR(SYSDATE, 'YYYY') AS REFERENCIA,
                             TO_CHAR(SYSDATE, 'DD') || ' de ' ||
                             TRIM(TO_CHAR(SYSDATE, 'Month')) || ' de ' ||
                             TO_CHAR(SYSDATE, 'YYYY') AS REF_COMPLETA,
                             GER.NOME_PESSOA AS GERENTE
               FROM RHAF1123                 RHAF1123,
                    RHAF1129                 RHAF1129,
                    RHAF1138                 RHAF1138,
                    RHAF1108                 RHAF1108,
                    RHAF1119                 RHAF1119,
                    RHAF1145                 RHAF1145,
                    RHFP0310                 RHFP0310,
                    V_DADOS_ORGANOGRAMAS_AVT ORG,
                    V_DADOS_PESSOA           VDP,
                    V_GERENTES_LOJAS_AVT     GER
              WHERE RHAF1123.COD_OCORRENCIA = RHAF1129.COD_OCORRENCIA
                AND RHAF1123.COD_CONTRATO = RHAF1108.COD_CONTRATO(+)
                AND RHAF1123.COD_CONTRATO = RHAF1119.COD_CONTRATO
                AND RHAF1119.COD_TURNO = RHAF1145.COD_TURNO
                AND RHAF1123.COD_CONTRATO = RHFP0310.COD_CONTRATO
                AND RHFP0310.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
                AND VDP.COD_CONTRATO = RHAF1123.COD_CONTRATO
                AND GER.COD_UNIDADE = VDP.COD_UNIDADE
                AND RHAF1123.DATA_OCORRENCIA BETWEEN :DATA_INICIO_OCO AND
                    :DATA_FIM_OCO
                AND RHAF1123.DATA_OCORRENCIA BETWEEN RHAF1108.DATA_INICIO AND
                    RHAF1108.DATA_FIM
                AND RHAF1129.COD_MOTIVO_OCO = RHAF1138.COD_MOTIVO_OCO(+)
                AND GER.COD_CONTRATO NOT IN 387620
                AND RHFP0310.DATA_FIM = '31/12/2999'
                AND ORG.COD_EMP = 8
                AND (ORG.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
                AND (VDP.COD_GRUPO = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
                AND ORG.COD_REDE_LOCAL NOT IN ('013', '001')
                AND RHAF1145.CARGA_HORARIA BETWEEN 165 AND 180
                AND RHAF1123.COD_OCORRENCIA = 2049
              ORDER BY ORG.COD_UNIDADE, RHAF1123.COD_CONTRATO ASC) D ON A.COD_CONTRATO =
                                                                        D.COD_CONTRATO
                                                                    AND A.COD_UNIDADE =
                                                                        D.COD_UNIDADE
                                                                    AND A.DES_UNIDADE =
                                                                        D.DES_UNIDADE
                                                                    AND A.MES_OCORRENCIA =
                                                                        D.MES_OCORRENCIA
                                                                    AND A.ORIGEM =
                                                                        D.ORIGEM
  LEFT JOIN (SELECT DISTINCT RHAF1123.COD_CONTRATO,
                             VDP.DES_PESSOA,
                             ORG.COD_UNIDADE,
                             ORG.DES_UNIDADE,
                             VDP.COD_GRUPO,
                             VDP.DES_GRUPO,
                             RHAF1129.COD_OCORRENCIA,
                             RHAF1129.NOME_OCORRENCIA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'MONTH') AS NOME_MES,
                             TRIM(TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'Month')) || '/' ||
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'YYYY') AS MES_OCORRENCIA,
                             TO_CHAR(RHAF1123.DATA_OCORRENCIA, 'DD/MM/YYYY') AS DATA_COMPLETA,
                             RHAF1123.ORIGEM,
                             TO_CHAR(TRUNC(RHAF1123.NUM_HORAS)) || ':' ||
                             TO_CHAR(MOD(RHAF1123.NUM_HORAS * 60, 60),
                                     'FM00') AS NUM_HORAS_HM,
                             TRIM(TO_CHAR(SYSDATE, 'MONTH')) || '/' ||
                             TO_CHAR(SYSDATE, 'YYYY') AS REFERENCIA,
                             TO_CHAR(SYSDATE, 'DD') || ' de ' ||
                             TRIM(TO_CHAR(SYSDATE, 'Month')) || ' de ' ||
                             TO_CHAR(SYSDATE, 'YYYY') AS REF_COMPLETA,
                             GER.NOME_PESSOA AS GERENTE
               FROM RHAF1123                 RHAF1123,
                    RHAF1129                 RHAF1129,
                    RHAF1138                 RHAF1138,
                    RHAF1108                 RHAF1108,
                    RHAF1119                 RHAF1119,
                    RHAF1145                 RHAF1145,
                    RHFP0310                 RHFP0310,
                    V_DADOS_ORGANOGRAMAS_AVT ORG,
                    V_DADOS_PESSOA           VDP,
                    V_GERENTES_LOJAS_AVT     GER
              WHERE RHAF1123.COD_OCORRENCIA = RHAF1129.COD_OCORRENCIA
                AND RHAF1123.COD_CONTRATO = RHAF1108.COD_CONTRATO(+)
                AND RHAF1123.COD_CONTRATO = RHAF1119.COD_CONTRATO
                AND RHAF1119.COD_TURNO = RHAF1145.COD_TURNO
                AND RHAF1123.COD_CONTRATO = RHFP0310.COD_CONTRATO
                AND RHFP0310.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
                AND VDP.COD_CONTRATO = RHAF1123.COD_CONTRATO
                AND VDP.COD_CONTRATO = RHAF1123.COD_CONTRATO
                AND GER.COD_UNIDADE = VDP.COD_UNIDADE
                AND RHAF1123.DATA_OCORRENCIA BETWEEN :DATA_INICIO_OCO AND
                    :DATA_FIM_OCO
                AND RHAF1123.DATA_OCORRENCIA BETWEEN RHAF1108.DATA_INICIO AND
                    RHAF1108.DATA_FIM
                AND RHAF1129.COD_MOTIVO_OCO = RHAF1138.COD_MOTIVO_OCO(+)
                AND GER.COD_CONTRATO NOT IN 387620
                AND RHFP0310.DATA_FIM = '31/12/2999'
                AND ORG.COD_EMP = 8
                AND (ORG.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
                AND (VDP.COD_GRUPO = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
                AND ORG.COD_REDE_LOCAL NOT IN ('013', '001')
                AND RHAF1123.COD_OCORRENCIA = 901
              ORDER BY ORG.COD_UNIDADE, RHAF1123.COD_CONTRATO ASC) E ON A.COD_CONTRATO =
                                                                        E.COD_CONTRATO
                                                                    AND A.COD_UNIDADE =
                                                                        E.COD_UNIDADE
                                                                    AND A.DES_UNIDADE =
                                                                        E.DES_UNIDADE
                                                                    AND A.MES_OCORRENCIA =
                                                                        E.MES_OCORRENCIA
                                                                    AND A.ORIGEM =
                                                                        E.ORIGEM
 ORDER BY A.COD_UNIDADE,
          TO_DATE(A.MES_OCORRENCIA, 'MM/YYYY'),
          A.COD_CONTRATO ASC
           