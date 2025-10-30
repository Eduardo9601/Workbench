--SELECTs ATUALIZADOS INTEGRAÇÃO MOAVI

--DADOS FILIAIS

SELECT A.UNIDADE AS FILIAL_COD,
       A.NOME_UNIDADE AS FILIAL,
       TO_CHAR(B.DATA_INICIO, 'YYYY-MM-DD') AS INICIO,
       A.COD_UF AS UF,
       A.CIDADE,
       A.CNPJ,
       A.REGIAO AS REGIONAL,
       A.EMAIL,
       A.CELULAR,
       MIN(DECODE(B.COD_SEQ_JORNADA, 7, NULL, B.HORA_ENT)) AS ABERT_SEM,
       MAX(DECODE(B.COD_SEQ_JORNADA, 7, NULL, B.HORA_SAI)) AS FECH_SEM,
       MIN(DECODE(B.COD_SEQ_JORNADA, 7, B.HORA_ENT, NULL)) AS ABERT_SAB,
       MAX(DECODE(B.COD_SEQ_JORNADA, 7, B.HORA_SAI, NULL)) AS FECH_SAB,
       MIN(DECODE(B.COD_SEQ_JORNADA, 8, B.HORA_ENT, NULL)) AS ABERT_DOM,
       MAX(DECODE(B.COD_SEQ_JORNADA, 8, B.HORA_SAI, NULL)) AS FECH_DOM
  FROM V_DADOS_LOJAS_AVT A, V_DADOS_FILIAIS B
 WHERE A.UNIDADE = B.FILIAL
 GROUP BY A.UNIDADE,
          A.NOME_UNIDADE,
          B.DATA_INICIO,
          A.COD_UF,
          A.CIDADE,
          A.CNPJ,
          A.REGIAO,
          A.EMAIL,
          A.CELULAR
 ORDER BY A.UNIDADE;



--==================================================--
--==================================================--

--DADOS VENDAS

