CREATE OR REPLACE VIEW VH_CARGO_CONTRATO_AVT AS
SELECT RHFP0340.COD_CONTRATO,
       RHFP0340.DATA_INICIO AS DATA_INI_CLH,
       RHFP0340.DATA_FIM AS DATA_FIM_CLH,
       RHFP0340.COD_CLH AS COD_FUNCAO,
       RHFP0500.NOME_CLH AS DES_FUNCAO,
       RHFP0500.COD_CBO,
       RHFP0500.COD_CBO_2002,
       RHFP0500.SEQUENCIA_CBO_2002 AS SEQ_CBO_2002,
       RHFP0500.EDICAO_CLH AS EDI_CLH,
       RHFP0103.NOME_CBO AS DES_CBO,
       RHFP0137.NOME_CBO_2002 AS DES_CBO_2002,
       RHFP0340.COD_MOTIVO,
       RHFP0323.NOME_MOTIVO AS DES_MOTIVO,
       RHFP0323.COD_TIPO_MOTIVO,
       RHFP0115.NOME_TIPO_MOTIVO AS DES_TIPO_MOTIVO,
       RHFP0500.COD_GRUPO_OCUP,
       RHFP0609.NOME_GRUPO_OCUP AS DES_GRUPO_OCUP,
       ROUND((MONTHS_BETWEEN(DECODE(RHFP0340.DATA_FIM,
                                    TO_DATE('31/12/2999'),
                                    DECODE(RHFP0300.DATA_FIM,
                                           NULL,
                                           TRUNC(SYSDATE),
                                           RHFP0300.DATA_FIM),
                                    RHFP0340.DATA_FIM),
                             RHFP0340.DATA_INICIO) / 12),
             2) AS ANOS_CARGO_BASE10,
       TRUNC(MONTHS_BETWEEN(DECODE(RHFP0340.DATA_FIM,
                                   TO_DATE('31/12/2999'),
                                   DECODE(RHFP0300.DATA_FIM,
                                          NULL,
                                          TRUNC(SYSDATE),
                                          RHFP0300.DATA_FIM),
                                   RHFP0340.DATA_FIM),
                            RHFP0340.DATA_INICIO) / 12) AS ANOS_CARGO,
       ROUND(MONTHS_BETWEEN(DECODE(RHFP0340.DATA_FIM,
                                   TO_DATE('31/12/2999'),
                                   DECODE(RHFP0300.DATA_FIM,
                                          NULL,
                                          TRUNC(SYSDATE),
                                          RHFP0300.DATA_FIM),
                                   RHFP0340.DATA_FIM),
                            RHFP0340.DATA_INICIO)) AS MESES_CARGO
  FROM RHFP0300 RHFP0300,
       RHFP0340 RHFP0340,
       RHFP0323 RHFP0323,
       RHFP0115 RHFP0115,
       RHFP0500 RHFP0500,
       RHFP0103 RHFP0103,
       RHFP0137 RHFP0137,
       RHFP0609 RHFP0609
 WHERE RHFP0300.COD_CONTRATO = RHFP0340.COD_CONTRATO
   AND RHFP0340.COD_MOTIVO = RHFP0323.COD_MOTIVO(+)
   AND RHFP0500.COD_GRUPO_OCUP = RHFP0609.COD_GRUPO_OCUP(+)
   AND RHFP0323.COD_TIPO_MOTIVO = RHFP0115.COD_TIPO_MOTIVO(+)
   AND RHFP0340.COD_CLH = RHFP0500.COD_CLH(+)
   AND RHFP0500.COD_CBO = RHFP0103.COD_CBO(+)
   AND RHFP0500.COD_CBO_2002 = RHFP0137.COD_CBO_2002(+)
   AND RHFP0500.SEQUENCIA_CBO_2002 = RHFP0137.SEQUENCIA(+)
      /*AND (RHFP0340.COD_CONTRATO, RHFP0340.DATA_INICIO) IN
                     (SELECT X1.COD_CONTRATO, X1.DATA_INICIO
                        FROM (SELECT Y1.COD_CONTRATO,
                                     MAX(Y1.DATA_INICIO) AS DATA_INICIO
                                FROM RHFP0340 Y1
                               WHERE TRUNC(SYSDATE) NOT BETWEEN Y1.DATA_INICIO AND
                                     Y1.DATA_FIM
                                 AND Y1.DATA_INICIO < TRUNC(SYSDATE)
                               GROUP BY Y1.COD_CONTRATO) X1
                       WHERE X1.COD_CONTRATO = RHFP0340.COD_CONTRATO
                         AND X1.DATA_INICIO = RHFP0340.DATA_INICIO)*/
   --AND RHFP0340.COD_CONTRATO = 389622

