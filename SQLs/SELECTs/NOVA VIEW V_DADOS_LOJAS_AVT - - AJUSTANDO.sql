/*NOVA VIEW V_DADOS_LOJAS_AVT - - AJUSTANDO*/


/*VERSÃO ORIGINAL - ALTERNATIVA*/
SELECT DISTINCT 
    A.COD_ORGANOGRAMA,
    A.EDICAO_ORG,
    A.EDICAO_ORG || ' - ' || UNI.DES_FANTASIA AS DES_UNI,
    UNI.COD_REDE,
    UNI.DES_REDE,
    UNI.COD_REGIAO,
    UNI.DES_REGIAO,
    DECODE(UNI.COD_REDE,
            10, 'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@grazziotin.com.br',
            30, 'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@pormenos.com.br',
            40, 'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@francogiorgi.com.br',
            50, 'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@tottal.com.br',
            70, DECODE(A.EDICAO_ORG,                
                580, 'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@gztstore.com.br',
                'loja' || LPAD(A.EDICAO_ORG, 4, '0') || '@gztstore.com.br'
            )
        ) AS EMAIL,
    UNI.CELULAR,
    UNI.NUM_CGC AS COD_CNPJ,
    PJ.CEP,
    PJ.TIP_LOGRA,
    PJ.NOME_TIP_LOGRA,
    PJ.COD_LOGRA,
    PJ.NOME_LOGRA AS DES_LOGRA,
    PJ.NUMERO,
    PJ.COD_BAIRRO,
    PJ.NOME_BAIRRO AS DES_BAIRRO,
    PJ.COD_MUNIC AS COD_CIDADE,
    PJ.NOME_MUNIC AS DES_CIDADE,
    PJ.COD_UF,
    DECODE(CTO.DATA_FIM, TO_DATE('31/12/2999', 'DD/MM/YYYY'), 'S', 'N') AS IND_COLAB_LOCAL,
    A.EDICAO_NIVEL2 AS EMPRESA,
    DECODE(A.EDICAO_NIVEL2, '008', 'GRAZZIOTIN S/A', NULL) AS DES_EMPRESA,
    A.DATA_INICIO,
    A.DATA_FIM,    
    A.COD_NIVEL1,
    A.COD_NIVEL2,
    A.COD_NIVEL3,
    NVL(ORG.COD_NIVEL4, 0) AS COD_NIVEL4,
    NVL(ORG.COD_NIVEL5, 0) AS COD_NIVEL5,
    A.COD_NIVEL1 || '.' ||
    A.COD_NIVEL2 || '.' ||
    A.COD_NIVEL3 || '.' ||
    A.COD_NIVEL4 || '.' ||
    A.COD_NIVEL5 AS NIVEL_COMPLETO,
    A.EDICAO_NIVEL1,
    A.EDICAO_NIVEL2,
    A.EDICAO_NIVEL3,
    NVL(A.EDICAO_NIVEL4, 0) AS EDICAO_NIVEL4,
    NVL(A.EDICAO_NIVEL5, 0) AS EDICAO_NIVEL5,
    A.EDICAO_NIVEL1 || '.' ||
    A.EDICAO_NIVEL2 || '.' ||
    A.EDICAO_NIVEL3 || '.' ||
    A.EDICAO_NIVEL4 || '.' ||
    A.EDICAO_NIVEL5 AS EDICAO_COMPLETA
FROM RHFP0401 A
INNER JOIN RHFP0400 B ON A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA
INNER JOIN V_UNIDADES_ATIVAS UNI ON A.EDICAO_ORG = UNI.COD_UNIDADE
INNER JOIN PESSOA_JURIDICA PJ ON UNI.NUM_CGC = PJ.CGC
INNER JOIN RHFP0310 CTO ON A.COD_ORGANOGRAMA = CTO.COD_ORGANOGRAMA AND CTO.DATA_FIM = '31/12/2999'
INNER JOIN PE0002 PE ON PJ.COD_PESSOA = PE.COD_PESSOA
LEFT JOIN RHFP0401 ORG ON A.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA AND A.EDICAO_ORG = ORG.EDICAO_ORG
WHERE A.EDICAO_ORG NOT IN ('001','013')
AND A.COD_NIVEL2 = 8
AND A.COD_NIVEL3 NOT IN (9,21)
AND A.DATA_FIM = '31/12/2999'
AND PE.VALOR = 0
ORDER BY A.EDICAO_ORG ASC;


