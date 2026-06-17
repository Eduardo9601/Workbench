/*SEL0038 - ÍNDICES DE ABSENTEÍSMO GERAL*/

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
   2) CONTRATO x MÊS RESOLVENDO FICHA
   ========================================================= */
CONTRATO_MES AS (
    SELECT
        X.COD_CONTRATO,
        X.DATA_ADMISSAO,
        X.DATA_DEMISSAO,
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
            C.DATA_ADMISSAO,
            C.DATA_DEMISSAO,
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
    ) X
    WHERE X.RN = 1
),

/* =========================================================
   3) ORGANOGRAMA HISTÓRICO DO MÊS
   AQUI entra a filtragem correta por TIPO / FILIAL / REDE
   ========================================================= */
ORG_MES AS (
    SELECT
        X.COD_CONTRATO,
        X.DATA_MES,
        X.COD_EMP,
        X.EDICAO_EMP,
        X.DES_EMP,
        X.COD_ORGANOGRAMA,
        X.COD_UNIDADE,
        X.DES_UNIDADE,
        X.COD_REDE,
        X.DES_REDE,
        X.COD_TIPO,
        X.DES_TIPO
    FROM (
        SELECT
            C.COD_CONTRATO,
            C.DATA_MES,
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
            ROW_NUMBER() OVER (
                PARTITION BY C.COD_CONTRATO, C.DATA_MES
                ORDER BY NVL(O.DATA_FIM_ORG, DATE '2999-12-31') DESC,
                         O.DATA_INI_ORG DESC,
                         O.COD_ORGANOGRAMA DESC
            ) AS RN
        FROM CONTRATO_MES C
        JOIN VH_EST_ORG_CONTRATO_AVT O
          ON O.COD_CONTRATO = C.COD_CONTRATO
         AND O.COD_EMP = 8
         AND O.EDICAO_ORG_4 IS NOT NULL
         AND C.DATA_MES BETWEEN O.DATA_INI_ORG
                            AND NVL(O.DATA_FIM_ORG, DATE '2999-12-31')
        WHERE (TO_NUMBER(:TIPO)   = 0 OR O.COD_TIPO    = TO_NUMBER(:TIPO))
          AND (TO_NUMBER(:FILIAL) = 0 OR O.COD_UNIDADE = TO_NUMBER(:FILIAL))
          AND (TO_CHAR(:REDE)     = '0' OR TO_CHAR(O.COD_REDE) = TO_CHAR(:REDE))
    ) X
    WHERE X.RN = 1
),

/* =========================================================
   4) TURNO DO MÊS
   ========================================================= */
TURNO_MES AS (
    SELECT
        X.COD_CONTRATO,
        X.DATA_MES,
        X.COD_TURNO
    FROM (
        SELECT
            C.COD_CONTRATO,
            C.DATA_MES,
            T.COD_TURNO,
            ROW_NUMBER() OVER (
                PARTITION BY C.COD_CONTRATO, C.DATA_MES
                ORDER BY NVL(T.DATA_FIM, DATE '2999-12-31') DESC,
                         T.DATA_INICIO DESC
            ) AS RN
        FROM CONTRATO_MES C
        JOIN RHAF1119 T
          ON T.COD_CONTRATO = C.COD_CONTRATO
         AND C.DATA_MES_FIM >= T.DATA_INICIO
         AND C.DATA_MES <= NVL(T.DATA_FIM, DATE '2999-12-31')
    ) X
    WHERE X.RN = 1
),

/* =========================================================
   5) FUNÇÃO DO MÊS
   Usada só para exclusão de aprendiz/estagiário
   ========================================================= */
