/* =========================================================
   ABSENTEÍSMO / HORAS / FALTAS / ATESTADOS POR COLABORADOR
   EMPRESA 4
   AJUSTADO PARA RETORNAR TODOS OS COLABORADORES DO PERÍODO
   PELA LOTAÇÃO HISTÓRICA DO MÊS
   ========================================================= */
WITH
/* =========================================================
   1) MESES DO PERÍODO
   ========================================================= */
MESES AS (
    SELECT
        ADD_MONTHS(TRUNC(:DATA_INICIO, 'MM'), LEVEL - 1) AS DATA_MES,
        LAST_DAY(ADD_MONTHS(TRUNC(:DATA_INICIO, 'MM'), LEVEL - 1)) AS DATA_MES_FIM,
        TO_CHAR(ADD_MONTHS(TRUNC(:DATA_INICIO, 'MM'), LEVEL - 1), 'MM/YYYY') AS MES_ANO,
        TO_CHAR(ADD_MONTHS(TRUNC(:DATA_INICIO, 'MM'), LEVEL - 1),
                'fmMonth YYYY',
                'NLS_DATE_LANGUAGE=PORTUGUESE') AS MES_ANO_EXTENSO
    FROM DUAL
    CONNECT BY LEVEL <= MONTHS_BETWEEN(TRUNC(:DATA_FIM, 'MM'),
                                       TRUNC(:DATA_INICIO, 'MM')) + 1
),

RANGE_FILTRO AS (
    SELECT
        MIN(DATA_MES) AS DT_INI,
        ADD_MONTHS(MAX(DATA_MES), 1) AS DT_FIM_EXCL
    FROM MESES
),

/* =========================================================
   2) CONTRATO x MÊS RESOLVENDO A FICHA CORRETA
   SEM STATUS = 0 PARA NÃO MATAR HISTÓRICO
   ========================================================= */
CONTRATO_MES AS (
    SELECT
        X.COD_CONTRATO,
        X.DES_PESSOA,
        X.DATA_NASCIMENTO,
        X.DATA_ADMISSAO,
        X.DATA_DEMISSAO,
        X.STATUS,
        X.IND_DEFICIENCIA,
        X.SEXO,
        X.NUM_FICHA_REGISTRO,
        X.DATA_INI_FICHA,
        X.DATA_FIM_FICHA,
        X.DATA_MES,
        X.DATA_MES_FIM,
        X.MES_ANO,
        X.MES_ANO_EXTENSO
    FROM (
        SELECT
            C.COD_CONTRATO,
            C.DES_PESSOA,
            C.DATA_NASCIMENTO,
            C.DATA_ADMISSAO,
            C.DATA_DEMISSAO,
            C.STATUS,
            C.IND_DEFICIENCIA,
            C.SEXO,
            C.NUM_FICHA_REGISTRO,
            C.DATA_INI_FICHA,
            C.DATA_FIM_FICHA,
            M.DATA_MES,
            M.DATA_MES_FIM,
            M.MES_ANO,
            M.MES_ANO_EXTENSO,
            ROW_NUMBER() OVER (
                PARTITION BY C.COD_CONTRATO, M.DATA_MES
                ORDER BY NVL(C.DATA_FIM_FICHA, DATE '2999-12-31') DESC,
                         C.DATA_INI_FICHA DESC,
                         C.NUM_FICHA_REGISTRO DESC
            ) AS RN
        FROM V_DADOS_CONTRATO_AVT C
        JOIN MESES M
          ON C.DATA_ADMISSAO <= M.DATA_MES_FIM
         AND NVL(C.DATA_DEMISSAO, DATE '2999-12-31') >= M.DATA_MES
         AND M.DATA_MES BETWEEN C.DATA_INI_FICHA
                            AND NVL(C.DATA_FIM_FICHA, DATE '2999-12-31')
        WHERE (TO_NUMBER(:CONTRATO) = 0 OR C.COD_CONTRATO = TO_NUMBER(:CONTRATO))
    ) X
    WHERE X.RN = 1
),

