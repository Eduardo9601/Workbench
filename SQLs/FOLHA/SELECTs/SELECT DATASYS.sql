SELECT S1.COD_CONTRATO,
                      R400.COD_ORGANOGRAMA AS COD_FILIAL,
                      PJ.NOME_PESSOA AS NOME_EMPRESA,
                      CONCAT(PJ.NOME_LOGRA, CONCAT( ' ', PJ.NUMERO)) AS ENDERECO,
                      PJ.NOME_BAIRRO,
                      PJ.CEP,
                      PJ.CGC,
                      PJ.NOME_MUNIC,
                      PJ.NOME_MUNIC || ' - ' || PJ.COD_UF AS NOME_MUNIC_RS,
                      S1.COD_NIVEL3 AS COD_NIVEL
                 FROM PESSOA_JURIDICA PJ,
                      RHFP0400 R400,
                      RHFP0400 ORGEMP,
                      PESSOA PESEMP,
                      (SELECT RHFP0300.COD_CONTRATO,
                              TO_DATE('25092023','dd/MM/yyyy') AS DATA_REFERENCIA,
                              RHFP0401.COD_NIVEL2,
                              RHFP0401.COD_NIVEL3
                         FROM " + OperadorDB.getRhfp0300(codOperador) + " RHFP0300,
                              RHFP0310 RHFP0310,
                              RHFP0401 RHFP0401
                        WHERE RHFP0300.COD_CONTRATO = RHFP0310.COD_CONTRATO
                          AND RHFP0310.COD_ORGANOGRAMA = RHFP0310.COD_ORGANOGRAMA
                          AND RHFP0310.COD_ORGANOGRAMA = RHFP0401.COD_ORGANOGRAMA
                          AND TO_DATE('25092023','dd/MM/yyyy') BETWEEN RHFP0310.DATA_INICIO AND RHFP0310.DATA_FIM
                          AND TO_DATE('25092023','dd/MM/yyyy') BETWEEN RHFP0401.DATA_INICIO AND RHFP0401.DATA_FIM) S1
                WHERE S1.COD_NIVEL3 <> 0
                  AND S1.COD_NIVEL3 = R400.COD_ORGANOGRAMA
                  AND R400.COD_PESSOA = PJ.COD_PESSOA
                  AND S1.COD_NIVEL2 = ORGEMP.COD_ORGANOGRAMA
                  AND ORGEMP.COD_PESSOA = PESEMP.COD_PESSOA
                UNION ALL
               SELECT S1.COD_CONTRATO,
                      R400.COD_ORGANOGRAMA AS COD_FILIAL,
                      PJ.NOME_PESSOA AS NOME_EMPRESA,
                      CONCAT(PJ.NOME_LOGRA, CONCAT( ' ', PJ.NUMERO)) AS ENDERECO,
                      PJ.NOME_BAIRRO,
                      PJ.CEP,
                      PJ.CGC,
                      PJ.NOME_MUNIC,
                      PJ.NOME_MUNIC || ' - ' || PJ.COD_UF AS NOME_MUNIC_RS,
                      S1.COD_NIVEL2 AS COD_NIVEL
                 FROM PESSOA_JURIDICA PJ,
                      RHFP0400 R400,
                      RHFP0400 RFIL,
                      (SELECT RHFP0300.COD_CONTRATO,
                              TO_DATE('25092023','dd/MM/yyyy') AS DATA_REFERENCIA,
                              RHFP0401.COD_NIVEL2,
                              RHFP0401.COD_NIVEL3
                         FROM " + OperadorDB.getRhfp0300(codOperador) + " RHFP0300,
                              RHFP0310 RHFP0310,
                              RHFP0401 RHFP0401
                        WHERE RHFP0300.COD_CONTRATO = RHFP0310.COD_CONTRATO
                          AND RHFP0310.COD_ORGANOGRAMA = RHFP0310.COD_ORGANOGRAMA
                          AND RHFP0310.COD_ORGANOGRAMA = RHFP0401.COD_ORGANOGRAMA
                          AND TO_DATE('25092023','dd/MM/yyyy') BETWEEN RHFP0310.DATA_INICIO AND RHFP0310.DATA_FIM
                          AND TO_DATE('25092023','dd/MM/yyyy') BETWEEN RHFP0401.DATA_INICIO AND RHFP0401.DATA_FIM