/*PROCESSO DE BACKUP DA TABELA DOS KPIs DA P.L.R*/


CREATE TABLE GRZ_KPI_AVALIACAO_PLR_TB_BKP AS
SELECT *
FROM BKP_GRZ_KPI_AVALIACAO_PLR_TB;

SELECT * FROM GRZ_KPI_AVALIACAO_PLR_TB

UPDATE GRZ_KPI_AVALIACAO_PLR_TB T
   SET (T.VLR_VALE_TRANS, T.VT) =
       (
         SELECT NVL(X.VLR_VALE_TRANS, 0),
                CASE
                  WHEN NVL(T.VLR_VENDA_LIQUIDA, 0) <> 0 THEN
                   ROUND((NVL(X.VLR_VALE_TRANS, 0) * 100) / T.VLR_VENDA_LIQUIDA, 2)
                  ELSE
                   0
                END
           FROM (
                 SELECT A.COD_UNIDADE,
                        NVL(ROUND(SUM(NVL(A.VLR_REALIZADO, 0)), 2), 0) AS VLR_VALE_TRANS
                   FROM NL.OR_VALORES@NLGRZ A
                  WHERE A.COD_EMP = 1
                    AND A.COD_ORCAMENTO = 400
                    AND A.DTA_ORCAMENTO BETWEEN T.DTA_INI AND T.DTA_FIM
                    AND A.DES_CHAVE IN ('15#15025', '15#15030')
                  GROUP BY A.COD_UNIDADE
                ) X
          WHERE X.COD_UNIDADE = T.COD_UNIDADE
       )
 WHERE T.DTA_INI = DATE '2025-01-01'
   AND T.DTA_FIM = DATE '2025-01-31';
   


MERGE INTO GRZ_KPI_AVALIACAO_PLR_TB T
USING (
    WITH BASE AS (
        SELECT
            ROWID AS RID,
            COD_UNIDADE,
            DTA_INI,
            DTA_FIM,
            NVL(VLR_VENDA_LIQUIDA, 0) AS VLR_VENDA_LIQUIDA
        FROM GRZ_KPI_AVALIACAO_PLR_TB
    ),
    VT_CALCULADO AS (
        SELECT
            B.RID,
            NVL(ROUND(SUM(NVL(A.VLR_REALIZADO, 0)), 2), 0) AS VLR_VALE_TRANS
        FROM BASE B
        LEFT JOIN NL.OR_VALORES@NLGRZ A
               ON A.COD_UNIDADE    = B.COD_UNIDADE
              AND A.COD_EMP        = 1
              AND A.COD_ORCAMENTO  = 400
              AND A.DTA_ORCAMENTO >= B.DTA_INI
              AND A.DTA_ORCAMENTO <= B.DTA_FIM
              AND A.DES_CHAVE IN ('15#15025', '15#15030')
        GROUP BY B.RID
    )
    SELECT
        B.RID,
        V.VLR_VALE_TRANS,
        CASE
            WHEN B.VLR_VENDA_LIQUIDA <> 0 THEN
                ROUND((V.VLR_VALE_TRANS * 100) / B.VLR_VENDA_LIQUIDA, 2)
            ELSE
                0
        END AS VT
    FROM BASE B
    JOIN VT_CALCULADO V
      ON V.RID = B.RID
) X
ON (T.ROWID = X.RID)
WHEN MATCHED THEN
    UPDATE SET
        T.VLR_VALE_TRANS = X.VLR_VALE_TRANS,
        T.VT             = X.VT;
