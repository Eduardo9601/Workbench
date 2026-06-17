----SQLS PARA COLETAR DADOS PARA INTEGRAÇÃO ENTRE MOAVI + GRAZZIOTIN
--___________________________________________________________________--


--ITEM 2.1 INFORMAÇÕES BÁSICAS - DADOS DAS FILIAIS:

---DADOS FILIAL----
SELECT A.FILIAL "COD_FILIAL",
       P.DES_FANTASIA "FILIAL",
       A.DATA_INICIO "INICIO",
       G1.COD_UF "UF",
       G1.DES_CIDADE "CIDADE",
       PJ.NUM_CGC "CNPJ",
       GE.COD_GRUPO "REGIONAL",
       P.DES_EMAIL "EMAIL",
       TEL.NUM_FONE "CELULAR",
       MIN(DECODE(A.COD_SEQ_JORNADA, 7, NULL, A.HORA_ENT)) "ABERT_SEM",
       MAX(DECODE(A.COD_SEQ_JORNADA, 7, NULL, A.HORA_SAI)) "FECH_SEM",
       MIN(DECODE(A.COD_SEQ_JORNADA, 7, A.HORA_ENT, NULL)) "ABERT_SAB",
       MAX(DECODE(A.COD_SEQ_JORNADA, 7, A.HORA_SAI, NULL)) "FECH_SAB",
       MIN(DECODE(A.COD_SEQ_JORNADA, 8, A.HORA_ENT, NULL)) "ABERT_DOM",
       MAX(DECODE(A.COD_SEQ_JORNADA, 8, A.HORA_SAI, NULL)) "FECH_DOM"
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
 ORDER BY A.FILIAL ASC





--=============================================================================================--
--=============================================================================================--



--ITEM 2.2. VENDAS - DADOS DAS OPERAÇÕES POR HORÁRIO

----SELECT OPERAÇÕES LOJA----
SELECT MVTO.COD_UNIDADE AS FILIAL_COD,
       'LOJA' AS SETOR,
       TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD') AS DATA,
       MVTO.HORA_MVTO AS HORA,
       TO_CHAR(SUM(MVTO.VLR_FATURAMENTO),
               '99999999D999',
               'NLS_NUMERIC_CHARACTERS = ''.,''') AS FATURAMENTO,
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
         WHERE B.COD_OPER IN (300, 302, 305, 4300, 4302, 4305, 3000, 3050)
           AND A.COD_EMP = 1
           AND A.IND_STATUS = 1
           AND A.COD_UNIDADE IN
               (073, 082, 316, 327, 336, 339, 343, 344, 352, 370, 375, 384, 391, 413, 448, 465, 488, 490, 527, 566, 568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173, 7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
           AND A.DTA_EMISSAO BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -13), 'MM') AND
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
           AND A.DTA_PAGAMENTO BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -13), 'MM') AND
               LAST_DAY(ADD_MONTHS(SYSDATE, -1))
         GROUP BY A.COD_UNIDADE_PGTO,
                  A.DTA_PAGAMENTO,
                  NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00') MVTO
 GROUP BY MVTO.COD_UNIDADE,
          TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD'),
          MVTO.HORA_MVTO
 ORDER BY MVTO.COD_UNIDADE ASC,
          TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD') ASC,
          MVTO.HORA_MVTO ASC



SELECT A.COD_UNIDADE, A.NUM_NOTA, A.DTA_EMISSAO, B.VLR_OPERACAO
FROM NL.NS_NOTAS@NLGRZ A, NL.NS_NOTAS_OPERACOES@NLGRZ B
WHERE A.COD_MAQUINA = B.COD_MAQUINA
AND A.COD_UNIDADE = 73





--=============================================================================================--
--=============================================================================================--


--ITEM 2.3 FUNCIONÁRIOS - DADOS DOS COLABORADORES

