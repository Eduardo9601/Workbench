CREATE OR REPLACE PROCEDURE GRZ_EXPORT_EVENTOS_ANO_TRE_CSV (

    /*=======================================================================================
    === ROTINA CRIADA COM INTUITO DE GERAR A BASE DE DADOS FINANCEIROS DOS COLABORADORES, ===
    === PARA FINS DE MIGRAÇÃO DO SISTEMA DA FOLHA PARA O HCM DA SÊNIOR                    ===
    === CRIADO POR: Jaisson                                                               ===
    === ATUALIZADO POR: Eduardo                                                           ===
    ========================================================================================= */

    p_dt_ini   IN DATE,
    p_dt_fim   IN DATE,
    p_prefix   IN VARCHAR2 DEFAULT 'export_eventos'
) IS
    v_dir        CONSTANT VARCHAR2(4000) := '/mnt/nlgestao/nfe/HCM_1040_TRANSF.EMP';
    v_q_ini       DATE;
    v_q_fim       DATE;
    v_file        UTL_FILE.FILE_TYPE;
    v_filename    VARCHAR2(4000);

    v_header      VARCHAR2(4000) :=
      'codigo_empresa;tipo_colaborador;cadastro_colaborador;codigo_calculo;tabela_evento;codigo_evento;referencia_evento;valor_evento;codigo_rubrica;fator_rubrica;origem_evento';

    v_cnt         NUMBER;

    /* =========================
       Cursor principal (dados)
       ========================= */
    CURSOR c_dados (pc_ini DATE, pc_fim DATE) IS