/* =========================================================
   3) ORGANOGRAMA HISTÓRICO DO MÊS
   FILTRO CORRETO POR SETOR NO MÊS
   ========================================================= */
ORG_MES AS (
    SELECT
        T.COD_CONTRATO,
        T.DATA_MES,
        T.COD_EMP,
        T.EDICAO_EMP,
        T.DES_EMP,
        T.COD_ORGANOGRAMA,
        T.COD_UNIDADE,
        T.DES_UNIDADE,
        T.COD_REDE,
        T.DES_REDE,
        T.COD_TIPO,
        T.DES_TIPO,
        T.DATA_INI_ORG,
        T.DATA_FIM_ORG
    FROM (
        SELECT
            B.COD_CONTRATO,
            B.DATA_MES,
            O.COD_EMP,
            O.EDICAO_EMP,
            O.DES_EMP,
            O.COD_ORGANOGRAMA,
            O.COD_UNIDADE,
            O.DES_UNIDADE,
            O.COD_REDE,
            O.DES_REDE,
            O.COD_TIPO,
            O.DES_TIPO,
            O.DATA_INI_ORG,
            O.DATA_FIM_ORG,
            ROW_NUMBER() OVER (
                PARTITION BY B.COD_CONTRATO, B.DATA_MES
                ORDER BY NVL(O.DATA_FIM_ORG, DATE '2999-12-31') DESC,
                         O.DATA_INI_ORG DESC,
                         O.COD_ORGANOGRAMA DESC
            ) AS RN
        FROM CONTRATO_MES B
        JOIN VH_EST_ORG_CONTRATO_AVT O
          ON O.COD_CONTRATO = B.COD_CONTRATO
         AND O.COD_EMP = 4
         AND O.EDICAO_ORG_4 IS NOT NULL
         AND B.DATA_MES BETWEEN O.DATA_INI_ORG
                            AND NVL(O.DATA_FIM_ORG, DATE '2999-12-31')
        WHERE (TO_CHAR(:SETOR) = '0' OR O.COD_UNIDADE = TO_CHAR(:SETOR))
    ) T
    WHERE T.RN = 1
),

/* =========================================================
   4) TURNO DO MÊS
   ========================================================= */
TURNO_MES AS (
    SELECT
        T.COD_CONTRATO,
        T.DATA_MES,
        T.COD_TURNO
    FROM (
        SELECT
            B.COD_CONTRATO,
            B.DATA_MES,
            TU.COD_TURNO,
            ROW_NUMBER() OVER (
                PARTITION BY B.COD_CONTRATO, B.DATA_MES
                ORDER BY NVL(TU.DATA_FIM, DATE '2999-12-31') DESC,
                         TU.DATA_INICIO DESC
            ) AS RN
        FROM CONTRATO_MES B
        JOIN RHAF1119 TU
          ON TU.COD_CONTRATO = B.COD_CONTRATO
         AND B.DATA_MES_FIM >= TU.DATA_INICIO
         AND B.DATA_MES <= NVL(TU.DATA_FIM, DATE '2999-12-31')
    ) T
    WHERE T.RN = 1
),

/* =========================================================
   5) FUNÇÃO HISTÓRICA DO MÊS
   ========================================================= */
FUNCAO_MES AS (
    SELECT
        T.COD_CONTRATO,
        T.DATA_MES,
        T.COD_FUNCAO,
        T.DES_FUNCAO,
        T.DATA_INI_CLH,
        T.DATA_FIM_CLH
    FROM (
        SELECT
            B.COD_CONTRATO,
            B.DATA_MES,
            F.COD_FUNCAO,
            F.DES_FUNCAO,
            F.DATA_INI_CLH,
            F.DATA_FIM_CLH,
            ROW_NUMBER() OVER (
                PARTITION BY B.COD_CONTRATO, B.DATA_MES
                ORDER BY NVL(F.DATA_FIM_CLH, DATE '2999-12-31') DESC,
                         F.DATA_INI_CLH DESC,
                         F.COD_FUNCAO DESC
            ) AS RN
        FROM CONTRATO_MES B
        JOIN VH_CARGO_CONTRATO_AVT F
          ON F.COD_CONTRATO = B.COD_CONTRATO
         AND B.DATA_MES BETWEEN F.DATA_INI_CLH
                            AND NVL(F.DATA_FIM_CLH, DATE '2999-12-31')
    ) T
    WHERE T.RN = 1
),