---SELECT COLABORADORES----
SELECT PIS.NRO_PIS_PASEP "PIS",
       CT.COD_CONTRATO "MATRICULA",
       PSP.NOME_PESSOA "NOME",
       FILIAL.EDICAO_NIVEL3 "FILIAL",
       CNPJ.CGC "CNPJ",
       CASE
         WHEN CT.DATA_FIM IS NULL THEN
          0
         ELSE
          1
       END "STATUS",
       '0' "CPF",
       INFO.NOME_CLH "CARGO",
       FERIAS.DATA_FERIAS "INI FERIAS",
       FERIAS.DATA_RETORNO "FIM FERIAS"
  FROM RHFP0300 CT
  JOIN RHFP0340 A ON A.COD_CONTRATO = CT.COD_CONTRATO
  JOIN RHFP0310 ORG ON ORG.COD_CONTRATO = CT.COD_CONTRATO
  JOIN RHFP0340 CARGO ON CARGO.COD_CONTRATO = CT.COD_CONTRATO
  LEFT JOIN RHFP0327 FERIAS ON FERIAS.COD_CONTRATO = CT.COD_CONTRATO -- Usando LEFT JOIN aqui
  JOIN PESSOA PSP ON PSP.COD_PESSOA = CT.COD_FUNC
  JOIN RHFP0200 PIS ON PIS.COD_FUNC = CT.COD_FUNC
  JOIN RHFP0401 FILIAL ON FILIAL.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
  JOIN RHFP0500 INFO ON INFO.COD_CLH = CARGO.COD_CLH
  JOIN (SELECT A.CGC, ORG.EDICAO_NIVEL3
          FROM PESSOA_JURIDICA A
          JOIN RHFP0400 FILIAL ON FILIAL.COD_PESSOA = A.COD_PESSOA
          JOIN RHFP0401 ORG ON FILIAL.COD_ORGANOGRAMA = ORG.COD_ORGANOGRAMA
         WHERE ORG.EDICAO_NIVEL3 IN
               ('073', '082', '316', '327', '336', '339', '343', '344', '352',
                '370', '375', '384', '391', '413', '448', '465', '488', '490',
                '527', '566', '568', '623', '631', '7002', '7022', '7041',
                '7065', '7093', '7173', '7386', '7390', '7412', '7461',
                '7491', '7563', '7589', '7591')) CNPJ ON FILIAL.EDICAO_NIVEL3 =
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
 ORDER BY FILIAL.EDICAO_NIVEL3, INFO.NOME_CLH, FERIAS.DATA_FERIAS
 










--===================================================================================================================--
--===================================================================================================================--


--EXXEMPLO 1


CREATE OR REPLACE PROCEDURE GRZ_VENDAS_MOAVI IS

BEGIN

CURSOR c_vendas_moavi IS

SELECT MVTO.COD_UNIDADE "FILIAL",
       'LOJA' "SETOR",
       MVTO.DTA_MVTO "EMISSAO",
       MVTO.HORA_MVTO "HORA",
       SUM(0) "FATURAMENTO",
       SUM(MVTO.NRO_CUPONS) "CUPONS",
       SUM(MVTO.NRO_ITENS) "ITENS"
