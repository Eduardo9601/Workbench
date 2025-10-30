WITH
/*==============================INDICES POR UNIDADES E REDE============================================*/
-- CTE para gerar todos os meses do período de apuração
CTE_MESES AS (
    /*PARA TESTES*/

    /*SELECT TO_CHAR(ADD_MONTHS(TO_DATE('01/12/2024', 'DD/MM/YYYY'),
                              LEVEL - 1),
                   'MM/YYYY') AS MES_ANO,
           ADD_MONTHS(TO_DATE('01/12/2024', 'DD/MM/YYYY'), LEVEL - 1) AS DATA_MES
      FROM DUAL
    CONNECT BY LEVEL <=
               MONTHS_BETWEEN(TO_DATE('28/02/2025', 'DD/MM/YYYY'),
                              TO_DATE('01/12/2024', 'DD/MM/YYYY')) + 1*/

    /*==PARA INFORMAR AS DATAS NA GERAÇÃO DO RELATÓRIO*/
    /*SELECT TO_CHAR(ADD_MONTHS(:DATA_INICIO, LEVEL - 1), 'MM/YYYY') AS MES_ANO,
           ADD_MONTHS(:DATA_INICIO, LEVEL - 1) AS DATA_MES
      FROM DUAL
    CONNECT BY LEVEL <= MONTHS_BETWEEN(:DATA_FIM, :DATA_INICIO) + 1*/


    SELECT
        TO_CHAR(ADD_MONTHS(:DATA_INICIO, LEVEL - 1), 'MM/YYYY') AS MES_ANO,
        ADD_MONTHS(:DATA_INICIO, LEVEL - 1) AS DATA_MES,
        INITCAP(TRIM(TO_CHAR(ADD_MONTHS(:DATA_INICIO, LEVEL - 1), 'Month'))) || '/' ||
        TO_CHAR(ADD_MONTHS(:DATA_INICIO, LEVEL - 1), 'YYYY') AS MES_ANO_EXTENSO
    FROM DUAL
    CONNECT BY LEVEL <= MONTHS_BETWEEN(:DATA_FIM, :DATA_INICIO) + 1

),

