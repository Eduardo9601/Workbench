/* === SQL DO PONTO ===
   CHECKPOINT 01 | PONTO HCM | APURACAO DIARIA (VERSAO DE VALIDACAO)
   SOMENTE LEITURA: sem CREATE VIEW / INSERT / UPDATE / DELETE.
   Uma linha por empresa + tipo + cadastro + dia, inclusive dias sem registro.

   PARAMETROS: :P_CADASTRO (0 = todos), :P_DATA_INICIO, :P_DATA_FIM
   Empresa: 8 (alterar no CTE PARAMS se necessario).

   IMPORTANTE - LEIA ANTES DE HOMOLOGAR
   A) 1 e 513 sao situacoes CONFERIDAS NA TELA ENVIADA PELO USUARIO;
      demais classes por descricao/tipo sao PROVISORIAS, nunca oficiais.
   B) QTDHOR: MODO_QTDHOR = 1 assume MINUTOS BRUTOS (528 -> 08:48);
      MODO_QTDHOR = 2 assume HHMM numérico (848 -> 08:48).
      VALIDAR valor bruto com consulta 02 antes de interpretar os valores!
   C) HorAcc e minutos desde meia-noite (conforme consulta original).
   D) Um turno noturno, marcações impares e pausas sem marcação
      exigem conferência. Nao inventar marcacoes a partir da escala.
   E) MIN_REALIZADAS_APURADAS = NORMAL + EXTRA.
      MIN_SALDO_DEMONSTRATIVO = REALIZADAS - ATRASO - FALTA - ATESTADO.
      NUNCA confundir saldo com horas trabalhadas: pode haver dupla subtracao!
   F) R070ACC e R066SIT podem registrar periodos ainda nao apurados;
      vazio nao e zero. STATUS_CONFERENCIA discrimina.
   =========================================================================== */
WITH
PARAMS AS (
    SELECT 8 AS EMPRESA,
           NVL(TO_NUMBER(:P_CADASTRO), 0) AS CADASTRO,
           TRUNC(CAST(:P_DATA_INICIO AS DATE)) AS D_INI,
           TRUNC(CAST(:P_DATA_FIM AS DATE)) AS D_FIM,
           1 AS MODO_QTDHOR
      FROM DUAL
),

DIAS AS (
    SELECT P.D_INI + LEVEL - 1 AS DATA_APURACAO
      FROM PARAMS P
   CONNECT BY LEVEL <= P.D_FIM - P.D_INI + 1
),

/* Limita a criacao de dias aos vinculos que cruzam o periodo consultado.
   Contratos DEMITIDOS sem data conhecida merecem auditoria antes de uso amplo. */
RESCISOES AS (
    SELECT R.NUMEMP, R.TIPCOL, R.NUMCAD, MAX(R.DATDEM) AS DAT_DEMISSAO
      FROM R042RCM R
      JOIN PARAMS P
        ON P.EMPRESA = R.NUMEMP
     GROUP BY R.NUMEMP, R.TIPCOL, R.NUMCAD
),

COLABORADORES AS (
    SELECT F.NUMEMP,
           F.TIPCOL,
           F.NUMCAD,
           F.NOMFUN,
           F.DATADM,
           F.SITAFA AS SITUACAO_ATUAL,
           R.DAT_DEMISSAO
      FROM R034FUN F
      JOIN PARAMS P
        ON P.EMPRESA = F.NUMEMP
      LEFT JOIN RESCISOES R
        ON R.NUMEMP = F.NUMEMP
       AND R.TIPCOL = F.TIPCOL
       AND R.NUMCAD = F.NUMCAD
     WHERE (P.CADASTRO = 0 OR F.NUMCAD = P.CADASTRO)
       AND F.DATADM < P.D_FIM + 1
       AND (R.DAT_DEMISSAO IS NULL OR R.DAT_DEMISSAO >= P.D_INI)
),