/* =========================================================
   6) HORA BASE HISTÓRICA DO MÊS
   ========================================================= */
HORA_BASE_MES AS (
    SELECT
        T.COD_CONTRATO,
        T.DATA_MES,
        T.HR_BASE_MES,
        T.DATA_INI_HR,
        T.DATA_FIM_HR,
        T.IND_BATE_PONTO
    FROM (
        SELECT
            B.COD_CONTRATO,
            B.DATA_MES,
            CAST(H.HR_BASE_MES AS NUMBER) AS HR_BASE_MES,
            H.DATA_INI_HR,
            H.DATA_FIM_HR,
            H.IND_BATE_PONTO,
            ROW_NUMBER() OVER (
                PARTITION BY B.COD_CONTRATO, B.DATA_MES
                ORDER BY NVL(H.DATA_FIM_HR, DATE '2999-12-31') DESC,
                         H.DATA_INI_HR DESC
            ) AS RN
        FROM CONTRATO_MES B
        JOIN VH_HIST_HORAS_COLAB_AVT H
          ON H.COD_CONTRATO = B.COD_CONTRATO
         AND B.DATA_MES BETWEEN H.DATA_INI_HR
                            AND NVL(H.DATA_FIM_HR, DATE '2999-12-31')
    ) T
    WHERE T.RN = 1
),

/* =========================================================
   7) FÉRIAS DO MÊS
   ========================================================= */
FERIAS_MES AS (
    SELECT
        C.COD_CONTRATO,
        C.DATA_MES,
        1 AS TEM_FERIAS
    FROM CONTRATO_MES C
    JOIN RHFP0306 A
      ON A.COD_CONTRATO = C.COD_CONTRATO
     AND A.COD_CAUSA_AFAST = 7
     AND A.DATA_INICIO <= C.DATA_MES_FIM
     AND NVL(A.DATA_FIM, DATE '2999-12-31') >= C.DATA_MES
    GROUP BY
        C.COD_CONTRATO,
        C.DATA_MES
),

/* =========================================================
   7.1) AFASTAMENTOS DO MÊS
   INFORMATIVO, SEM EXCLUIR COLABORADOR
   ========================================================= */
AFAST_MES AS (
    SELECT
        X.COD_CONTRATO,
        X.DATA_MES,
        X.COD_AFAST,
        X.DES_AFAST,
        X.DATA_INICIO_AFAST,
        X.DATA_FIM_AFAST
    FROM (
        SELECT
            C.COD_CONTRATO,
            C.DATA_MES,
            NVL(A.COD_CAUSA_AFAST, 0) AS COD_AFAST,
            T.NOME_CAUSA_AFAST AS DES_AFAST,
            A.DATA_INICIO AS DATA_INICIO_AFAST,
            A.DATA_FIM AS DATA_FIM_AFAST,
            ROW_NUMBER() OVER (
                PARTITION BY C.COD_CONTRATO, C.DATA_MES
                ORDER BY NVL(A.DATA_FIM, DATE '2999-12-31') DESC,
                         A.DATA_INICIO DESC,
                         A.COD_CAUSA_AFAST DESC
            ) AS RN
        FROM CONTRATO_MES C
        JOIN RHFP0306 A
          ON A.COD_CONTRATO = C.COD_CONTRATO
         AND A.COD_CAUSA_AFAST <> 7
         AND A.DATA_INICIO <= C.DATA_MES_FIM
         AND NVL(A.DATA_FIM, DATE '2999-12-31') >= C.DATA_MES
        LEFT JOIN RHFP0100 T
          ON T.COD_CAUSA_AFAST = A.COD_CAUSA_AFAST
    ) X
    WHERE X.RN = 1
),

/* =========================================================
   8) DIMENSÃO FINAL
   ========================================================= */
