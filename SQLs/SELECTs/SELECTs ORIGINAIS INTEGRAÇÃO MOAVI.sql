--SELECTs ORIGINAIS INTEGRAÇÃO MOAVI


--SELECT DADOS FILIAIS

SELECT A.FILIAL AS FILIAL_COD,
             P.DES_FANTASIA AS FILIAL,
	     TO_CHAR(A.DATA_INICIO, 'YYYY-MM-DD') AS INICIO,
             G1.COD_UF AS UF,
             G1.DES_CIDADE AS CIDADE,
             PJ.NUM_CGC AS CNPJ,
             GE.COD_GRUPO AS REGIONAL,
             P.DES_EMAIL AS EMAIL,
             TEL.NUM_FONE AS CELULAR,
             MIN(DECODE(A.COD_SEQ_JORNADA, 7, NULL, A.HORA_ENT)) AS ABERT_SEM,
             MAX(DECODE(A.COD_SEQ_JORNADA, 7, NULL, A.HORA_SAI)) AS FECH_SEM,
             MIN(DECODE(A.COD_SEQ_JORNADA, 7, A.HORA_ENT, NULL)) AS ABERT_SAB,
             MAX(DECODE(A.COD_SEQ_JORNADA, 7, A.HORA_SAI, NULL)) AS FECH_SAB,
             MIN(DECODE(A.COD_SEQ_JORNADA, 8, A.HORA_ENT, NULL)) AS ABERT_DOM,
             MAX(DECODE(A.COD_SEQ_JORNADA, 8, A.HORA_SAI, NULL)) AS FECH_DOM
        FROM V_DADOS_FILIAIS             A,
             NL.PS_PESSOAS@NLGRZ         P,
             NL.PS_JURIDICAS@NLGRZ       PJ,
             NL.PS_TELEFONES@NLGRZ       TEL,
             NL.G1_CIDADES@NLGRZ         G1,
             NL.GE_GRUPOS_UNIDADES@NLGRZ GE
       WHERE GE.COD_UNIDADE = A.FILIAL
         AND GE.COD_GRUPO IN
             (8701, 8702, 8703, 8704, 8705, 8706, 8707, 8708, 8709, 8710, 8711, 8712, 8713, 8714, 8715, 8716, 8717, 8718, 8719, 8720)
         AND GE.COD_EMP = 1
         AND G1.COD_CIDADE = P.COD_CIDADE
         AND TEL.COD_PESSOA = P.COD_PESSOA
         AND TEL.NUM_SEQ = 4
         AND PJ.COD_PESSOA = P.COD_PESSOA
         AND P.COD_PESSOA = A.FILIAL
         AND A.FILIAL IN
             (073, 082, 316, 327, 336, 339, 343, 344, 352, 370, 375, 384, 391, 413, 448, 465, 488, 490, 527, 566, 568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173, 7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
       GROUP BY A.FILIAL,
                P.DES_FANTASIA,
                A.DATA_INICIO,
                G1.COD_UF,
                G1.DES_CIDADE,
                PJ.NUM_CGC,
                GE.COD_GRUPO,
                P.DES_EMAIL,
                TEL.NUM_FONE
       ORDER BY A.FILIAL ASC;



--=================================================--
--=================================================--


--SELECT DADOS FATURAMENTOS(VENDAS)


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
                                                  AND B.COD_MAQUINA =
                                                      A.COD_MAQUINA
                JOIN NL.CE_DIARIOS@NLGRZ C ON C.NUM_SEQ_NS = B.NUM_SEQ
                                           AND C.COD_MAQ_NS = B.COD_MAQUINA
                                           AND C.NUM_SEQ_OPER_NS = B.NUM_SEQ_OPER
               WHERE B.COD_OPER IN
                     (300, 302, 305, 4300, 4302, 4305, 3000, 3050)
                 AND A.COD_EMP = 1
                 AND A.IND_STATUS = 1
                 AND A.COD_UNIDADE IN
                     (073, 082, 316, 327, 336, 339, 343, 344, 352, 370, 375, 384, 391, 413, 448, 465, 488, 490, 527, 566, 568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173, 7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
                 AND A.DTA_EMISSAO BETWEEN
                     TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM') AND
                     LAST_DAY(ADD_MONTHS(SYSDATE, -1))
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
                 AND A.COD_UNIDADE_PGTO IN
                     (073, 082, 316, 327, 336, 339, 343, 344, 352, 370, 375, 384, 391, 413, 448, 465, 488, 490, 527, 566, 568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173, 7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
                 AND A.DTA_PAGAMENTO BETWEEN
                     TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM') AND
                     LAST_DAY(ADD_MONTHS(SYSDATE, -1))
               GROUP BY A.COD_UNIDADE_PGTO,
                        A.DTA_PAGAMENTO,
                        NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00') MVTO
       GROUP BY MVTO.COD_UNIDADE,
                TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD'),
                MVTO.HORA_MVTO
       ORDER BY MVTO.COD_UNIDADE ASC,
                TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD') ASC,
                MVTO.HORA_MVTO ASC;




--=================================================--
--=================================================--


--SELECT DADOSCOLABORADORES


      SELECT PIS.NRO_PIS_PASEP     AS PIS,
             CT.COD_CONTRATO       AS MATRICULA,
             PSP.NOME_PESSOA       AS NOME,
             FILIAL.EDICAO_NIVEL3  AS FILIAL,
             CNPJ.CGC              AS CNPJ,
             CASE
               WHEN CT.DATA_FIM IS NULL THEN
                0
               ELSE
                1
             END AS STATUS,
             '0'           AS CPF,
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
        JOIN RHFP0401 FILIAL ON FILIAL.COD_ORGANOGRAMA =
                                ORG.COD_ORGANOGRAMA
        JOIN RHFP0500 INFO ON INFO.COD_CLH = CARGO.COD_CLH
        JOIN (SELECT A.CGC, ORG.EDICAO_NIVEL3
                FROM PESSOA_JURIDICA A
                JOIN RHFP0400 FILIAL ON FILIAL.COD_PESSOA = A.COD_PESSOA
                JOIN RHFP0401 ORG ON FILIAL.COD_ORGANOGRAMA =
                                     ORG.COD_ORGANOGRAMA
               WHERE ORG.EDICAO_NIVEL3 IN
                     ('073', '082', '316', '327', '336', '339', '343', '344',
                      '352', '370', '375', '384', '391', '413', '448', '465',
                      '488', '490', '527', '566', '568', '623', '631', '7002',
                      '7022', '7041', '7065', '7093', '7173', '7386', '7390',
                      '7412', '7461', '7491', '7563', '7589', '7591')) CNPJ ON FILIAL.EDICAO_NIVEL3 =
                                                                               CNPJ.EDICAO_NIVEL3
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