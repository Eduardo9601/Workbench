UPDATE RHFP1004 MOV SET MOV.VALOR_VD = (SELECT A.VALOR_VD
                                        FROM RHFP1005 A
                                        WHERE A.COD_EVENTO = 22
                                          AND A.DATA_REFERENCIA = TO_DATE('31/03/2022', 'DD/MM/YYYY')
                                          AND A.COD_CONTRATO = MOV.COD_CONTRATO
                                          AND A.COD_VD = 1090

                                       ),
									   OBSERVACAO = 'Aumento Salarial (Evento 22) - Mestre 15009'  
WHERE MOV.COD_EVENTO = 1
  AND MOV.DATA_MOV = TO_DATE('31/03/2022', 'DD/MM/YYYY')
  
  AND MOV.COD_VD = 905
  --AND MOV.COD_CONTRATO = 387692
  AND MOV.COD_CONTRATO IN (SELECT A.COD_CONTRATO
                           FROM RHFP1005 A, V_DADOS_PESSOA B
                           WHERE A.COD_EVENTO = 22
                             AND A.DATA_REFERENCIA = TO_DATE('31/03/2022', 'DD/MM/YYYY')
                             AND A.COD_CONTRATO = MOV.COD_CONTRATO
                             AND A.COD_VD = 1090
                             AND B.COD_EMP = 4
                             AND A.COD_CONTRATO = B.COD_CONTRATO
			     )


------------------------------------------------------------------------


INSERT INTO RHFP1004 (
SELECT 1 AS COD_EVENTO,
       CC.COD_CONTRATO,
       CC.DATA_REFERENCIA,
       905 AS COD_VD,
       CC.TIPO_INF_VD,
       99 AS PRESTACAO_VD,
       CC.QTDE_VD,
       CC.VALOR_VD,
       1 AS COD_ORIGEM_MOV,
       CC.COD_MESTRE_EVENTO,
       CC.DATA_REFERENCIA,
       'Aumento Salarial (Evento 22) - Mestre 15009' AS OBSERVACAO,
       NULL
FROM RHFP1005 CC
WHERE CC.COD_EVENTO = 22
  AND DATA_REFERENCIA = TO_DATE('31/03/2022', 'DD/MM/YYYY')
  AND CC.COD_VD = 1090
   -- AND CC.COD_CONTRATO = 387692
  AND CC.COD_CONTRATO NOT IN (SELECT COD_CONTRATO
                              FROM RHFP1004
                              WHERE COD_EVENTO = 1
                                AND COD_CONTRATO = CC.COD_CONTRATO
                                AND DATA_MOV = CC.DATA_REFERENCIA
                                AND COD_VD = 905 ))