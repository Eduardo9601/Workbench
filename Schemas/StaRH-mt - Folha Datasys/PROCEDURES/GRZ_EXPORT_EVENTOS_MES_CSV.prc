CREATE OR REPLACE PROCEDURE GRZ_EXPORT_EVENTOS_MES_CSV (

    /*=======================================================================================
    === ROTINA PARA GERAR A BASE DE DADOS FINANCEIROS DOS COLABORADORES                  ===
    === ARQUIVO 1040 - FICHA FINANCEIRA                                                   ===
    === VERSÃO MENSAL: PERMITE ESCOLHER ANO/MÊS SEM GERAR O ANO INTEIRO                  ===
    ========================================================================================= */

    p_ano      IN NUMBER,
    p_mes      IN NUMBER,
    p_prefix   IN VARCHAR2 DEFAULT 'export_eventos'
) IS
    v_dir        CONSTANT VARCHAR2(4000) := '/mnt/nlgestao/nfe/HCM_1040';

    v_dt_ini     DATE;
    v_dt_fim     DATE;

    v_file       UTL_FILE.FILE_TYPE;
    v_filename   VARCHAR2(4000);

    v_header     VARCHAR2(4000) :=
      'codigo_empresa;tipo_colaborador;cadastro_colaborador;codigo_calculo;tabela_evento;codigo_evento;referencia_evento;valor_evento;codigo_rubrica;fator_rubrica;origem_evento';

    v_cnt        NUMBER;

    /* =========================
       Cursor principal
       ========================= */
    CURSOR c_dados (pc_ini DATE, pc_fim DATE) IS
        SELECT q.codigo_empresa,
               1 AS tipo_colaborador,
               q.cadastro_colaborador,
               q.codigo_calculo,
               1 AS tabela_evento,
               q.codigo_evento,
               q.referencia_evento,
               q.valor_evento,
               q.codigo_rubrica,
               q.fator_rubrica,
               q.origem_evento
          FROM (
                SELECT DISTINCT
                       org.cod_nivel2 AS codigo_empresa,
                       a.cod_contrato AS cadastro_colaborador,
                       ev.cod_evento AS codigo_evento,
                       CASE
                           WHEN TRUNC(a1.data_referencia) = DATE '2026-04-30' THEN 
                             a1.cod_mestre_evento

                           WHEN TRUNC(a1.data_referencia) = DATE '2026-05-31' THEN 
                             18587

                           ELSE
                             a1.cod_mestre_evento
                       END AS codigo_calculo,

                       ROUND(NVL(a.qtde_vd, 0), 2) AS referencia_evento,
                       ROUND(NVL(a.valor_vd, 0), 2) AS valor_evento,

                       CAST(NULL AS VARCHAR2(50)) AS codigo_rubrica,
                       CAST(NULL AS VARCHAR2(50)) AS fator_rubrica,
                       CAST(NULL AS VARCHAR2(50)) AS origem_evento,

                       /* Técnicas para ordenação */
                       TRUNC(a1.data_referencia, 'MM') AS ord_mes,
                       TRUNC(a1.data_referencia) AS ord_ref,
                       TRUNC(a1.data_ini_mov) AS ord_ini

                  FROM rhfp1006 a

                  JOIN rhfp1003 a1
                    ON a1.cod_mestre_evento = a.cod_mestre_evento

                  JOIN rhfp1002 b
                    ON b.cod_evento = a1.cod_evento

                  JOIN rhfp1000 c
                    ON c.cod_vd = a.cod_vd

                  JOIN tb_eventos_vd ev
                    ON ev.cod_vd = a.cod_vd

                  JOIN (
                        SELECT c.cod_contrato
                          FROM v_dados_contrato_avt c
                         GROUP BY c.cod_contrato
                        HAVING MIN(NVL(TRUNC(c.data_admissao), DATE '1900-01-01')) < DATE '2026-06-01'
                       ) ok
                    ON ok.cod_contrato = a.cod_contrato

                  OUTER APPLY (
                        SELECT h.cod_organograma
                          FROM (
                                SELECT h.*,
                                       CASE
                                         WHEN TRUNC(h.data_inicio) <= TRUNC(a1.data_ini_mov)
                                          AND TRUNC(NVL(h.data_fim, DATE '9999-12-31')) >= TRUNC(a1.data_ini_mov)
                                         THEN 1

                                         WHEN TRUNC(h.data_inicio) <= TRUNC(a1.data_ini_mov)
                                         THEN 2

                                         ELSE 3
                                       END AS rk,

                                       CASE
                                         WHEN TRUNC(h.data_inicio) <= TRUNC(a1.data_ini_mov)
                                          AND TRUNC(NVL(h.data_fim, DATE '9999-12-31')) >= TRUNC(a1.data_ini_mov)
                                         THEN 0

                                         WHEN TRUNC(h.data_inicio) <= TRUNC(a1.data_ini_mov)
                                         THEN TRUNC(a1.data_ini_mov) - TRUNC(h.data_inicio)

                                         ELSE TRUNC(h.data_inicio) - TRUNC(a1.data_ini_mov)
                                       END AS dist

                                  FROM rhfp0310 h
                                 WHERE h.cod_contrato = a.cod_contrato
                               ) h
                         ORDER BY h.rk,
                                  h.dist,
                                  CASE WHEN h.rk IN (1, 2) THEN h.data_inicio END DESC,
                                  CASE WHEN h.rk = 3 THEN h.data_inicio END ASC
                         FETCH FIRST 1 ROW ONLY
                  ) hist

                  LEFT JOIN rhfp0401 org
                    ON org.cod_organograma = hist.cod_organograma

                 WHERE org.cod_nivel2 IS NOT NULL

                   AND a1.cod_evento NOT IN (
                       15, 16, 17, 19, 21, 22, 23, 25, 26
                   )

                   AND c.tipo_vd NOT IN ('B', 'O')

                   /* Período mensal escolhido */
                   AND a1.data_referencia >= TRUNC(pc_ini)
                   AND a1.data_referencia <  TRUNC(pc_fim) + 1
               ) q

         ORDER BY q.ord_mes,
                  q.ord_ref,
                  q.ord_ini,
                  q.codigo_calculo,
                  q.codigo_evento;


    /* ============================================
       Verifica se existem dados no mês informado
       ============================================ */
    FUNCTION count_periodo(p_ini DATE, p_fim DATE) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v
          FROM (
                SELECT 1
                  FROM rhfp1006 a

                  JOIN rhfp1003 a1
                    ON a1.cod_mestre_evento = a.cod_mestre_evento

                  JOIN rhfp1002 b
                    ON b.cod_evento = a1.cod_evento

                  JOIN rhfp1000 c
                    ON c.cod_vd = a.cod_vd

                  JOIN tb_eventos_vd ev
                    ON ev.cod_vd = a.cod_vd

                  JOIN (
                        SELECT c.cod_contrato
                          FROM v_dados_contrato_avt c
                         GROUP BY c.cod_contrato
                        HAVING MIN(NVL(TRUNC(c.data_admissao), DATE '1900-01-01')) < DATE '2026-06-01'
                       ) ok
                    ON ok.cod_contrato = a.cod_contrato

                  OUTER APPLY (
                        SELECT h.cod_organograma
                          FROM (
                                SELECT h.*,
                                       CASE
                                         WHEN TRUNC(h.data_inicio) <= TRUNC(a1.data_ini_mov)
                                          AND TRUNC(NVL(h.data_fim, DATE '9999-12-31')) >= TRUNC(a1.data_ini_mov)
                                         THEN 1

                                         WHEN TRUNC(h.data_inicio) <= TRUNC(a1.data_ini_mov)
                                         THEN 2

                                         ELSE 3
                                       END AS rk,

                                       CASE
                                         WHEN TRUNC(h.data_inicio) <= TRUNC(a1.data_ini_mov)
                                          AND TRUNC(NVL(h.data_fim, DATE '9999-12-31')) >= TRUNC(a1.data_ini_mov)
                                         THEN 0

                                         WHEN TRUNC(h.data_inicio) <= TRUNC(a1.data_ini_mov)
                                         THEN TRUNC(a1.data_ini_mov) - TRUNC(h.data_inicio)

                                         ELSE TRUNC(h.data_inicio) - TRUNC(a1.data_ini_mov)
                                       END AS dist

                                  FROM rhfp0310 h
                                 WHERE h.cod_contrato = a.cod_contrato
                               ) h
                         ORDER BY h.rk,
                                  h.dist,
                                  CASE WHEN h.rk IN (1, 2) THEN h.data_inicio END DESC,
                                  CASE WHEN h.rk = 3 THEN h.data_inicio END ASC
                         FETCH FIRST 1 ROW ONLY
                  ) hist

                  LEFT JOIN rhfp0401 org
                    ON org.cod_organograma = hist.cod_organograma

                 WHERE org.cod_nivel2 IS NOT NULL

                   AND a1.cod_evento NOT IN (
                       15, 16, 17, 19, 21, 22, 23, 25, 26
                   )

                   AND c.tipo_vd NOT IN ('B', 'O')

                   AND a1.data_referencia >= TRUNC(p_ini)
                   AND a1.data_referencia <  TRUNC(p_fim) + 1

                   FETCH FIRST 1 ROW ONLY
          );

        RETURN v;
    END;