DIM AS (
    SELECT
        B.STATUS,
        B.COD_CONTRATO,
        B.DES_PESSOA,
        B.DATA_NASCIMENTO,
        B.DATA_ADMISSAO,
        B.DATA_DEMISSAO,
        B.IND_DEFICIENCIA,
        B.SEXO,
        B.NUM_FICHA_REGISTRO,
        B.DATA_INI_FICHA,
        B.DATA_FIM_FICHA,
        B.DATA_MES,
        B.DATA_MES_FIM,
        B.MES_ANO,
        B.MES_ANO_EXTENSO,

        AF.COD_AFAST,
        AF.DES_AFAST,
        AF.DATA_INICIO_AFAST,
        AF.DATA_FIM_AFAST,

        O.COD_EMP,
        O.EDICAO_EMP,
        O.DES_EMP,
        O.COD_ORGANOGRAMA,
        O.COD_UNIDADE,
        O.DES_UNIDADE,
        O.COD_REDE,
        O.DES_REDE,
        O.COD_TIPO,
        O.DES_TIPO,
        O.DATA_INI_ORG,
        O.DATA_FIM_ORG,

        F.COD_FUNCAO,
        F.DES_FUNCAO,
        F.DATA_INI_CLH,
        F.DATA_FIM_CLH,

        H.HR_BASE_MES,
        H.DATA_INI_HR,
        H.DATA_FIM_HR,
        H.IND_BATE_PONTO,

        T.COD_TURNO
    FROM CONTRATO_MES B
    JOIN ORG_MES O
      ON O.COD_CONTRATO = B.COD_CONTRATO
     AND O.DATA_MES     = B.DATA_MES
    LEFT JOIN FUNCAO_MES F
      ON F.COD_CONTRATO = B.COD_CONTRATO
     AND F.DATA_MES     = B.DATA_MES
    LEFT JOIN HORA_BASE_MES H
      ON H.COD_CONTRATO = B.COD_CONTRATO
     AND H.DATA_MES     = B.DATA_MES
    LEFT JOIN TURNO_MES T
      ON T.COD_CONTRATO = B.COD_CONTRATO
     AND T.DATA_MES     = B.DATA_MES
    LEFT JOIN AFAST_MES AF
      ON AF.COD_CONTRATO = B.COD_CONTRATO
     AND AF.DATA_MES     = B.DATA_MES
    WHERE NVL(T.COD_TURNO, 0) <> 85
      AND (
            F.DES_FUNCAO IS NULL
            OR (
                UPPER(F.DES_FUNCAO) NOT LIKE '%APRENDIZ%'
            AND UPPER(F.DES_FUNCAO) NOT LIKE '%ESTAGIARIO%'
            )
          )
),

/* =========================================================
   9) HORAS TRABALHADAS POR CONTRATO x MÊS
   ========================================================= */
HORAS_TRAB AS (
    SELECT
        HM.COD_CONTRATO,
        TRUNC(HM.DATA_OCORRENCIA, 'MM') AS DATA_MES,
        SUM(CASE
              WHEN HM.COD_OCORRENCIA = 2 THEN TO_NUMBER(HM.NUM_HORAS)
              ELSE 0
            END) AS TOT_HORAS_TRAB
    FROM RHAF1123 HM
    CROSS JOIN RANGE_FILTRO R
    WHERE HM.DATA_OCORRENCIA >= R.DT_INI
      AND HM.DATA_OCORRENCIA <  R.DT_FIM_EXCL
    GROUP BY
        HM.COD_CONTRATO,
        TRUNC(HM.DATA_OCORRENCIA, 'MM')
),

/* =========================================================
   10) FALTAS / ATESTADOS POR CONTRATO x MÊS
   ========================================================= */
