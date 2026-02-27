CREATE OR REPLACE VIEW V_SETORES_ADM_AVT AS
SELECT DISTINCT C.COD_CUSTO_CONTABIL,
                A.COD_ORGANOGRAMA,
                A.EDICAO_ORG AS COD_UNIDADE,
                A.EDICAO_ORG || ' - ' || B.NOME_ORGANOGRAMA AS DES_UNIDADE,
                A.DATA_INICIO,
                A.DATA_FIM,
                B.COD_NIVEL_ORG AS COD_NIVEL,
                C.COD_CUSTO_SUB,
                A.COD_ORGANOGRAMA_SUB,
                CASE
                  WHEN A.EDICAO_NIVEL3 = '013' THEN
                   '013'
                  ELSE
                   '001'
                END AS COD_REDE,
                CASE
                  WHEN A.EDICAO_NIVEL3 = '013' THEN
                   'LOGÍSTICA'
                  ELSE
                   'ADMINISTRAÇÃO'
                END AS DES_REDE,
                CASE
                  WHEN A.EDICAO_NIVEL3 = '013' THEN
                   21
                  ELSE
                   9
                END AS COD_REGIAO,
                CASE
                  WHEN A.EDICAO_NIVEL3 = '013' THEN
                   'CD'
                  ELSE
                   'ADM'
                END AS DES_REGIAO,
                CASE
                  WHEN A.EDICAO_NIVEL3 = '013' THEN
                   '3'
                  ELSE
                   '2'
                END AS COD_TIPO,
                CASE
                  WHEN A.EDICAO_NIVEL3 = '013' THEN
                   'DEPÓSITO'
                  ELSE
                   'SETOR'
                END AS DES_TIPO,
                CASE
                  WHEN A.EDICAO_NIVEL2 = '008' THEN
                   '008'
                  ELSE
                   NULL
                END AS COD_EMP,
                CASE
                  WHEN A.EDICAO_NIVEL2 = '008' THEN
                   'GRAZZIOTIN S/A'
                  ELSE
                   NULL
                END AS DES_EMPRESA,
                'R' AS TIPO_LOGRA,
                'Rua' AS DES_TIP_LOGRA,
                446 AS COD_LOGRA,
                'VALENTIN GRAZZIOTIN' AS DES_LOGRA,
                77 AS NUMERO,
                10 AS COD_BAIRRO,
                'SÃO CRISTÓVÃO' AS DES_BAIRRO,
                1 AS COD_CIDADE,
                'PASSO FUNDO' AS DES_CIDADE,
                'RS' AS COD_UF,
                CASE
                    WHEN A.EDICAO_NIVEL3 = '001' THEN
                     '92.012.467/0001-70'
                    WHEN A.EDICAO_NIVEL3 = '013' THEN
                     '92.012.467/0013-03'
                    ELSE
                     NULL
                END AS NUM_CNPJ,
                C.COD_NIVEL_CONTABIL,
                A.COD_NIVEL1,
                A.COD_NIVEL2,
                A.COD_NIVEL3,
                A.COD_NIVEL4,
                A.COD_NIVEL5,
                A.COD_NIVEL6,
                A.EDICAO_NIVEL1,
                A.EDICAO_NIVEL2,
                A.EDICAO_NIVEL3,
                A.EDICAO_NIVEL4,
                A.EDICAO_NIVEL5,
                CASE
                  WHEN TRIM(A.EDICAO_NIVEL6) IS NULL OR
                       A.EDICAO_NIVEL6 = ' ' THEN
                   '0'
                  ELSE
                   A.EDICAO_NIVEL6
                END AS EDICAO_NIVEL6,
                CASE
                  WHEN TRIM(A.EDICAO_NIVEL7) IS NULL OR
                       A.EDICAO_NIVEL7 = ' ' THEN
                   '0'
                  ELSE
                   A.EDICAO_NIVEL7
                END AS EDICAO_NIVEL7,
                A.EDICAO_NIVEL1 || '.' || A.EDICAO_NIVEL2 || '.' ||
                A.EDICAO_NIVEL3 || '.' || A.EDICAO_NIVEL4 || '.' ||
                A.EDICAO_NIVEL5 ||
                CASE
                  WHEN A.EDICAO_NIVEL6 IS NOT NULL AND LENGTH(TRIM(A.EDICAO_NIVEL6)) > 0 THEN
                    '.' || A.EDICAO_NIVEL6
                  ELSE ''
                END ||
                CASE
                  WHEN A.EDICAO_NIVEL7 IS NOT NULL AND LENGTH(TRIM(A.EDICAO_NIVEL7)) > 0 THEN
                    '.' || A.EDICAO_NIVEL7
                  ELSE ''
                END AS EDICAO_COMPLETA,
                CASE
                    WHEN B.COD_NIVEL_ORG = 4 THEN
                     B.COD_NIVEL_ORG
                    WHEN B.COD_NIVEL_ORG = 5 THEN
                     B.COD_NIVEL_ORG
                    WHEN B.COD_NIVEL_ORG = 6 THEN
                     B.COD_NIVEL_ORG
                    ELSE
                     0
                END AS NIVEL_ORG,
                CASE
                    WHEN B.COD_NIVEL_ORG = 4 THEN
                     'DIVISÃO'
                    WHEN B.COD_NIVEL_ORG = 5 THEN
                     'DEPARTAMENTO'
                    WHEN B.COD_NIVEL_ORG = 6 THEN
                     'SETOR'
                    ELSE
                     NULL
                END AS DES_NIVEL_ORG
  FROM RHFP0401 A
  LEFT JOIN RHFP0400 B ON B.COD_ORGANOGRAMA = A.COD_ORGANOGRAMA
  LEFT JOIN RHFP0402 C ON C.COD_CUSTO_CONTABIL = B.COD_CUSTO_CONTABIL
  LEFT JOIN RHFP0310 D ON D.COD_ORGANOGRAMA = A.COD_ORGANOGRAMA
 WHERE A.COD_NIVEL3 IN (9, 21)
   AND C.COD_CUSTO_CONTABIL IS NOT NULL
   AND A.DATA_FIM = TO_DATE('31/12/2999', 'DD/MM/YYYY')
   AND D.DATA_FIM = TO_DATE('31/12/2999', 'DD/MM/YYYY')
   AND A.COD_ORGANOGRAMA NOT IN (346, 347, 348, 349, 350, 1465, 1611)
   AND A.EDICAO_ORG NOT IN
       ('531', '546', '561', '572', '582', '587', '760', '813', '818', '821', '828', '833', '838', '838', '848', '853', '858', '868')
 ORDER BY A.EDICAO_ORG, A.COD_ORGANOGRAMA

