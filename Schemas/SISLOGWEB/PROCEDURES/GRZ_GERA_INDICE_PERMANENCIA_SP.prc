CREATE OR REPLACE PROCEDURE GRZ_GERA_INDICE_PERMANENCIA_SP (
  p_dta_ref IN DATE DEFAULT NULL
)
IS
  -- mês de referência = parâmetro (se vier) OU mês anterior ao SYSDATE (1º dia)
  v_dta_ref DATE := NVL(TRUNC(p_dta_ref, 'MM'), TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM'));
  v_dummy   NUMBER;
BEGIN
  ------------------------------------------------------------------------------
  -- Gate: exige fechamento em GRZ_FECHAMENTO_GERENCIA para o mês v_dta_ref
  ------------------------------------------------------------------------------
  BEGIN
    SELECT 1
      INTO v_dummy
      FROM GRZ_FECHAMENTO_GERENCIA
     WHERE DTA_MES >= v_dta_ref
       AND DTA_MES <  ADD_MONTHS(v_dta_ref, 1)
       AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(
        -20002,
        'FECHAMENTO AINDA NÃO CONCLUÍDO. ESPERADO REGISTRO NO LOG COM DTA_MES = '||
        TO_CHAR(v_dta_ref,'DD/MM/YYYY')||'.'
      );
  END;

  ------------------------------------------------------------------------------
  -- Remove carga anterior do mesmo mês (caso haja necessidade)
  ------------------------------------------------------------------------------
  DELETE FROM GRZ_INDICE_PERMANENCIA_TB T
   WHERE T.DTA_REFERENCIA >= v_dta_ref
     AND T.DTA_REFERENCIA <  ADD_MONTHS(v_dta_ref, 1);

  ------------------------------------------------------------------------------
  -- Carga (Inserção dos dados na tabela de PERMANENCIA)
  ------------------------------------------------------------------------------
  INSERT INTO GRZ_INDICE_PERMANENCIA_TB
    (COD_EMP,
     COD_UNIDADE,
     DES_UNIDADE,
     DTA_REFERENCIA,
     VLR_CUSTO,
     VLR_ESTOQUE_ANT,
     VLR_MEDIO_EMP,
     VLR_ESTMEDIO_PERM,
     PERMANENCIA)
  WITH
    PARAMS AS (
      SELECT v_dta_ref AS DTA_REF FROM DUAL
    ),
    AGREGADO AS (
      SELECT A.COD_EMP,
             A.COD_UNIDADE,
             P1.DES_FANTASIA AS DES_UNIDADE,
             SUM(NVL(A.VLR_CUSTO, 0)) AS VLR_CUSTO,
             SUM(NVL(A.VLR_ESTOQUE_ANT, 0)) AS VLR_ESTOQUE_ANT,
             SUM(NVL(A.VLR_MEDIO_EMP, 0)) AS VLR_MEDIO_EMP,
             SUM(NVL(A.VLR_ESTOQUE_ANT, 0) + NVL(A.VLR_MEDIO_EMP, 0)) AS VLR_ESTMEDIO_PERM
        FROM NL.ES_0124_CE_ESTMEDIO A
        JOIN NL.PS_PESSOAS P1 ON P1.COD_PESSOA = A.COD_UNIDADE
       CROSS JOIN PARAMS PRM
       WHERE A.DTA_MVTO BETWEEN ADD_MONTHS(PRM.DTA_REF, -11) AND PRM.DTA_REF
         --AND A.COD_UNIDADE IN (4)
         AND A.COD_ITEM <> 344356
         AND A.COD_UNIDADE NOT IN (818, 838, 848, 858,
                                   1145, 1406, 1437, 1446, 1485, 1504, 1541,
                                   1563, 1586, 1587, 1620, 3066, 3145, 3485,
                                   3587, 3620, 5406, 5437, 5446, 5485,
                                   1081808)
         AND EXISTS (SELECT 1 FROM NL.IE_ITENS T WHERE T.COD_ITEM = A.COD_ITEM)
         AND EXISTS (SELECT 1
                       FROM NL.IE_MASCARAS E
                      WHERE E.COD_ITEM    = A.COD_ITEM
                        AND E.COD_MASCARA = 170
                        AND E.COD_NIV0    = '1')
       GROUP BY A.COD_EMP, A.COD_UNIDADE, P1.DES_FANTASIA
    )
  SELECT A.COD_EMP,
         A.COD_UNIDADE,
         A.DES_UNIDADE,
         PRM.DTA_REF AS DTA_REFERENCIA,
         SUM(NVL(A.VLR_CUSTO, 0))         AS VLR_CUSTO,
         SUM(NVL(A.VLR_ESTOQUE_ANT, 0))   AS VLR_ESTOQUE_ANT,
         SUM(NVL(A.VLR_MEDIO_EMP, 0))     AS VLR_MEDIO_EMP,
         SUM(NVL(A.VLR_ESTMEDIO_PERM, 0)) AS VLR_ESTMEDIO_PERM,
         ROUND(
           360 / CASE
                   WHEN (SUM(A.VLR_CUSTO) /
                         CASE WHEN (SUM(A.VLR_ESTMEDIO_PERM) / 365.25) > 0
                              THEN (SUM(A.VLR_ESTMEDIO_PERM) / 365.25)
                              ELSE 1 END) > 0
                   THEN (SUM(A.VLR_CUSTO) /
                         CASE WHEN (SUM(A.VLR_ESTMEDIO_PERM) / 365.25) > 0
                              THEN (SUM(A.VLR_ESTMEDIO_PERM) / 365.25)
                              ELSE 1 END)
                   ELSE 1
                 END
           ,0
         ) AS PERMANENCIA
    FROM AGREGADO A
   CROSS JOIN PARAMS PRM
   GROUP BY A.COD_EMP, A.COD_UNIDADE, A.DES_UNIDADE, PRM.DTA_REF
   ORDER BY A.COD_UNIDADE;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END GRZ_GERA_INDICE_PERMANENCIA_SP;
/