--=====================================================================--


CREATE OR REPLACE VIEW V_DADOS_LOJAS_AVT AS
/*VERSÃO FINAL - OFICIAL*/
SELECT UNI.COD_ATIVIDADE,
       1 AS COD_TIPO,
       'LOJA' AS DES_TIPO,
       A.COD_ORGANOGRAMA,
       A.EDICAO_ORG AS COD_UNIDADE,
       A.EDICAO_ORG || ' - ' || UNI.DES_FANTASIA AS DES_UNIDADE,
       UNI.COD_REDE,
       UNI.DES_REDE,
       UNI.COD_REGIAO,
       UNI.DES_REGIAO,
       DECODE(UNI.COD_REDE,
              10,
              'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@grazziotin.com.br',
              30,
              'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@pormenos.com.br',
              40,
              'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@francogiorgi.com.br',
              50,
              'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@tottal.com.br',
              70,
              DECODE(A.EDICAO_ORG,
                     580,
                     'loja' || LPAD(A.EDICAO_ORG, 3, '0') ||
                     '@gztstore.com.br',
                     'loja' || LPAD(A.EDICAO_ORG, 4, '0') ||
                     '@gztstore.com.br')) AS EMAIL,
       UNI.CELULAR,
       UNI.NUM_CGC AS NUM_CNPJ,
       PJ.CEP,
       PJ.TIP_LOGRA AS TIPO_LOGRA,
       PJ.NOME_TIP_LOGRA AS DES_TIP_LOGRA,
       PJ.COD_LOGRA,
       PJ.NOME_LOGRA AS DES_LOGRA,
       PJ.NUMERO,
       PJ.COD_BAIRRO,
       PJ.NOME_BAIRRO AS DES_BAIRRO,
       PJ.COD_MUNIC AS COD_CIDADE,
       PJ.NOME_MUNIC AS DES_CIDADE,
       PJ.COD_UF,
       DECODE(CTO.DATA_FIM, TO_DATE('31/12/2999', 'DD/MM/YYYY'), 'S', 'N') AS IND_COLAB_LOCAL,
       COUNT(CT.COD_CONTRATO) AS QTDE_CONTRATOS,
       A.EDICAO_NIVEL2 AS COD_EMP,
       DECODE(A.EDICAO_NIVEL2, '008', 'GRAZZIOTIN S/A', NULL) AS DES_EMP,
       A.DATA_INICIO,
       A.DATA_FIM,
       A.COD_NIVEL1,
       A.COD_NIVEL2,
       A.COD_NIVEL3,
       NVL(ORG.COD_NIVEL4, 0) AS COD_NIVEL4,
       NVL(ORG.COD_NIVEL5, 0) AS COD_NIVEL5,
       A.COD_NIVEL1 || '.' || A.COD_NIVEL2 || '.' || A.COD_NIVEL3 || '.' ||
       A.COD_NIVEL4 || '.' || A.COD_NIVEL5 AS NIVEL_COMPLETO,
       A.EDICAO_NIVEL1,
       A.EDICAO_NIVEL2,
       A.EDICAO_NIVEL3,
       NVL(A.EDICAO_NIVEL4, 0) AS EDICAO_NIVEL4,
       NVL(A.EDICAO_NIVEL5, 0) AS EDICAO_NIVEL5,
       A.EDICAO_NIVEL1 || '.' || A.EDICAO_NIVEL2 || '.' || A.EDICAO_NIVEL3 || '.' ||
       A.EDICAO_NIVEL4 || '.' || A.EDICAO_NIVEL5 AS EDICAO_COMPLETA
  FROM RHFP0401 A
 INNER JOIN RHFP0400 B ON A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA
 INNER JOIN V_UNIDADES_ATIVAS UNI ON A.EDICAO_ORG = UNI.COD_UNIDADE
 INNER JOIN PESSOA_JURIDICA PJ ON UNI.NUM_CGC = PJ.CGC
 INNER JOIN RHFP0310 CTO ON A.COD_ORGANOGRAMA = CTO.COD_ORGANOGRAMA
                        AND CTO.DATA_FIM = '31/12/2999'
 INNER JOIN RHFP0300 CT ON CTO.COD_CONTRATO = CT.COD_CONTRATO
                       AND CT.DATA_FIM IS NULL
 INNER JOIN PE0002 PE ON PJ.COD_PESSOA = PE.COD_PESSOA
  LEFT JOIN RHFP0401 ORG ON A.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
                        AND A.EDICAO_ORG = ORG.EDICAO_ORG
 WHERE A.EDICAO_ORG NOT IN ('001', '013')
   AND A.COD_NIVEL2 = 8
   AND A.COD_NIVEL3 NOT IN (9, 21)
   AND A.DATA_FIM = '31/12/2999'
   AND PE.VALOR = 0
 GROUP BY UNI.COD_ATIVIDADE,
          A.COD_ORGANOGRAMA,
          A.EDICAO_ORG,
          A.EDICAO_ORG || ' - ' || UNI.DES_FANTASIA,
          UNI.COD_REDE,
          UNI.DES_REDE,
          UNI.COD_REGIAO,
          UNI.DES_REGIAO,
          DECODE(UNI.COD_REDE,
                 10,
                 'loja' || LPAD(A.EDICAO_ORG, 3, '0') ||
                 '@grazziotin.com.br',
                 30,
                 'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@pormenos.com.br',
                 40,
                 'loja' || LPAD(A.EDICAO_ORG, 3, '0') ||
                 '@francogiorgi.com.br',
                 50,
                 'loja' || LPAD(A.EDICAO_ORG, 3, '0') || '@tottal.com.br',
                 70,
                 DECODE(A.EDICAO_ORG,
                        580,
                        'loja' || LPAD(A.EDICAO_ORG, 3, '0') ||
                        '@gztstore.com.br',
                        'loja' || LPAD(A.EDICAO_ORG, 4, '0') ||
                        '@gztstore.com.br')),
          UNI.CELULAR,
          UNI.NUM_CGC,
          PJ.CEP,
          PJ.TIP_LOGRA,
          PJ.NOME_TIP_LOGRA,
          PJ.COD_LOGRA,
          PJ.NOME_LOGRA,
          PJ.NUMERO,
          PJ.COD_BAIRRO,
          PJ.NOME_BAIRRO,
          PJ.COD_MUNIC,
          PJ.NOME_MUNIC,
          PJ.COD_UF,
          DECODE(CTO.DATA_FIM,
                 TO_DATE('31/12/2999', 'DD/MM/YYYY'),
                 'S',
                 'N'),
          A.EDICAO_NIVEL2,
          DECODE(A.EDICAO_NIVEL2, '008', 'GRAZZIOTIN S/A', NULL),
          A.DATA_INICIO,
          A.DATA_FIM,
          A.COD_NIVEL1,
          A.COD_NIVEL2,
          A.COD_NIVEL3,
          NVL(ORG.COD_NIVEL4, 0),
          NVL(ORG.COD_NIVEL5, 0),
          A.COD_NIVEL1 || '.' || A.COD_NIVEL2 || '.' || A.COD_NIVEL3 || '.' ||
          A.COD_NIVEL4 || '.' || A.COD_NIVEL5,
          A.EDICAO_NIVEL1,
          A.EDICAO_NIVEL2,
          A.EDICAO_NIVEL3,
          NVL(A.EDICAO_NIVEL4, 0),
          NVL(A.EDICAO_NIVEL5, 0),
          A.EDICAO_NIVEL1 || '.' || A.EDICAO_NIVEL2 || '.' ||
          A.EDICAO_NIVEL3 || '.' || A.EDICAO_NIVEL4 || '.' ||
          A.EDICAO_NIVEL5
 ORDER BY A.EDICAO_ORG ASC;