-- CTE para consolidar as ocorrências do período
CTE_HORAS AS (
    SELECT B.COD_ORGANOGRAMA,
           B.COD_UNIDADE,
           B.DES_UNIDADE,
           B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.COD_EMP,
           TO_CHAR(TRUNC(HM.DATA_OCORRENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           /*TO_HOUR_MINUTES_03(SUM(CASE
                                    WHEN COD_OCORRENCIA = 2 THEN
                                     NUM_HORAS
                                    ELSE
                                     0
                                  END)) AS TOTAL_HORAS_TRAB,
           SUM(CASE
                 WHEN COD_OCORRENCIA = 2 THEN
                  NUM_HORAS
                 ELSE
                  0
               END) AS TOT_HORAS_TRAB*/
           SUM(CASE
                 WHEN COD_OCORRENCIA = 2 THEN
                  NUM_HORAS
                 ELSE
                  0
               END) AS TOT_HORAS_TRAB

      FROM RHAF1123 HM
      LEFT JOIN RHAF1119 TU ON HM.COD_CONTRATO = TU.COD_CONTRATO
                           AND (TU.DATA_FIM = '31/12/2999' OR
                                TU.DATA_FIM >= :DATA_REFERENCIA)
                           AND (TU.DATA_INICIO <= :DATA_REFERENCIA)
      INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON HM.COD_CONTRATO = B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
      LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON HM.COD_CONTRATO = E.COD_CONTRATO
                                           AND (E.DATA_FIM_AFAST IS NULL OR
                                                E.DATA_FIM_AFAST >= :DATA_REFERENCIA)
                                           AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
     WHERE HM.DATA_OCORRENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND B.COD_EMP = 8
       AND TU.COD_TURNO <> 85
       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST <> '31/12/2999')
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND HM.COD_CONTRATO = 392184
     GROUP BY B.COD_ORGANOGRAMA,
              B.COD_UNIDADE,
              B.DES_UNIDADE,
              B.COD_REDE,
              B.DES_REDE,
              B.COD_TIPO,
              B.COD_EMP,
              TRUNC(HM.DATA_OCORRENCIA, 'MM')

),

/*-- CTE para consolidar as faltas do período
CTE_FALTAS AS (
    SELECT B.COD_UNIDADE,
           B.DES_UNIDADE,
           B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.COD_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           SUM(C.QTDE_VD) AS TOT_FALTAS
           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_FALTAS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND C.COD_VD = 632
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
     GROUP BY B.COD_UNIDADE,
              B.DES_UNIDADE,
              B.COD_REDE,
              B.DES_REDE,
              B.COD_TIPO,
              B.COD_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),

-- CTE para consolidar os atestados
CTE_ATESTADOS AS (
    SELECT B.COD_UNIDADE,
           B.DES_UNIDADE,
           B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.COD_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           SUM(C.QTDE_VD) AS TOT_HR_ATESTADOS
           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_HORAS_ATESTADOS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND C.COD_VD = 897
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND C.COD_CONTRATO = 392184
     GROUP BY B.COD_UNIDADE,
              B.DES_UNIDADE,
              B.COD_REDE,
              B.DES_REDE,
              B.COD_TIPO,
              B.COD_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),*/

CTE_ATESTADOS_FALTAS AS (
    SELECT B.COD_ORGANOGRAMA,
           B.COD_UNIDADE,
           B.DES_UNIDADE,
           B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.COD_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           -- TOTAL FALTAS
           SUM(CASE WHEN C.COD_VD = 632 THEN C.QTDE_VD ELSE 0 END) AS TOT_FALTAS,

           -- TOTAL ATESTADOS
           SUM(CASE WHEN C.COD_VD = 897 THEN C.QTDE_VD ELSE 0 END) AS TOT_ATESTADOS,

           -- TOTAL FALTAS + ATESTADOS
           SUM(CASE WHEN C.COD_VD IN (632, 897) THEN C.QTDE_VD ELSE 0 END) AS TOT_FALTAS_ATESTADOS
           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_HORAS_ATESTADOS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND C.COD_CONTRATO = 392184
     GROUP BY B.COD_ORGANOGRAMA,
              B.COD_UNIDADE,
              B.DES_UNIDADE,
              B.COD_REDE,
              B.DES_REDE,
              B.COD_TIPO,
              B.COD_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),

-- CTE para consolidar os colaboradores ativos
CTE_COLABORADORES AS (
    SELECT B.COD_ORGANOGRAMA,
           B.COD_UNIDADE,
           B.DES_UNIDADE,
           B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.DES_TIPO,
           B.COD_EMP
      FROM VH_COLAB_PESSOA_AVT A
      INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON A.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
      LEFT JOIN RHAF1119 TU ON A.COD_CONTRATO = TU.COD_CONTRATO
                           AND (TU.DATA_FIM = '31/12/2999' OR
                                TU.DATA_FIM >= :DATA_REFERENCIA)
                           AND (TU.DATA_INICIO <= :DATA_REFERENCIA)
      LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO =
                                               E.COD_CONTRATO
                                           AND (E.DATA_FIM_AFAST IS NULL OR
                                                E.DATA_FIM_AFAST >= :DATA_REFERENCIA)
                                           AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
     WHERE (A.DATA_DEMISSAO IS NULL OR
            A.DATA_DEMISSAO >= :DATA_REFERENCIA)
       AND A.DATA_ADMISSAO <= :DATA_REFERENCIA
       AND B.COD_EMP = 8
       AND TU.COD_TURNO <> 85
       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST <> '31/12/2999')
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
       GROUP BY B.COD_UNIDADE,
                B.DES_UNIDADE,
                B.COD_REDE,
                B.DES_REDE,
                B.COD_TIPO,
                B.DES_TIPO,
                B.COD_EMP
),

--========================REDES==========--

