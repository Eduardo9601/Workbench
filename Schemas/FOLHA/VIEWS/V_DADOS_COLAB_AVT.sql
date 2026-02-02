CREATE OR REPLACE VIEW V_DADOS_COLAB_AVT AS
WITH
/* =========================
   1) CONTRATOS (BASE)
   ========================= */

FICHA_ATUAL AS (
  /* GARANTE 1 LINHA POR CONTRATO PARA FICHA/MOTIVO (RHFP0344 PODE DUPLICAR) */
  SELECT COD_CONTRATO,
         MAX(NUM_FICHA_REGISTRO) AS NUM_FICHA_REGISTRO,
         MAX(COD_MOTIVO) AS COD_MOTIVO
    FROM RHFP0344
   WHERE DATA_FIM = DATE '2999-12-31'
   GROUP BY COD_CONTRATO
),

CONTRATOS AS (
  SELECT DISTINCT
         B.COD_PESSOA,
         A.COD_CONTRATO,
         INITCAP(B.NOME_PESSOA) AS DES_PESSOA,

         /* NOME CURTO COM INICIAIS DOS NOMES DO MEIO, IGNORANDO DA/DE/DO/DAS/DOS/E, MÁX. 40 CHARS */
         SUBSTR(
           CASE
             WHEN TRIM(
                    REGEXP_REPLACE(
                      REGEXP_REPLACE(
                        TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(B.NOME_PESSOA, '\s+', ' '),
                                                           '^\S+|\S+$', ''),
                                           ' +', ' ')),
                        '\b(da|de|do|das|dos|e)\b', '', 1, 0, 'i'
                      ),
                      ' +', ' '
                    )
                  ) IS NULL
             THEN
               INITCAP(REGEXP_SUBSTR(REGEXP_REPLACE(B.NOME_PESSOA,'\s+',' '), '^\S+'))
               || ' ' ||
               INITCAP(REGEXP_SUBSTR(REGEXP_REPLACE(B.NOME_PESSOA,'\s+',' '), '\S+$'))
             ELSE
               INITCAP(REGEXP_SUBSTR(REGEXP_REPLACE(B.NOME_PESSOA,'\s+',' '), '^\S+'))
               || ' ' ||
               TRIM(
                 REGEXP_REPLACE(
                   UPPER(
                     TRIM(
                       REGEXP_REPLACE(
                         REGEXP_REPLACE(
                           TRIM(REGEXP_REPLACE(REGEXP_REPLACE(B.NOME_PESSOA,'\s+',' '),
                                               '^\S+|\S+$','')),
                           '\b(da|de|do|das|dos|e)\b','',1,0,'i'
                         ),
                         ' +',' '
                       )
                     )
                   ),
                   '(^| )([[:alpha:]])[[:alpha:]]*', '\1\2.'
                 )
               )
               || ' ' ||
               INITCAP(REGEXP_SUBSTR(REGEXP_REPLACE(B.NOME_PESSOA,'\s+',' '), '\S+$'))
           END
         , 1, 40) AS DES_PESSOA_ABREV,

         INITCAP(REGEXP_SUBSTR(B.NOME_PESSOA, '^\S+')) AS PRIMEIRO_NOME,
         INITCAP(REGEXP_SUBSTR(B.NOME_PESSOA, ' (.+) ')) AS SEGUNDO_NOME,
         INITCAP(REGEXP_SUBSTR(B.NOME_PESSOA, '\S+$')) AS SOBRENOME,

         A.DATA_AVANCO,
         A.DATA_INICIO AS DATA_ADMISSAO,
         A.DATA_FIM    AS DATA_DEMISSAO,

         A.COD_CAUSA_DEMISSAO AS COD_DEMISSAO,
         C.NOME_CAUSA_DEMISSAO AS DES_DEMISSAO,

         A.COD_VINCULO_EMPREG,
         A.COD_CATEGORIA_TRAB,
         G.COD_ESOCIAL,

         A.NRO_CONTA_PGTO,
         A.COD_AGE_PGTO,
         CASE
           WHEN A.NRO_CONTA_PGTO IS NOT NULL THEN A.NRO_CONTA_PGTO || '/' || A.COD_AGE_PGTO
           ELSE NULL
         END AS CONTA_BANCARIA,

         A.COD_BCO_PGTO AS COD_BANCO,
         F.NOME_PESSOA  AS DES_BANCO,

         A.COD_BCO_FGTD,
         A.COD_AGE_FGTS,
         A.NRO_CONTA_FGTS,
         A.DATA_OPCAO_FGTS,

         H.NUM_FICHA_REGISTRO,
         H.COD_MOTIVO,
         I.NOME_MOTIVO AS DES_MOTIVO,

         CASE
           WHEN A.DATA_FIM IS NOT NULL AND A.DATA_FIM < TRUNC(SYSDATE) THEN 1
           ELSE 0
         END AS STATUS,

         CASE
           WHEN A.DATA_FIM IS NOT NULL AND A.DATA_FIM < TRUNC(SYSDATE) THEN 'INATIVO'
           WHEN A.DATA_INICIO <= TRUNC(SYSDATE) THEN 'ATIVO'
           WHEN A.DATA_INICIO >  TRUNC(SYSDATE) THEN 'ADMISSAO FUTURA'
         END AS DESC_STATUS

    FROM RHFP0300 A
    INNER JOIN PESSOA_FISICA B ON A.COD_FUNC = B.COD_PESSOA
    LEFT JOIN RHFP0102 C ON A.COD_CAUSA_DEMISSAO = C.COD_CAUSA_DEMISSAO
    LEFT JOIN RHFP0128 D ON A.COD_CATEGORIA_TRAB = D.COD_CATEGORIA_TRAB
    LEFT JOIN BANCO E ON A.COD_BCO_PGTO = E.COD_BANCO
    LEFT JOIN PESSOA F ON E.COD_PESSOA = F.COD_PESSOA
    LEFT JOIN RHFP0128 G ON A.COD_CATEGORIA_TRAB = G.COD_CATEGORIA_TRAB

    /* BLINDA A FICHA/MOTIVO: 1:1 POR CONTRATO */
    LEFT JOIN FICHA_ATUAL H ON H.COD_CONTRATO = A.COD_CONTRATO
    LEFT JOIN RHFP0323 I ON I.COD_MOTIVO = H.COD_MOTIVO

   WHERE (
           (A.DATA_FIM IS NULL OR TRUNC(SYSDATE) BETWEEN A.DATA_INICIO AND NVL(A.DATA_FIM, DATE '2999-12-31'))
        OR (A.DATA_FIM = TRUNC(SYSDATE) AND A.DATA_FIM < TRUNC(SYSDATE) + 1)
        OR (A.DATA_FIM > TRUNC(SYSDATE))
        OR (A.DATA_FIM >= TRUNC(SYSDATE) - 35550)
         )
),