SELECT MVTO.COD_UNIDADE AS FILIAL_COD,
             'LOJA' AS SETOR,
             TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD') AS DATA,
             MVTO.HORA_MVTO AS HORA,
             REPLACE(TO_CHAR(SUM(MVTO.VLR_FATURAMENTO)), ',', '.') AS FATURAMENTO,
             SUM(MVTO.NRO_CUPONS) AS CUPONS,
             SUM(MVTO.NRO_ITENS) AS ITENS
        FROM (SELECT A.COD_UNIDADE,
                     A.DTA_EMISSAO DTA_MVTO,
                     NVL(TO_CHAR(A.DTH_FIM_VENDA, 'HH24'), '00') || ':00' HORA_MVTO,
                     SUM(B.VLR_OPERACAO) AS VLR_FATURAMENTO,
                     COUNT(DISTINCT(A.NUM_SEQ || A.COD_MAQUINA)) NRO_CUPONS,
                     COUNT(DISTINCT C.COD_ITEM) NRO_ITENS
                FROM NL.NS_NOTAS@NLGRZ A
                JOIN NL.NS_NOTAS_OPERACOES@NLGRZ B ON B.NUM_SEQ = A.NUM_SEQ
                                                   AND B.COD_MAQUINA = A.COD_MAQUINA
                JOIN NL.CE_DIARIOS@NLGRZ C ON C.NUM_SEQ_NS = B.NUM_SEQ
                                           AND C.COD_MAQ_NS = B.COD_MAQUINA
                                           AND C.NUM_SEQ_OPER_NS = B.NUM_SEQ_OPER
               WHERE B.COD_OPER IN
                     (300, 302, 305, 4300, 4302, 4305, 3000, 3050)
                 AND A.COD_EMP = 1
                 AND A.IND_STATUS = 1
                    --AND A.DTA_EMISSAO = '31/08/2023'
                 AND A.DTA_EMISSAO BETWEEN
                     TRUNC(ADD_MONTHS(SYSDATE, -13), 'MM') 
					 AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
               GROUP BY A.COD_UNIDADE,
                        A.DTA_EMISSAO,
                        NVL(TO_CHAR(A.DTH_FIM_VENDA, 'HH24'), '00') || ':00'
						
              UNION ALL
			  
              SELECT A.COD_UNIDADE_PGTO COD_UNIDADE,
                     A.DTA_PAGAMENTO DTA_MVTO,
                     NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00' HORA_MVTO,
                     0 VLR_FATURAMENTO,
                     COUNT(DISTINCT(A.NUM_LCTO_INICIAL || A.NUM_DOC_CAIXA)) NRO_CUPONS,
                     COUNT(1) NRO_ITENS
                FROM NL.CR_HISTORICOS@NLGRZ A
               WHERE A.COD_EMP = 1
                 AND A.IND_DC = 2
                 AND A.IND_LANCAMENTO = 2
                    --AND A.DTA_PAGAMENTO = '31/08/2023'
                 AND A.DTA_PAGAMENTO BETWEEN
                     TRUNC(ADD_MONTHS(SYSDATE, -13), 'MM') 
					 AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
               GROUP BY A.COD_UNIDADE_PGTO,
                        A.DTA_PAGAMENTO,
                        NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00') MVTO,
             V_DADOS_LOJAS_AVT AVT
       WHERE AVT.UNIDADE = MVTO.COD_UNIDADE
       GROUP BY MVTO.COD_UNIDADE,
                TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD'),
                MVTO.HORA_MVTO
       ORDER BY MVTO.COD_UNIDADE ASC,
                TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD') ASC,
                MVTO.HORA_MVTO ASC;



--==================================================--
--==================================================--


--DADOS FUNCIONARIOS

SELECT PIS.NRO_PIS_PASEP AS PIS,
               CT.COD_CONTRATO AS MATRICULA,
               PSP.NOME_PESSOA AS NOME,
               FILIAL.EDICAO_NIVEL3 AS FILIAL,
               VDL.CNPJ AS FILIAL_CNPJ,
               CASE
                 WHEN CT.DATA_FIM IS NULL THEN
                  0
                 ELSE
                  1
               END AS STATUS,
               '0' AS CPF,
               INFO.NOME_CLH AS CARGO,
               TO_CHAR(FERIAS.DATA_FERIAS, 'YYYY-MM-DD') AS INI_FERIAS,
               TO_CHAR(FERIAS.DATA_RETORNO, 'YYYY-MM-DD') AS FIM_FERIAS
          FROM RHFP0300 CT
          JOIN RHFP0340 A ON A.COD_CONTRATO = CT.COD_CONTRATO
          JOIN RHFP0310 ORG ON ORG.COD_CONTRATO = CT.COD_CONTRATO
          JOIN RHFP0340 CARGO ON CARGO.COD_CONTRATO = CT.COD_CONTRATO
          LEFT JOIN RHFP0327 FERIAS ON FERIAS.COD_CONTRATO = CT.COD_CONTRATO
          JOIN PESSOA PSP ON PSP.COD_PESSOA = CT.COD_FUNC
          JOIN RHFP0200 PIS ON PIS.COD_FUNC = CT.COD_FUNC
          JOIN RHFP0401 FILIAL ON FILIAL.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
          JOIN RHFP0500 INFO ON INFO.COD_CLH = CARGO.COD_CLH
          JOIN (SELECT CNPJ, UNIDADE FROM V_DADOS_LOJAS_AVT) VDL ON FILIAL.EDICAO_NIVEL3 = VDL.UNIDADE
         WHERE CT.DATA_FIM IS NULL
           AND A.DATA_FIM = '31/12/2999'
           AND ORG.DATA_FIM = '31/12/2999'
           AND CARGO.DATA_FIM = '31/12/2999'
           AND (FERIAS.DATA_FERIAS =
               (SELECT MAX(DATA_FERIAS)
                   FROM RHFP0327 Y
                  WHERE Y.COD_CONTRATO = FERIAS.COD_CONTRATO) OR
               FERIAS.DATA_FERIAS IS NULL) -- Considera registros onde DATA_FERIAS é NULL
         ORDER BY FILIAL.EDICAO_NIVEL3, INFO.NOME_CLH, FERIAS.DATA_FERIAS;