CTE_HORAS_RD AS (
    SELECT B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.COD_EMP,
           TO_CHAR(TRUNC(HM.DATA_OCORRENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           SUM(CASE
                 WHEN COD_OCORRENCIA = 2 THEN
                  NUM_HORAS
                 ELSE
                  0
               END) AS TOT_HORAS_TRAB
      FROM RHAF1123 HM
      LEFT JOIN RHAF1119 TU ON HM.COD_CONTRATO = TU.COD_CONTRATO
                           AND (TU.DATA_FIM = '31/12/2999' OR
                                TU.DATA_FIM >= :DATA_REFERENCIA)
                           AND (TU.DATA_INICIO <= :DATA_REFERENCIA)
      INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON HM.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
      LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON HM.COD_CONTRATO =
                                               E.COD_CONTRATO
                                           AND (E.DATA_FIM_AFAST IS NULL OR
                                                E.DATA_FIM_AFAST >= :DATA_REFERENCIA)
                                           AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
     WHERE HM.DATA_OCORRENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND B.COD_EMP = 8
       AND TU.COD_TURNO <> 85
       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST <> '31/12/2999')
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND HM.COD_CONTRATO = 392184
     GROUP BY B.COD_REDE,
              B.DES_REDE,
              B.COD_TIPO,
              B.COD_EMP,
              TRUNC(HM.DATA_OCORRENCIA, 'MM')

),

/*-- CTE para consolidar as faltas do período
CTE_FALTAS_RD AS (
    SELECT B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.COD_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           SUM(C.QTDE_VD) AS TOT_FALTAS
           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_FALTAS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND C.COD_VD = 632
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
     GROUP BY B.COD_REDE,
              B.DES_REDE,
              B.COD_TIPO,
              B.COD_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),

-- CTE para consolidar os atestados
CTE_ATESTADOS_RD AS (
    SELECT B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.COD_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           SUM(C.QTDE_VD) AS TOT_HR_ATESTADOS
           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_HORAS_ATESTADOS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND C.COD_VD = 897
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND C.COD_CONTRATO = 392184
     GROUP BY B.COD_REDE,
              B.DES_REDE,
              B.COD_TIPO,
              B.COD_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),*/

CTE_ATESTADOS_FALTAS_RD AS (
    SELECT B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.COD_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           -- TOTAL FALTAS
           SUM(CASE WHEN C.COD_VD = 632 THEN C.QTDE_VD ELSE 0 END) AS TOT_FALTAS,

           -- TOTAL ATESTADOS
           SUM(CASE WHEN C.COD_VD = 897 THEN C.QTDE_VD ELSE 0 END) AS TOT_ATESTADOS,

           -- TOTAL FALTAS + ATESTADOS
           SUM(CASE WHEN C.COD_VD IN (632, 897) THEN C.QTDE_VD ELSE 0 END) AS TOT_FALTAS_ATESTADOS
           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_HORAS_ATESTADOS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND C.COD_CONTRATO = 392184
     GROUP BY B.COD_REDE,
              B.DES_REDE,
              B.COD_TIPO,
              B.COD_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),

-- CTE para consolidar os colaboradores ativos
CTE_COLABORADORES_RD AS (
    SELECT B.COD_REDE,
           B.DES_REDE,
           B.COD_TIPO,
           B.DES_TIPO,
           B.COD_EMP
      FROM VH_COLAB_PESSOA_AVT A
      INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON A.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
      LEFT JOIN RHAF1119 TU ON A.COD_CONTRATO = TU.COD_CONTRATO
                           AND (TU.DATA_FIM = '31/12/2999' OR
                                TU.DATA_FIM >= :DATA_REFERENCIA)
                           AND (TU.DATA_INICIO <= :DATA_REFERENCIA)
      LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO =
                                               E.COD_CONTRATO
                                           AND (E.DATA_FIM_AFAST IS NULL OR
                                                E.DATA_FIM_AFAST >= :DATA_REFERENCIA)
                                           AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
     WHERE (A.DATA_DEMISSAO IS NULL OR
           A.DATA_DEMISSAO >= :DATA_REFERENCIA)
       AND A.DATA_ADMISSAO <= :DATA_REFERENCIA
       AND B.COD_EMP = 8
       AND TU.COD_TURNO <> 85
       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST <> '31/12/2999')
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
       GROUP BY B.COD_REDE,
                B.DES_REDE,
                B.COD_TIPO,
                B.DES_TIPO,
                B.COD_EMP
),


