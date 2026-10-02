/* ===================================================================
   === SQL DE 'DE x PARA' DA MONTAGEM CONTÁBIL ENTRE DATASYS E HCM ===
   =================================================================== */


WITH DATASYS AS
(
    SELECT
        D.COD_CLASSE_CONT,
        D.NOME_CLASSE_CONT,
        D.COD_TOTAL,
        D.NOME_TOTAL,
        D.COD_VD,
        D.NOME_VD,
        D.COD_CONTA_CONTABIL,
        D.NOME_CONTA_CONTABIL,
        UPPER(TRIM(D.TIPO_LANCAMENTO)) AS TIPO_LANCAMENTO,
        D.COD_CONTRAPARTIDA,
        D.COD_HISTORICO,
        D.DES_HISTORICO,

        REGEXP_REPLACE(
            TRIM(D.COD_CONTA_CONTABIL),
            '[^0-9]',
            ''
        ) AS CONTA_DS_COMPARACAO

    FROM V_DADOS_CONTABIL_AVT D

    WHERE D.COD_CLASSE_CONT IN (27, 28, 29)
),

DE_PARA AS
(
    SELECT DISTINCT
           COD_VD,
           NOME_VD,
           COD_EVENTO,
           NOME_EVENTO
    FROM TB_EVENTOS_VD
),

HCM AS
(
    SELECT DISTINCT
           H.NUMEMP,
           H.CODCCU,
           H.CODTAB,
           H.CODEVE,
           H.DESEVE,
           H.CLC_EVENTO,

           H.CLC_DEBITO,
           H.CONTA_DEBITO,

           H.CLC_CREDITO,
           H.CONTA_CREDITO,

           REGEXP_REPLACE(
               TRIM(H.CONTA_DEBITO),
               '[^0-9]',
               ''
           ) AS CONTA_DEBITO_COMP,

           REGEXP_REPLACE(
               TRIM(H.CONTA_CREDITO),
               '[^0-9]',
               ''
           ) AS CONTA_CREDITO_COMP

    FROM R001CTBH H

    /* FILTRO DA EMPRESA FICA AQUI */
    WHERE H.NUMEMP = 1629
),

CONFRONTO AS
(
    SELECT
        D.COD_CLASSE_CONT,
        D.NOME_CLASSE_CONT,

        D.COD_TOTAL,
        D.NOME_TOTAL,

        D.COD_VD,
        D.NOME_VD,

        M.COD_EVENTO AS CODEVE_HCM,
        M.NOME_EVENTO AS NOME_EVENTO_HCM,

        H.NUMEMP,
        H.CODCCU,

        D.TIPO_LANCAMENTO,

        /* ============================= */
        /* DATASYS                       */
        /* ============================= */

        D.COD_CONTA_CONTABIL AS CONTA_DATASYS,
        D.NOME_CONTA_CONTABIL,

        /* ============================= */
        /* HCM                           */
        /* ============================= */

        H.CLC_DEBITO,
        H.CONTA_DEBITO,

        H.CLC_CREDITO,
        H.CONTA_CREDITO,

        /* ============================= */
        /* CONTA HCM USADA NO CONFRONTO  */
        /* ============================= */

        CASE
            WHEN D.TIPO_LANCAMENTO = 'D'
                THEN H.CONTA_DEBITO

            WHEN D.TIPO_LANCAMENTO = 'C'
                THEN H.CONTA_CREDITO
        END AS CONTA_HCM_CONFRONTO,

        /* ============================= */
        /* STATUS                        */
        /* ============================= */

        CASE

            WHEN M.COD_EVENTO IS NULL
                THEN 'SEM DE/PARA'

            WHEN H.CODEVE IS NULL
                THEN 'EVENTO NAO ENCONTRADO NO HCM'

            WHEN D.TIPO_LANCAMENTO NOT IN ('D','C')
                THEN 'TIPO LANCAMENTO INVALIDO'

            WHEN D.TIPO_LANCAMENTO = 'D'
                 AND H.CONTA_DEBITO IS NULL
                THEN 'SEM CONTA DEBITO HCM'

            WHEN D.TIPO_LANCAMENTO = 'C'
                 AND H.CONTA_CREDITO IS NULL
                THEN 'SEM CONTA CREDITO HCM'

            WHEN D.TIPO_LANCAMENTO = 'D'
             AND D.CONTA_DS_COMPARACAO = H.CONTA_DEBITO_COMP
                THEN 'OK'

            WHEN D.TIPO_LANCAMENTO = 'C'
             AND D.CONTA_DS_COMPARACAO = H.CONTA_CREDITO_COMP
                THEN 'OK'

            ELSE 'CONTA DIVERGENTE'

        END AS STATUS_CONFRONTO,

        D.COD_CONTRAPARTIDA,
        D.COD_HISTORICO,
        D.DES_HISTORICO

    FROM DATASYS D

    /* PRESERVA TODOS OS REGISTROS DO DATASYS */
    LEFT JOIN DE_PARA M
           ON M.COD_VD = D.COD_VD

    /* AQUI O HCM JÁ ESTÁ RESTRITO À EMPRESA 1629 */
    LEFT JOIN HCM H
           ON H.CODEVE = M.COD_EVENTO
)

SELECT *
FROM CONFRONTO

ORDER BY
    CASE COD_CLASSE_CONT
        WHEN 27 THEN 1
        WHEN 28 THEN 2
        WHEN 29 THEN 3
        ELSE 99
    END,

    COD_TOTAL,
    COD_VD,
    CODEVE_HCM,
    CODCCU,
    TIPO_LANCAMENTO;
