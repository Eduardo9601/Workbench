CREATE OR REPLACE VIEW VH_HORAS_TURNO_AVT AS
WITH F_UNICO AS (                        -- 1 linha por COD_HORAS_BASE
  SELECT F.COD_HORAS_BASE,
         MAX(F.QTD_HORBAS_MES) AS QTD_HORBAS_MES,
         MAX(F.QTD_HORBAS_SEM) AS QTD_HORBAS_SEM,
         MAX(F.QTD_HORBAS_DIA) AS QTD_HORBAS_DIA
  FROM RHFP0321 F
  GROUP BY F.COD_HORAS_BASE
),
BASE AS (
  SELECT *
    FROM (SELECT A.COD_CONTRATO,
                 A.COD_TURNO,
                 A.DATA_INICIO,
                 A.DATA_FIM,
                 
                 -- horas base (históricas, vindas da vigência de E que cobre o período de A)
                 LTRIM(RTRIM(TRIM(TRAILING '.' FROM
                                  TRIM(TRAILING '0' FROM
                                       TO_CHAR(F.QTD_HORBAS_MES,
                                               '9999999990.99'))))) AS HR_BASE_MES,
                 LTRIM(RTRIM(TRIM(TRAILING '.' FROM
                                  TRIM(TRAILING '0' FROM
                                       TO_CHAR(F.QTD_HORBAS_SEM,
                                               '9999999990.99'))))) AS HR_BASE_SEM,
                 LTRIM(RTRIM(TRIM(TRAILING '.' FROM
                                  TRIM(TRAILING '0' FROM
                                       TO_CHAR(F.QTD_HORBAS_DIA,
                                               '9999999990.99'))))) AS HR_BASE_DIA,
                 
                 B.HORARIO_1_ENT,
                 B.HORARIO_1_SAI,
                 B.HORARIO_2_ENT,
                 B.HORARIO_2_SAI,
                 B.HORARIO_3_ENT,
                 B.HORARIO_3_SAI,
                 B.HORARIO_4_ENT,
                 B.HORARIO_4_SAI,
                 
                 C.COD_HORARIO_1,
                 C.DIA_ESOCIAL,
                 D.COD_HORARIO,
                 D.NOME_HORARIO,
                 
                 -- Sábado usa 3/4?
                 CASE
                   WHEN C.DIA_ESOCIAL = 7 AND
                        (NVL(B.HORARIO_3_ENT, 0) + NVL(B.HORARIO_3_SAI, 0) +
                        NVL(B.HORARIO_4_ENT, 0) + NVL(B.HORARIO_4_SAI, 0)) > 0 THEN
                    1
                   ELSE
                    0
                 END AS SAB_USA_34,
                 
                 -- desempate: se mais de uma linha de E cobrir o período de A,
                 -- fica com a de maior DATA_INICIO (ou DATA_FIM mais recente)
                 ROW_NUMBER() OVER(PARTITION BY A.COD_CONTRATO, 
                                                A.COD_TURNO, 
                                                A.DATA_INICIO, 
                                                A.DATA_FIM, 
                                                C.DIA_ESOCIAL, 
                                                D.COD_HORARIO 
                                   ORDER BY NVL(E.DATA_INICIO, DATE '0001-01-01') DESC, NVL(E.DATA_FIM, DATE '2999-12-31') DESC) AS RN
            FROM RHAF1119 A
            JOIN RHAF1145 B ON B.COD_TURNO = A.COD_TURNO
            LEFT JOIN RHAF1120 C ON C.COD_TURNO = B.COD_TURNO
            LEFT JOIN RHAF1113 D ON D.COD_HORARIO = C.COD_HORARIO_1
          
          /* *** AQUI ESTÁ O PONTO: join por VIGÊNCIA (sobreposição de períodos) *** */
            LEFT JOIN RHFP0307 E ON E.COD_CONTRATO = A.COD_CONTRATO
                                AND NVL(E.DATA_INICIO, DATE '0001-01-01') <=
                                    A.DATA_FIM
                                AND NVL(E.DATA_FIM, DATE '2999-12-31') >=
                                    A.DATA_INICIO
          
            LEFT JOIN F_UNICO F ON F.COD_HORAS_BASE = E.COD_HORAS_BASE
          
          -- opcional: filtre um contrato, mas o join acima preserva o histórico
          -- WHERE A.COD_CONTRATO = 389622
          ) X
   WHERE X.RN = 1 -- mantém 1 única linha de E por registro de A
)

