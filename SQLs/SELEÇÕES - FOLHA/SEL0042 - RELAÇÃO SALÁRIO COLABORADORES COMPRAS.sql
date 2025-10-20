SELECT A.COD_CONTRATO || ' - ' || A.DES_PESSOA AS COLABORADOR,
       A.DATA_ADMISSAO,
       A.DATA_DEMISSAO,
       -- Cálculo do tempo de empresa formatado como 'X anos, Y meses e Z dias'
       TRUNC(MONTHS_BETWEEN(SYSDATE, A.DATA_ADMISSAO) / 12) || ' anos, ' ||
       MOD(TRUNC(MONTHS_BETWEEN(SYSDATE, A.DATA_ADMISSAO)), 12) ||
       ' meses e ' ||
       TRUNC(SYSDATE -
             ADD_MONTHS(A.DATA_ADMISSAO,
                        TRUNC(MONTHS_BETWEEN(SYSDATE, A.DATA_ADMISSAO)))) ||
       ' dias' AS TEMPO_EMPRESA,
       
       A.DES_FUNCAO,
       -- Cálculo do tempo de empresa formatado como 'X anos, Y meses e Z dias'
       TRUNC(MONTHS_BETWEEN(SYSDATE, A.DATA_INICIO_CLH) / 12) || ' anos, ' ||
       MOD(TRUNC(MONTHS_BETWEEN(SYSDATE, A.DATA_INICIO_CLH)), 12) ||
       ' meses e ' ||
       TRUNC(SYSDATE -
             ADD_MONTHS(A.DATA_INICIO_CLH,
                        TRUNC(MONTHS_BETWEEN(SYSDATE, A.DATA_INICIO_CLH)))) ||
       ' dias' AS TEMPO_CARGO,
       TO_CHAR(B.VALOR_SALARIO, 'FM999G999G999D90') AS SALARIO
  FROM V_DADOS_COLAB_AVT A
 INNER JOIN RHFP0608 B ON A.COD_CONTRATO = B.COD_CONTRATO
                      AND B.DATA_FIM = TO_DATE('31/12/2999', 'DD/MM/YYYY')
 WHERE A.STATUS = 0
   AND A.EDICAO_DIVISAO = '720'
   AND A.DES_FUNCAO LIKE '%ASSISTENTE%'