FUNCAO_MES AS (
    SELECT
        X.COD_CONTRATO,
        X.DATA_MES,
        X.DES_FUNCAO
    FROM (
        SELECT
            C.COD_CONTRATO,
            C.DATA_MES,
            F.DES_FUNCAO,
            ROW_NUMBER() OVER (
                PARTITION BY C.COD_CONTRATO, C.DATA_MES
                ORDER BY NVL(F.DATA_FIM_CLH, DATE '2999-12-31') DESC,
                         F.DATA_INI_CLH DESC
            ) AS RN
        FROM CONTRATO_MES C
        JOIN VH_CARGO_CONTRATO_AVT F
          ON F.COD_CONTRATO = C.COD_CONTRATO
         AND C.DATA_MES BETWEEN F.DATA_INI_CLH
                            AND NVL(F.DATA_FIM_CLH, DATE '2999-12-31')
    ) X
    WHERE X.RN = 1
),

/* =========================================================
   6) FÉRIAS DO MÊS
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
   7) BASE CONTRATO x MÊS ÚNICA
   ========================================================= */
BASE_CONTRATO_MES AS (
    SELECT
        C.COD_CONTRATO,
        C.DATA_MES,
        C.DATA_MES_FIM,
        C.MES_ANO,
        C.MES_ANO_EXTENSO,
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
        T.COD_TURNO,
        F.DES_FUNCAO
    FROM CONTRATO_MES C
    JOIN ORG_MES O
      ON O.COD_CONTRATO = C.COD_CONTRATO
     AND O.DATA_MES     = C.DATA_MES
    LEFT JOIN TURNO_MES T
      ON T.COD_CONTRATO = C.COD_CONTRATO
     AND T.DATA_MES     = C.DATA_MES
    LEFT JOIN FUNCAO_MES F
      ON F.COD_CONTRATO = C.COD_CONTRATO
     AND F.DATA_MES     = C.DATA_MES
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
   8) HORAS POR CONTRATO x MÊS
   ========================================================= */
HORAS_CONTRATO_MES AS (
    SELECT
        H.COD_CONTRATO,
        TRUNC(H.DATA_OCORRENCIA, 'MM') AS DATA_MES,
        SUM(CASE WHEN H.COD_OCORRENCIA = 2 THEN TO_NUMBER(H.NUM_HORAS) ELSE 0 END) AS TOT_HORAS_TRAB
    FROM RHAF1123 H
    CROSS JOIN RANGE_FILTRO R
    WHERE H.DATA_OCORRENCIA >= R.DT_INI
      AND H.DATA_OCORRENCIA <  R.DT_FIM_EXCL
    GROUP BY
        H.COD_CONTRATO,
        TRUNC(H.DATA_OCORRENCIA, 'MM')
),

/* =========================================================
   9) EVENTOS POR CONTRATO x MÊS
   ========================================================= */
EVENTOS_CONTRATO_MES AS (
    SELECT
        C.COD_CONTRATO,
        TRUNC(D.DATA_REFERENCIA, 'MM') AS DATA_MES,
        SUM(CASE WHEN C.COD_VD = 632 THEN TO_NUMBER(C.QTDE_VD) ELSE 0 END) AS TOT_FALTAS,
        SUM(CASE WHEN C.COD_VD = 897 THEN TO_NUMBER(C.QTDE_VD) ELSE 0 END) AS TOT_ATESTADOS,
        SUM(CASE WHEN C.COD_VD IN (632, 897) THEN TO_NUMBER(C.QTDE_VD) ELSE 0 END) AS TOT_FALTAS_ATESTADOS
    FROM RHFP1006 C
    JOIN RHFP1003 D
      ON D.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
    CROSS JOIN RANGE_FILTRO R
    WHERE D.DATA_REFERENCIA >= R.DT_INI
      AND D.DATA_REFERENCIA <  R.DT_FIM_EXCL
      AND D.COD_ORGANOGRAMA = 8
    GROUP BY
        C.COD_CONTRATO,
        TRUNC(D.DATA_REFERENCIA, 'MM')
),

/* =========================================================
   10) EVENTOS AJUSTADOS (zera férias)
   ========================================================= */