BEGIN
    /* Validação dos parâmetros */
    IF p_ano IS NULL OR p_mes IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ano e mês são obrigatórios.');
    END IF;

    IF p_mes < 1 OR p_mes > 12 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Mês inválido. Informe um valor entre 1 e 12.');
    END IF;

    IF p_ano < 1900 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Ano inválido.');
    END IF;

    /* Monta o período do mês escolhido */
    v_dt_ini := TO_DATE(TO_CHAR(p_ano) || LPAD(p_mes, 2, '0') || '01', 'YYYYMMDD');
    v_dt_fim := LAST_DAY(v_dt_ini);

    v_cnt := count_periodo(v_dt_ini, v_dt_fim);

    IF v_cnt > 0 THEN

        v_filename :=
            p_prefix || '_' ||
            TO_CHAR(v_dt_ini, 'YYYYMM') || '_' ||
            TO_CHAR(v_dt_ini, 'YYYYMMDD') || '_' ||
            TO_CHAR(v_dt_fim, 'YYYYMMDD') || '.csv';

        v_file := UTL_FILE.FOPEN(v_dir, v_filename, 'W', 32767);

        /* Header */
        UTL_FILE.PUT_LINE(v_file, v_header);

        /* Dados */
        FOR r IN c_dados(v_dt_ini, v_dt_fim) LOOP
            UTL_FILE.PUT_LINE(
                v_file,

                NVL(TO_CHAR(r.codigo_empresa), '') || ';' ||
                '1' || ';' ||
                NVL(TO_CHAR(r.cadastro_colaborador), '') || ';' ||
                NVL(TO_CHAR(r.codigo_calculo), '') || ';' ||
                '1' || ';' ||
                NVL(TO_CHAR(r.codigo_evento), '') || ';' ||

                TO_CHAR(
                    NVL(r.referencia_evento, 0),
                    'FM9999999990D00',
                    q'[NLS_NUMERIC_CHARACTERS = ',.']'
                ) || ';' ||

                TO_CHAR(
                    NVL(r.valor_evento, 0),
                    'FM9999999990D00',
                    q'[NLS_NUMERIC_CHARACTERS = ',.']'
                ) || ';' ||

                NVL(r.codigo_rubrica, '') || ';' ||
                NVL(r.fator_rubrica, '') || ';' ||
                NVL(r.origem_evento, '')
            );
        END LOOP;

        UTL_FILE.FCLOSE(v_file);

        DBMS_OUTPUT.PUT_LINE('Arquivo gerado: ' || v_filename);

    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Nenhum dado encontrado para o período ' ||
            TO_CHAR(v_dt_ini, 'MM/YYYY') ||
            '. Arquivo não gerado.'
        );
    END IF;

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