/* =========================
   1.1) CONTRATOS_FILTRADO
   1 CONTRATO POR PESSOA
   ========================= */
CONTRATOS_FILTRADO AS (
  SELECT *
  FROM (
    SELECT
      CT.*,
      ROW_NUMBER() OVER (
        PARTITION BY CT.COD_PESSOA
        ORDER BY
          CASE CT.DESC_STATUS
            WHEN 'ATIVO' THEN 3
            WHEN 'ADMISSAO FUTURA' THEN 2
            ELSE 1
          END DESC,
          NVL(CT.DATA_DEMISSAO, DATE '2999-12-31') DESC,
          CT.DATA_ADMISSAO DESC,
          CT.COD_CONTRATO DESC
      ) RN_PESSOA
    FROM CONTRATOS CT
  )
  WHERE RN_PESSOA = 1
),

/* =========================
   2) DADOS_PESSOAIS
   ========================= */
DADOS_PESSOAIS AS (
  SELECT DISTINCT A.COD_FUNC,
                  A.DATA_NASCIMENTO,
                  TRUNC(MONTHS_BETWEEN(SYSDATE, A.DATA_NASCIMENTO) / 12) AS IDADE,
                  A.SEXO,
                  A.COD_ESTADO_CIVIL AS COD_EST_CIVIL,
                  D.NOME_ESTADO_CIVIL AS DES_EST_CIVIL,
                  A.COD_PESSOA_PAI,
                  H1.NOME_PESSOA AS DES_PAI,
                  A.COD_PESSOA_MAE,
                  H2.NOME_PESSOA AS DES_MAE,
                  A.IND_DEFICIENCIA,
                  A.COD_DEFICIENCIA,
                  F.NOME_DEFICIENCIA AS DES_DEFICIENCIA,
                  CASE
                    WHEN I.EMAIL LIKE '%grazziotin.com.br%' OR
                         I.EMAIL LIKE '%grupograzziotin.com.br%' OR
                         I.EMAIL LIKE '%tottal.com.br%' OR
                         I.EMAIL LIKE '%pormenos.com.br%' OR
                         I.EMAIL LIKE '%gztstore.com.br%' OR
                         I.EMAIL LIKE '%francogiorgi.com.br%' THEN
                     I.EMAIL
                    ELSE
                     NULL
                  END AS DES_EMAIL,
                  I.EMAIL_ALTER AS DES_EMAIL_ALTER,
                  I.DDD_FONE_CEL AS COD_DDD,
                  I.FONE_CEL,
                  I.CPF,
                  A.NRO_IDENTIDADE,
                  C.NOME_PESSOA AS EMISSOR_RG,
                  A.COD_UF_IDENTIDADE AS UF_RG,
                  C.NOME_PESSOA || '/' || A.COD_UF_IDENTIDADE AS EMISSOR,
                  A.DATA_EMI_IDENTIDADE,
                  A.NRO_PIS_PASEP,
                  A.DATA_PIS_PASEP,
                  A.NRO_CTPS,
                  A.NRO_SERIE_CTPS,
                  A.NRO_CTPS || '/' || A.NRO_SERIE_CTPS AS CTPS,
                  A.DATA_EXP_CTPS,
                  A.COD_UF_CTPS,
                  A.COD_TIPO_APOSENT,
                  A.NRO_BENEFICIO_INSS,
                  A.DATA_APOSENTADORIA,
                  A.NRO_TITULO,
                  A.NRO_ZONA_TITULO,
                  A.NRO_SECAO_TITULO,
                  A.DATA_EMISSAO_TITULO,
                  A.COD_UF_TITULO,
                  A.COD_MUN_TITULO,
                  A.NRO_HABILITACAO,
                  A.DATA_EMISSAO_HAB,
                  A.DATA_VALIDADE_HAB,
                  A.COD_CATEGORIA_HAB,
                  A.COD_ORGAO_HAB,
                  C1.NOME_PESSOA AS DES_ORGAO_HAB,
                  A.NRO_RESERVISTA,
                  A.SERVICO_MILITAR,
                  A.COD_GRAU_INSTRUCAO AS COD_INSTRUCAO,
                  G.NOME_RESUMIDO AS DES_INSTRUCAO,
                  A.COD_NACIONALIDADE,
                  E.NOME_NACIONALIDADE || '(a)' AS NACIONALIDADE,
                  A.COD_NACIONALIDADE || ' - ' || E.NOME_NACIONALIDADE ||
                  '(a)' AS DES_NACIONALIDADE,
                  A.COD_RACA_COR,
                  B.NOME_RACA_COR AS DES_RACA_COR,
                  A.DATA_CHEG_BRASIL,
                  A.DATA_NATURALIZACAO,
                  A.NRO_CARTEIRA_ESTRANG,
                  A.NRO_TIT_DECLARATORIO,
                  A.CLASS_TRAB_ESTRANG,
                  A.INFO_COTA,
                  A.IDE_OC,
                  A.COND_ING,
                  A.COD_MUNIC_NASCIMENTO,
                  J2.COD_IBGE AS COD_IBGE_NASCTO,
                  A.COD_UF_NASCIMENTO,
                  A.COD_PAIS_NASCTO,
                  A.IND_REG_CONSELHO,
                  I.CEP AS COD_CEP,
                  I.TIPO_LOGRA,
                  I.COD_LOGRA,
                  I.NOME_LOGRA AS DES_LOGRA,
                  I.NUMERO,
                  I.COMPLEMENTO,
                  I.COD_BAIRRO,
                  I.NOME_BAIRRO AS DES_BAIRRO,
                  I.COD_MUNIC AS COD_CIDADE,
                  I.NOME_MUNIC AS DES_CIDADE,
                  I.COD_UF,
                  J1.COD_IBGE
    FROM RHFP0200 A
    LEFT JOIN RHFP0130 B
      ON A.COD_RACA_COR = B.COD_RACA_COR
    LEFT JOIN PESSOA_JURIDICA C
      ON A.COD_ORG_IDENTIDADE = C.COD_PESSOA
    LEFT JOIN RHFP0104 D
      ON A.COD_ESTADO_CIVIL = D.COD_ESTADO_CIVIL
    LEFT JOIN RHFP0107 E
      ON A.COD_NACIONALIDADE = E.COD_NACIONALIDADE
    LEFT JOIN RHFP0132 F
      ON A.COD_DEFICIENCIA = F.COD_DEFICIENCIA
    LEFT JOIN RHFP0105 G
      ON A.COD_GRAU_INSTRUCAO = G.COD_GRAU_INSTRUCAO
    LEFT JOIN PESSOA H1
      ON A.COD_PESSOA_PAI = H1.COD_PESSOA
    LEFT JOIN PESSOA H2
      ON A.COD_PESSOA_MAE = H2.COD_PESSOA
   INNER JOIN PESSOA_FISICA I
      ON A.COD_FUNC = I.COD_PESSOA
    LEFT JOIN MUNIBGE J1
      ON J1.COD_MUNIC = I.COD_MUNIC
    LEFT JOIN MUNIBGE J2
      ON J2.COD_MUNIC = A.COD_MUNIC_NASCIMENTO
    LEFT JOIN PESSOA_JURIDICA C1
      ON C1.COD_PESSOA = A.COD_ORGAO_HAB
),