BASE_MENSAL_CONTRATO AS (
    SELECT
        B.COD_CONTRATO,
        B.DATA_MES,
        B.MES_ANO,
        B.MES_ANO_EXTENSO,
        B.COD_EMP,
        B.EDICAO_EMP,
        B.DES_EMP,
        B.COD_ORGANOGRAMA,
        B.COD_UNIDADE,
        B.DES_UNIDADE,
        B.COD_REDE,
        B.DES_REDE,
        B.COD_TIPO,
        B.DES_TIPO,
        NVL(H.TOT_HORAS_TRAB, 0) AS TOT_HORAS_TRAB,
        CASE WHEN F.TEM_FERIAS = 1 THEN 0 ELSE NVL(E.TOT_FALTAS, 0) END AS TOT_FALTAS,
        CASE WHEN F.TEM_FERIAS = 1 THEN 0 ELSE NVL(E.TOT_ATESTADOS, 0) END AS TOT_ATESTADOS,
        CASE WHEN F.TEM_FERIAS = 1 THEN 0 ELSE NVL(E.TOT_FALTAS_ATESTADOS, 0) END AS TOT_FALTAS_ATESTADOS
    FROM BASE_CONTRATO_MES B
    LEFT JOIN HORAS_CONTRATO_MES H
      ON H.COD_CONTRATO = B.COD_CONTRATO
     AND H.DATA_MES     = B.DATA_MES
    LEFT JOIN EVENTOS_CONTRATO_MES E
      ON E.COD_CONTRATO = B.COD_CONTRATO
     AND E.DATA_MES     = B.DATA_MES
    LEFT JOIN FERIAS_MES F
      ON F.COD_CONTRATO = B.COD_CONTRATO
     AND F.DATA_MES     = B.DATA_MES
),

/* =========================================================
   11) LISTAS BASE
   ========================================================= */
UNIDADES_MES AS (
    SELECT DISTINCT
        COD_ORGANOGRAMA,
        COD_UNIDADE,
        DES_UNIDADE,
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO
    FROM BASE_CONTRATO_MES
),

REDES_MES AS (
    SELECT DISTINCT
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO
    FROM BASE_CONTRATO_MES
),

EMPRESA_MES AS (
    SELECT DISTINCT
        COD_EMP,
        EDICAO_EMP,
        DES_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO
    FROM BASE_CONTRATO_MES
),

/* =========================================================
   12) AGREGAÇÕES
   ========================================================= */
AGG_UNIDADE AS (
    SELECT
        COD_ORGANOGRAMA,
        COD_UNIDADE,
        DES_UNIDADE,
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO,
        SUM(TOT_HORAS_TRAB)       AS TOT_HR_TRAB_UNI,
        SUM(TOT_FALTAS)           AS TOT_FALTAS_UNI,
        SUM(TOT_ATESTADOS)        AS TOT_ATESTADOS_UNI,
        SUM(TOT_FALTAS_ATESTADOS) AS TOT_FT_ATEST_UNI
    FROM BASE_MENSAL_CONTRATO
    GROUP BY
        COD_ORGANOGRAMA,
        COD_UNIDADE,
        DES_UNIDADE,
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO
),

AGG_REDE AS (
    SELECT
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO,
        SUM(TOT_HORAS_TRAB)       AS TOT_HR_TRAB_RD,
        SUM(TOT_FALTAS)           AS TOT_FALTAS_RD,
        SUM(TOT_ATESTADOS)        AS TOT_ATESTADOS_RD,
        SUM(TOT_FALTAS_ATESTADOS) AS TOT_FT_ATEST_RD
    FROM BASE_MENSAL_CONTRATO
    GROUP BY
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO
),

