/*SCRIPTS PARA CALCULAR APR DOS DEMITIDOS, PROPORCIONAIS E INTEGRAL*/


/*PROCESSO PARA GERAR O CÁLCULO DOS DEMITIDOS PARA O CÁLCULO DA P.L.R.*/




             /*=================================
			   =========VERSÕES ANTUAIS=========
			   ============OFICIAIS=============
			   =================================*/




/*CALCULA DEMITIDOS PROPORCIONAL AO MESES TRABALHADOS ANTES DA DEMISSÃO*/


SELECT
    A.COD_CONTRATO,
    A.DES_PESSOA,
    A.COD_FUNCAO,
    A.DES_FUNCAO,
    A.DES_UNIDADE,
    A.DATA_ADMISSAO,
    A.DATA_DEMISSAO,
    A.COD_DEMISSAO,
    A.DES_DEMISSAO,

    -- Quantidade de meses até demissão
    CASE
        WHEN A.DATA_DEMISSAO BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') AND TO_DATE('2024-12-31', 'YYYY-MM-DD') THEN
            GREATEST(
                0,
                EXTRACT(MONTH FROM A.DATA_DEMISSAO) -
                CASE
                    WHEN EXTRACT(DAY FROM A.DATA_DEMISSAO) <= 14 THEN 1
                    ELSE 0
                END
            )
        ELSE 0
    END AS QTDE_MESES_2024,

    -- Último salário
    TO_CHAR(LS.VALOR_VD, 'FM999G999G990D00') AS ULTIMO_SALARIO,

    -- Total adicionais (horas perdidas)
    TO_CHAR(ADICIONAIS.TOTAL_ADICIONAIS, 'FM999G999G990D00') AS TOTAL_ADICIONAIS,

    -- Formatação HH:MI
    TO_CHAR(TRUNC(ADICIONAIS.TOTAL_ADICIONAIS)) || ':' ||
    LPAD(TO_CHAR(ROUND((ADICIONAIS.TOTAL_ADICIONAIS - TRUNC(ADICIONAIS.TOTAL_ADICIONAIS)) * 60)), 2, '0')
    AS TOTAL_ADICIONAIS_HORA,

    -- APR final
    ROUND(
        (
            NVL(LS.VALOR_VD, 0) / 12 *
            GREATEST(
                0,
                EXTRACT(MONTH FROM A.DATA_DEMISSAO) -
                CASE WHEN EXTRACT(DAY FROM A.DATA_DEMISSAO) <= 14 THEN 1 ELSE 0 END
            ) * 0.50
        ) *
        (1 - (NVL(ADICIONAIS.TOTAL_ADICIONAIS, 0) / 2) / 100)
    , 2) AS VALOR_GERAL_PLR

FROM V_CONTRATOS_DEMITIDOS_AVT A

-- LATERAL 1: Último salário (VD 1700)
LEFT JOIN LATERAL (
    SELECT B.VALOR_VD
    FROM RHFP1006 B
    LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
    LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
    WHERE B.COD_CONTRATO = A.COD_CONTRATO
      AND B.COD_MESTRE_EVENTO IN (
          16723, 16646, 16494, 16572, 16798, 16873,
          16941, 17017, 17151, 17226, 17090, 17337)
      AND B.COD_VD = 1700
      AND D.DATA_REFERENCIA BETWEEN TO_DATE('01/01/2024','DD/MM/YYYY') AND A.DATA_DEMISSAO
    ORDER BY D.DATA_REFERENCIA DESC
    FETCH FIRST 1 ROW ONLY
) LS ON 1=1

-- LATERAL 2: Soma das horas perdidas
LEFT JOIN LATERAL (
    SELECT SUM(B.QTDE_VD) AS TOTAL_ADICIONAIS
    FROM RHFP1006 B
    LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
    LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
    WHERE B.COD_CONTRATO = A.COD_CONTRATO
      AND B.COD_MESTRE_EVENTO IN (
          16723, 16646, 16494, 16572, 16798, 16873,
          16941, 17017, 17151, 17226, 17090, 17337)
      AND B.COD_VD IN (631, 632, 831, 832, 887, 897)
      AND D.DATA_REFERENCIA BETWEEN TO_DATE('01/01/2024','DD/MM/YYYY') AND A.DATA_DEMISSAO
) ADICIONAIS ON 1=1