/* =========================
   3) FUNCAO (1 LINHA CONTRATO)
   ========================= */
FUNCAO AS (
  SELECT *
  FROM (
    SELECT
      A.COD_CONTRATO,
      A.COD_CLH AS COD_FUNCAO,
      B.NOME_CLH,
      A.COD_CLH || ' - ' || B.NOME_CLH AS DES_FUNCAO,
      A.DATA_INICIO AS DATA_INICIO_CLH,
      A.DATA_FIM    AS DATA_FIM_CLH,
      ROW_NUMBER() OVER(
        PARTITION BY A.COD_CONTRATO
        ORDER BY
          CASE WHEN SYSDATE BETWEEN A.DATA_INICIO AND NVL(A.DATA_FIM, DATE '2999-12-31') THEN 1 ELSE 2 END,
          A.DATA_INICIO DESC,
          NVL(A.DATA_FIM, DATE '2999-12-31') DESC
      ) RN
    FROM RHFP0340 A
    JOIN RHFP0500 B ON B.COD_CLH = A.COD_CLH
    WHERE (SYSDATE BETWEEN A.DATA_INICIO AND NVL(A.DATA_FIM, DATE '2999-12-31')
           OR A.DATA_INICIO >= SYSDATE)
  )
  WHERE RN = 1
),