AGG_EMPRESA AS (
    SELECT
        COD_EMP,
        EDICAO_EMP,
        DES_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO,
        SUM(TOT_HORAS_TRAB)       AS TOT_HR_TRAB_EMP,
        SUM(TOT_FALTAS)           AS TOT_FALTAS_EMP,
        SUM(TOT_ATESTADOS)        AS TOT_ATESTADOS_EMP,
        SUM(TOT_FALTAS_ATESTADOS) AS TOT_FT_ATEST_EMP
    FROM BASE_MENSAL_CONTRATO
    GROUP BY
        COD_EMP,
        EDICAO_EMP,
        DES_EMP,
        DATA_MES,
        MES_ANO,
        MES_ANO_EXTENSO
),


/* =========================================================
   12.1) TOTAL DO PERÍODO POR UNIDADE
   ========================================================= */
PERIODO_UNIDADE AS (
    SELECT
        COD_ORGANOGRAMA,
        COD_UNIDADE,
        DES_UNIDADE,
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP,
        SUM(TOT_HORAS_TRAB)       AS TOT_HR_TRAB_PERIODO_UNI,
        SUM(TOT_FALTAS)           AS TOT_FALTAS_PERIODO_UNI,
        SUM(TOT_ATESTADOS)        AS TOT_ATESTADOS_PERIODO_UNI,
        SUM(TOT_FALTAS_ATESTADOS) AS TOT_FT_ATEST_PERIODO_UNI,
        NVL(ROUND(SUM(TOT_FALTAS_ATESTADOS) * 100 / NULLIF(SUM(TOT_HORAS_TRAB), 0), 2), 0) AS PERC_ABS_PERIODO_UNI
    FROM BASE_MENSAL_CONTRATO
    GROUP BY
        COD_ORGANOGRAMA,
        COD_UNIDADE,
        DES_UNIDADE,
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP
),

/* =========================================================
   12.2) TOTAL DO PERÍODO POR REDE
   ========================================================= */
PERIODO_REDE AS (
    SELECT
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP,
        SUM(TOT_HORAS_TRAB)       AS TOT_HR_TRAB_PERIODO_RD,
        SUM(TOT_FALTAS)           AS TOT_FALTAS_PERIODO_RD,
        SUM(TOT_ATESTADOS)        AS TOT_ATESTADOS_PERIODO_RD,
        SUM(TOT_FALTAS_ATESTADOS) AS TOT_FT_ATEST_PERIODO_RD,
        NVL(ROUND(SUM(TOT_FALTAS_ATESTADOS) * 100 / NULLIF(SUM(TOT_HORAS_TRAB), 0), 2), 0) AS PERC_ABS_PERIODO_RD
    FROM BASE_MENSAL_CONTRATO
    GROUP BY
        COD_REDE,
        DES_REDE,
        COD_TIPO,
        COD_EMP
),

/* =========================================================
   12.3) TOTAL DO PERÍODO DA EMPRESA
   ========================================================= */
PERIODO_EMPRESA AS (
    SELECT
        COD_EMP,
        EDICAO_EMP,
        DES_EMP,
        SUM(TOT_HORAS_TRAB)       AS TOT_HR_TRAB_PERIODO_EMP,
        SUM(TOT_FALTAS)           AS TOT_FALTAS_PERIODO_EMP,
        SUM(TOT_ATESTADOS)        AS TOT_ATESTADOS_PERIODO_EMP,
        SUM(TOT_FALTAS_ATESTADOS) AS TOT_FT_ATEST_PERIODO_EMP,
        NVL(ROUND(SUM(TOT_FALTAS_ATESTADOS) * 100 / NULLIF(SUM(TOT_HORAS_TRAB), 0), 2), 0) AS PERC_ABS_PERIODO_EMP
    FROM BASE_MENSAL_CONTRATO
    GROUP BY
        COD_EMP,
        EDICAO_EMP,
        DES_EMP
)

/* =========================================================
   13) RESULTADO FINAL
   ========================================================= */