SELECT q."codigo_empresa",
       1 AS "tipo_colaborador",
       q."cadastro_colaborador",
       q."codigo_calculo",
       1 AS "tabela_evento",
       q."codigo_evento",
       q."referencia_evento",
       q."valor_evento",
       q."codigo_rubrica",
       q."fator_rubrica",
       q."origem_evento"
  FROM (
        WITH
        MAPA_BASE AS (
            SELECT DISTINCT
                   M.COD_CONTRATO,
                   M.EMPRESA_ORIGEM,
                   M.EMPRESA_DESTINO,
                   TRUNC(M.DATA_TRANSFERENCIA) AS DATA_TRANSFERENCIA
              FROM GRZ_MAPA_TRANSF_EMPRESA_V2 M
             WHERE M.EMPRESA_ORIGEM  IS NOT NULL
               AND M.EMPRESA_DESTINO IS NOT NULL
               AND M.EMPRESA_ORIGEM <> M.EMPRESA_DESTINO
        ),

        MAPA_STATS AS (
            SELECT X.COD_CONTRATO,
                   COUNT(*) AS QT_MOVIMENTOS,
                   COUNT(DISTINCT X.EMPRESA) AS QT_EMPRESAS
              FROM (
                    SELECT COD_CONTRATO, EMPRESA_ORIGEM  AS EMPRESA FROM MAPA_BASE
                    UNION
                    SELECT COD_CONTRATO, EMPRESA_DESTINO AS EMPRESA FROM MAPA_BASE
                   ) X
             GROUP BY X.COD_CONTRATO
        ),

        MOV_SEQ AS (
            SELECT MB.COD_CONTRATO,
                   MB.EMPRESA_ORIGEM,
                   MB.EMPRESA_DESTINO,
                   MB.DATA_TRANSFERENCIA,
                   ROW_NUMBER() OVER (
                       PARTITION BY MB.COD_CONTRATO
                       ORDER BY MB.DATA_TRANSFERENCIA,
                                MB.EMPRESA_ORIGEM,
                                MB.EMPRESA_DESTINO
                   ) AS RN
              FROM MAPA_BASE MB
        ),

        ULTIMA_TRANSF AS (
            SELECT COD_CONTRATO,
                   EMPRESA_ORIGEM,
                   EMPRESA_DESTINO,
                   DATA_TRANSFERENCIA
              FROM (
                    SELECT MS.*,
                           ROW_NUMBER() OVER (
                               PARTITION BY MS.COD_CONTRATO
                               ORDER BY MS.DATA_TRANSFERENCIA DESC,
                                        MS.RN DESC
                           ) AS RN_ULT
                      FROM MOV_SEQ MS
                   )
             WHERE RN_ULT = 1
        ),

        PARES_2_EMPRESAS AS (
            SELECT U.COD_CONTRATO,
                   U.EMPRESA_ORIGEM,
                   U.EMPRESA_DESTINO,
                   U.DATA_TRANSFERENCIA
              FROM ULTIMA_TRANSF U
              JOIN MAPA_STATS S
                ON S.COD_CONTRATO = U.COD_CONTRATO
             WHERE S.QT_EMPRESAS = 2
        ),

        PARES_IMEDIATOS_3MAIS AS (
            SELECT M.COD_CONTRATO,
                   M.EMPRESA_ORIGEM,
                   M.EMPRESA_DESTINO,
                   M.DATA_TRANSFERENCIA
              FROM MOV_SEQ M
              JOIN MAPA_STATS S
                ON S.COD_CONTRATO = M.COD_CONTRATO
             WHERE S.QT_EMPRESAS > 2
        ),

        EMPRESAS_ANTERIORES AS (
            SELECT DISTINCT
                   CUR.COD_CONTRATO,
                   CUR.RN              AS RN_ATUAL,
                   ANT.EMPRESA_ORIGEM  AS EMPRESA_ANTERIOR
              FROM MOV_SEQ CUR
              JOIN MOV_SEQ ANT
                ON ANT.COD_CONTRATO = CUR.COD_CONTRATO
               AND ANT.RN < CUR.RN
              JOIN MAPA_STATS S
                ON S.COD_CONTRATO = CUR.COD_CONTRATO
             WHERE S.QT_EMPRESAS > 2

            UNION

            SELECT DISTINCT
                   CUR.COD_CONTRATO,
                   CUR.RN               AS RN_ATUAL,
                   ANT.EMPRESA_DESTINO  AS EMPRESA_ANTERIOR
              FROM MOV_SEQ CUR
              JOIN MOV_SEQ ANT
                ON ANT.COD_CONTRATO = CUR.COD_CONTRATO
               AND ANT.RN < CUR.RN
              JOIN MAPA_STATS S
                ON S.COD_CONTRATO = CUR.COD_CONTRATO
             WHERE S.QT_EMPRESAS > 2
        ),

        PARES_ACUM_3MAIS AS (
            SELECT DISTINCT
                   CUR.COD_CONTRATO,
                   EA.EMPRESA_ANTERIOR AS EMPRESA_ORIGEM,
                   CUR.EMPRESA_DESTINO AS EMPRESA_DESTINO,
                   CUR.DATA_TRANSFERENCIA
              FROM MOV_SEQ CUR
              JOIN EMPRESAS_ANTERIORES EA
                ON EA.COD_CONTRATO = CUR.COD_CONTRATO
               AND EA.RN_ATUAL     = CUR.RN
              JOIN MAPA_STATS S
                ON S.COD_CONTRATO = CUR.COD_CONTRATO
             WHERE S.QT_EMPRESAS > 2
               AND EA.EMPRESA_ANTERIOR <> CUR.EMPRESA_DESTINO
        ),

        PARES_3MAIS_BRUTO AS (
            SELECT * FROM PARES_IMEDIATOS_3MAIS
            UNION ALL
            SELECT * FROM PARES_ACUM_3MAIS
        ),

        PARES_3MAIS AS (
            SELECT COD_CONTRATO,
                   EMPRESA_ORIGEM,
                   EMPRESA_DESTINO,
                   DATA_TRANSFERENCIA
              FROM (
                    SELECT P.*,
                           ROW_NUMBER() OVER (
                               PARTITION BY P.COD_CONTRATO,
                                            P.EMPRESA_ORIGEM,
                                            P.EMPRESA_DESTINO
                               ORDER BY P.DATA_TRANSFERENCIA DESC
                           ) AS RN_PAR
                      FROM PARES_3MAIS_BRUTO P
                   )
             WHERE RN_PAR = 1
        ),

        MAPA_FINAL AS (
            SELECT * FROM PARES_2_EMPRESAS
            UNION ALL
            SELECT * FROM PARES_3MAIS
        ),

        BASE_ORIGEM AS (
            SELECT DISTINCT
                   ORG.COD_NIVEL2 AS "codigo_empresa",
                   A.COD_CONTRATO AS "cadastro_colaborador",
                   A1.COD_MESTRE_EVENTO AS "codigo_calculo",
                   EV.COD_EVENTO AS "codigo_evento",
                   TO_CHAR(ROUND(NVL(A.QTDE_VD, 0), 2), 'FM9999999990D00') AS "referencia_evento",
                   TO_CHAR(ROUND(NVL(A.VALOR_VD, 0), 2), 'FM9999999990D00') AS "valor_evento",
                   NULL AS "codigo_rubrica",
                   NULL AS "fator_rubrica",
                   NULL AS "origem_evento",

                   TRUNC(A1.DATA_REFERENCIA, 'MM') AS ord_mes,
                   TRUNC(A1.DATA_REFERENCIA) AS ord_ref,
                   TRUNC(A1.DATA_INI_MOV) AS ord_ini,
                   NVL(A.VALOR_VD, 0) AS VALOR_NUM

              FROM RHFP1006 A
              JOIN RHFP1003 A1
                ON A1.COD_MESTRE_EVENTO = A.COD_MESTRE_EVENTO
              JOIN RHFP1002 B
                ON B.COD_EVENTO = A1.COD_EVENTO
              JOIN RHFP1000 C
                ON A.COD_VD = C.COD_VD
              JOIN TB_EVENTOS_VD EV
                ON A.COD_VD = EV.COD_VD
              JOIN (
                    SELECT C.COD_CONTRATO
                      FROM V_DADOS_CONTRATO_AVT C
                     GROUP BY C.COD_CONTRATO
                    HAVING MIN(NVL(TRUNC(C.DATA_ADMISSAO), DATE '1900-01-01')) < DATE '2026-05-01'
              ) OK
                ON OK.COD_CONTRATO = A.COD_CONTRATO

             OUTER APPLY (
                 SELECT H.COD_ORGANOGRAMA
                   FROM (
                         SELECT H.*,
                                CASE
                                  WHEN TRUNC(H.DATA_INICIO) <= TRUNC(A1.DATA_INI_MOV)
                                   AND TRUNC(NVL(H.DATA_FIM, DATE '9999-12-31')) >= TRUNC(A1.DATA_INI_MOV) THEN 1
                                  WHEN TRUNC(H.DATA_INICIO) <= TRUNC(A1.DATA_INI_MOV) THEN 2
                                  ELSE 3
                                END AS RK,
                                CASE
                                  WHEN TRUNC(H.DATA_INICIO) <= TRUNC(A1.DATA_INI_MOV)
                                   AND TRUNC(NVL(H.DATA_FIM, DATE '9999-12-31')) >= TRUNC(A1.DATA_INI_MOV) THEN 0
                                  WHEN TRUNC(H.DATA_INICIO) <= TRUNC(A1.DATA_INI_MOV) THEN TRUNC(A1.DATA_INI_MOV) - TRUNC(H.DATA_INICIO)
                                  ELSE TRUNC(H.DATA_INICIO) - TRUNC(A1.DATA_INI_MOV)
                                END AS DIST
                           FROM RHFP0310 H
                          WHERE H.COD_CONTRATO = A.COD_CONTRATO
                        ) H
                  ORDER BY RK,
                           DIST,
                           CASE WHEN RK IN (1, 2) THEN H.DATA_INICIO END DESC,
                           CASE WHEN RK = 3 THEN H.DATA_INICIO END ASC
                  FETCH FIRST 1 ROW ONLY
             ) HIST

              LEFT JOIN RHFP0401 ORG
                ON ORG.COD_ORGANOGRAMA = HIST.COD_ORGANOGRAMA

             WHERE ORG.COD_NIVEL2 IS NOT NULL
               AND A1.COD_EVENTO NOT IN (15, 16, 17, 19, 21, 22, 23, 25, 26)
               AND C.TIPO_VD NOT IN ('B', 'O')
               AND EXISTS (
                     SELECT 1
                       FROM MAPA_BASE MB
                      WHERE MB.COD_CONTRATO = A.COD_CONTRATO
               )
               AND TRUNC(A1.DATA_REFERENCIA) BETWEEN TRUNC(pc_ini) AND TRUNC(pc_fim)
        ),

        BASE_REPLICADA AS (
            SELECT
                   MF.EMPRESA_DESTINO AS "codigo_empresa",
                   BO."cadastro_colaborador",
                   BO."codigo_calculo",
                   BO."codigo_evento",
                   BO."referencia_evento",
                   BO."valor_evento",
                   BO."codigo_rubrica",
                   BO."fator_rubrica",
                   BO."origem_evento",
                   BO.ord_mes,
                   BO.ord_ref,
                   BO.ord_ini,
                   BO.VALOR_NUM,
                   ROW_NUMBER() OVER (
                       PARTITION BY
                           MF.EMPRESA_DESTINO,
                           BO."cadastro_colaborador",
                           BO."codigo_calculo",
                           BO."codigo_evento",
                           BO."referencia_evento",
                           BO."valor_evento"
                       ORDER BY
                           MF.DATA_TRANSFERENCIA DESC,
                           MF.EMPRESA_ORIGEM DESC
                   ) AS RN
              FROM BASE_ORIGEM BO
              JOIN MAPA_FINAL MF
                ON MF.COD_CONTRATO   = BO."cadastro_colaborador"
               AND MF.EMPRESA_ORIGEM = BO."codigo_empresa"
        )

        SELECT BR."codigo_empresa",
               BR."cadastro_colaborador",
               BR."codigo_calculo",
               BR."codigo_evento",
               BR."referencia_evento",
               BR."valor_evento",
               BR."codigo_rubrica",
               BR."fator_rubrica",
               BR."origem_evento",
               BR.ord_mes,
               BR.ord_ref,
               BR.ord_ini
          FROM BASE_REPLICADA BR
         WHERE BR.RN = 1
           AND BR.VALOR_NUM <> 0
       ) q
 ORDER BY q.ord_mes,
          q.ord_ref,
          q.ord_ini,
          q."codigo_calculo",
          q."codigo_evento";

    /* ============================================
       Conta dados do período (não cria arquivo se 0)
       (mantive o nome original pra não mexer mais do que precisa)
       ============================================ */
    FUNCTION count_trimester(p_ini DATE, p_fim DATE) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v
          FROM (
                SELECT DISTINCT
                       ORG.COD_NIVEL2,
                       A.COD_CONTRATO,
                       A1.COD_MESTRE_EVENTO,
                       EV.COD_EVENTO,
                       A.VALOR_VD,
                       A1.DATA_REFERENCIA,
                       A1.DATA_PAGAMENTO,
                       A1.DATA_INI_MOV
                  FROM RHFP1006 A
                  JOIN RHFP1003 A1
                    ON A1.COD_MESTRE_EVENTO = A.COD_MESTRE_EVENTO
                  JOIN RHFP1002 B
                    ON B.COD_EVENTO = A1.COD_EVENTO
                  JOIN RHFP1000 C
                    ON A.COD_VD = C.COD_VD

                  JOIN TB_EVENTOS_VD EV
                    ON A.COD_VD = EV.COD_VD

                  JOIN (SELECT C.COD_CONTRATO
                        FROM V_DADOS_CONTRATO_AVT C
                       GROUP BY C.COD_CONTRATO
                      HAVING MIN(NVL(TRUNC(C.DATA_ADMISSAO), DATE '1900-01-01')) < '01/05/2026') OK
                    ON OK.COD_CONTRATO = A.COD_CONTRATO
                 OUTER APPLY (
                     SELECT H.COD_ORGANOGRAMA
                       FROM (
                             SELECT H.*,
                                    CASE
                                      WHEN TRUNC(H.DATA_INICIO) <= TRUNC(A1.DATA_INI_MOV)
                                           AND TRUNC(NVL(H.DATA_FIM, DATE '9999-12-31')) >= TRUNC(A1.DATA_INI_MOV)
                                      THEN 1
                                      WHEN TRUNC(H.DATA_INICIO) <= TRUNC(A1.DATA_INI_MOV) THEN 2
                                      ELSE 3
                                    END AS RK,
                                    CASE
                                      WHEN TRUNC(H.DATA_INICIO) <= TRUNC(A1.DATA_INI_MOV)
                                           AND TRUNC(NVL(H.DATA_FIM, DATE '9999-12-31')) >= TRUNC(A1.DATA_INI_MOV)
                                      THEN 0
                                      WHEN TRUNC(H.DATA_INICIO) <= TRUNC(A1.DATA_INI_MOV)
                                      THEN TRUNC(A1.DATA_INI_MOV) - TRUNC(H.DATA_INICIO)
                                      ELSE TRUNC(H.DATA_INICIO) - TRUNC(A1.DATA_INI_MOV)
                                    END AS DIST
                               FROM RHFP0310 H
                              WHERE H.COD_CONTRATO = A.COD_CONTRATO
                            ) H
                      ORDER BY RK,
                               DIST,
                               CASE WHEN RK IN (1,2) THEN H.DATA_INICIO END DESC,
                               CASE WHEN RK = 3     THEN H.DATA_INICIO END ASC
                      FETCH FIRST 1 ROW ONLY
                 ) HIST
                  LEFT JOIN RHFP0401 ORG
                    ON ORG.COD_ORGANOGRAMA = HIST.COD_ORGANOGRAMA
                 WHERE ORG.COD_NIVEL2 IS NOT NULL
                   AND C.TIPO_VD NOT IN ('B', 'O')
                   AND A1.COD_EVENTO NOT IN (15, 16, 17, 19, 21, 22, 23, 25, 26)
                   AND TRUNC(A1.DATA_REFERENCIA) BETWEEN TRUNC(P_INI) AND TRUNC(P_FIM)
          );
        RETURN v;
    END;

    FUNCTION year_label(p_date DATE) RETURN VARCHAR2 IS
    BEGIN
        RETURN TO_CHAR(p_date,'YYYY');
    END;

