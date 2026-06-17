INSERT INTO RHFP1004 (
    COD_EVENTO,
    COD_CONTRATO,
    DATA_MOV,
    COD_VD,
    TIPO_INF_VD,
    PRESTACAO_VD,
    QTDE_VD,
    VALOR_VD,
    COD_ORIGEM_MOV,
    COD_MESTRE_EVENTO,
    DATA_DIGITACAO,
    OBSERVACAO,
    COMPETENCIA
)
SELECT DISTINCT
       1 AS COD_EVENTO,
       c.COD_CONTRATO,
       DATE '2025-12-22' AS DATA_MOV,
       4109 AS COD_VD,
       'V' AS TIPO_INF_VD,
       CAST(NULL AS NUMBER) AS PRESTACAO_VD,
       CAST(NULL AS NUMBER) AS QTDE_VD,
       480 AS VALOR_VD,
       188 AS COD_ORIGEM_MOV,
       18171 AS COD_MESTRE_EVENTO,
       SYSDATE AS DATA_DIGITACAO,
       'VALOR REFERENTE A CESTA DE NATAL 2025' AS OBSERVACAO,
       CAST(NULL AS VARCHAR2(7)) AS COMPETENCIA
FROM V_DADOS_COLAB_AVT c
WHERE c.DATA_DEMISSAO IS NULL
  AND TRUNC(c.DATA_ADMISSAO) <= DATE '2025-11-14'                 -- exclui admitidos após 14/11/2025
  AND c.COD_ORGANOGRAMA NOT IN (336, 337, 339)                    -- exclui organogramas
  AND NVL(TRUNC(c.DATA_FIM_AFAST), DATE '1900-01-01') <> DATE '2999-12-31'  -- exclui afast. indeterminado
  AND C.COD_EMP NOT IN (4, 6)
  -- exclui Aprendizes/Estagiários (case/acento-insensitive)
  AND NOT REGEXP_LIKE(
        UPPER(TRANSLATE(c.DES_FUNCAO,
          'ÁÀÂÃÄáàâãäÉÈÊËéèêëÍÌÎÏíìîïÓÒÔÕÖóòôõöÚÙÛÜúùûüÇç',
          'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCc')),
        '(APRENDIZ|ESTAG)')
  -- isola casos que irão para o SQL 2 (COD_AFAST=4 com data fim definida e real):
  AND NOT (c.COD_AFAST = 4
           AND c.DATA_FIM_AFAST IS NOT NULL
           AND TRUNC(c.DATA_FIM_AFAST) <> DATE '2999-12-31');