--========================EMPRESA==================--
CTE_HORAS_EMP AS (
    SELECT B.COD_EMP,
           B.EDICAO_EMP,
           B.DES_EMP,
           TO_CHAR(TRUNC(HM.DATA_OCORRENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           SUM(CASE
                 WHEN COD_OCORRENCIA = 2 THEN
                  NUM_HORAS
                 ELSE
                  0
               END) AS TOT_HORAS_TRAB
      FROM RHAF1123 HM
      LEFT JOIN RHAF1119 TU ON HM.COD_CONTRATO = TU.COD_CONTRATO
                           AND (TU.DATA_FIM = '31/12/2999' OR
                                TU.DATA_FIM >= :DATA_REFERENCIA)
                           AND (TU.DATA_INICIO <= :DATA_REFERENCIA)
      INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON HM.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
      LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON HM.COD_CONTRATO =
                                               E.COD_CONTRATO
                                           AND (E.DATA_FIM_AFAST IS NULL OR
                                                E.DATA_FIM_AFAST >= :DATA_REFERENCIA)
                                           AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
     WHERE HM.DATA_OCORRENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND B.COD_EMP = 8
       AND TU.COD_TURNO <> 85
       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST <> '31/12/2999')
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND HM.COD_CONTRATO = 392184
     GROUP BY B.COD_EMP,
              B.EDICAO_EMP,
              B.DES_EMP,
              TRUNC(HM.DATA_OCORRENCIA, 'MM')

),

/*-- CTE para consolidar as faltas do período
CTE_FALTAS_EMP AS (
    SELECT B.COD_EMP,
           B.EDICAO_EMP,
           B.DES_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           SUM(C.QTDE_VD) AS TOT_FALTAS
           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_FALTAS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND C.COD_VD = 632
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
     GROUP BY B.COD_EMP,
              B.EDICAO_EMP,
              B.DES_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),

-- CTE para consolidar os atestados
CTE_ATESTADOS_EMP AS (
    SELECT B.COD_EMP,
           B.EDICAO_EMP,
           B.DES_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           SUM(C.QTDE_VD) AS TOT_HR_ATESTADOS
           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_HORAS_ATESTADOS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       AND C.COD_VD = 897
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND C.COD_CONTRATO = 392184
     GROUP BY B.COD_EMP,
              B.EDICAO_EMP,
              B.DES_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),*/


CTE_ATESTADOS_FALTAS_EMP AS (
    SELECT B.COD_EMP,
           B.EDICAO_EMP,
           B.DES_EMP,
           TO_CHAR(TRUNC(D.DATA_REFERENCIA, 'MM'), 'MM/YYYY') AS MES_ANO,
           -- TOTAL FALTAS
           SUM(CASE WHEN C.COD_VD = 632 THEN C.QTDE_VD ELSE 0 END) AS TOT_FALTAS,

           -- TOTAL ATESTADOS
           SUM(CASE WHEN C.COD_VD = 897 THEN C.QTDE_VD ELSE 0 END) AS TOT_ATESTADOS,

           -- TOTAL FALTAS + ATESTADOS
           SUM(CASE WHEN C.COD_VD IN (632, 897) THEN C.QTDE_VD ELSE 0 END) AS TOT_FALTAS_ATESTADOS

           --TO_HOUR_MINUTES_03(SUM(C.QTDE_VD)) AS TOTAL_HORAS_ATESTADOS
      FROM RHFP1006 C
     INNER JOIN RHFP1003 D ON C.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
     INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON C.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
     WHERE D.DATA_REFERENCIA BETWEEN :DATA_INICIO AND :DATA_FIM
       --AND C.COD_VD = 897
       AND D.COD_ORGANOGRAMA = 8
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
    --AND C.COD_CONTRATO = 392184
     GROUP BY B.COD_EMP,
              B.EDICAO_EMP,
              B.DES_EMP,
              TRUNC(D.DATA_REFERENCIA, 'MM')
),


-- CTE para consolidar os colaboradores ativos
CTE_COLABORADORES_EMP AS (
    SELECT B.COD_EMP,
           B.EDICAO_EMP,
           B.DES_EMP
      FROM VH_COLAB_PESSOA_AVT A
      INNER JOIN VH_EST_ORG_CONTRATO_AVT B ON A.COD_CONTRATO =
                                             B.COD_CONTRATO
                                         AND (B.DATA_FIM_ORG = '31/12/2999' OR
                                              B.DATA_FIM_ORG >= :DATA_REFERENCIA)
                                         AND (B.DATA_INI_ORG <= :DATA_REFERENCIA)
      LEFT JOIN RHAF1119 TU ON A.COD_CONTRATO = TU.COD_CONTRATO
                           AND (TU.DATA_FIM = '31/12/2999' OR
                                TU.DATA_FIM >= :DATA_REFERENCIA)
                           AND (TU.DATA_INICIO <= :DATA_REFERENCIA)
      LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO =
                                               E.COD_CONTRATO
                                           AND (E.DATA_FIM_AFAST IS NULL OR
                                                E.DATA_FIM_AFAST >= :DATA_REFERENCIA)
                                           AND (E.DATA_INI_AFAST <= :DATA_REFERENCIA)
     WHERE (A.DATA_DEMISSAO IS NULL OR
           A.DATA_DEMISSAO >= :DATA_REFERENCIA)
       AND A.DATA_ADMISSAO <= :DATA_REFERENCIA
       AND B.COD_EMP = 8
       AND TU.COD_TURNO <> 85
       AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST <> '31/12/2999')
       AND (B.COD_TIPO = :TIPO OR :TIPO = 0)
       AND (B.COD_UNIDADE = :FILIAL OR :FILIAL = 0)
       AND (B.COD_REDE = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0)
       GROUP BY B.COD_EMP,
                B.EDICAO_EMP,
                B.DES_EMP

),