/* =========================
   4) TURNO / HORARIOS
   ========================= */
TURNO_BASE AS (
  SELECT *
  FROM (
    SELECT
      A.COD_CONTRATO,
      A.COD_TURNO,
      A.DATA_INICIO,
      A.DATA_FIM,
      ROW_NUMBER() OVER(
        PARTITION BY A.COD_CONTRATO
        ORDER BY
          CASE WHEN TRUNC(SYSDATE) BETWEEN A.DATA_INICIO AND NVL(A.DATA_FIM, DATE '2999-12-31') THEN 1 ELSE 2 END,
          A.DATA_INICIO DESC,
          NVL(A.DATA_FIM, DATE '2999-12-31') DESC
      ) RN
    FROM RHAF1119 A
    WHERE NVL(A.DATA_FIM, DATE '2999-12-31') >= TRUNC(SYSDATE)
  )
  WHERE RN = 1
),

HORAS_BASE AS (
  /* GARANTE 1 LINHA POR CONTRATO PARA HORAS BASE */
  SELECT *
    FROM (SELECT H.*,
                 ROW_NUMBER() OVER(PARTITION BY H.COD_CONTRATO ORDER BY H.DATA_INICIO DESC, NVL(H.DATA_FIM, DATE '2999-12-31') DESC) RN
            FROM V_HORAS_COLAB_AVT H)
   WHERE RN = 1
),

TURNO AS (
  SELECT TB.COD_CONTRATO,
         CASE
           WHEN TB.COD_TURNO IN (2, 85) THEN
            'N'
           ELSE
            'S'
         END AS IND_BATE_PONTO,
         TB.COD_TURNO,
         B.NOME_TURNO AS DES_TURNO,
         LTRIM(RTRIM(TRIM(TRAILING '.' FROM
                          TRIM(TRAILING '0' FROM
                               TO_CHAR(HB.QTD_HORBAS_MES, '9999999990.99'))))) AS HR_BASE_MES,
         LTRIM(RTRIM(TRIM(TRAILING '.' FROM
                          TRIM(TRAILING '0' FROM
                               TO_CHAR(HB.QTD_HORBAS_SEM, '9999999990.99'))))) AS HR_BASE_SEM,
         LTRIM(RTRIM(TRIM(TRAILING '.' FROM
                          TRIM(TRAILING '0' FROM
                               TO_CHAR(HB.QTD_HORBAS_DIA, '9999999990.99'))))) AS HR_BASE_DIA,
         HB.DATA_INICIO AS DATA_INICIO_HR,
         HB.DATA_FIM AS DATA_FIM_HR
    FROM TURNO_BASE TB
    LEFT JOIN RHAF1145 B
      ON B.COD_TURNO = TB.COD_TURNO
    LEFT JOIN HORAS_BASE HB
      ON HB.COD_CONTRATO = TB.COD_CONTRATO
),

HORARIOS AS (
  SELECT TB.COD_CONTRATO,
         TB.DATA_INICIO AS DATA_INICIO_HOR,
         TB.DATA_FIM AS DATA_FIM_HOR,
         TB.COD_TURNO,
         D.NOME_TURNO AS DES_TURNO,
         A.COD_MOTIVO,
         B.NOME_MOTIVO,
         A.TIPO_TURNO,
         DECODE(D.HORARIO_1_ENT,
                NULL,
                NULL,
                LPAD(RHYF0118(RHYF0117(D.HORARIO_1_ENT), 'S'), 5, '0')) AS HOR_1_ENT,
         DECODE(D.HORARIO_1_SAI,
                NULL,
                NULL,
                LPAD(RHYF0118(RHYF0117(D.HORARIO_1_SAI), 'S'), 5, '0')) AS HOR_1_SAI,
         DECODE(D.HORARIO_2_ENT,
                NULL,
                NULL,
                LPAD(RHYF0118(RHYF0117(D.HORARIO_2_ENT), 'S'), 5, '0')) AS HOR_2_ENT,
         DECODE(D.HORARIO_2_SAI,
                NULL,
                NULL,
                LPAD(RHYF0118(RHYF0117(D.HORARIO_2_SAI), 'S'), 5, '0')) AS HOR_2_SAI,
         DECODE(D.HORARIO_3_ENT,
                NULL,
                NULL,
                LPAD(RHYF0118(RHYF0117(D.HORARIO_3_ENT), 'S'), 5, '0')) AS HOR_3_ENT,
         DECODE(D.HORARIO_3_SAI,
                NULL,
                NULL,
                LPAD(RHYF0118(RHYF0117(D.HORARIO_3_SAI), 'S'), 5, '0')) AS HOR_3_SAI,
         DECODE(D.HORARIO_4_ENT,
                NULL,
                NULL,
                LPAD(RHYF0118(RHYF0117(D.HORARIO_4_ENT), 'S'), 5, '0')) AS HOR_4_ENT,
         DECODE(D.HORARIO_4_SAI,
                NULL,
                NULL,
                LPAD(RHYF0118(RHYF0117(D.HORARIO_4_SAI), 'S'), 5, '0')) AS HOR_4_SAI
    FROM TURNO_BASE TB
    JOIN RHAF1119 A
      ON A.COD_CONTRATO = TB.COD_CONTRATO
     AND A.COD_TURNO = TB.COD_TURNO
     AND A.DATA_INICIO = TB.DATA_INICIO
     AND NVL(A.DATA_FIM, DATE '2999-12-31') =
         NVL(TB.DATA_FIM, DATE '2999-12-31')
    LEFT JOIN RHFP0323 B
      ON A.COD_MOTIVO = B.COD_MOTIVO
    LEFT JOIN RHAF1145 D
      ON A.COD_TURNO = D.COD_TURNO
),