SELECT
    U.COD_ORGANOGRAMA,
    U.COD_UNIDADE,
    U.DES_UNIDADE,
    U.COD_REDE,
    U.DES_REDE,
    U.COD_TIPO,
    U.MES_ANO,
    U.MES_ANO_EXTENSO,

    ROUND(NVL(AU.TOT_HR_TRAB_UNI, 0), 2) AS TOT_HR_TRAB_UNI,
    ROUND(NVL(AU.TOT_FALTAS_UNI, 0), 2) AS TOT_FALTAS_UNI,
    ROUND(NVL(AU.TOT_ATESTADOS_UNI, 0), 2) AS TOT_ATESTADOS_UNI,
    ROUND(NVL(AU.TOT_FT_ATEST_UNI, 0), 2) AS TOT_FT_ATEST_UNI,
    NVL(ROUND(NVL(AU.TOT_FT_ATEST_UNI, 0) * 100 / NULLIF(NVL(AU.TOT_HR_TRAB_UNI, 0), 0), 2), 0) AS PERC_ABSENTEISMO_UNI,

    ROUND(NVL(PU.TOT_HR_TRAB_PERIODO_UNI, 0), 2) AS TOT_HR_TRAB_PERIODO_UNI,
    ROUND(NVL(PU.TOT_FALTAS_PERIODO_UNI, 0), 2) AS TOT_FALTAS_PERIODO_UNI,
    ROUND(NVL(PU.TOT_ATESTADOS_PERIODO_UNI, 0), 2) AS TOT_ATESTADOS_PERIODO_UNI,
    ROUND(NVL(PU.TOT_FT_ATEST_PERIODO_UNI, 0), 2) AS TOT_FT_ATEST_PERIODO_UNI,
    NVL(PU.PERC_ABS_PERIODO_UNI, 0) AS PERC_ABS_PERIODO_UNI,

    'REDES =>' AS ESPACO_1,

    R.COD_REDE AS REDE_RD,
    R.DES_REDE AS DES_REDE_RD,
    R.COD_TIPO AS COD_TIPO_RD,
    R.MES_ANO AS MES_ANO_RD,
    R.MES_ANO_EXTENSO AS MES_ANO_EXTENSO_RD,

    ROUND(NVL(AR.TOT_HR_TRAB_RD, 0), 2) AS TOT_HR_TRAB_RD,
    ROUND(NVL(AR.TOT_FALTAS_RD, 0), 2) AS TOT_FALTAS_RD,
    ROUND(NVL(AR.TOT_ATESTADOS_RD, 0), 2) AS TOT_ATESTADOS_RD,
    ROUND(NVL(AR.TOT_FT_ATEST_RD, 0), 2) AS TOT_FT_ATEST_RD,
    NVL(ROUND(NVL(AR.TOT_FT_ATEST_RD, 0) * 100 / NULLIF(NVL(AR.TOT_HR_TRAB_RD, 0), 0), 2), 0) AS PERC_ABSENTEISMO_RD,

    ROUND(NVL(PR.TOT_HR_TRAB_PERIODO_RD, 0), 2) AS TOT_HR_TRAB_PERIODO_RD,
    ROUND(NVL(PR.TOT_FALTAS_PERIODO_RD, 0), 2) AS TOT_FALTAS_PERIODO_RD,
    ROUND(NVL(PR.TOT_ATESTADOS_PERIODO_RD, 0), 2) AS TOT_ATESTADOS_PERIODO_RD,
    ROUND(NVL(PR.TOT_FT_ATEST_PERIODO_RD, 0), 2) AS TOT_FT_ATEST_PERIODO_RD,
    NVL(PR.PERC_ABS_PERIODO_RD, 0) AS PERC_ABS_PERIODO_RD,

    'EMPRESA =>' AS ESPACO_2,

    E.EDICAO_EMP,
    E.DES_EMP,
    E.MES_ANO AS MES_ANO_EMP,
    E.MES_ANO_EXTENSO AS MES_ANO_EXTENSO_EMP,

    ROUND(NVL(AE.TOT_HR_TRAB_EMP, 0), 2) AS TOT_HR_TRAB_EMP,
    ROUND(NVL(AE.TOT_FALTAS_EMP, 0), 2) AS TOT_FALTAS_EMP,
    ROUND(NVL(AE.TOT_ATESTADOS_EMP, 0), 2) AS TOT_ATESTADOS_EMP,
    ROUND(NVL(AE.TOT_FT_ATEST_EMP, 0), 2) AS TOT_FT_ATEST_EMP,
    NVL(ROUND(NVL(AE.TOT_FT_ATEST_EMP, 0) * 100 / NULLIF(NVL(AE.TOT_HR_TRAB_EMP, 0), 0), 2), 0) AS PERC_ABSENTEISMO_EMP,

    ROUND(NVL(PE.TOT_HR_TRAB_PERIODO_EMP, 0), 2) AS TOT_HR_TRAB_PERIODO_EMP,
    ROUND(NVL(PE.TOT_FALTAS_PERIODO_EMP, 0), 2) AS TOT_FALTAS_PERIODO_EMP,
    ROUND(NVL(PE.TOT_ATESTADOS_PERIODO_EMP, 0), 2) AS TOT_ATESTADOS_PERIODO_EMP,
    ROUND(NVL(PE.TOT_FT_ATEST_PERIODO_EMP, 0), 2) AS TOT_FT_ATEST_PERIODO_EMP,
    NVL(PE.PERC_ABS_PERIODO_EMP, 0) AS PERC_ABS_PERIODO_EMP,

    SYSDATE AS DATA_SISTEMA,

    'Tipo: ' || TO_CHAR(:TIPO) || ' / ' ||
    'Filial: ' || TO_CHAR(:FILIAL) || ' / ' ||
    'Rede: ' || TO_CHAR(:REDE) || ' / ' ||
    'Data de: ' || TO_CHAR(:DATA_INICIO, 'DD/MM/YYYY') || ' à ' || TO_CHAR(:DATA_FIM, 'DD/MM/YYYY') AS PARAMETROS,

    'Índices = (Faltas + Atestados) x 100 / Horas Trabalhadas no mês' AS FORMULA_CALCULO