SELECT COD_CONTRATO,
       COD_TURNO,
       DATA_INICIO,
       DATA_FIM,
       HR_BASE_MES,
       HR_BASE_SEM,
       HR_BASE_DIA,
       COD_HORARIO,
       NOME_HORARIO,
       
       CASE
         WHEN COD_HORARIO = 1 THEN
          'DSR'
         WHEN COD_HORARIO = 2 THEN
          'Compensado'
         ELSE
          TO_CHAR(DIA_ESOCIAL)
       END AS COD_DIA,
       
       CASE
         WHEN COD_HORARIO_1 = 1 THEN
          'DOM'
         WHEN DIA_ESOCIAL = 2 THEN
          'SEG'
         WHEN DIA_ESOCIAL = 3 THEN
          'TER'
         WHEN DIA_ESOCIAL = 4 THEN
          'QUA'
         WHEN DIA_ESOCIAL = 5 THEN
          'QUI'
         WHEN DIA_ESOCIAL = 6 THEN
          'SEX'
         WHEN (DIA_ESOCIAL = 7 OR COD_HORARIO = 2) THEN
          'SAB'
         ELSE
          TO_CHAR(DIA_ESOCIAL)
       END AS DIA,
       
       /* 1º período */
       CASE
         WHEN COD_HORARIO IN (1, 2) THEN
          NULL
         WHEN SAB_USA_34 = 1 THEN
          LPAD(RHYF0118(RHYF0117(HORARIO_3_ENT), 'S'), 5, '0')
         ELSE
          LPAD(RHYF0118(RHYF0117(HORARIO_1_ENT), 'S'), 5, '0')
       END AS HOR_1_ENT,
       CASE
         WHEN COD_HORARIO IN (1, 2) THEN
          NULL
         WHEN SAB_USA_34 = 1 THEN
          LPAD(RHYF0118(RHYF0117(HORARIO_3_SAI), 'S'), 5, '0')
         ELSE
          LPAD(RHYF0118(RHYF0117(HORARIO_1_SAI), 'S'), 5, '0')
       END AS HOR_1_SAI,
       
       /* 2º período */
       CASE
         WHEN COD_HORARIO IN (1, 2) THEN
          NULL
         WHEN SAB_USA_34 = 1 THEN
          LPAD(RHYF0118(RHYF0117(HORARIO_4_ENT), 'S'), 5, '0')
         ELSE
          LPAD(RHYF0118(RHYF0117(HORARIO_2_ENT), 'S'), 5, '0')
       END AS HOR_2_ENT,
       CASE
         WHEN COD_HORARIO IN (1, 2) THEN
          NULL
         WHEN SAB_USA_34 = 1 THEN
          LPAD(RHYF0118(RHYF0117(HORARIO_4_SAI), 'S'), 5, '0')
         ELSE
          LPAD(RHYF0118(RHYF0117(HORARIO_2_SAI), 'S'), 5, '0')
       END AS HOR_2_SAI      
       
  FROM BASE
  --WHERE COD_CONTRATO = 389622
 ORDER BY
  COD_CONTRATO,
  COD_TURNO,
  DATA_INICIO,
  DATA_FIM,
  CASE
    WHEN DIA = 'DOM' THEN 1
    WHEN DIA = 'SEG' THEN 2
    WHEN DIA = 'TER' THEN 3
    WHEN DIA = 'QUA' THEN 4
    WHEN DIA = 'QUI' THEN 5
    WHEN DIA = 'SEX' THEN 6
    WHEN DIA = 'SAB' THEN 7
    ELSE 99
  END,
  COD_HORARIO;
