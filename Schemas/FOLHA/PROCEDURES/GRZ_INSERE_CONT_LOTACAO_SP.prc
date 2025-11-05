CREATE OR REPLACE PROCEDURE GRZ_INSERE_CONT_LOTACAO_SP AS
BEGIN
  FOR REC IN (SELECT VDC.COD_CONTRATO AS COD_CONTRATO,
                     '01/10/2024' AS DATA_INICIO,
                     '31/12/2999' AS DATA_FIM,
                     LT1.COD_LOTACAO AS COD_LOTACAO,
                     'N' AS IND_TITULAR,
                     '414' AS COD_MOTIVO
                FROM V_DADOS_COLAB_AVT VDC
                INNER JOIN RHFP0510 LT1 ON VDC.COD_ORGANOGRAMA =
                                          LT1.COD_ORGANOGRAMA
                                      AND LT1.COD_CLH = VDC.COD_FUNCAO
               WHERE VDC.COD_EMP = 8
                 AND VDC.STATUS = 0
                 AND VDC.STATUS_AFAST IN ('EM ATIVIDADE', 'AFASTADO TEMP', 'EM FÉRIAS')
                 AND VDC.COD_TIPO = 1
                 AND (VDC.COD_FUNCAO = 68 OR
                     VDC.COD_FUNCAO IN
                     (77, 78, 79, 80, 81, 86, 87, 88, 89, 90, 184, 185, 186, 188, 189, 190, 192, 294, 318) OR
                     VDC.COD_FUNCAO IN (121, 305, 122) OR
                     VDC.COD_FUNCAO = 206 OR VDC.COD_FUNCAO = 120 OR
                     VDC.COD_FUNCAO = 102 OR VDC.COD_FUNCAO = 74 OR
                     VDC.COD_FUNCAO = 75 OR VDC.COD_FUNCAO = 409 OR
                     VDC.COD_FUNCAO = 204)
			          --AND LT1.COD_LOTACAO = 735
               ORDER BY LT1.COD_LOTACAO) LOOP
    INSERT INTO RHFP0309
      (COD_CONTRATO,
       COD_LOTACAO,
       DATA_INICIO,
       DATA_FIM,
       IND_TITULAR,
       COD_MOTIVO)
    VALUES
      (REC.COD_CONTRATO,
       REC.COD_LOTACAO,
       REC.DATA_INICIO,
       REC.DATA_FIM,
       REC.IND_TITULAR,
       REC.COD_MOTIVO);
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END GRZ_INSERE_CONT_LOTACAO_SP;
/