BEGIN
    IF p_dt_ini IS NULL OR p_dt_fim IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Datas inicial e final são obrigatórias.');
    END IF;

    IF TRUNC(p_dt_ini) > TRUNC(p_dt_fim) THEN
        RAISE_APPLICATION_ERROR(-20002,'p_dt_ini não pode ser maior que p_dt_fim.');
    END IF;

    -- início no começo do ano (quebra anual)
    v_q_ini := TRUNC(p_dt_ini,'YYYY');

    WHILE v_q_ini <= TRUNC(p_dt_fim) LOOP
        -- fim do ano ou p_dt_fim (o que vier primeiro)
        v_q_fim := LEAST(TRUNC(ADD_MONTHS(v_q_ini,12)) - 1, TRUNC(p_dt_fim));

        -- garante que o primeiro arquivo respeite a data inicial real informada
        IF v_q_ini < TRUNC(p_dt_ini) THEN
            v_q_ini := TRUNC(p_dt_ini);
        END IF;

        v_cnt := count_trimester(v_q_ini, v_q_fim);

        IF v_cnt > 0 THEN
            v_filename :=
                p_prefix || '_' ||
                year_label(v_q_ini) || '_' ||
                TO_CHAR(v_q_ini,'YYYYMMDD') || '_' ||
                TO_CHAR(v_q_fim,'YYYYMMDD') || '.csv';

            v_file := UTL_FILE.FOPEN(v_dir, v_filename, 'W', 32767);

            -- header fixo
            UTL_FILE.PUT_LINE(v_file, v_header);

            -- dados
            FOR r IN c_dados(v_q_ini, v_q_fim) LOOP
                UTL_FILE.PUT_LINE(
                    v_file,
                    NVL(r."codigo_empresa",'') || ';' ||
                    '1' || ';' ||
                    NVL(r."cadastro_colaborador",'') || ';' ||
                    NVL(r."codigo_calculo",'') || ';' ||
                    '1' || ';' ||
                    NVL(r."codigo_evento",'') || ';' ||
                    NVL(r."referencia_evento",'') || ';' ||
                    REPLACE(TO_CHAR(NVL(r."valor_evento",0), 'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS=,.'), '.', ',') || ';' ||
                    NVL(r."codigo_rubrica",'') || ';' ||
                    NVL(r."fator_rubrica",'') || ';' ||
                    NVL(r."origem_evento",'')

                    /*backp colunas caso precise*/
                    /*NVL(r."tipo_calculo",'') || ';' ||
                    NVL(r."referencia",'') || ';' ||
                    NVL(r."data_pagamento",'')*/
                );
            END LOOP;

            UTL_FILE.FCLOSE(v_file);
        END IF;

        -- próximo ano
        v_q_ini := TRUNC(ADD_MONTHS(TRUNC(v_q_fim) + 1, 0), 'YYYY');
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            IF UTL_FILE.IS_OPEN(v_file) THEN
                UTL_FILE.FCLOSE(v_file);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        RAISE;
END;
/