/* =========================
   5) SINDICATO / ORGANOGRAMA / RESPONSAVEL
   ========================= */
SINDICATO AS (
  SELECT *
    FROM (SELECT COD_CONTRATO,
                 COD_SINDICATO,
                 DES_SINDICATO,
                 IND_CONT_SINDICAL,
                 DATA_INICIO AS DATA_INI_SIND,
                 DATA_FIM AS DATA_FIM_SIND,
                 ROW_NUMBER() OVER(PARTITION BY COD_CONTRATO ORDER BY DATA_INICIO DESC) RN
            FROM V_SINDICATOS_CONTRATOS_AVT)
   WHERE RN = 1
),

ORGANOGRAMA AS (
  SELECT *
    FROM (SELECT ORG.*,
                 ROW_NUMBER() OVER(PARTITION BY ORG.COD_CONTRATO ORDER BY ORG.DATA_INI_ORG DESC) RN
            FROM VH_EST_ORG_CONTRATO_AVT ORG)
   WHERE RN = 1
),

RESPONSAVEL AS (
  SELECT COD_CONTRATO, MAX(IND_RESP_UNI) AS IND_RESP_UNI
    FROM V_SUPERIOR_IMEDIATO_AVT
   GROUP BY COD_CONTRATO
),

/* =========================
   6) LOTACAO
   ========================= */
LOTACAO AS (
  SELECT COD_CONTRATO,
         COD_LOTACAO,
         DES_LOTACAO,
         UNI_LOTACAO,
         DTA_INICIO_LOT,
         DTA_FIM_LOT
    FROM (SELECT A.COD_CONTRATO,
                 CASE
                   WHEN A.COD_LOTACAO IS NOT NULL THEN
                    A.COD_LOTACAO
                 END AS COD_LOTACAO,
                 CASE
                   WHEN A.COD_LOTACAO IS NOT NULL THEN
                    B.NOME_LOTACAO
                 END AS DES_LOTACAO,
                 CASE
                   WHEN A.COD_LOTACAO IS NOT NULL THEN
                    B.EDICAO_QL
                 END AS UNI_LOTACAO,
                 CASE
                   WHEN A.COD_LOTACAO IS NOT NULL THEN
                    A.DATA_INICIO
                 END AS DTA_INICIO_LOT,
                 CASE
                   WHEN A.COD_LOTACAO IS NOT NULL THEN
                    A.DATA_FIM
                 END AS DTA_FIM_LOT,
                 ROW_NUMBER() OVER(PARTITION BY A.COD_CONTRATO ORDER BY NVL(A.DATA_INICIO, DATE '1900-01-01') DESC, NVL(A.DATA_FIM, DATE '2999-12-31') DESC) RN
            FROM RHFP0309 A
            LEFT JOIN RHFP0509 B
              ON A.COD_LOTACAO = B.COD_LOTACAO)
   WHERE RN = 1
),

/* =========================
   7) AFASTAMENTOS
   ========================= */
