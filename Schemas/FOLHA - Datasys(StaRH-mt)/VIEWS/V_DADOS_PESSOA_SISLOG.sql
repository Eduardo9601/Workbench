CREATE OR REPLACE VIEW V_DADOS_PESSOA_SISLOG AS
SELECT DISTINCT FP03.COD_CONTRATO COD_FUNCIONARIO,
                      NVL2(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                           ORG_EMP.EDICAO_NIVEL5,
                           001) COD_UNIDADE,
                      NVL2(ORG_CUSTO_CTB.CUSTO_CONTABIL,
                           ORG_EMP.EDICAO_NIVEL5,
                           001) COD_CENTRO_CUSTO,
                      INITCAP(P.NOME_PESSOA) DES_NOME,
                      FP03.DATA_INICIO DTA_ADMISSAO,
                      FP03.DATA_FIM DTA_DEMISSAO,
                      FP02.DATA_NASCIMENTO DATA_NASCIMENTO,
                      (CASE
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 8 THEN
                         8
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 4 THEN
                         4
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 276 THEN
                         276
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 280 THEN
                         280
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 282 THEN
                         282
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 2 THEN
                         2
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 6 THEN
                         6
                        ELSE
                         8
                      END) COD_EMPRESA,
                      (CASE
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 8 THEN
                         'GRAZZIOTIN S/A'
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 4 THEN
                         'MUNDIART S/A'
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 276 THEN
                         'CENTRO SHOPPING LDTA'
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 280 THEN
                         'CAULESPAR LTDA'
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 282 THEN
                         'GRAZZIOTIN FINANCIADORA S/A'
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 2 THEN
                         'VR LTDA'
                        WHEN ORGANOGRAMA.COD_ORGANOGRAMA = 6 THEN
                         'GRATO LTDA'
                        ELSE
                         'GRAZZIOTIN S/A'
                      END) DES_EMPRESA,
                      FUNCOES.COD_CLH COD_FUNCAO,
                      FUNCOES.NOME_CLH DES_FUNCAO,
                      TURNO.COD_TURNO,
                      TRIM(TO_CHAR(HORAS2.QTD_HORBAS_MES, '999')) QTD_CH_MENSAL,
                      TRIM(FP02.NRO_CTPS) NUM_CART_TRAB,
                      TRIM(FP02.NRO_SERIE_CTPS) NUM_SERIE_CART_TRAB,
                      NVL(AFASTAMENTO.COD_CAUSA_AFAST, 0) COD_AFASTAMENTO,
                      AFASTAMENTO.DATA_INICIO DATA_AFASTAMENTO_INI,
                      AFASTAMENTO.DATA_FIM DATA_AFASTAMENTO_FIM,
                      TRIM(FIS.CPF) CPF
        FROM RHFP0200    FP02,
             RHFP0300    FP03,
             PESSOA      P,
             MUNICI      MUN,
             FISICA      FIS,
             RHFP0310    CONTR_ORGANOGRAMA,
             RHFP0400    ORGANOGRAMA,
             RHFP0401    ORG_EMP,
             RHFP0402    ORG_CUSTO_CTB,
             RHFP0500    FUNCOES,
             RHFP0340    CONTRFUNC,
             MDL_USUARIO SENHA,
             RHAF1119    TURNO,
             RHFP0308    DES_TURNO,
             RHFP0307    HORAS,
             RHFP0321    HORAS2,
             RHFP0306    AFASTAMENTO
       WHERE TURNO.DATA_INICIO IN
             (SELECT MAX(Z.DATA_INICIO) DATA_INICIO
                FROM RHAF1119 Z
               WHERE TURNO.COD_CONTRATO = Z.COD_CONTRATO)
         AND HORAS.DATA_INICIO IN
             (SELECT MAX(Y.DATA_INICIO)
                FROM RHFP0307 Y
               WHERE Y.COD_CONTRATO = FP03.COD_CONTRATO)
         AND FP03.DATA_INICIO IN
             (SELECT MAX(W.DATA_INICIO)
                FROM RHFP0300 W
               WHERE W.COD_CONTRATO = FP03.COD_CONTRATO)
         AND P.COD_PESSOA = FP02.COD_FUNC
         AND FIS.COD_PESSOA = FP02.COD_FUNC
         AND FP02.COD_FUNC = FP03.COD_FUNC
         AND FP03.COD_CONTRATO = CONTRFUNC.COD_CONTRATO
         AND FP03.COD_CONTRATO = DES_TURNO.COD_CONTRATO(+)
         AND FP03.COD_CONTRATO = HORAS.COD_CONTRATO
         AND HORAS.COD_HORAS_BASE = HORAS2.COD_HORAS_BASE
         AND FUNCOES.COD_CLH = CONTRFUNC.COD_CLH
         AND FP03.COD_CONTRATO = TURNO.COD_CONTRATO
         AND FP03.COD_CONTRATO = CONTR_ORGANOGRAMA.COD_CONTRATO
         AND FP03.COD_CONTRATO = AFASTAMENTO.COD_CONTRATO(+)
         AND FP03.COD_CONTRATO = SENHA.COD_CONTRATO(+)
         AND ORGANOGRAMA.COD_CUSTO_CONTABIL =
             ORG_CUSTO_CTB.COD_CUSTO_CONTABIL(+)
         AND FIS.COD_MUNIC = MUN.COD_MUNIC
         AND CONTR_ORGANOGRAMA.COD_ORGANOGRAMA =
             ORGANOGRAMA.COD_ORGANOGRAMA
         AND ORGANOGRAMA.COD_ORGANOGRAMA = ORG_EMP.COD_ORGANOGRAMA
         AND CONTR_ORGANOGRAMA.DATA_FIM > TRUNC(SYSDATE)
         AND TRUNC(SYSDATE) >= AFASTAMENTO.DATA_INICIO(+)
         AND TRUNC(SYSDATE) <= AFASTAMENTO.DATA_FIM(+)
         AND CONTRFUNC.DATA_FIM > TRUNC(SYSDATE)
         AND ORG_EMP.DATA_INICIO <= TRUNC(SYSDATE)
         AND ORG_EMP.DATA_FIM > TRUNC(SYSDATE)
         AND FP02.NRO_SERIE_CTPS IS NOT NULL
         AND FP02.NRO_CTPS IS NOT NULL
             AND FIS.CPF IS NOT NULL;