CTE_COLABORADORES_COM_MESES AS (
  SELECT DISTINCT
    B.COD_ORGANOGRAMA,
    B.COD_UNIDADE,
    B.DES_UNIDADE,
    B.COD_REDE,
    B.DES_REDE,
    B.COD_TIPO,
    B.DES_TIPO,
    B.COD_EMP,
    M.MES_ANO,
    M.MES_ANO_EXTENSO,
    COUNT(*) OVER (PARTITION BY COD_UNIDADE, MES_ANO)
  FROM VH_COLAB_PESSOA_AVT A
  INNER JOIN VH_EST_ORG_CONTRATO_AVT B
    ON A.COD_CONTRATO = B.COD_CONTRATO
    AND (B.DATA_FIM_ORG = '31/12/2999' OR B.DATA_FIM_ORG >= :DATA_REFERENCIA)
    AND B.DATA_INI_ORG <= :DATA_REFERENCIA
  LEFT JOIN RHAF1119 TU ON A.COD_CONTRATO = TU.COD_CONTRATO
    AND (TU.DATA_FIM = '31/12/2999' OR TU.DATA_FIM >= :DATA_REFERENCIA)
    AND TU.DATA_INICIO <= :DATA_REFERENCIA
  LEFT JOIN VH_AFASTAMENTOS_COLAB_AVT E ON A.COD_CONTRATO = E.COD_CONTRATO
    AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST >= :DATA_REFERENCIA)
    AND E.DATA_INI_AFAST <= :DATA_REFERENCIA
  CROSS JOIN CTE_MESES M
  WHERE (A.DATA_DEMISSAO IS NULL OR A.DATA_DEMISSAO >= :DATA_REFERENCIA)
    AND A.DATA_ADMISSAO <= :DATA_REFERENCIA
    AND B.COD_EMP = 8
    AND TU.COD_TURNO <> 85
    AND (E.DATA_FIM_AFAST IS NULL OR E.DATA_FIM_AFAST <> '31/12/2999')
    AND (:TIPO = 0 OR B.COD_TIPO = :TIPO)
    AND (:FILIAL = 0 OR B.COD_UNIDADE = :FILIAL)
    AND (:REDE = 0 OR B.COD_REDE = TO_CHAR(:REDE))
)