AFASTAMENTOS AS (
  SELECT COD_CONTRATO,
         COD_AFAST,
         DES_AFAST,
         DATA_INI_AFAST,
         DATA_FIM_AFAST,
         COD_STATUS_AFAST,
         STATUS_AFAST
    FROM (SELECT AFAST.COD_CONTRATO,
                 AFAST.COD_CAUSA_AFAST AS COD_AFAST,
                 CASE
                   WHEN AFAST.COD_CAUSA_AFAST IS NOT NULL AND
                        AFAST.COD_CAUSA_AFAST <> 0 THEN
                    AFAST.COD_CAUSA_AFAST || ' - ' || AFAST.NOME_CAUSA_AFAST
                   ELSE
                    NULL
                 END AS DES_AFAST,
                 AFAST.DATA_INICIO AS DATA_INI_AFAST,
                 AFAST.DATA_FIM AS DATA_FIM_AFAST,
                 CASE
                   WHEN AFAST.COD_CAUSA_AFAST IS NULL OR
                        TRIM(TO_CHAR(AFAST.COD_CAUSA_AFAST)) IS NULL THEN
                    0
                   ELSE
                    AFAST.COD_CAUSA_AFAST
                 END AS COD_STATUS_AFAST,
                 CASE
                   WHEN CT.DATA_FIM IS NOT NULL AND CT.DATA_FIM < SYSDATE THEN
                    'INATIVO'
                   WHEN AFAST.COD_CAUSA_AFAST <> 0 AND
                        AFAST.COD_CAUSA_AFAST NOT IN (4, 21, 60) AND
                        AFAST.DATA_FIM = DATE '2999-12-31' THEN
                    'AFASTADO'
                   WHEN AFAST.COD_CAUSA_AFAST IN (21, 60) THEN
                    'ATIVO, SEM RETORNO'
                   WHEN AFAST.COD_CAUSA_AFAST = 7 THEN
                    'EM FÉRIAS'
                   WHEN AFAST.COD_CAUSA_AFAST IN (3, 6) THEN
                    'AFASTADO TEMP'
                   WHEN AFAST.COD_CAUSA_AFAST = 4 AND AFAST.DATA_FIM = DATE
                    '2999-12-31' THEN
                    'PODERÁ RETORNAR'
                   ELSE
                    'EM ATIVIDADE'
                 END AS STATUS_AFAST,
                 ROW_NUMBER() OVER(PARTITION BY AFAST.COD_CONTRATO ORDER BY AFAST.DATA_INICIO DESC) RN
            FROM V_AFAST_COLAB_AVT AFAST
            JOIN RHFP0300 CT
              ON AFAST.COD_CONTRATO = CT.COD_CONTRATO)
   WHERE RN = 1
),

/* =========================
   8) FERIAS (1 LINHA POR CONTRATO)
   ========================= */
FERIAS AS (
  SELECT *
    FROM (SELECT COD_CONTRATO,
                 DATA_PREVISTA_FERIAS,
                 DATA_FERIAS,
                 DATA_RETORNO,
                 ROW_NUMBER() OVER(PARTITION BY COD_CONTRATO ORDER BY DATA_PREVISTA_FERIAS) RN
            FROM VH_PROGRAMACAO_FERIAS_AVT
           WHERE IND_FERIAS = 0)
   WHERE RN = 1
),

/* =========================
   9) DADOS ANTERIORES
   ========================= */
CARGO_ANT AS (
  SELECT COD_CONTRATO,
         COD_CLH_ANT,
         DES_CLH_ANT,
         DATA_INICIO_ANT,
         DATA_FIM_ANT
    FROM (SELECT CC.COD_CONTRATO,
                 CC.COD_CLH_ANT,
                 CC.DES_CLH_ANT,
                 CC.DATA_INICIO_ANT,
                 CC.DATA_FIM_ANT,
                 ROW_NUMBER() OVER(PARTITION BY CC.COD_CONTRATO ORDER BY CC.DATA_INICIO_ANT DESC) RN
            FROM V_CARGO_CONTRATO_AVT CC)
   WHERE RN = 1
),

ORGANOGRAMA_ANT AS (
  SELECT COD_CONTRATO,
         EDICAO_ORG_ANT,
         DES_ORGANOGRAMA_ANT,
         DATA_INICIO_ORG_ANT,
         DATA_FIM_ORG_ANT
    FROM (SELECT CO.COD_CONTRATO,
                 CO.EDICAO_ORG_ANT,
                 CO.DES_ORGANOGRAMA_ANT,
                 CO.DATA_INICIO_ORG_ANT,
                 CO.DATA_FIM_ORG_ANT,
                 ROW_NUMBER() OVER(PARTITION BY CO.COD_CONTRATO ORDER BY CO.DATA_INICIO_ORG_ANT DESC) RN
            FROM V_ORGANOGRAMA_CONTRATO_AVT CO)
   WHERE RN = 1
)

/* =========================
   SELECT FINAL
   ========================= */