--========================================================================================--
--========================================================================================--



/*VERSÃO ANTIGA DA VIEW - APENAS PARA BECHKUP*/
SELECT
    LOJASATV.ORG_LOJA,
    LOJASATV.COD_ORGANOGRAMA_SUB,
    LOJASATV.COD_ORGANOGRAMA,
    LOJASATV.COD_UNIDADE,
    LOJASATV.DES_UNIDADE,
    LOJASATV.DATA_INICIO,
    LOJASATV.DATA_FIM,
    LOJASATV.COD_REDE_LOCAL,
    LOJASATV.DES_REDE_LOCAL,
    LOJASATV.IND_COLAB_LOCAL,
    LOJASATV.EDICAO_NIVEL2 AS COD_EMP,
    LOJASATV.DES_EMPRESA,
    LOJASATV.EMAIL,
    LOJASATV.CELULAR AS NUM_CELULAR,
    LOJASATV.REGIAO AS COD_REGIAO,
    LOJASATV.DES_REGIAO,
    LOJASATV.COD_TIPO,
    LOJASATV.DES_TIPO,
    --LOJASATV.COD_TURNO,
    LOJASATV.EDICAO_NIVEL1 || '.' ||
    LOJASATV.EDICAO_NIVEL2 || '.' ||
    LOJASATV.EDICAO_NIVEL3 || '.' ||
    LOJASATV.EDICAO_NIVEL4 || '.' ||
    LOJASATV.EDICAO_NIVEL5 AS EDICAO_COMPLETA,
    LOJASATV.NUM_CGC AS NUM_CNPJ_CGC,
    LOJASATV.CEP AS NUM_CEP,
    LOJASATV.TIP_LOGRA AS TIP_LOGRA,
    LOJASATV.NOME_LOGRA AS DES_LOGRA,
    LOJASATV.NUMERO AS NUM_LOCAL,
    LOJASATV.NOME_BAIRRO AS DES_BAIRRO,
    LOJASATV.NOME_MUNIC AS DES_CIDADE,
    LOJASATV.COD_UF
