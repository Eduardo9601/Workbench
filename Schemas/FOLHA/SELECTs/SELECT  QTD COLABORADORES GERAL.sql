SELECT * FROM V_DADOS_COLAB_AVT
where status = 0
and cod_emp = '008'
and cod_setor_loja in ('001', '013')


SELECT COD_UNIDADE,
       DES_UNIDADE,
       COD_SETOR_LOJA,
       TIPO,
       COUNT(COD_CONTRATO) AS QTD_CONTRATOS,
       SUM(CASE
             WHEN COD_FUNCAO NOT IN
                  (7, 8, 14, 68, 71, 74, 77, 78, 79, 80, 81, 86, 87, 88, 90, 128, 137, 168, 184, 185, 186, 188, 189, 190, 192, 255, 268, 275, 283, 294, 299, 301, 302, 304, 310, 318, 325) THEN
              1
             ELSE
              0
           END) QTD_COLABORADORES,
       SUM(CASE
             WHEN COD_FUNCAO IN
                  (7, 8, 14, 77, 78, 79, 80, 81, 86, 87, 88, 90, 128, 137, 184, 185, 186, 188, 189, 190, 192, 255, 268, 275, 283, 294, 299, 301, 302, 304, 318, 325) THEN
              1
             ELSE
              0
           END) QTD_GERENTES,
       SUM(CASE
             WHEN COD_FUNCAO = 168 THEN
              1
             ELSE
              0
           END) QTD_ESTAGIARIOS,
       SUM(CASE
             WHEN COD_FUNCAO IN (71, 74, 310) THEN
              1
             ELSE
              0
           END) QTD_APRENDIZ,
       SUM(CASE
             WHEN COD_FUNCAO = 68 THEN
              1
             ELSE
              0
           END) QTD_SERVENTES,
       SUM(CASE
             WHEN COD_AFAST NOT IN ('0', '7') THEN
              1
             ELSE
              0
           END) QTD_AFASTADOS  
  FROM V_DADOS_COLAB_AVT
  WHERE 
       COD_EMP = '008' AND
       STATUS = 0 AND
     --COD_SETOR_LOJA NOT IN ('001', '013') AND
      (DATA_FIM_AFAST IS NULL OR DATA_FIM_AFAST <> TO_DATE('31/12/2999', 'DD/MM/YYYY')) AND
      --(COD_REDE_LOCAL = TO_CHAR(:REDE) OR TO_CHAR(:REDE) = 0) AND
       DATA_ADMISSAO <= TO_DATE('23/10/2023', 'DD/MM/YYYY') AND
      (DATA_DEMISSAO IS NULL OR DATA_DEMISSAO >= TO_DATE('23/10/2023', 'DD/MM/YYYY'))
  GROUP BY COD_UNIDADE,
       DES_UNIDADE,
       COD_SETOR_LOJA,
       TIPO
  ORDER BY CASE
             WHEN TIPO = 'LOJA' THEN 1
             WHEN TIPO = 'SETOR' THEN 2
             WHEN TIPO = 'DEPÓSITO' THEN 3
             ELSE 4
           END,
    COD_UNIDADE ASC
       