EVENTOS_MES AS (
    SELECT
        C.COD_CONTRATO,
        TRUNC(E.DATA_REFERENCIA, 'MM') AS DATA_MES,
        SUM(CASE WHEN C.COD_VD = 632 THEN TO_NUMBER(C.QTDE_VD) ELSE 0 END) AS TOT_FALTAS,
        SUM(CASE WHEN C.COD_VD = 897 THEN TO_NUMBER(C.QTDE_VD) ELSE 0 END) AS TOT_ATESTADOS,
        SUM(CASE WHEN C.COD_VD IN (632, 897) THEN TO_NUMBER(C.QTDE_VD) ELSE 0 END) AS TOT_FALTAS_ATESTADOS
    FROM RHFP1006 C
    JOIN RHFP1003 E
      ON E.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
    CROSS JOIN RANGE_FILTRO R
    WHERE E.DATA_REFERENCIA >= R.DT_INI
      AND E.DATA_REFERENCIA <  R.DT_FIM_EXCL
      AND E.COD_ORGANOGRAMA = 4
    GROUP BY
        C.COD_CONTRATO,
        TRUNC(E.DATA_REFERENCIA, 'MM')
),

/* =========================================================
   11) EVENTOS AJUSTADOS (zera férias)
   ========================================================= */
A1 AS (
    SELECT
        D.COD_CONTRATO,
        D.DATA_MES,
        CASE WHEN F.TEM_FERIAS = 1 THEN 0 ELSE NVL(E.TOT_FALTAS, 0) END AS TOT_FALTAS,
        CASE WHEN F.TEM_FERIAS = 1 THEN 0 ELSE NVL(E.TOT_ATESTADOS, 0) END AS TOT_ATESTADOS,
        CASE WHEN F.TEM_FERIAS = 1 THEN 0 ELSE NVL(E.TOT_FALTAS_ATESTADOS, 0) END AS TOT_FALTAS_ATESTADOS
    FROM DIM D
    LEFT JOIN EVENTOS_MES E
      ON E.COD_CONTRATO = D.COD_CONTRATO
     AND E.DATA_MES     = D.DATA_MES
    LEFT JOIN FERIAS_MES F
      ON F.COD_CONTRATO = D.COD_CONTRATO
     AND F.DATA_MES     = D.DATA_MES
),

/* =========================================================
   12) BASE MENSAL
   HISTÓRICA DO MÊS
   ========================================================= */
BASE_MENSAL AS (
    SELECT
        D.COD_CONTRATO,
        D.DATA_MES,
        D.COD_ORGANOGRAMA,
        D.COD_TIPO,
        D.COD_UNIDADE,
        D.COD_REDE,

        CAST(NVL(H.TOT_HORAS_TRAB, 0) AS NUMBER) AS TOT_HR_TRAB,
        CAST(NVL(A1.TOT_FALTAS, 0) AS NUMBER) AS TOT_FALTAS,
        CAST(NVL(A1.TOT_ATESTADOS, 0) AS NUMBER) AS TOT_ATESTADOS,
        CAST(NVL(A1.TOT_FALTAS_ATESTADOS, 0) AS NUMBER) AS TOT_FT_ATEST,
        CAST(
            CASE
                WHEN NVL(H.TOT_HORAS_TRAB, 0) > 0 THEN NVL(H.TOT_HORAS_TRAB, 0)
                ELSE NVL(D.HR_BASE_MES, 0)
            END AS NUMBER
        ) AS TOT_HR_BASE
    FROM DIM D
    LEFT JOIN HORAS_TRAB H
      ON H.COD_CONTRATO = D.COD_CONTRATO
     AND H.DATA_MES     = D.DATA_MES
    LEFT JOIN A1
      ON A1.COD_CONTRATO = D.COD_CONTRATO
     AND A1.DATA_MES     = D.DATA_MES
),

/* =========================================================
   13) TOTAL DO PERÍODO
   ========================================================= */
PERIODO_COLAB AS (
    SELECT
        COD_CONTRATO,
        SUM(TOT_FALTAS)    AS TOT_FALTAS_PERIODO,
        SUM(TOT_ATESTADOS) AS TOT_ATESTADOS_PERIODO,
        SUM(TOT_HR_TRAB)   AS TOT_HR_TRAB_PERIODO,
        SUM(TOT_FT_ATEST)  AS TOT_FT_ATEST_PERIODO,
        NVL(ROUND(SUM(TOT_FT_ATEST) * 100 / NULLIF(SUM(TOT_HR_BASE), 0), 2), 0) AS PERC_ABS_PERIODO
    FROM BASE_MENSAL
    GROUP BY COD_CONTRATO
)