SELECT
      /* DADOS DO CONTRATO */
       CT.COD_PESSOA,
       CT.COD_CONTRATO,
       CT.DES_PESSOA,
       CT.DES_PESSOA_ABREV,
       CT.PRIMEIRO_NOME,
       CT.SEGUNDO_NOME,
       CT.SOBRENOME,
       CT.DATA_AVANCO,
       CT.DATA_ADMISSAO,
       CT.DATA_DEMISSAO,
       CT.COD_DEMISSAO,
       CT.DES_DEMISSAO,
       CT.NRO_CONTA_PGTO,
       CT.COD_AGE_PGTO,
       CT.CONTA_BANCARIA,
       CT.COD_BANCO,
       CT.DES_BANCO,
       CT.COD_BCO_FGTD,
       CT.COD_AGE_FGTS,
       CT.NRO_CONTA_FGTS,
       CT.DATA_OPCAO_FGTS,
       CT.NUM_FICHA_REGISTRO,
       CT.COD_MOTIVO,
       CT.DES_MOTIVO,
       CT.STATUS,
       CT.DESC_STATUS,
       
       FU.COD_FUNCAO,
       FU.NOME_CLH,
       FU.DES_FUNCAO,
       FU.DATA_INICIO_CLH,
       FU.DATA_FIM_CLH,
       
       CT.COD_VINCULO_EMPREG,
       CT.COD_CATEGORIA_TRAB,
       CT.COD_ESOCIAL,
       
       TU.IND_BATE_PONTO,
       TU.COD_TURNO,
       TU.DES_TURNO,
       TU.HR_BASE_MES,
       TU.HR_BASE_SEM,
       TU.HR_BASE_DIA,
       TU.DATA_INICIO_HR,
       TU.DATA_FIM_HR,
       
       HR.DATA_INICIO_HOR,
       HR.DATA_FIM_HOR,
       HR.HOR_1_ENT,
       HR.HOR_1_SAI,
       HR.HOR_2_ENT,
       HR.HOR_2_SAI,
       HR.HOR_3_ENT,
       HR.HOR_3_SAI,
       HR.HOR_4_ENT,
       HR.HOR_4_SAI,
       
       SI.COD_SINDICATO,
       SI.DES_SINDICATO,
       SI.IND_CONT_SINDICAL,
       SI.DATA_INI_SIND,
       SI.DATA_FIM_SIND,
       
       /* DADOS DO ORGANOGRAMA */
       ORG.COD_ORGANOGRAMA,
       ORG.COD_UNIDADE,
       ORG.DES_UNIDADE,
       ORG.DATA_INI_ORG,
       ORG.DATA_FIM_ORG,
       RESP.IND_RESP_UNI,
       ORG.COD_REDE        AS COD_REDE_LOCAL,
       ORG.DES_REDE        AS DES_REDE_LOCAL,
       ORG.COD_UF          AS COD_UF_ORG,
       
       ORG.COD_ORG_1    AS COD_GRUPO_EMP,
       ORG.EDICAO_ORG_1 AS EDICAO_GRUPO_EMP,
       ORG.NOME1        AS DES_GRUPO_EMP,
       ORG.COD_ORG_2    AS COD_EMP,
       ORG.EDICAO_ORG_2 AS EDICAO_EMP,
       ORG.NOME2        AS DES_EMPRESA,
       ORG.COD_ORG_3    AS COD_ORG_FILIAL,
       ORG.EDICAO_ORG_3 AS EDICAO_FILIAL,
       ORG.NOME3        AS DES_FILIAL,
       ORG.COD_ORG_4    AS COD_ORG_DIVISAO,
       ORG.EDICAO_ORG_4 AS EDICAO_DIVISAO,
       ORG.NOME4        AS DES_DIVISAO,
       ORG.COD_ORG_5    AS COD_ORG_DEPART,
       ORG.EDICAO_ORG_5 AS EDICAO_DEPART,
       ORG.NOME5        AS DES_DEPART,
       ORG.COD_ORG_6    AS COD_ORG_SETOR,
       ORG.EDICAO_ORG_6 AS EDICAO_SETOR,
       ORG.NOME6        AS DES_SETOR,
       ORG.COD_ORG_7    AS COD_ORG_SECAO,
       ORG.EDICAO_ORG_7 AS EDICAO_SECAO,
       ORG.NOME7        AS DES_SECAO,
       ORG.COD_ORG_8    AS COD_ORG_UNI,
       ORG.EDICAO_ORG_8 AS EDICAO_UNI,
       ORG.NOME8        AS DES_UNI,
       ORG.COD_TIPO,
       ORG.DES_TIPO,
       
       /* LOTAÇÃO */
       LOT.COD_LOTACAO,
       LOT.DES_LOTACAO,
       LOT.UNI_LOTACAO,
       LOT.DTA_INICIO_LOT,
       LOT.DTA_FIM_LOT,
       
       /* DADOS PESSOAIS */
       DP.DATA_NASCIMENTO,
       DP.IDADE,
       DP.SEXO,
       DP.COD_EST_CIVIL,
       DP.DES_EST_CIVIL,
       DP.COD_PESSOA_PAI,
       DP.DES_PAI,
       DP.COD_PESSOA_MAE,
       DP.DES_MAE,
       DP.IND_DEFICIENCIA,
       DP.COD_DEFICIENCIA,
       DP.DES_DEFICIENCIA,
       DP.DES_EMAIL,
       DP.DES_EMAIL_ALTER,
       DP.COD_DDD,
       DP.FONE_CEL,
       DP.CPF,
       DP.NRO_IDENTIDADE,
       DP.EMISSOR_RG,
       DP.UF_RG,
       DP.EMISSOR,
       DP.DATA_EMI_IDENTIDADE,
       DP.NRO_PIS_PASEP,
       DP.DATA_PIS_PASEP,
       DP.NRO_CTPS,
       DP.NRO_SERIE_CTPS,
       DP.CTPS,
       DP.DATA_EXP_CTPS,
       DP.COD_UF_CTPS,
       DP.COD_TIPO_APOSENT,
       DP.NRO_BENEFICIO_INSS,
       DP.DATA_APOSENTADORIA,
       DP.NRO_TITULO,
       DP.NRO_ZONA_TITULO,
       DP.NRO_SECAO_TITULO,
       DP.DATA_EMISSAO_TITULO,
       DP.COD_UF_TITULO,
       DP.COD_MUN_TITULO,
       DP.NRO_HABILITACAO,
       DP.DATA_EMISSAO_HAB,
       DP.DATA_VALIDADE_HAB,
       DP.COD_CATEGORIA_HAB,
       DP.COD_ORGAO_HAB,
       DP.DES_ORGAO_HAB,
       DP.NRO_RESERVISTA,
       DP.SERVICO_MILITAR,
       DP.COD_INSTRUCAO,
       DP.DES_INSTRUCAO,
       DP.COD_NACIONALIDADE,
       DP.NACIONALIDADE,
       DP.DES_NACIONALIDADE,
       DP.COD_RACA_COR,
       DP.DES_RACA_COR,
       DP.DATA_CHEG_BRASIL,
       DP.DATA_NATURALIZACAO,
       DP.NRO_CARTEIRA_ESTRANG,
       DP.NRO_TIT_DECLARATORIO,
       DP.CLASS_TRAB_ESTRANG,
       DP.INFO_COTA,
       DP.IDE_OC,
       DP.COND_ING,
       DP.COD_MUNIC_NASCIMENTO,
       DP.COD_IBGE_NASCTO,
       DP.COD_UF_NASCIMENTO,
       DP.COD_PAIS_NASCTO,
       DP.IND_REG_CONSELHO,
       DP.COD_CEP,
       DP.TIPO_LOGRA,
       DP.COD_LOGRA,
       DP.DES_LOGRA,
       DP.NUMERO,
       DP.COMPLEMENTO,
       DP.COD_BAIRRO,
       DP.DES_BAIRRO,
       DP.COD_CIDADE,
       DP.DES_CIDADE,
       DP.COD_UF,
       DP.COD_IBGE,
       
       /* AFASTAMENTOS / FERIAS */
       AF.COD_AFAST,
       AF.DES_AFAST,
       AF.DATA_INI_AFAST,
       AF.DATA_FIM_AFAST,
       AF.COD_STATUS_AFAST,
       CASE
         WHEN AF.STATUS_AFAST IS NULL THEN
          'EM ATIVIDADE'
         ELSE
          AF.STATUS_AFAST
       END AS STATUS_AFAST,
       
       FER.DATA_PREVISTA_FERIAS,
       FER.DATA_FERIAS,
       FER.DATA_RETORNO,
       
       /* ANTERIORES */
       'DADOS ANTERIORES DO CONTRATO =>' AS ESPACO,
       
       CC.COD_CLH_ANT     AS COD_FUNCAO_ANT,
       CC.DES_CLH_ANT     AS DES_FUNCAO_ANT,
       CC.DATA_INICIO_ANT,
       CC.DATA_FIM_ANT,
       
       CO.EDICAO_ORG_ANT      AS COD_UNIDADE_ANT,
       CO.DES_ORGANOGRAMA_ANT AS DES_UNIDADE_ANT,
       CO.DATA_INICIO_ORG_ANT,
       CO.DATA_FIM_ORG_ANT

        FROM CONTRATOS_FILTRADO CT
        LEFT JOIN DADOS_PESSOAIS DP
          ON CT.COD_PESSOA = DP.COD_FUNC
        LEFT JOIN FUNCAO FU
          ON CT.COD_CONTRATO = FU.COD_CONTRATO
        LEFT JOIN TURNO TU
          ON CT.COD_CONTRATO = TU.COD_CONTRATO
        LEFT JOIN HORARIOS HR
          ON CT.COD_CONTRATO = HR.COD_CONTRATO
        LEFT JOIN SINDICATO SI
          ON CT.COD_CONTRATO = SI.COD_CONTRATO
       INNER JOIN ORGANOGRAMA ORG
          ON CT.COD_CONTRATO = ORG.COD_CONTRATO
        LEFT JOIN RESPONSAVEL RESP
          ON CT.COD_CONTRATO = RESP.COD_CONTRATO
        LEFT JOIN LOTACAO LOT
          ON CT.COD_CONTRATO = LOT.COD_CONTRATO
        LEFT JOIN AFASTAMENTOS AF
          ON CT.COD_CONTRATO = AF.COD_CONTRATO
        LEFT JOIN FERIAS FER
          ON CT.COD_CONTRATO = FER.COD_CONTRATO
        LEFT JOIN CARGO_ANT CC
          ON CT.COD_CONTRATO = CC.COD_CONTRATO
        LEFT JOIN ORGANOGRAMA_ANT CO
          ON CT.COD_CONTRATO = CO.COD_CONTRATO
;