UNIVERSO_DIAS AS (
    SELECT C.NUMEMP,
           C.TIPCOL,
           C.NUMCAD,
           C.NOMFUN,
           D.DATA_APURACAO,
           C.SITUACAO_ATUAL,
           C.DAT_DEMISSAO
      FROM COLABORADORES C
     CROSS JOIN DIAS D
     WHERE C.DATADM < D.DATA_APURACAO + 1
       AND (C.DAT_DEMISSAO IS NULL OR C.DAT_DEMISSAO >= D.DATA_APURACAO)
),

/* Marcações do ponto: nao limitar ORIACC='E', pois podem existir
   geradas, digitadas ou regularizadas. Filtros de ignoradas seguem a
   consulta fornecida e precisam ser auditados com a consulta 03. */
MARCACOES_BASE AS (
    SELECT A.NUMEMP,
           A.TIPCOL,
           A.NUMCAD,
           TRUNC(A.DATAPU) DATA_APURACAO,
           A.DATACC,
           A.HORACC,
           A.SEQACC,
           A.NUMNSR,
           A.ORIACC,
           A.CODRLG,
           A.USOMAR,
           ROW_NUMBER() OVER (PARTITION BY A.NUMEMP, A.TIPCOL, A.NUMCAD, TRUNC(A.DATAPU) ORDER BY A.DATACC NULLS LAST, A.HORACC, A.SEQACC, A.NUMNSR) RN
     FROM R070ACC A
      JOIN PARAMS P
        ON A.NUMEMP = P.EMPRESA
     WHERE A.NUMCAD > 0
       AND (P.CADASTRO = 0 OR A.NUMCAD = P.CADASTRO)
       AND A.DATAPU >= P.D_INI
       AND A.DATAPU < P.D_FIM + 1
       AND A.DATAPU <> DATE '1900-12-31'
       AND NVL(A.MOTIGN, 0) = 0
       AND NVL(A.EXCPON, 'N') = 'N'
),

MARCACOES_PARES AS (
    SELECT B.*,
           LEAD(B.DATACC) OVER (PARTITION BY B.NUMEMP, B.TIPCOL, B.NUMCAD, B.DATA_APURACAO ORDER BY B.RN) PROX_DATA,
           LEAD(B.HORACC) OVER (PARTITION BY B.NUMEMP, B.TIPCOL, B.NUMCAD, B.DATA_APURACAO ORDER BY B.RN) PROX_HORA
      FROM MARCACOES_BASE B
),

MARCACOES_DIA AS (
    SELECT M.NUMEMP,
           M.TIPCOL,
           M.NUMCAD,
           M.DATA_APURACAO,
           COUNT(*) QTD_MARCACOES,
           MAX(CASE
                 WHEN M.RN = 1 THEN
                  M.HORACC
               END) ENT1_MIN_RELOGIO,
           MAX(CASE
                 WHEN M.RN = 2 THEN
                  M.HORACC
               END) SAI1_MIN_RELOGIO,
           MAX(CASE
                 WHEN M.RN = 3 THEN
                  M.HORACC
               END) ENT2_MIN_RELOGIO,
           MAX(CASE
                 WHEN M.RN = 4 THEN
                  M.HORACC
               END) SAI2_MIN_RELOGIO,
           MAX(CASE
                 WHEN M.RN = 1 THEN
                  M.ORIACC
               END) ORIGEM_ENT1,
           MAX(CASE
                 WHEN M.RN = 2 THEN
                  M.ORIACC
               END) ORIGEM_SAI1,
           MAX(CASE
                 WHEN M.RN = 3 THEN
                  M.ORIACC
               END) ORIGEM_ENT2,
           MAX(CASE
                 WHEN M.RN = 4 THEN
                  M.ORIACC
               END) ORIGEM_SAI2,
           SUM(CASE
                 WHEN MOD(M.RN, 2) = 1 AND M.PROX_HORA IS NOT NULL AND
                      M.DATACC IS NOT NULL AND M.PROX_DATA IS NOT NULL AND
                      ((TRUNC(M.PROX_DATA) - TRUNC(M.DATACC)) * 1440 +
                       M.PROX_HORA - M.HORACC) BETWEEN 0 AND 1440 THEN
                  (TRUNC(M.PROX_DATA) - TRUNC(M.DATACC)) * 1440 + M.PROX_HORA -
                  M.HORACC
                 ELSE
                  0
               END) AS MIN_PRESENCA_PARES,
           SUM(CASE
                 WHEN MOD(M.RN, 2) = 1 AND M.PROX_HORA IS NOT NULL AND
                      (M.DATACC IS NULL OR M.PROX_DATA IS NULL OR
                       ((TRUNC(M.PROX_DATA) - TRUNC(M.DATACC)) * 1440 +
                       M.PROX_HORA - M.HORACC) NOT BETWEEN 0 AND 1440) THEN
                  1
                 ELSE
                  0
               END) AS PARES_INVALIDOS,
           LISTAGG(LPAD(TRUNC(M.HORACC / 60), 2, '0') || ':' ||
                   LPAD(MOD(M.HORACC, 60), 2, '0') || ' (' ||
                   NVL(M.ORIACC, '?') || ')',
                   ' | ') WITHIN GROUP(ORDER BY M.RN) AS TODAS_MARCACOES
      FROM MARCACOES_PARES M
     GROUP BY M.NUMEMP, M.TIPCOL, M.NUMCAD, M.DATA_APURACAO
),

