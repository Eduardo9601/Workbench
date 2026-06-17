CREATE OR REPLACE PROCEDURE GRZ_FOLHA_TEMPO_OP_CAIXAS IS
BEGIN

  /******************************************/
  /******************************************/
  /****   VERSÃO: 3.1                    ****/
  /****   CRIADO POR: ÂNDERSON           ****/
  /******************************************/
  /****   ANTERADO POR: EDUARDO          ****/
  /****   DATA DA ALTERAÇÃO: 12/06/2025  ****/
  /******************************************/
  /******************************************/

  DECLARE
  
    -- DECLARAÇÃO DE VARIAVEIS --
    wCodEvento  NUMBER;
    wTempoLogin NUMBER(15, 2);
    wDataMov    DATE;
  
    CURSOR C1 IS
    
      SELECT TEMPO.COD_USUARIO,
             TO_DATE(TO_CHAR((LAST_DAY(SYSDATE)), 'DD/MM/YYYY')) AS DATA_REFERENCIA,
             SUM((TRIM(TO_CHAR(RHYF0118(TEMPO.TEMPO_LOGIN), '990,00')))) AS TEMPO_LOGIN,
             CT.DATA_FIM,
             TEMPO.QTD_HORBAS_MES,
             TEMPO.NOME_CLH
        FROM (SELECT A.COD_USUARIO,
                     K.QTD_HORBAS_MES,
                     SUM(ROUND((A.TEMPO_LOGIN / 60), 2)) AS TEMPO_LOGIN,
                     NMCLH.NOME_CLH
                FROM SISLOGWEB.GER_TEMPO_LOGIN@NLGRZ A,
                     RHFP0340                        CARGO,
                     RHFP0500                        NMCLH,
                     RHFP0307                        G,
                     RHFP0321                        K
               WHERE TO_DATE(SUBSTR(HORA_INICIAL, 1, 10)) >=
                     to_date('15/' || to_char(add_months(TRUNC(SYSDATE), -1),
                                              'mm/yyyy'),
                             'dd/mm/yyyy')
                 AND TO_DATE(SUBSTR(HORA_INICIAL, 1, 10)) <=
                     to_date('15/' || to_char(TRUNC(SYSDATE), 'mm/yyyy')) -- PERÍODO ENTRE DIA 15 DO MES PASSADO AO DIA 15 DO MES ATUAL
                 AND CARGO.COD_CONTRATO = A.COD_USUARIO
                 AND G.COD_CONTRATO = A.COD_USUARIO
                 AND K.COD_HORAS_BASE = G.COD_HORAS_BASE
                 AND G.DATA_FIM = '31/12/2999'
                 AND CARGO.DATA_FIM = '31/12/2999'
                 AND NMCLH.COD_CLH = CARGO.COD_CLH
                 AND CARGO.COD_CLH NOT IN (102, 47, 225, 120)
                 AND NMCLH.NOME_CLH NOT LIKE '%GERENTE%'
                 AND NOT EXISTS
               (SELECT 1
                        FROM V_DADOS_PESSOA Y
                       WHERE Y.COD_CONTRATO = A.COD_USUARIO
                         AND (Y.DES_GRUPO LIKE '%FRANCO GIORGI%' OR
                             Y.COD_UNIDADE IN
                             ('205', '289', '567', '016', '392'))
                         AND Y.COD_CONTRATO = A.COD_USUARIO) -- NÃO IMPORTA HORAS OPERADAS DE VENDEDOR DE MODA MASCULINA DAS FILIAIS FRANCO GIORGI E DAS LOJAS COM SINDICATO (63, 159)
               GROUP BY A.COD_USUARIO, K.QTD_HORBAS_MES, NMCLH.NOME_CLH) TEMPO,
             RHFP0300 CT
       WHERE CT.COD_CONTRATO = TEMPO.COD_USUARIO
         AND NOT EXISTS
       (SELECT 1
                FROM RHFP1004 A
               WHERE A.COD_CONTRATO = TEMPO.COD_USUARIO
                 AND (DATA_MOV = TO_CHAR((LAST_DAY(SYSDATE)), 'DD/MM/YYYY') OR
                     DATA_MOV = DATA_FIM)
                 AND COD_VD = 838
                 AND COD_EVENTO IN (1, 17)) -- VALIDA/IMPEDE INSERÇÃO CASO JÁ INFORMADO O VD838
      --AND TEMPO.COD_USUARIO IN (383058,379928,337196,387898)
       GROUP BY TEMPO.COD_USUARIO,
                CT.DATA_FIM,
                TEMPO.QTD_HORBAS_MES,
                TEMPO.NOME_CLH;
  
    r1 C1%ROWTYPE;
  
  BEGIN
  
    FOR R1 IN C1 LOOP
    
      -- VALIDA EVENTO MENSAL/RESCISÃO E DATA DE MOVIMENTO --
      IF (r1.DATA_FIM IS NULL) OR (r1.DATA_FIM > TRUNC(SYSDATE)) THEN
        wCodEvento := 1;
        wDataMov   := r1.DATA_REFERENCIA;
      ELSIF (r1.DATA_FIM <= TRUNC(SYSDATE)) THEN
        wCodEvento := 17;
        wDataMov   := r1.DATA_FIM;
      END IF;
    
      -- VALIDA TEMPO OPERADO ACIMA DA CARGA HORÁRIA DO USUÁRIO --
      IF (r1.TEMPO_LOGIN > r1.QTD_HORBAS_MES) THEN
        wTempoLogin := r1.QTD_HORBAS_MES;
      ELSE
        wTempoLogin := r1.TEMPO_LOGIN;
      END IF;
    
      INSERT INTO RHFP1004
        (COD_EVENTO,
         COD_CONTRATO,
         DATA_MOV,
         COD_VD,
         TIPO_INF_VD,
         PRESTACAO_VD,
         QTDE_VD,
         VALOR_VD,
         COD_ORIGEM_MOV,
         COD_MESTRE_EVENTO,
         DATA_DIGITACAO,
         OBSERVACAO)
      VALUES
        (wCodEvento,
         r1.COD_USUARIO,
         wDataMov,
         838,
         'H',
         NULL,
         wTempoLogin,
         NULL,
         6,
         NULL,
         SYSDATE,
         'Movimento Importado Do Sislog');
    
    END LOOP;
    COMMIT;
  END;

END GRZ_FOLHA_TEMPO_OP_CAIXAS;