/* =========================================================
   14) RESULTADO FINAL
   HISTÓRICO DO MÊS
   ========================================================= */
SELECT
    D.COD_ORGANOGRAMA,
    D.COD_CONTRATO,
    D.DES_PESSOA,
    D.DATA_ADMISSAO,
    CASE
        WHEN D.DATA_DEMISSAO IS NULL THEN '-'
        ELSE TO_CHAR(D.DATA_DEMISSAO, 'DD/MM/YYYY')
    END AS DATA_DEMISSAO,
    D.DES_FUNCAO,
    D.COD_UNIDADE,
    D.DES_UNIDADE,
    D.COD_AFAST,
    CASE
        WHEN D.DES_AFAST IS NULL THEN 'Em Atividade'
        ELSE D.DES_AFAST
    END AS DES_AFAST,
    CASE
        WHEN D.DATA_INICIO_AFAST IS NULL THEN '-'
        ELSE TO_CHAR(D.DATA_INICIO_AFAST, 'DD/MM/YYYY')
    END AS DATA_INICIO_AFAST,
    CASE
        WHEN D.DATA_FIM_AFAST IS NULL THEN '-'
        ELSE TO_CHAR(D.DATA_FIM_AFAST, 'DD/MM/YYYY')
    END AS DATA_FIM_AFAST,
    D.COD_REDE,
    D.DES_REDE,
    D.COD_TIPO,
    D.MES_ANO,
    D.MES_ANO_EXTENSO,

    ROUND(NVL(BM.TOT_HR_TRAB, 0), 2) AS TOT_HR_TRAB_UNI,
    ROUND(NVL(BM.TOT_FALTAS, 0), 2) AS TOT_FALTAS_UNI,
    ROUND(NVL(BM.TOT_ATESTADOS, 0), 2) AS TOT_ATESTADOS_UNI,
    ROUND(NVL(BM.TOT_FT_ATEST, 0), 2) AS TOT_FT_ATEST_UNI,
    NVL(ROUND(NVL(BM.TOT_FT_ATEST, 0) * 100 / NULLIF(BM.TOT_HR_BASE, 0), 2), 0) AS PERC_ABSENTEISMO_UNI,

    ROUND(NVL(P.TOT_FALTAS_PERIODO, 0), 2) AS TOT_FALTAS_PERIODO,
    ROUND(NVL(P.TOT_ATESTADOS_PERIODO, 0), 2) AS TOT_ATESTADOS_PERIODO,
    ROUND(NVL(P.TOT_HR_TRAB_PERIODO, 0), 2) AS TOT_HR_TRAB_PERIODO,
    ROUND(NVL(P.TOT_FT_ATEST_PERIODO, 0), 2) AS TOT_FT_ATEST_PERIODO,
    NVL(P.PERC_ABS_PERIODO, 0) AS PERC_ABSENTEISMO_PERIODO,

    SYSDATE AS DATA_SISTEMA,

    'Setor: ' || TO_CHAR(:SETOR) || ' | ' ||
    'Contrato: ' || TO_CHAR(:CONTRATO) || ' | ' ||
    'Data de: ' || TO_CHAR(:DATA_INICIO, 'DD/MM/YYYY') || ' à ' || TO_CHAR(:DATA_FIM, 'DD/MM/YYYY') AS PARAMETROS,
     
    'Índice = (Faltas + Atestados) x 100 / Horas Base consideradas no mês' AS FORMULA_CALCULO
FROM DIM D
LEFT JOIN BASE_MENSAL BM
  ON BM.COD_CONTRATO = D.COD_CONTRATO
 AND BM.DATA_MES     = D.DATA_MES
LEFT JOIN PERIODO_COLAB P
  ON P.COD_CONTRATO  = D.COD_CONTRATO
ORDER BY
    D.COD_TIPO,
    D.DES_UNIDADE,
    D.COD_CONTRATO,
    D.DATA_MES