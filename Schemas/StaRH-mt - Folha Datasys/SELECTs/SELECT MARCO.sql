SELECT A.COD_UNIDADE,
       A.NUM_NOTA,
       A.DTA_EMISSAO,
       A.DTA_PAGAMENTO,
       TO_CHAR(A.ACRESCIMO,'9G999G999G990D00') ACRESCIMO,
       TO_CHAR(A.IOF,'9G999G999G990D00') IOF,
       TO_CHAR(A.SEGURO,'9G999G999G990D00') SEGURO,
       TO_CHAR(A.VLR_PRINCIPAL,'9G999G999G990D00') VLR_PRINCIPAL,
       TO_CHAR(A.VLR_ENTRADA,'9G999G999G990D00') VLR_ENTRADA,
       TO_CHAR(A.VLR_TOTAL_FINANC,'9G999G999G990D00') VLR_TOTAL_FINANC,
       CASE
    WHEN LENGTH(TO_CHAR(A.NUM_CPF)) = 11 THEN 
        SUBSTR(TO_CHAR(A.NUM_CPF), 1, 3) || '.' || 
        SUBSTR(TO_CHAR(A.NUM_CPF), 4, 3) || '.' || 
        SUBSTR(TO_CHAR(A.NUM_CPF), 7, 3) || '-' || 
        SUBSTR(TO_CHAR(A.NUM_CPF), 10, 2)
    ELSE TO_CHAR(A.NUM_CPF)
END AS NUM_CPF,
       TO_CHAR(SUM(A.VLR_LANCAMENTO),'9G999G999G990D00') VLR_LANCAMENTO,
       TO_CHAR(SUM(A.VLR_JUROS),'9G999G999G990D00') VLR_JUROS,
       TO_CHAR(SUM(A.VLR_MULTA),'9G999G999G990D00') VLR_MULTA,
       TO_CHAR(SUM(A.VLR_DESCONTO),'9G999G999G990D00') VLR_DESCONTO,
       A.COD_PESSOA,
       A.ASSESSORIA,
       TO_CHAR(SUM((A.VLR_LANCAMENTO + A.VLR_JUROS + A.VLR_MULTA - A.VLR_DESCONTO) / A.VLR_PRINCIPAL * A.VLR_ENTRADA),'9G999G999G990D00') PORCENTAGEM
  FROM (SELECT DISTINCT A.COD_UNIDADE,
                        A.NUM_NOTA,
                        A.DTA_EMISSAO,
                        C.DTA_PAGAMENTO,
                        A.ACRESCIMO,
                        A.IOF,
                        A.SEGURO,
                        A.VLR_PRINCIPAL,
                        A.VLR_ENTRADA,
                        A.VLR_TOTAL_FINANC,
                        A.NUM_CPF,
                        C.NUM_TITULO,
                        C.VLR_LANCAMENTO,
                        NVL(C.VLR_JURO_COBR, 0) VLR_JUROS,
                        NVL(C.VLR_DESP_COBR, 0) VLR_MULTA,
                        NVL(C.VLR_DESCONTO, 0) VLR_DESCONTO,
                        B.COD_PESSOA,
                        C.NUM_PARCELA,
                        D.DTA_VENCIMENTO,
                        NVL((SELECT X.DES_ASSESSORIA
                              FROM GRZ_ASSESSORIAS_COBRANCA Z
                             INNER JOIN GRZ_ASSESSORIAS X ON X.IND_ASSESSORIA = Z.IND_ASSESSORIA
                             WHERE Z.COD_EMP = C.COD_EMP
                               AND Z.COD_UNIDADE = C.COD_UNIDADE
                               AND Z.COD_PESSOA = C.COD_PESSOA
                               AND Z.NUM_TITULO = C.NUM_TITULO
                               AND Z.COD_COMPL = C.COD_COMPL
                               AND Z.NUM_PARCELA = C.NUM_PARCELA),
                            'GRAZZIOTIN') ASSESSORIA
          FROM V_GRZ_TITULOS_RENEGOCIADOS A,
               PS_FISICAS                 B,
               CR_HISTORICOS              C,
               CR_TITULOS                 D
         WHERE D.COD_EMP = 1
           AND C.COD_EMP = 1
           AND A.NUM_CPF = B.NUM_CPF
           AND (CASE WHEN substr(A.CONTRATO_RENEGOCIADO,13,15) = 'CRE' THEN SUBSTR(replace(A.CONTRATO_RENEGOCIADO,'CRE',''),6,15)
             WHEN substr(A.CONTRATO_RENEGOCIADO,13,15) = 'CPP' THEN SUBSTR(replace(A.CONTRATO_RENEGOCIADO,'CPP',''),6,15)
             WHEN substr(A.CONTRATO_RENEGOCIADO,13,15) = 'VSE' THEN SUBSTR(replace(A.CONTRATO_RENEGOCIADO,'VSE',''),6,15)
             WHEN substr(A.CONTRATO_RENEGOCIADO,13,15) = 'VSP' THEN SUBSTR(replace(A.CONTRATO_RENEGOCIADO,'VSP',''),6,15) END) = c.num_titulo
           AND B.COD_PESSOA = C.COD_PESSOA
           AND C.COD_EMP = D.COD_EMP
           AND C.COD_UNIDADE = D.COD_UNIDADE
           AND C.COD_PESSOA = D.COD_PESSOA
           AND C.NUM_TITULO = D.NUM_TITULO
           AND C.COD_COMPL = D.COD_COMPL
           AND C.NUM_PARCELA = D.NUM_PARCELA
           AND C.COD_LANCAMENTO = 112
           AND A.DTA_EMISSAO = C.DTA_PAGAMENTO
           AND C.DTA_PAGAMENTO >= TO_DATE('01/01/2023', 'dd/mm/yyyy')
           AND C.DTA_PAGAMENTO <= TO_DATE('30/01/2023', 'dd/mm/yyyy')
           AND A.NUM_CPF between 0 and 99999999999
           and a.cod_unidade IN (SELECT f.cod_unidade FROM v_unidades f where f.rede = 10 and f.cod_unidade between 4 and 14)
         ORDER BY 1, 2, 3, 11, 17) A
 GROUP BY A.COD_UNIDADE,
          A.NUM_NOTA,
          A.DTA_EMISSAO,
          A.DTA_PAGAMENTO,
          A.ACRESCIMO,
          A.IOF,
          A.SEGURO,
          A.VLR_PRINCIPAL,
          A.VLR_ENTRADA,
          A.VLR_TOTAL_FINANC,
          A.NUM_CPF,
          A.COD_PESSOA,
          A.ASSESSORIA
    order by a.dta_pagamento DESC;