FROM (
    SELECT A.COD_UNIDADE,
           A.DTA_EMISSAO DTA_MVTO,
           NVL(TO_CHAR(A.DTH_FIM_VENDA, 'HH24'), '00') || ':00' HORA_MVTO,
           SUM(0) VLR_FATURAMENTO,
           COUNT(DISTINCT(A.NUM_SEQ || A.COD_MAQUINA)) NRO_CUPONS,
           COUNT(DISTINCT C.COD_ITEM) NRO_ITENS
    FROM NL.NS_NOTAS@NLGRZ A
    JOIN NL.NS_NOTAS_OPERACOES@NLGRZ B ON B.NUM_SEQ = A.NUM_SEQ AND B.COD_MAQUINA = A.COD_MAQUINA
    JOIN NL.CE_DIARIOS@NLGRZ C ON C.NUM_SEQ_NS = B.NUM_SEQ AND C.COD_MAQ_NS = B.COD_MAQUINA AND C.NUM_SEQ_OPER_NS = B.NUM_SEQ_OPER
    WHERE B.COD_OPER IN (300, 302, 305, 4300, 4302, 4305, 3000, 3050)
      AND A.COD_EMP = 1
      AND A.IND_STATUS = 1
      AND A.COD_UNIDADE IN (073, 082, 316, 327, 336, 339, 343, 344, 352, 370,
                            375, 384, 391, 413, 448, 465, 488, 490, 527, 566,
                            568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173,
                            7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
      AND A.DTA_EMISSAO BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM') AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
    GROUP BY A.COD_UNIDADE,
             A.DTA_EMISSAO,
             NVL(TO_CHAR(A.DTH_FIM_VENDA, 'HH24'), '00') || ':00'
    UNION ALL
    SELECT A.COD_UNIDADE_PGTO COD_UNIDADE,
           A.DTA_PAGAMENTO DTA_MVTO,
           NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00' HORA_MVTO,
           SUM(0) VLR_FATURAMENTO,
           COUNT(DISTINCT(A.NUM_LCTO_INICIAL || A.NUM_DOC_CAIXA)) NRO_CUPONS,
           COUNT(1) NRO_ITENS
    FROM NL.CR_HISTORICOS@NLGRZ A
    WHERE A.COD_EMP = 1
      AND A.IND_DC = 2
      AND A.IND_LANCAMENTO = 2
      AND A.COD_UNIDADE_PGTO IN (073, 082, 316, 327, 336, 339, 343, 344, 352, 370,
                                 375, 384, 391, 413, 448, 465, 488, 490, 527, 566,
                                 568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173,
                                 7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
      AND A.DTA_PAGAMENTO BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM') AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
    GROUP BY A.COD_UNIDADE_PGTO,
             A.DTA_PAGAMENTO,
             NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00'
) MVTO
GROUP BY MVTO.COD_UNIDADE, MVTO.DTA_MVTO, MVTO.HORA_MVTO, MVTO.VLR_FATURAMENTO
ORDER BY MVTO.COD_UNIDADE ASC, MVTO.DTA_MVTO ASC, MVTO.HORA_MVTO ASC;

 r_vendas_moavi c_vendas_moavi %ROWTYPE;


    file_handle                     UTL_FILE.FILE_TYPE;
    nome_arq                        VARCHAR2(100);
    
	nome_arq    := 'REL_VENDAS_MOAVI_'||to_char(sysdate, 'HH24miss')||'.txt';
    
	file_handle := UTL_FILE.FOPEN('/mnt/datasys/Moavi/Vendas',nome_arq,'W');
    Utl_File.Put_Line(file_handle,'FILIAL;SETOR;EMISSAO;HORA;FATURAMENTO;CUPONS;ITENS;');

    OPEN c_vendas_moavi;
    FETCH c_vendas_moavi INTO r_vendas_moavi;
    WHILE c_vendas_moavi%FOUND LOOP
      BEGIN

        Utl_File.Put_Line(file_handle,r_vendas_moavi.FILIAL||';'
                                    ||r_vendas_moavi.SETOR||';'
                                    ||r_vendas_moavi.EMISSAO||';'
                                    ||r_vendas_moavi.HORA||';'
                                    ||r_vendas_moavi.FATURAMENTO||';'
                                    ||r_vendas_moavi.CUPONS||';'
                                    ||r_vendas_moavi.ITENS||';');
                                   
      END;
    FETCH c_vendas_moavi INTO r_vendas_moavi;
    END LOOP;
    CLOSE c_vendas_moavi;
    UTL_FILE.FCLOSE(file_handle);
    
    COMMIT;
	END;
END GRZ_VENDAS_MOAVI;




--============================================--
--============================================--

--EXEMPLO 2

CREATE OR REPLACE PROCEDURE GRZ_VENDAS_MOAVI IS
    file_handle UTL_FILE.FILE_TYPE;
    nome_arq VARCHAR2(100) := 'REL_VENDAS_MOAVI_' || to_char(sysdate, 'HH24miss') || '.txt';

    CURSOR c_vendas_moavi IS
    SELECT MVTO.COD_UNIDADE "FILIAL",
       'LOJA' "SETOR",
       MVTO.DTA_MVTO "EMISSAO",
       MVTO.HORA_MVTO "HORA",
       SUM(0) "FATURAMENTO",
       SUM(MVTO.NRO_CUPONS) "CUPONS",
       SUM(MVTO.NRO_ITENS) "ITENS"
FROM (
    SELECT A.COD_UNIDADE,
           A.DTA_EMISSAO DTA_MVTO,
           NVL(TO_CHAR(A.DTH_FIM_VENDA, 'HH24'), '00') || ':00' HORA_MVTO,
           SUM(0) VLR_FATURAMENTO,
           COUNT(DISTINCT(A.NUM_SEQ || A.COD_MAQUINA)) NRO_CUPONS,
           COUNT(DISTINCT C.COD_ITEM) NRO_ITENS
    FROM NL.NS_NOTAS@NLGRZ A
    JOIN NL.NS_NOTAS_OPERACOES@NLGRZ B ON B.NUM_SEQ = A.NUM_SEQ AND B.COD_MAQUINA = A.COD_MAQUINA
    JOIN NL.CE_DIARIOS@NLGRZ C ON C.NUM_SEQ_NS = B.NUM_SEQ AND C.COD_MAQ_NS = B.COD_MAQUINA AND C.NUM_SEQ_OPER_NS = B.NUM_SEQ_OPER
    WHERE B.COD_OPER IN (300, 302, 305, 4300, 4302, 4305, 3000, 3050)
      AND A.COD_EMP = 1
      AND A.IND_STATUS = 1
      AND A.COD_UNIDADE IN (073, 082, 316, 327, 336, 339, 343, 344, 352, 370,
                            375, 384, 391, 413, 448, 465, 488, 490, 527, 566,
                            568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173,
                            7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
      AND A.DTA_EMISSAO BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM') AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
    GROUP BY A.COD_UNIDADE,
             A.DTA_EMISSAO,
             NVL(TO_CHAR(A.DTH_FIM_VENDA, 'HH24'), '00') || ':00'
    UNION ALL
    SELECT A.COD_UNIDADE_PGTO COD_UNIDADE,
           A.DTA_PAGAMENTO DTA_MVTO,
           NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00' HORA_MVTO,
           SUM(0) VLR_FATURAMENTO,
           COUNT(DISTINCT(A.NUM_LCTO_INICIAL || A.NUM_DOC_CAIXA)) NRO_CUPONS,
           COUNT(1) NRO_ITENS
    FROM NL.CR_HISTORICOS@NLGRZ A
    WHERE A.COD_EMP = 1
      AND A.IND_DC = 2
      AND A.IND_LANCAMENTO = 2
      AND A.COD_UNIDADE_PGTO IN (073, 082, 316, 327, 336, 339, 343, 344, 352, 370,
                                 375, 384, 391, 413, 448, 465, 488, 490, 527, 566,
                                 568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173,
                                 7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
      AND A.DTA_PAGAMENTO BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM') AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
    GROUP BY A.COD_UNIDADE_PGTO,
             A.DTA_PAGAMENTO,
             NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00'
) MVTO
GROUP BY MVTO.COD_UNIDADE, MVTO.DTA_MVTO, MVTO.HORA_MVTO, MVTO.VLR_FATURAMENTO
ORDER BY MVTO.COD_UNIDADE ASC, MVTO.DTA_MVTO ASC, MVTO.HORA_MVTO ASC;

BEGIN
    file_handle := UTL_FILE.FOPEN('/mnt/datasys/Moavi/Vendas', nome_arq, 'W');
    UTL_FILE.PUT_LINE(file_handle, 'FILIAL;SETOR;EMISSAO;HORA;FATURAMENTO;CUPONS;ITENS;');

    FOR r_vendas_moavi IN c_vendas_moavi LOOP
        UTL_FILE.PUT_LINE(file_handle,
                          r_vendas_moavi.FILIAL || ';' ||
                          r_vendas_moavi.SETOR || ';' ||
                          r_vendas_moavi.EMISSAO || ';' ||
                          r_vendas_moavi.HORA || ';' ||
                          r_vendas_moavi.FATURAMENTO || ';' ||
                          r_vendas_moavi.CUPONS || ';' ||
                          r_vendas_moavi.ITENS || ';'
                         );
    END LOOP;

    UTL_FILE.FCLOSE(file_handle);

EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(file_handle) THEN
            UTL_FILE.FCLOSE(file_handle);
        END IF;
        RAISE;

END GRZ_VENDAS_MOAVI;



--==============================================================--
--==============================================================--



--EXEMPLO 3

CREATE OR REPLACE PROCEDURE GRZ_CAD_FORNECEDOR_NEOGRID_SP IS
BEGIN
    DECLARE
        file_handle1 UTL_FILE.FILE_TYPE;
        nome_arq     VARCHAR2(50);
    BEGIN
        nome_arq := 'X_GRAZZIOTIN_' || TO_CHAR(SYSDATE, 'RRRRMMDDHH24MISS') || '_FORNECEDORES.TXT';
        file_handle1 := UTL_FILE.FOPEN('/mnt/neogrid', nome_arq, 'W');

        FOR r_data IN (
            -- Seu SELECT aqui
            SELECT a.filial "FILIAL_COD",
                   p.des_fantasia "FILIAL",
                   a.data_inicio "INICIO",
                   g1.cod_uf "UF",
                   g1.des_cidade "CIDADE",
                   pj.num_cgc "CNPJ",
                   ge.cod_grupo "REGIONAL",
                   p.des_email "EMAIL",
                   tel.num_fone "CELULAR",
                   MIN(decode(a.cod_seq_jornada, 7, NULL, a.hora_ent)) "ABERT_SEM",
                   MAX(decode(a.cod_seq_jornada, 7, NULL, a.hora_sai)) "FECH_SEM",
                   MIN(decode(a.cod_seq_jornada, 7, a.hora_ent, NULL)) "ABERT_SAB",
                   MAX(decode(a.cod_seq_jornada, 7, a.hora_sai, NULL)) "FECH_SAB",
                   MIN(decode(a.cod_seq_jornada, 8, a.hora_ent, NULL)) "ABERT_DOM",
                   MAX(decode(a.cod_seq_jornada, 8, a.hora_sai, NULL)) "FECH_DOM"
              FROM v_dados_filiais             a,
                   nl.ps_pessoas@nlgrz         p,
                   nl.ps_juridicas@nlgrz       pj,
                   nl.ps_telefones@nlgrz       tel,
                   nl.g1_cidades@nlgrz         g1,
                   nl.ge_grupos_unidades@nlgrz ge
             WHERE ge.cod_unidade = a.filial
               AND ge.cod_grupo IN
                   (8701, 8702, 8703, 8704, 8705, 8706, 8707, 8708, 8709, 8710, 8711, 8712, 8713, 8714, 8715, 8716, 8717, 8718, 8719, 8720)
               AND ge.cod_emp = 1
               AND g1.cod_cidade = p.cod_cidade
               AND tel.cod_pessoa = p.cod_pessoa
               AND tel.num_seq = 4
               AND pj.cod_pessoa = p.cod_pessoa
               AND p.cod_pessoa = a.filial
               AND a.filial IN
                   (073, 082, 316, 327, 336, 339, 343, 344, 352, 370, 375, 384, 391, 413, 448, 465, 488, 490, 527, 566, 568, 623, 631, 7002, 7022, 7041, 7065, 7093, 7173, 7386, 7390, 7412, 7461, 7491, 7563, 7589, 7591)
             GROUP BY a.filial,
                      p.des_fantasia,
                      a.data_inicio,
                      g1.cod_uf,
                      g1.des_cidade,
                      pj.num_cgc,
                      ge.cod_grupo,
                      p.des_email,
                      tel.num_fone
             ORDER BY a.filial ASC
        ) LOOP
            UTL_FILE.PUT_LINE(file_handle1,
                r_data.FILIAL_COD || ';' ||
                r_data.FILIAL || ';' ||
                r_data.INICIO || ';' ||
                r_data.UF || ';' ||
                r_data.CIDADE || ';' ||
                r_data.CNPJ || ';' ||
                r_data.REGIONAL || ';' ||
                r_data.EMAIL || ';' ||
                r_data.CELULAR || ';' ||
                r_data.ABERT_SEM || ';' ||
                r_data.FECH_SEM || ';' ||
                r_data.ABERT_SAB || ';' ||
                r_data.FECH_SAB || ';' ||
                r_data.ABERT_DOM || ';' ||
                r_data.FECH_DOM
            );
        END LOOP;

        UTL_FILE.FCLOSE(file_handle1);

    EXCEPTION
        WHEN OTHERS THEN
            IF UTL_FILE.IS_OPEN(file_handle1) THEN
                UTL_FILE.FCLOSE(file_handle1);
            END IF;
            RAISE;
    END;
END GRZ_CAD_FORNECEDOR_NEOGRID_SP;
/

