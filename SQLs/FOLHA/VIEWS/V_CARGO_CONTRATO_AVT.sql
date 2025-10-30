CREATE OR REPLACE VIEW V_CARGO_CONTRATO_AVT AS
SELECT CLH.COD_CONTRATO,
       CLH.DATA_INICIO,
       CLH.DATA_FIM,
       CLH.COD_CLH,
       NCLH.NOME_CLH,
       CLH.COD_CLH || ' - ' || NCLH.NOME_CLH AS DES_CLH,
       NCLH.COD_CBO,
       NCLH.COD_CBO_2002,
       NCLH.SEQUENCIA_CBO_2002 AS SEQ_CBO_2002,
       NCLH.EDICAO_CLH,
       NCBO.NOME_CBO,
       CBO.NOME_CBO_2002,
       CLH.COD_MOTIVO,
       MT.NOME_MOTIVO,
       MT.COD_TIPO_MOTIVO,
       NMT.NOME_TIPO_MOTIVO,
       NVL(SUP.COD_GRUPO_OCUP, NCLH.COD_GRUPO_OCUP) AS COD_GRUPO_OCUP,
       NVL(GO_SUP.NOME_GRUPO_OCUP, GRU.NOME_GRUPO_OCUP) AS NOME_GRUPO_OCUP,
       ROUND((MONTHS_BETWEEN(DECODE(CLH.DATA_FIM,
                                    TO_DATE('31/12/2999'),
                                    DECODE(CT.DATA_FIM,
                                           NULL,
                                           TRUNC(SYSDATE),
                                           CT.DATA_FIM),
                                    CLH.DATA_FIM),
                             CLH.DATA_INICIO) / 12),
             2) AS ANOS_CARGO_BASE10,
       TRUNC(MONTHS_BETWEEN(DECODE(CLH.DATA_FIM,
                                   TO_DATE('31/12/2999'),
                                   DECODE(CT.DATA_FIM,
                                          NULL,
                                          TRUNC(SYSDATE),
                                          CT.DATA_FIM),
                                   CLH.DATA_FIM),
                            CLH.DATA_INICIO) / 12) AS ANOS_CARGO,
       ROUND(MONTHS_BETWEEN(DECODE(CLH.DATA_FIM,
                                   TO_DATE('31/12/2999'),
                                   DECODE(CT.DATA_FIM,
                                          NULL,
                                          TRUNC(SYSDATE),
                                          CT.DATA_FIM),
                                   CLH.DATA_FIM),
                            CLH.DATA_INICIO)) AS MESES_CARGO,
       ANTE.COD_CLH AS COD_CLH_ANT,
       CASE
           WHEN ANTE.COD_CLH IS NOT NULL THEN
            ANTE.COD_CLH || ' - ' || ANTE.NOME_CLH
           ELSE
            NULL
       END AS DES_CLH_ANT,
       ANTE.DATA_INICIO AS DATA_INICIO_ANT,
       ANTE.DATA_FIM AS DATA_FIM_ANT,
       ANTE.COD_CBO AS COD_CBO_ANT,
       ANTE.COD_CBO_2002 AS COD_CBO_2002_ANT,
       ANTE.SEQUENCIA_CBO_2002 AS SEQ_CBO_2002_ANT,
       ANTE.EDI_CLH,
       ANTE.NOME_CBO AS NOME_CBO_ANT,
       ANTE.NOME_CBO_2002 AS NOME_CBO_2002_ANT,
       ANTE.COD_MOTIVO AS COD_MOTIVO_ANT,
       ANTE.NOME_MOTIVO AS NOME_MOTIVO_ANT,
       ANTE.COD_TIPO_MOTIVO AS COD_TIPO_MOTIVO_ANT,
       ANTE.NOME_TIPO_MOTIVO AS NOME_TIPO_MOTIVO_ANT,
       ANTE.COD_GRUPO_OCUP AS COD_GRUPO_OCUP_ANT,
       ANTE.NOME_GRUPO_OCUP AS NOME_GRUPO_OCUP_ANT,
       ANTE.ANOS_CARGO_BASE10 AS ANOS_CARGO_BASE10_ANT,
       ANTE.ANOS_CARGO AS ANOS_CARGO_ANT,
       ANTE.MESES_CARGO AS MESES_CARGO_ANT
  FROM RHFP0300 CT,
       RHFP0340 CLH,
       RHFP0323 MT,
       RHFP0115 NMT,
       RHFP0500 NCLH,
       RHFP0103 NCBO,
       RHFP0137 CBO,
       RHFP0514 FUN,
       RHFP0609 GRU,
       RHCS0196 CS2,
       RHFP0502 FP1,
       RHFP0500 SUP,
       RHCS0530 CS,
       RHFP0609 GO_SUP,
       (
        --==CARGO ANTERIOR==--
        SELECT RHFP0340.COD_CONTRATO,
                RHFP0340.DATA_INICIO,
                RHFP0340.DATA_FIM,
                RHFP0340.COD_CLH,
                RHFP0500.NOME_CLH,
                RHFP0500.COD_CBO,
                RHFP0500.COD_CBO_2002,
                RHFP0500.SEQUENCIA_CBO_2002,
                RHFP0500.EDICAO_CLH AS EDI_CLH,
                RHFP0103.NOME_CBO,
                RHFP0137.NOME_CBO_2002,
                RHFP0340.COD_MOTIVO,
                RHFP0323.NOME_MOTIVO,
                RHFP0323.COD_TIPO_MOTIVO,
                RHFP0115.NOME_TIPO_MOTIVO,
                RHFP0500.COD_GRUPO_OCUP,
                RHFP0609.NOME_GRUPO_OCUP,
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
           AND (RHFP0340.COD_CONTRATO, RHFP0340.DATA_INICIO) IN
               (SELECT X1.COD_CONTRATO, X1.DATA_INICIO
                  FROM (SELECT Y1.COD_CONTRATO,
                               MAX(Y1.DATA_INICIO) AS DATA_INICIO
                          FROM RHFP0340 Y1
                         WHERE TRUNC(SYSDATE) NOT BETWEEN Y1.DATA_INICIO AND
                               Y1.DATA_FIM
                           AND Y1.DATA_INICIO < TRUNC(SYSDATE)
                         GROUP BY Y1.COD_CONTRATO) X1
                 WHERE X1.COD_CONTRATO = RHFP0340.COD_CONTRATO
                   AND X1.DATA_INICIO = RHFP0340.DATA_INICIO)
        /*AND RHFP0340.COD_CONTRATO = 389622*/
        ) ANTE
 WHERE CLH.COD_MOTIVO = MT.COD_MOTIVO(+)
   AND NCLH.COD_CARREIRA = CS.COD_CARREIRA(+)
   AND CLH.COD_CONTRATO = CS2.COD_CONTRATO(+)
   AND NCLH.COD_GRUPO_OCUP = GRU.COD_GRUPO_OCUP(+)
   AND MT.COD_TIPO_MOTIVO = NMT.COD_TIPO_MOTIVO(+)
   AND CLH.COD_CLH = NCLH.COD_CLH(+)
   AND NCLH.COD_CBO = NCBO.COD_CBO(+)
   AND NCLH.COD_CBO_2002 = CBO.COD_CBO_2002(+)
   AND NCLH.SEQUENCIA_CBO_2002 = CBO.SEQUENCIA(+)
   AND CLH.COD_FUN_CARGO = FUN.COD_FUN_CARGO(+)
   AND CLH.COD_CONTRATO = CT.COD_CONTRATO
   AND CLH.COD_CONTRATO = ANTE.COD_CONTRATO(+)
   AND CLH.DATA_INICIO - 1 = ANTE.DATA_FIM(+)
   AND TRUNC(SYSDATE) BETWEEN CLH.DATA_INICIO AND CLH.DATA_FIM
   AND CLH.COD_CLH = FP1.COD_CLH(+)
   AND TRUNC(SYSDATE) BETWEEN FP1.DATA_INICIO(+) AND FP1.DATA_FIM(+)
   AND SUP.COD_CLH(+) = FP1.COD_CLH_SUB
   AND CS.COD_CARREIRA(+) = SUP.COD_CARREIRA
   AND GO_SUP.COD_GRUPO_OCUP(+) = SUP.COD_GRUPO_OCUP