FROM (
    SELECT DISTINCT
        A1.COD_NIVEL3 AS ORG_LOJA,
        A1.COD_ORGANOGRAMA_SUB,
        A2.COD_ORGANOGRAMA,
        DECODE(UNI.REDE,
            10, LPAD(UNI.COD_UNIDADE, 3, '0'),
            30, LPAD(UNI.COD_UNIDADE, 3, '0'),
            40, LPAD(UNI.COD_UNIDADE, 3, '0'),
            50, LPAD(UNI.COD_UNIDADE, 3, '0'),
            70, DECODE(UNI.COD_UNIDADE,
                566, LPAD(UNI.COD_UNIDADE, 3, '0'),
                580, LPAD(UNI.COD_UNIDADE, 3, '0'),
                LPAD(UNI.COD_UNIDADE, 4, '0')
            )
        ) AS COD_UNIDADE,
        DECODE(UNI.REDE,
            10, LPAD(UNI.COD_UNIDADE, 3, '0'),
            30, LPAD(UNI.COD_UNIDADE, 3, '0'),
            40, LPAD(UNI.COD_UNIDADE, 3, '0'),
            50, LPAD(UNI.COD_UNIDADE, 3, '0'),
            70, DECODE(UNI.COD_UNIDADE,
                566, LPAD(UNI.COD_UNIDADE, 3, '0'),
                580, LPAD(UNI.COD_UNIDADE, 3, '0'),
                LPAD(UNI.COD_UNIDADE, 4, '0')
            )
        ) || ' - ' || UNI.DES_FANTASIA AS DES_UNIDADE,
        A1.DATA_INICIO,
        A1.DATA_FIM,
        NVL(UNI.REDE, 0) AS COD_REDE_LOCAL,
        DECODE(UNI.REDE,
            10, 'GRAZZIOTIN',
            30, 'PORMENOS',
            40, 'FRANCO GIORGI',
            50, 'TOTTAL',
            70, 'GZT STORE'
        ) AS DES_REDE_LOCAL,
        DECODE(A4.DATA_FIM, TO_DATE('31/12/2999', 'DD/MM/YYYY'), 'CONTRATOS ATIVOS', NULL) AS IND_COLAB_LOCAL,
        A1.EDICAO_NIVEL2 AS EMPRESA,
        DECODE(A1.EDICAO_NIVEL2, '008', 'GRAZZIOTIN S/A', NULL) AS DES_EMPRESA,
        DECODE(UNI.REDE,
            10, 'loja' || LPAD(UNI.COD_UNIDADE, 3, '0') || '@grazziotin.com.br',
            30, 'loja' || LPAD(UNI.COD_UNIDADE, 3, '0') || '@pormenos.com.br',
            40, 'loja' || LPAD(UNI.COD_UNIDADE, 3, '0') || '@francogiorgi.com.br',
            50, 'loja' || LPAD(UNI.COD_UNIDADE, 3, '0') || '@tottal.com.br',
            70, DECODE(UNI.COD_UNIDADE,
                566, 'loja' || LPAD(UNI.COD_UNIDADE, 3, '0') || '@gztstore.com.br',
                580, 'loja' || LPAD(UNI.COD_UNIDADE, 3, '0') || '@gztstore.com.br',
                'loja' || LPAD(UNI.COD_UNIDADE, 4, '0') || '@gztstore.com.br'
            )
        ) AS EMAIL,
        DECODE(TEL.NUM_SEQ, 4, TEL.NUM_FONE, NULL) AS CELULAR,
        REG.COD_GRUPO AS REGIAO,
        DREG.NOME_REGIAO AS DES_REGIAO,
        1 AS COD_TIPO,
        'LOJA' AS DES_TIPO,
        --TU.COD_TURNO,
        UNI.NUM_CGC,
        J.CEP,
        L.TIP_LOGRA,
        L.NOME_LOGRA,
        J.NUMERO,
        B.NOME_BAIRRO,
        M.NOME_MUNIC,
        J.COD_UF,
        A1.EDICAO_NIVEL1,
        A1.EDICAO_NIVEL2,
        A1.EDICAO_NIVEL3,
        A1.EDICAO_NIVEL4,
        A1.EDICAO_NIVEL5,
        ROW_NUMBER() OVER (PARTITION BY UNI.COD_UNIDADE ORDER BY
            DECODE(A2.COD_NIVEL_ORG, 5, DECODE(A3.COD_NIVEL_CONTABIL, 5, 0, 1), 1)
        ) AS RN
    FROM
        SISLOGWEB.V_UNIDADES_ATIVAS@NLGRZ UNI
    INNER JOIN RHFP0401 A1 ON UNI.COD_UNIDADE = A1.EDICAO_ORG
    INNER JOIN RHFP0400 A2 ON A2.COD_ORGANOGRAMA = A1.COD_ORGANOGRAMA
    INNER JOIN RHFP0402 A3 ON A3.COD_CUSTO_CONTABIL = A2.COD_CUSTO_CONTABIL
    INNER JOIN RHFP0310 A4 ON A1.COD_ORGANOGRAMA = A4.COD_ORGANOGRAMA
     LEFT JOIN JURIDICA J ON J.CGC = UNI.NUM_CGC
    INNER JOIN NL.GE_GRUPOS_UNIDADES@NLGRZ REG ON REG.COD_UNIDADE = UNI.COD_UNIDADE
    INNER JOIN NL.DATALAKE_DIM_REGIAO@NLGRZ DREG ON REG.COD_GRUPO = DREG.COD_REGIAO
    INNER JOIN MUNICI M ON M.COD_MUNIC = J.COD_MUNIC
    INNER JOIN BAIRRO B ON B.COD_BAIRRO = J.COD_BAIRRO
    INNER JOIN LOGRA L ON L.COD_LOGRA = J.COD_LOGRA
     LEFT JOIN NL.PS_TELEFONES@NLGRZ TEL ON TEL.COD_PESSOA = UNI.COD_UNIDADE
    --LEFT JOIN PE0002 PE ON J.COD_PESSOA = PE.COD_PESSOA
    /*LEFT JOIN (
        SELECT A.COD_ORGANOGRAMA AS ORG,
               C.EDICAO_NIVEL3 AS EDICAO_ORG,
               C.EDICAO_ORG AS UNIDADE,
               B.NOME_ORGANOGRAMA,
               A.COD_TURNO,
               A.DATA_INICIO,
               A.DATA_FIM
        FROM RHAF1149 A
        INNER JOIN RHFP0400 B ON A.COD_ORGANOGRAMA = B.COD_ORGANOGRAMA
        INNER JOIN RHFP0401 C ON B.COD_ORGANOGRAMA = C.COD_ORGANOGRAMA
        WHERE A.DATA_FIM = TO_DATE('31/12/2999', 'DD/MM/YYYY')
          AND C.DATA_FIM = '31/12/2999'
    ) TU ON UNI.COD_UNIDADE = TU.UNIDADE*/
    WHERE
        UNI.COD_UNIDADE NOT IN ('900', '1549', '3549', '4549', '5549', '7549')
        AND REG.COD_GRUPO BETWEEN 8701 AND 8716
        AND A2.COD_NIVEL_ORG = 5
        AND A3.COD_NIVEL_CONTABIL = 5
        AND A3.EDICAO_NIVEL5 IS NOT NULL
        AND A1.COD_NIVEL2 NOT IN (4, 6, 128, 276, 282)
        AND A1.COD_NIVEL2 = 8
        AND A1.DATA_FIM = '31/12/2999'
        AND A4.DATA_FIM = '31/12/2999'
) LOJASATV
WHERE RN = 1
ORDER BY LOJASATV.COD_UNIDADE ASC