SELECT DISTINCT
       C.COD_ORGANOGRAMA,
       C.COD_UNIDADE,
       C.DES_UNIDADE,
       C.COD_REDE,
       C.DES_REDE,
       C.COD_TIPO,
       C.MES_ANO,
       C.MES_ANO_EXTENSO,

       -- TOTAL HORAS TRABALHADAS
       ROUND(NVL(H.TOT_HORAS_TRAB, 0), 2) AS TOT_HR_TRAB_UNI,

       -- FALTAS
       ROUND(NVL(A1.TOT_FALTAS, 0), 2) AS TOT_FALTAS_UNI,

       -- ATESTADOS
       ROUND(NVL(A1.TOT_ATESTADOS, 0), 2) AS TOT_ATESTADOS_UNI,

       -- FALTAS + ATESTADOS
       ROUND(NVL(A1.TOT_FALTAS_ATESTADOS, 0), 2) AS TOT_FT_ATEST_UNI,

       -- % ABSENTEISMO
       NVL(ROUND(NVL(A1.TOT_FALTAS_ATESTADOS, 0) * 100 / NULLIF(NVL(H.TOT_HORAS_TRAB, 0), 0), 2), 0) AS PERC_ABSENTEISMO_UNI,

       'REDES =>' AS ESPACO_1,

       R5.COD_REDE AS REDE_RD,
       R5.DES_REDE AS DES_REDE_RD,
       R5.COD_TIPO AS COD_TIPO_RD,
       C.MES_ANO AS MES_ANO_RD,
       C.MES_ANO_EXTENSO,

       ROUND(NVL(R6.TOT_HORAS_TRAB, 0), 2) AS TOT_HR_TRAB_RD,
       ROUND(NVL(R7.TOT_FALTAS, 0), 2) AS TOT_FALTAS_RD,
       ROUND(NVL(R7.TOT_ATESTADOS, 0), 2) AS TOT_ATESTADOS_RD,
       ROUND(NVL(R7.TOT_FALTAS_ATESTADOS, 0), 2) AS TOT_FT_ATEST_RD,
       NVL(ROUND(NVL(R7.TOT_FALTAS_ATESTADOS, 0) * 100 / NULLIF(NVL(R6.TOT_HORAS_TRAB, 0), 0), 2), 0) AS PERC_ABSENTEISMO_RD,

       'EMPRESA =>' AS ESPACO_2,

       G1.EDICAO_EMP,
       G1.DES_EMP,
       C.MES_ANO AS MES_ANO_EMP,
       C.MES_ANO_EXTENSO,

       ROUND(NVL(G2.TOT_HORAS_TRAB, 0), 2) AS TOT_HR_TRAB_EMP,
       ROUND(NVL(G3.TOT_FALTAS, 0), 2) AS TOT_FALTAS_EMP,
       ROUND(NVL(G3.TOT_ATESTADOS, 0), 2) AS TOT_ATESTADOS_EMP,
       ROUND(NVL(G3.TOT_FALTAS_ATESTADOS, 0), 2) AS TOT_FT_ATEST_EMP,
       NVL(ROUND(NVL(G3.TOT_FALTAS_ATESTADOS, 0) * 100 / NULLIF(NVL(G2.TOT_HORAS_TRAB, 0), 0), 2), 0) AS PERC_ABSENTEISMO_EMP,

       SYSDATE AS DATA_SISTEMA,

       'Tipo: ' || TO_CHAR(:TIPO) || ' / ' ||
       'Filial: ' || TO_CHAR(:FILIAL) || ' / ' ||
       'Rede: ' || TO_CHAR(:REDE) || ' / ' ||
       'Data de: ' || TO_CHAR(:DATA_INICIO, 'DD/MM/YYYY') || ' à ' || TO_CHAR(:DATA_FIM, 'DD/MM/YYYY') || ' / ' ||
       'Referência: ' || TO_CHAR(:DATA_REFERENCIA, 'DD/MM/YYYY') AS PARAMETROS

FROM CTE_COLABORADORES_COM_MESES C
LEFT JOIN CTE_HORAS H ON C.COD_ORGANOGRAMA = H.COD_ORGANOGRAMA AND C.MES_ANO = H.MES_ANO
LEFT JOIN CTE_ATESTADOS_FALTAS A1 ON C.COD_ORGANOGRAMA = A1.COD_ORGANOGRAMA AND C.MES_ANO = A1.MES_ANO
LEFT JOIN CTE_COLABORADORES_RD R5 ON C.COD_REDE = R5.COD_REDE AND C.COD_TIPO = R5.COD_TIPO AND C.COD_EMP = R5.COD_EMP
LEFT JOIN CTE_HORAS_RD R6 ON C.COD_REDE = R6.COD_REDE AND C.COD_TIPO = R6.COD_TIPO AND C.COD_EMP = R6.COD_EMP AND C.MES_ANO = R6.MES_ANO
LEFT JOIN CTE_ATESTADOS_FALTAS_RD R7 ON C.COD_REDE = R7.COD_REDE AND C.COD_TIPO = R7.COD_TIPO AND C.COD_EMP = R7.COD_EMP AND C.MES_ANO = R7.MES_ANO
LEFT JOIN CTE_COLABORADORES_EMP G1 ON C.COD_EMP = G1.COD_EMP
LEFT JOIN CTE_HORAS_EMP G2 ON C.COD_EMP = G2.COD_EMP AND C.MES_ANO = G2.MES_ANO
LEFT JOIN CTE_ATESTADOS_FALTAS_EMP G3 ON C.COD_EMP = G3.COD_EMP AND C.MES_ANO = G3.MES_ANO

ORDER BY C.COD_TIPO, C.COD_REDE, R5.COD_REDE, C.DES_UNIDADE, TO_DATE(C.MES_ANO, 'MM/YYYY')