/* NÃO existe um mapeamento oficial de situacoes neste checkpoint.
   Confirmados pelo print: 1 = Trabalhando; 513 = Horas extras 60% BH.
   Demais classes inferidas por TIPO/DESCRICAO ficam marcadas provisórias.
   Banco de horas (sem a palavra EXTRA) nao e somado a extras automaticamente. */
SITUACOES_BASE AS (
    SELECT S.NUMEMP,
           S.TIPCOL,
           S.NUMCAD,
           TRUNC(S.DATAPU) DATA_APURACAO,
           S.CODSIT,
           S.MOTSIT,
           S.QTDHOR AS QTDHOR_BRUTO,
           C.TIPSIT,
           C.DESSIT,
           C.CONABS,
           UPPER(TRANSLATE(NVL(C.DESSIT, ' '),
                           'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                           'AAAAAEEEEIIIIOOOOOUUUUC')) DES_NORMALIZADA,
           P.MODO_QTDHOR
      FROM SENIOR_RH.R066SIT S
      JOIN PARAMS P
        ON P.EMPRESA = S.NUMEMP
      LEFT JOIN SENIOR_RH.R010SIT C
        ON C.CODSIT = S.CODSIT
     WHERE S.DATAPU >= P.D_INI
       AND S.DATAPU < P.D_FIM + 1
       AND (P.CADASTRO = 0 OR S.NUMCAD = P.CADASTRO)
       
),

SITUACOES_CLASSIFICADAS AS (
    SELECT S.*,
           CASE
             WHEN S.MODO_QTDHOR = 1 THEN
              S.QTDHOR_BRUTO
             WHEN S.MODO_QTDHOR = 2 THEN
              TRUNC(S.QTDHOR_BRUTO / 100) * 60 + MOD(S.QTDHOR_BRUTO, 100)
           END AS MINUTOS_SITUACAO,
           CASE
             WHEN S.CODSIT = 1 THEN
              'NORMAL'
             WHEN S.CODSIT = 513 THEN
              'EXTRA'
             WHEN S.TIPSIT = 16 THEN
              'EXTRA'
             WHEN S.DES_NORMALIZADA LIKE '%HORA%EXTRA%' THEN
              'EXTRA'
             WHEN S.DES_NORMALIZADA LIKE '%ATEST%' OR
                  S.DES_NORMALIZADA LIKE '%LICENCA MEDIC%' OR
                  S.DES_NORMALIZADA LIKE '%AFASTAMENTO MEDIC%' THEN
              'ATESTADO'
             WHEN S.DES_NORMALIZADA LIKE '%ATRAS%' OR
                  S.DES_NORMALIZADA LIKE '%SAIDA ANTECIP%' THEN
              'ATRASO'
             WHEN S.DES_NORMALIZADA LIKE '%FALTA%' THEN
              'FALTA'
             WHEN TRIM(S.DES_NORMALIZADA) IN
                  ('TRABALHANDO', 'TRABALHO', 'HORAS TRABALHADAS') THEN
              'NORMAL'
             ELSE
              'OUTRA'
           END AS CLASSE,
           CASE
             WHEN S.CODSIT IN (1, 513) THEN
              'CODIGO_CONFIRMADO_TELA'
             WHEN S.DESSIT IS NULL THEN
              'SEM_CADASTRO_SITUACAO'
             ELSE
              'PROVISORIO_DESCRICAO_OU_TIPO'
           END AS FONTE_CLASSE
      FROM SITUACOES_BASE S
),

APURACAO_DIA AS (
    SELECT S.NUMEMP,
           S.TIPCOL,
           S.NUMCAD,
           S.DATA_APURACAO,
           COUNT(*) AS QTD_LINHAS_APURACAO,
           SUM(CASE
                 WHEN S.CLASSE = 'NORMAL' THEN
                  S.MINUTOS_SITUACAO
                 ELSE
                  0
               END) MIN_NORMAL,
           SUM(CASE
                 WHEN S.CLASSE = 'EXTRA' THEN
                  S.MINUTOS_SITUACAO
                 ELSE
                  0
               END) MIN_EXTRA,
           SUM(CASE
                 WHEN S.CLASSE = 'ATRASO' THEN
                  S.MINUTOS_SITUACAO
                 ELSE
                  0
               END) MIN_ATRASO,
           SUM(CASE
                 WHEN S.CLASSE = 'FALTA' THEN
                  S.MINUTOS_SITUACAO
                 ELSE
                  0
               END) MIN_FALTA,
           SUM(CASE
                 WHEN S.CLASSE = 'ATESTADO' THEN
                  S.MINUTOS_SITUACAO
                 ELSE
                  0
               END) MIN_ATESTADO,
           SUM(CASE
                 WHEN S.CLASSE = 'OUTRA' THEN
                  S.MINUTOS_SITUACAO
                 ELSE
                  0
               END) MIN_OUTRAS,
           SUM(CASE
                 WHEN S.FONTE_CLASSE <> 'CODIGO_CONFIRMADO_TELA' THEN
                  1
                 ELSE
                  0
               END) SITUACOES_A_VALIDAR,
           SUM(CASE
                 WHEN S.CLASSE = 'OUTRA' THEN
                  1
                 ELSE
                  0
               END) SITUACOES_OUTRAS,
           LISTAGG(TO_CHAR(S.CODSIT) || ' ' ||
                   NVL(S.DESSIT, 'SEM DESCRICAO') || ' [' || S.CLASSE || ']',
                   ' | ') WITHIN GROUP(ORDER BY S.CODSIT, S.MOTSIT) SITUACOES_DO_DIA
      FROM SITUACOES_CLASSIFICADAS S
     GROUP BY S.NUMEMP, S.TIPCOL, S.NUMCAD, S.DATA_APURACAO
),

BASE_FINAL AS (
    SELECT U.NUMEMP,
           U.TIPCOL,
           U.NUMCAD,
           U.NOMFUN,
           U.DATA_APURACAO,
           U.SITUACAO_ATUAL,
           U.DAT_DEMISSAO,
           M.QTD_MARCACOES,
           M.ENT1_MIN_RELOGIO,
           M.SAI1_MIN_RELOGIO,
           M.ENT2_MIN_RELOGIO,
           M.SAI2_MIN_RELOGIO,
           M.ORIGEM_ENT1,
           M.ORIGEM_SAI1,
           M.ORIGEM_ENT2,
           M.ORIGEM_SAI2,
           M.TODAS_MARCACOES,
           M.MIN_PRESENCA_PARES,
           M.PARES_INVALIDOS,
           A.QTD_LINHAS_APURACAO,
           A.MIN_NORMAL,
           A.MIN_EXTRA,
           A.MIN_ATRASO,
           A.MIN_FALTA,
           A.MIN_ATESTADO,
           A.MIN_OUTRAS,
           A.SITUACOES_A_VALIDAR,
           A.SITUACOES_OUTRAS,
           A.SITUACOES_DO_DIA,
           CASE
             WHEN A.QTD_LINHAS_APURACAO > 0 THEN
              A.MIN_NORMAL + A.MIN_EXTRA
           END MIN_REALIZADAS_APURADAS,
           CASE
             WHEN A.QTD_LINHAS_APURACAO > 0 THEN
              A.MIN_NORMAL + A.MIN_EXTRA - A.MIN_ATRASO - A.MIN_FALTA -
              A.MIN_ATESTADO
           END MIN_SALDO_DEMONSTRATIVO
      FROM UNIVERSO_DIAS U
      LEFT JOIN MARCACOES_DIA M
        ON M.NUMEMP = U.NUMEMP
       AND M.TIPCOL = U.TIPCOL
       AND M.NUMCAD = U.NUMCAD
       AND M.DATA_APURACAO = U.DATA_APURACAO
      LEFT JOIN APURACAO_DIA A
        ON A.NUMEMP = U.NUMEMP
       AND A.TIPCOL = U.TIPCOL
       AND A.NUMCAD = U.NUMCAD
       AND A.DATA_APURACAO = U.DATA_APURACAO
)

SELECT B.NUMEMP AS COD_EMPRESA,
       B.TIPCOL AS TIPO_COLABORADOR,
       B.NUMCAD AS CADASTRO,
       B.NOMFUN AS NOME,
       B.DATA_APURACAO,
       CASE
         WHEN B.ENT1_MIN_RELOGIO IS NOT NULL THEN
          LPAD(TRUNC(B.ENT1_MIN_RELOGIO / 60), 2, '0') || ':' ||
          LPAD(MOD(B.ENT1_MIN_RELOGIO, 60), 2, '0')
       END AS ENTRADA_1,
       CASE
         WHEN B.SAI1_MIN_RELOGIO IS NOT NULL THEN
          LPAD(TRUNC(B.SAI1_MIN_RELOGIO / 60), 2, '0') || ':' ||
          LPAD(MOD(B.SAI1_MIN_RELOGIO, 60), 2, '0')
       END AS SAIDA_1,
       CASE
         WHEN B.ENT2_MIN_RELOGIO IS NOT NULL THEN
          LPAD(TRUNC(B.ENT2_MIN_RELOGIO / 60), 2, '0') || ':' ||
          LPAD(MOD(B.ENT2_MIN_RELOGIO, 60), 2, '0')
       END AS ENTRADA_2,
       CASE
         WHEN B.SAI2_MIN_RELOGIO IS NOT NULL THEN
          LPAD(TRUNC(B.SAI2_MIN_RELOGIO / 60), 2, '0') || ':' ||
          LPAD(MOD(B.SAI2_MIN_RELOGIO, 60), 2, '0')
       END AS SAIDA_2,
       B.ORIGEM_ENT1,
       B.ORIGEM_SAI1,
       B.ORIGEM_ENT2,
       B.ORIGEM_SAI2,
       NVL(B.QTD_MARCACOES, 0) AS QTD_MARCACOES,
       B.TODAS_MARCACOES,
       B.MIN_PRESENCA_PARES AS MIN_PRESENCA_PARES,
       B.MIN_NORMAL,
       B.MIN_EXTRA,
       B.MIN_ATRASO,
       B.MIN_FALTA,
       B.MIN_ATESTADO,
       B.MIN_OUTRAS,
       B.MIN_REALIZADAS_APURADAS AS MIN_TOTAL_REALIZADO,
       B.MIN_SALDO_DEMONSTRATIVO AS MIN_SALDO_AJUSTADO,
       /* FORMATACAO DE DURACOES; NULO = APURACAO NAO ENCONTRADA, NAO ZERO. */
       CASE
         WHEN B.MIN_PRESENCA_PARES IS NOT NULL THEN
          TRUNC(B.MIN_PRESENCA_PARES / 60) || ':' ||
          LPAD(MOD(B.MIN_PRESENCA_PARES, 60), 2, '0')
       END AS PRESENCA_HHMM,
       CASE
         WHEN B.MIN_NORMAL IS NOT NULL THEN
          TRUNC(B.MIN_NORMAL / 60) || ':' ||
          LPAD(MOD(B.MIN_NORMAL, 60), 2, '0')
       END AS NORMAL_HHMM,
       CASE
         WHEN B.MIN_EXTRA IS NOT NULL THEN
          TRUNC(B.MIN_EXTRA / 60) || ':' ||
          LPAD(MOD(B.MIN_EXTRA, 60), 2, '0')
       END AS EXTRA_HHMM,
       CASE
         WHEN B.MIN_ATRASO IS NOT NULL THEN
          TRUNC(B.MIN_ATRASO / 60) || ':' ||
          LPAD(MOD(B.MIN_ATRASO, 60), 2, '0')
       END AS ATRASO_HHMM,
       CASE
         WHEN B.MIN_FALTA IS NOT NULL THEN
          TRUNC(B.MIN_FALTA / 60) || ':' ||
          LPAD(MOD(B.MIN_FALTA, 60), 2, '0')
       END AS FALTA_HHMM,
       CASE
         WHEN B.MIN_ATESTADO IS NOT NULL THEN
          TRUNC(B.MIN_ATESTADO / 60) || ':' ||
          LPAD(MOD(B.MIN_ATESTADO, 60), 2, '0')
       END AS ATESTADO_HHMM,
       CASE
         WHEN B.MIN_REALIZADAS_APURADAS IS NOT NULL THEN
          TRUNC(B.MIN_REALIZADAS_APURADAS / 60) || ':' ||
          LPAD(MOD(B.MIN_REALIZADAS_APURADAS, 60), 2, '0')
       END AS REALIZADAS_HHMM,
       CASE
         WHEN B.MIN_SALDO_DEMONSTRATIVO IS NOT NULL THEN
          CASE
            WHEN B.MIN_SALDO_DEMONSTRATIVO < 0 THEN
             '-'
          END || TRUNC(ABS(B.MIN_SALDO_DEMONSTRATIVO) / 60) || ':' ||
          LPAD(MOD(ABS(B.MIN_SALDO_DEMONSTRATIVO), 60), 2, '0')
       END AS SALDO_AJUSTADO_HHMM,
       CASE
         WHEN B.SITUACAO_ATUAL = 7 AND B.DAT_DEMISSAO IS NULL THEN
          'PENDENTE_DATA_DEMISSAO'
         WHEN B.QTD_LINHAS_APURACAO IS NULL AND B.QTD_MARCACOES IS NULL THEN
          'SEM_MARCACAO_E_SEM_APURACAO'
         WHEN B.QTD_LINHAS_APURACAO IS NULL THEN
          'MARCADO_NAO_APURADO'
         WHEN B.QTD_MARCACOES IS NULL THEN
          'APURADO_SEM_MARCACAO'
         WHEN MOD(B.QTD_MARCACOES, 2) = 1 THEN
          'MARCACOES_IMPARES'
         WHEN B.QTD_MARCACOES > 4 THEN
          'MAIS_DE_4_MARCACOES'
         WHEN NVL(B.PARES_INVALIDOS, 0) > 0 THEN
          'PARES_INVALIDOS'
         WHEN B.SITUACOES_A_VALIDAR > 0 THEN
          'CONFERIR_SITUACOES'
         WHEN B.MIN_PRESENCA_PARES <> B.MIN_REALIZADAS_APURADAS THEN
          'PRESENCA_DIFERE_APURACAO'
         ELSE
          'OK_PRELIMINAR'
       END AS STATUS_CONFERENCIA,
       NVL(B.SITUACOES_A_VALIDAR, 0) AS SITUACOES_A_VALIDAR,
       B.SITUACOES_DO_DIA
  FROM BASE_FINAL B
 ORDER BY B.NUMEMP, B.TIPCOL, B.NUMCAD, B.DATA_APURACAO;