-- Filtros principais
WHERE A.DATA_DEMISSAO BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') AND TO_DATE('2024-12-31', 'YYYY-MM-DD')
  AND A.COD_EMP = '008'
  AND A.COD_DEMISSAO NOT IN (10, 13, 14, 21)
  AND A.DATA_ADMISSAO <= TO_DATE('01/07/2024', 'DD/MM/YYYY')
  AND A.DES_FUNCAO NOT LIKE '%APRENDIZ%'
  AND A.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
  AND A.DES_FUNCAO NOT LIKE '%SUPERVISOR%'
  AND A.DES_FUNCAO LIKE '%GERENTE%'
  AND A.COD_FUNCAO NOT IN (325)
  AND A.COD_TIPO = 3

ORDER BY A.COD_CONTRATO






/*CÁLCULO INTEGRAL*/



/*CALCULA DEMITIDOS NO ANO ATUAL*/

SELECT
    A.COD_CONTRATO,
    A.DES_PESSOA,
    A.COD_FUNCAO,
    A.DES_FUNCAO,
    A.DES_UNIDADE,
    A.DATA_ADMISSAO,
    A.DATA_DEMISSAO,
    A.COD_DEMISSAO,
    A.DES_DEMISSAO,

    /*-- Quantidade de meses até demissão
    CASE
        WHEN A.DATA_DEMISSAO BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') AND TO_DATE('2024-12-31', 'YYYY-MM-DD') THEN
            GREATEST(
                0,
                EXTRACT(MONTH FROM A.DATA_DEMISSAO) -
                CASE
                    WHEN EXTRACT(DAY FROM A.DATA_DEMISSAO) <= 14 THEN 1
                    ELSE 0
                END
            )
        ELSE 0
    END AS QTDE_MESES_2024,*/

    -- Último salário
    TO_CHAR(LS.VALOR_VD, 'FM999G999G990D00') AS ULTIMO_SALARIO,

    -- Total adicionais (horas perdidas)
    TO_CHAR(ADICIONAIS.TOTAL_ADICIONAIS, 'FM999G999G990D00') AS TOTAL_ADICIONAIS,

    -- Formatação HH:MI
    TO_CHAR(TRUNC(ADICIONAIS.TOTAL_ADICIONAIS)) || ':' ||
    LPAD(TO_CHAR(ROUND((ADICIONAIS.TOTAL_ADICIONAIS - TRUNC(ADICIONAIS.TOTAL_ADICIONAIS)) * 60)), 2, '0')
    AS TOTAL_ADICIONAIS_HORA,

    -- APR final
    ROUND(
        (
            NVL(LS.VALOR_VD, 0) / 12 *
            GREATEST(
                0,
                EXTRACT(MONTH FROM A.DATA_DEMISSAO) -
                CASE WHEN EXTRACT(DAY FROM A.DATA_DEMISSAO) <= 14 THEN 1 ELSE 0 END
            ) * 0.50
        ) *
        (1 - (NVL(ADICIONAIS.TOTAL_ADICIONAIS, 0) / 2) / 100)
    , 2) AS VALOR_GERAL_PLR

FROM V_CONTRATOS_DEMITIDOS_AVT A

-- LATERAL 1: Último salário (VD 1700)
LEFT JOIN LATERAL (
    SELECT B.VALOR_VD
    FROM RHFP1006 B
    LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
    LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
    WHERE B.COD_CONTRATO = A.COD_CONTRATO
      AND B.COD_MESTRE_EVENTO IN (
          16723, 16646, 16494, 16572, 16798, 16873,
          16941, 17017, 17151, 17226, 17090, 17337)
      AND B.COD_VD = 1700
      AND D.DATA_REFERENCIA BETWEEN TO_DATE('01/01/2024','DD/MM/YYYY') AND A.DATA_DEMISSAO
    ORDER BY D.DATA_REFERENCIA DESC
    FETCH FIRST 1 ROW ONLY
) LS ON 1=1