FROM UNIDADES_MES U
LEFT JOIN AGG_UNIDADE AU
  ON AU.COD_ORGANOGRAMA = U.COD_ORGANOGRAMA
 AND AU.DATA_MES        = U.DATA_MES
LEFT JOIN REDES_MES R
  ON R.COD_REDE = U.COD_REDE
 AND R.COD_TIPO = U.COD_TIPO
 AND R.COD_EMP  = U.COD_EMP
 AND R.DATA_MES = U.DATA_MES
LEFT JOIN AGG_REDE AR
  ON AR.COD_REDE = R.COD_REDE
 AND AR.COD_TIPO = R.COD_TIPO
 AND AR.COD_EMP  = R.COD_EMP
 AND AR.DATA_MES = R.DATA_MES
LEFT JOIN EMPRESA_MES E
  ON E.COD_EMP  = U.COD_EMP
 AND E.DATA_MES = U.DATA_MES
LEFT JOIN AGG_EMPRESA AE
  ON AE.COD_EMP  = E.COD_EMP
 AND AE.DATA_MES = E.DATA_MES 
LEFT JOIN PERIODO_UNIDADE PU
  ON PU.COD_ORGANOGRAMA = U.COD_ORGANOGRAMA
 AND PU.COD_EMP         = U.COD_EMP
LEFT JOIN PERIODO_REDE PR
  ON PR.COD_REDE = U.COD_REDE
 AND PR.COD_TIPO = U.COD_TIPO
 AND PR.COD_EMP  = U.COD_EMP
LEFT JOIN PERIODO_EMPRESA PE
  ON PE.COD_EMP = U.COD_EMP
ORDER BY
    U.COD_TIPO,
    U.COD_REDE,
    U.DES_UNIDADE,
    U.DATA_MES