-- LATERAL 2: Soma das horas perdidas
LEFT JOIN LATERAL (
    SELECT SUM(B.QTDE_VD) AS TOTAL_ADICIONAIS
    FROM RHFP1006 B
    LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
    LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
    WHERE B.COD_CONTRATO = A.COD_CONTRATO
      AND B.COD_MESTRE_EVENTO IN (16723, 16646, 16494, 16572, 16798, 16873,
          16941, 17017, 17151, 17226, 17090, 17337, 17434, 17503, 17581)
      AND B.COD_VD IN (631, 632, 831, 832, 887, 897)
      AND D.DATA_REFERENCIA BETWEEN TO_DATE('01/01/2024','DD/MM/YYYY') AND A.DATA_DEMISSAO
) ADICIONAIS ON 1=1

-- Filtros principais
WHERE A.DATA_DEMISSAO BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-12-31', 'YYYY-MM-DD')
  AND A.COD_EMP = '008'
  AND A.COD_DEMISSAO NOT IN (10, 13, 14, 21)
  --AND A.DATA_ADMISSAO <= TO_DATE('01/07/2024', 'DD/MM/YYYY')
  AND A.DES_FUNCAO NOT LIKE '%APRENDIZ%'
  AND A.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
  AND A.DES_FUNCAO NOT LIKE '%SUPERVISOR%'
  AND A.DES_FUNCAO NOT LIKE '%GERENTE%'
  AND A.COD_FUNCAO NOT IN (325)
  AND A.COD_TIPO = 1

ORDER BY A.COD_CONTRATO





/*================================================================================
==================================================================================*/






--=============================PROPORCIONAL=======================--


             /*=================================
			   =======VERSÕES ANTERIORES========
			   =================================*/

---====GERAL===---

SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.DES_FUNCAO,
       A.DES_UNIDADE,
       A.DATA_ADMISSAO,
       A.DATA_DEMISSAO,
       A.COD_DEMISSAO || ' - ' || A.DES_DEMISSAO AS CAUSA_DEMISSAO,
       (SELECT TO_CHAR(MAX(B.VALOR_VD), 'FM999G999G990D00')
          FROM RHFP1006 B
          LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO = C.COD_MESTRE_EVENTO
          LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO = D.COD_MESTRE_EVENTO
         WHERE B.COD_CONTRATO = A.COD_CONTRATO
           AND B.COD_MESTRE_EVENTO IN
               (15623, 15683, 15757, 15837, 15911, 15987, 16052, 16130, 16198,
                16268, 16329, 16413)
           AND B.COD_VD = 1700
           AND D.DATA_REFERENCIA <= A.DATA_DEMISSAO FETCH FIRST 1 ROW ONLY) AS ULTIMO_SALARIO

  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 1
   AND A.COD_EMP = '008'
   AND A.DATA_DEMISSAO BETWEEN '01/01/2023' AND '31/12/2023'
   AND A.DATA_ADMISSAO <= '01/07/2023'
   AND A.COD_CONTRATO NOT IN (6970)
   AND A.COD_DEMISSAO NOT IN (10, 13, 14, 21)
   AND A.DES_FUNCAO NOT LIKE '%APRENDIZ%'
   AND A.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
   AND (LEAST(A.DATA_DEMISSAO, TO_DATE('31/01/2023', 'DD/MM/YYYY')) - GREATEST(A.DATA_ADMISSAO, TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + 1 >= 15
   
   
   
--====================

--==GERENTES==--

SELECT SUB.COD_CONTRATO,
       SUB.DES_PESSOA,
       SUB.DES_FUNCAO,
       SUB.DES_UNIDADE,
       SUB.DATA_ADMISSAO,
       SUB.DATA_DEMISSAO,
       SUB.CAUSA_DEMISSAO,
       SUB.NUM_MEDIA,
       TO_CHAR((SUB.ULTIMO_SALARIO), 'FM999G999G990D00') AS ULT_SALARIO,
       TO_CHAR(ROUND(SUB.ULTIMO_SALARIO * 4, 2), 'FM999G999G990D00') AS SALARIO_X4,
       FLOOR(MONTHS_BETWEEN(SUB.DATA_DEMISSAO,
                            TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + CASE
         WHEN EXTRACT(DAY FROM SUB.DATA_DEMISSAO) >= 15 THEN
          1
         ELSE
          0
       END - CASE
         WHEN SUB.DATA_ADMISSAO > TO_DATE('01/01/2023', 'DD/MM/YYYY') AND
              EXTRACT(DAY FROM SUB.DATA_ADMISSAO) >= 15 THEN
          1
         ELSE
          0
       END AS MESES_TRABALHADOS,
       TO_CHAR(NVL(ROUND((ROUND(SUB.ULTIMO_SALARIO * 4, 2) / 12) * (FLOOR(MONTHS_BETWEEN(SUB.DATA_DEMISSAO,
                                                                                         TO_DATE('01/01/2023',
                                                                                                 'DD/MM/YYYY'))) + CASE
                           WHEN EXTRACT(DAY FROM SUB.DATA_DEMISSAO) >= 15 THEN
                            1
                           ELSE
                            0
                         END - CASE
                           WHEN SUB.DATA_ADMISSAO > TO_DATE('01/01/2023', 'DD/MM/YYYY') AND
                                EXTRACT(DAY FROM SUB.DATA_ADMISSAO) >= 15 THEN
                            1
                           ELSE
                            0
                         END),
                         2),
                   NULL),
               'FM999G999G990D00') AS APR_CALCULADA
  FROM (SELECT A.COD_CONTRATO,
               A.DES_PESSOA,
               A.DES_FUNCAO,
               A.DES_UNIDADE,
               A.DATA_ADMISSAO,
               A.DATA_DEMISSAO,
               B.NUM_MEDIA,
               A.COD_DEMISSAO || ' - ' || A.DES_DEMISSAO AS CAUSA_DEMISSAO,
               (SELECT MAX(B.VALOR_VD)
                  FROM RHFP1006 B
                  LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO =
                                          C.COD_MESTRE_EVENTO
                  LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO =
                                          D.COD_MESTRE_EVENTO
                 WHERE B.COD_CONTRATO = A.COD_CONTRATO
                   AND B.COD_MESTRE_EVENTO IN
                       (15623, 15683, 15757, 15837, 15911, 15987, 16052, 16130,
                        16198, 16268, 16329, 16413)
                   AND B.COD_VD = 1700
                   AND D.DATA_REFERENCIA <= A.DATA_DEMISSAO FETCH FIRST 1 ROW ONLY) AS ULTIMO_SALARIO
          FROM V_DADOS_COLAB_AVT A
          LEFT JOIN GRZ_AVALIACAO_REALIZADAS B ON A.COD_CONTRATO = B.COD_CONTRATO
         WHERE A.STATUS = 1
           AND A.COD_EMP = '008'
           AND A.DATA_DEMISSAO BETWEEN TO_DATE('01/01/2023', 'DD/MM/YYYY') AND
               TO_DATE('31/12/2023', 'DD/MM/YYYY')
           AND A.DATA_ADMISSAO <= TO_DATE('01/07/2023', 'DD/MM/YYYY')
           AND A.COD_CONTRATO NOT IN (6970)
           AND A.COD_DEMISSAO NOT IN (10, 13, 14, 21)
           AND (A.DES_FUNCAO LIKE '%GERENTE%' OR
               A.DES_FUNCAO LIKE '%COMPRADOR%' OR
               A.DES_FUNCAO LIKE '%SUPERVISOR%')
           AND A.DES_FUNCAO NOT LIKE '%APRENDIZ%'
           AND A.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
           AND (LEAST(A.DATA_DEMISSAO, TO_DATE('31/01/2023', 'DD/MM/YYYY')) -
               GREATEST(A.DATA_ADMISSAO,
                         TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + 1 >= 15) SUB




--==COLABORADORES==--

SELECT SUB.COD_CONTRATO,
       SUB.DES_PESSOA,
       SUB.DES_FUNCAO,
       SUB.DES_UNIDADE,
       SUB.DATA_ADMISSAO,
       SUB.DATA_DEMISSAO,
       SUB.CAUSA_DEMISSAO,
       SUB.NUM_MEDIA,
       TO_CHAR((SUB.ULTIMO_SALARIO), 'FM999G999G990D00') AS ULT_SALARIO,
       /*TO_CHAR(ROUND(SUB.ULTIMO_SALARIO * 4, 2), 'FM999G999G990D00') AS SALARIO_X4,*/
       FLOOR(MONTHS_BETWEEN(SUB.DATA_DEMISSAO,
                            TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + CASE
         WHEN EXTRACT(DAY FROM SUB.DATA_DEMISSAO) >= 15 THEN
          1
         ELSE
          0
       END - CASE
         WHEN SUB.DATA_ADMISSAO > TO_DATE('01/01/2023', 'DD/MM/YYYY') AND
              EXTRACT(DAY FROM SUB.DATA_ADMISSAO) >= 15 THEN
          1
         ELSE
          0
       END AS MESES_TRABALHADOS,
       TO_CHAR(NVL(ROUND((ROUND(SUB.ULTIMO_SALARIO) / 12) * (FLOOR(MONTHS_BETWEEN(SUB.DATA_DEMISSAO,
                                                                                         TO_DATE('01/01/2023',
                                                                                                 'DD/MM/YYYY'))) + CASE
                           WHEN EXTRACT(DAY FROM SUB.DATA_DEMISSAO) >= 15 THEN
                            1
                           ELSE
                            0
                         END - CASE
                           WHEN SUB.DATA_ADMISSAO > TO_DATE('01/01/2023', 'DD/MM/YYYY') AND
                                EXTRACT(DAY FROM SUB.DATA_ADMISSAO) >= 15 THEN
                            1
                           ELSE
                            0
                         END),
                         2),
                   NULL),
               'FM999G999G990D00') AS APR_CALCULADA
  FROM (SELECT A.COD_CONTRATO,
               A.DES_PESSOA,
               A.DES_FUNCAO,
               A.DES_UNIDADE,
               A.DATA_ADMISSAO,
               A.DATA_DEMISSAO,
               B.NUM_MEDIA,
               A.COD_DEMISSAO || ' - ' || A.DES_DEMISSAO AS CAUSA_DEMISSAO,
               (SELECT MAX(B.VALOR_VD)
                  FROM RHFP1006 B
                  LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO =
                                          C.COD_MESTRE_EVENTO
                  LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO =
                                          D.COD_MESTRE_EVENTO
                 WHERE B.COD_CONTRATO = A.COD_CONTRATO
                   AND B.COD_MESTRE_EVENTO IN
                       (15623, 15683, 15757, 15837, 15911, 15987, 16052, 16130,
                        16198, 16268, 16329, 16413)
                   AND B.COD_VD = 1700
                   AND D.DATA_REFERENCIA <= A.DATA_DEMISSAO FETCH FIRST 1 ROW ONLY) AS ULTIMO_SALARIO
          FROM V_DADOS_COLAB_AVT A
          LEFT JOIN GRZ_AVALIACAO_REALIZADAS B ON A.COD_CONTRATO = B.COD_CONTRATO
         WHERE A.STATUS = 1
           AND A.COD_EMP = '008'
           AND A.DATA_DEMISSAO BETWEEN TO_DATE('01/01/2023', 'DD/MM/YYYY') AND
               TO_DATE('31/12/2023', 'DD/MM/YYYY')
           AND A.DATA_ADMISSAO <= TO_DATE('01/07/2023', 'DD/MM/YYYY')
           AND A.COD_CONTRATO NOT IN (6970)
           AND A.COD_DEMISSAO NOT IN (10, 13, 14, 21)
           AND A.DES_FUNCAO NOT LIKE '%GERENTE%'
           AND A.DES_FUNCAO NOT LIKE '%COMPRADOR%'
           AND A.DES_FUNCAO NOT LIKE '%SUPERVISOR%'
           AND A.DES_FUNCAO NOT LIKE '%APRENDIZ%'
           AND A.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
           AND (LEAST(A.DATA_DEMISSAO, TO_DATE('31/01/2023', 'DD/MM/YYYY')) -
               GREATEST(A.DATA_ADMISSAO,
                         TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + 1 >= 15) SUB
                         
                         
                         

--==========================INTEGRAL==========================--

---===GERAL===---

SELECT A.COD_CONTRATO,
         A.DES_PESSOA,
         A.DES_FUNCAO,
         A.DES_UNIDADE,
         A.DATA_ADMISSAO,
         A.DATA_DEMISSAO,
         A.COD_DEMISSAO || ' - ' || A.DES_DEMISSAO AS CAUSA_DEMISSAO,
         (SELECT TO_CHAR(MAX(B.VALOR_VD), 'FM999G999G990D00')
            FROM RHFP1006 B
            LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO =
                                    C.COD_MESTRE_EVENTO
            LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO =
                                    D.COD_MESTRE_EVENTO
           WHERE B.COD_CONTRATO = A.COD_CONTRATO
             AND B.COD_MESTRE_EVENTO IN
                 (15623, 15683, 15757, 15837, 15911, 15987, 16052, 16130,
                  16198, 16268, 16329, 16413)
             AND B.COD_VD = 1700
             AND D.DATA_REFERENCIA <= A.DATA_DEMISSAO FETCH FIRST 1 ROW ONLY) AS ULTIMO_SALARIO
  
    FROM V_DADOS_COLAB_AVT A
   WHERE A.STATUS = 1
     AND A.COD_EMP = '008'
     AND A.DATA_DEMISSAO >= '01/01/2024'   
     AND A.DATA_DEMISSAO <= SYSDATE
     AND A.DATA_ADMISSAO <= '01/07/2023'
     AND A.COD_CONTRATO NOT IN (6970)
     AND A.COD_DEMISSAO NOT IN (10, 13, 14, 21)
     AND A.DES_FUNCAO NOT LIKE '%APRENDIZ%'
     AND A.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
     AND (LEAST(A.DATA_DEMISSAO, TO_DATE('31/01/2023', 'DD/MM/YYYY')) - GREATEST(A.DATA_ADMISSAO, TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + 1 >= 15;
     
     
     
--================--
 
--==GERENTES==--

SELECT SUB.COD_CONTRATO,
       SUB.DES_PESSOA,
       SUB.DES_FUNCAO,
       SUB.DES_UNIDADE,
       SUB.DATA_ADMISSAO,
       SUB.DATA_DEMISSAO,
       SUB.CAUSA_DEMISSAO,
       SUB.NUM_MEDIA,
       TO_CHAR((SUB.ULTIMO_SALARIO), 'FM999G999G990D00') AS ULT_SALARIO,
       TO_CHAR(
           ROUND(
               CASE 
                   WHEN SUB.DES_FUNCAO LIKE '%SUPERVISOR%' THEN SUB.ULTIMO_SALARIO * 6
                   ELSE SUB.ULTIMO_SALARIO * 4
               END,
               2
           ),
           'FM999G999G990D00'
       ) AS SALARIO_X,
       CASE 
           WHEN SUB.DATA_DEMISSAO >= TO_DATE('01/01/2024', 'DD/MM/YYYY') THEN 
               12
           ELSE
               FLOOR(MONTHS_BETWEEN(LEAST(SUB.DATA_DEMISSAO, TO_DATE('31/12/2023', 'DD/MM/YYYY')), TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + 
               CASE 
                   WHEN EXTRACT(DAY FROM LEAST(SUB.DATA_DEMISSAO, TO_DATE('31/12/2023', 'DD/MM/YYYY'))) >= 15 THEN 1 
                   ELSE 0 
               END
       END AS MESES_TRABALHADOS,
       TO_CHAR(
           NVL(
               ROUND(
                   (
                       ROUND(
                           CASE 
                               WHEN SUB.DES_FUNCAO LIKE '%SUPERVISOR%' THEN SUB.ULTIMO_SALARIO * 6
                               ELSE SUB.ULTIMO_SALARIO * 4
                           END,
                           2
                       ) / 12
                   ) * 
                   CASE 
                       WHEN SUB.DATA_DEMISSAO >= TO_DATE('01/01/2024', 'DD/MM/YYYY') THEN 
                           12
                       ELSE
                           FLOOR(MONTHS_BETWEEN(LEAST(SUB.DATA_DEMISSAO, TO_DATE('31/12/2023', 'DD/MM/YYYY')), TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + 
                           CASE 
                               WHEN EXTRACT(DAY FROM LEAST(SUB.DATA_DEMISSAO, TO_DATE('31/12/2023', 'DD/MM/YYYY'))) >= 15 THEN 1 
                               ELSE 0 
                           END
                   END,
                   2
               ),
               NULL
           ),
           'FM999G999G990D00'
       ) AS APR_CALCULADA
  FROM (SELECT A.COD_CONTRATO,
               A.DES_PESSOA,
               A.DES_FUNCAO,
               A.DES_UNIDADE,
               A.DATA_ADMISSAO,
               A.DATA_DEMISSAO,
               B.NUM_MEDIA,
               A.COD_DEMISSAO || ' - ' || A.DES_DEMISSAO AS CAUSA_DEMISSAO,
               (SELECT MAX(B.VALOR_VD)
                  FROM RHFP1006 B
                  LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO =
                                          C.COD_MESTRE_EVENTO
                  LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO =
                                          D.COD_MESTRE_EVENTO
                 WHERE B.COD_CONTRATO = A.COD_CONTRATO
                   AND B.COD_MESTRE_EVENTO IN
                       (15623, 15683, 15757, 15837, 15911, 15987, 16052, 16130,
                        16198, 16268, 16329, 16413)
                   AND B.COD_VD = 1700
                   AND D.DATA_REFERENCIA <= A.DATA_DEMISSAO FETCH FIRST 1 ROW ONLY) AS ULTIMO_SALARIO
          FROM V_DADOS_COLAB_AVT A
          LEFT JOIN GRZ_AVALIACAO_REALIZADAS B ON A.COD_CONTRATO = B.COD_CONTRATO
         WHERE A.STATUS = 1
           AND A.COD_EMP = '008'
           AND A.DATA_DEMISSAO >= '01/01/2024'
           AND A.DATA_DEMISSAO <= SYSDATE
           AND A.DATA_ADMISSAO <= TO_DATE('01/07/2023', 'DD/MM/YYYY')
           AND A.COD_CONTRATO NOT IN (6970)
           AND A.COD_DEMISSAO NOT IN (10, 13, 14)
           AND (A.DES_FUNCAO LIKE '%GERENTE%' OR
               A.DES_FUNCAO LIKE '%COMPRADOR%' OR
               A.DES_FUNCAO LIKE '%SUPERVISOR%')
           AND A.DES_FUNCAO NOT LIKE '%APRENDIZ%'
           AND A.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
           AND (LEAST(A.DATA_DEMISSAO, TO_DATE('31/01/2023', 'DD/MM/YYYY')) -
               GREATEST(A.DATA_ADMISSAO,
                         TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + 1 >= 15
         ORDER BY A.DES_UNIDADE) SUB




--==COLABORADORES==--

SELECT SUB.COD_CONTRATO,
       SUB.DES_PESSOA,
       SUB.DES_FUNCAO,
       SUB.DES_UNIDADE,
       SUB.DATA_ADMISSAO,
       SUB.DATA_DEMISSAO,
       SUB.CAUSA_DEMISSAO,
       SUB.NUM_MEDIA,
       TO_CHAR(SUB.ULTIMO_SALARIO, 'FM999G999G990D00') AS ULT_SALARIO,
       CASE
         WHEN SUB.DATA_DEMISSAO >= TO_DATE('01/01/2024', 'DD/MM/YYYY') THEN
          12
         ELSE
          FLOOR(MONTHS_BETWEEN(LEAST(SUB.DATA_DEMISSAO,
                                     TO_DATE('31/12/2023', 'DD/MM/YYYY')),
                               TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + CASE
         WHEN EXTRACT(DAY FROM LEAST(SUB.DATA_DEMISSAO,
                            TO_DATE('31/12/2023', 'DD/MM/YYYY'))) >= 15 THEN
          1
         ELSE
          0
       END END AS MESES_TRABALHADOS,
       TO_CHAR(NVL(ROUND((SUB.ULTIMO_SALARIO / 12) * CASE
                           WHEN SUB.DATA_DEMISSAO >= TO_DATE('01/01/2024', 'DD/MM/YYYY') THEN
                            12
                           ELSE
                            FLOOR(MONTHS_BETWEEN(LEAST(SUB.DATA_DEMISSAO,
                                                       TO_DATE('31/12/2023', 'DD/MM/YYYY')),
                                                 TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + CASE
                           WHEN EXTRACT(DAY FROM LEAST(SUB.DATA_DEMISSAO,
                                              TO_DATE('31/12/2023', 'DD/MM/YYYY'))) >= 15 THEN
                            1
                           ELSE
                            0
                         END END,
                         2),
                   NULL),
               'FM999G999G990D00') AS APR_CALCULADA
  FROM (SELECT A.COD_CONTRATO,
               A.DES_PESSOA,
               A.DES_FUNCAO,
               A.DES_UNIDADE,
               A.DATA_ADMISSAO,
               A.DATA_DEMISSAO,
               B.NUM_MEDIA,
               A.COD_DEMISSAO || ' - ' || A.DES_DEMISSAO AS CAUSA_DEMISSAO,
               (SELECT MAX(B.VALOR_VD)
                  FROM RHFP1006 B
                  LEFT JOIN RHFP1005 C ON B.COD_MESTRE_EVENTO =
                                          C.COD_MESTRE_EVENTO
                  LEFT JOIN RHFP1003 D ON B.COD_MESTRE_EVENTO =
                                          D.COD_MESTRE_EVENTO
                 WHERE B.COD_CONTRATO = A.COD_CONTRATO
                   AND B.COD_MESTRE_EVENTO IN
                       (15623, 15683, 15757, 15837, 15911, 15987, 16052, 16130,
                        16198, 16268, 16329, 16413)
                   AND B.COD_VD = 1700
                   AND D.DATA_REFERENCIA <= A.DATA_DEMISSAO FETCH FIRST 1 ROW ONLY) AS ULTIMO_SALARIO
          FROM V_DADOS_COLAB_AVT A
          LEFT JOIN GRZ_AVALIACAO_REALIZADAS B ON A.COD_CONTRATO =
                                                  B.COD_CONTRATO
         WHERE A.STATUS = 1
           AND A.COD_EMP = '008'
           --AND A.DATA_DEMISSAO >= '01/01/2024'
           AND A.DATA_DEMISSAO <= SYSDATE
           AND A.DATA_ADMISSAO <= TO_DATE('01/07/2023', 'DD/MM/YYYY')
           AND A.COD_CONTRATO NOT IN (6970)
           AND A.COD_DEMISSAO NOT IN (10, 13, 14)
           AND A.DES_FUNCAO NOT LIKE '%GERENTE%'
           AND A.DES_FUNCAO NOT LIKE '%COMPRADOR%'
           AND A.DES_FUNCAO NOT LIKE '%SUPERVISOR%'
           AND A.DES_FUNCAO NOT LIKE '%APRENDIZ%'
           AND A.DES_FUNCAO NOT LIKE '%ESTAGIARIO%'
           AND A.COD_CONTRATO NOT IN
               (378238, 390807, 386812, 391828, 379906, 389799, 393054,
                382643, 392693, 385829, 390344, 390536, 393147, 391650,
                387732, 392110, 392658, 167142, 390460, 392236, 386898,
                389088, 388512, 390738, 389927, 393012, 393206, 391214,
                387386, 390259, 392161, 390893, 389623, 392458, 389250,
                386191)
           AND (LEAST(A.DATA_DEMISSAO, TO_DATE('31/01/2023', 'DD/MM/YYYY')) -
               GREATEST(A.DATA_ADMISSAO,
                         TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + 1 >= 15
         ORDER BY A.DES_UNIDADE) SUB



SELECT * FROM GRZ_AVALIACAO_REALIZADAS
WHERE COD_CONTRATO in (378238, 390807, 386812, 391828, 379906, 389799, 393054, 
382643, 392693, 385829, 390344, 390536, 393147, 391650, 
387732, 392110, 392658, 167142, 390460, 392236, 386898, 
389088, 388512, 390738, 389927, 393012, 393206, 391214, 
387386, 390259, 392161, 390893, 389623, 392458, 389250, 386191)



SELECT COD_CONTRATO,
       DES_PESSOA,
       DES_FUNCAO,
       DES_UNIDADE,
       DATA_ADMISSAO, 
       DATA_DEMISSAO,
       CASE
         WHEN DATA_DEMISSAO >= TO_DATE('01/01/2024', 'DD/MM/YYYY') THEN
          12
         ELSE
          FLOOR(MONTHS_BETWEEN(LEAST(DATA_DEMISSAO,
                                     TO_DATE('31/12/2023', 'DD/MM/YYYY')),
                               TO_DATE('01/01/2023', 'DD/MM/YYYY'))) + CASE
         WHEN EXTRACT(DAY FROM LEAST(DATA_DEMISSAO,
                            TO_DATE('31/12/2023', 'DD/MM/YYYY'))) >= 15 THEN
          1
         ELSE
          0
       END END AS MESES_TRABALHADOS
FROM V_DADOS_COLAB_AVT
WHERE DATA_ADMISSAO BETWEEN '01/01/2023' AND '31/12/2023'
AND DATA_DEMISSAO IS NOT NULL
AND COD_EMP = '008'