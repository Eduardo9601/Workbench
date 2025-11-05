SELECT G.COD_QUEBRA "REGIÃO",
       A.COD_UNIDADE "UNIDADE",
       P.DES_FANTASIA "NOME",
       A.VLR_VENDA_ORC "ORÇADO VDA",
       A.VLR_VENDA_REAL "VDA REALIZADA",
       A.VLR_MARGEM_ORC "ORÇ.MARGEM",
       A.VLR_MARGEM_REAL "MARGEM REALIZ.",
       DECODE(A.QTD_PONTOS_MARGEM, 1, 'OK', 'N') "AV",
       DECODE(G.COD_NIVEL2,
              810,
              '47,5',
              830,
              '52,7',
              840,
              '57,5',
              850,
              '49,0',
              870,
              '53,0',
              '0') "MARGEM PLAN",
       A.PER_MARGEM "MARGEM LOJA",
       DECODE(G.COD_NIVEL2,
              810,
              '60 A 80',
              830,
              '60 A 80',
              840,
              '60 A 80',
              850,
              '70 A 90',
              870,
              '60 A 90',
              '0') "PERM.PLAN",
       A.VLR_PERM "PERM.LOJA",
       DECODE(A.QTD_PONTOS_PERM, 1, 'OK', 'N') "AV",
       DECODE(G.COD_NIVEL2,
              810,
              '12,0',
              830,
              '12,0',
              840,
              '11,0',
              850,
              '12,0',
              870,
              '11,0',
              '0') "PREV.PLAN",
       A.PER_PREVENTIVA_CRE "PREVENTIVA",
       DECODE(A.QTD_PONTOS_PREVENTIVA_CRE, 1, 'OK', 'N') "AV",
       DECODE((A.QTD_PONTOS_MARGEM + A.QTD_PONTOS_PERM +
              A.QTD_PONTOS_PREVENTIVA_CRE),
              3,
              'OK',
              'N') "AV.FINAL"
  FROM NL.GRZ_DADOS_CALCULO_APR A, NL.GE_GRUPOS_UNIDADES G, NL.PS_PESSOAS P
 WHERE P.COD_PESSOA = A.COD_UNIDADE
   AND G.COD_UNIDADE = A.COD_UNIDADE
   AND G.COD_GRUPO = 999
   --AND A.COD_UNIDADE IN (205, 371, 392, 554)
   AND G.COD_EMP = 1
   AND A.DTA_REF BETWEEN '01/01/2025' AND '31/03/2025'
 ORDER BY G.COD_QUEBRA, A.COD_UNIDADE
 
 
 
/*ROTIANAS USADAS NO EXECUTAVEL PARA RELATÓRIO*/

/*NL.GRZ_DADOS_ESTOQUE_CIA_APR_SP;
NL.GRZ_DADOS_ESTOQUE_APR_SP;
NL.GRZ_DADOS_ORC_VENDA_APR_SP;
NL.GRZ_DADOS_ORCAMENTO_APR_SP;
NL.GRZ_DADOS_PREVENTIVA_APR_SP;
NL.GRZ_CALCULO_PONTUACAO_APR_SP;*/



SELECT * FROM NL.GRZ_DADOS_CALCULO_APR
WHERE DTA_REF = '31/12/2024'

SELECT * FROM NL.V_UNIDADES_ATIVAS
WHERE COD_PESSOA = 4


GRZ_LOJAS


SELECT A.COD_UNIDADE,
       ROUND((A.VLR_MARGEM_REAL / A.VLR_VENDA_LIQUIDA) * 100, 2) MARGEM,
       ROUND(360 / (A.VLR_CUSTO_PERM / (A.VLR_EST_MEDIO_PERM / 365.25)), 0) PERM,
       ROUND((A.VLR_FALTA_INVENTARIO / A.VLR_VENDA_LIQUIDA) * 100, 2) INVENTARIO
  select  * FROM nl.GRZ_VALORES_REGIOES_APR_ANUAL A
 WHERE ANO = 2024
   AND A.VLR_VENDA_REAL > 0


SELECT DISTINCT(TABLE_NAME) 
FROM ALL_TAB_COLUMNS 
WHERE UPPER (TABLE_NAME) LIKE '%%'
AND COLUMN_NAME LIKE '%REDE%';

SELECT * FROM  NL.GRZ_VALORES_REGIOES_APR_ANUAL
WHERE ANO = 2024

/*PLANEJAMENTO DOS INDICADORES DE PONTUAÇÃO DA APR*/

select * from  nl.grz_cad_calculo_apr -- campo valor1 traz valor variável sMargem 
where cod_rede IN (10, 30, 40, 50, 70)
and cod_calculo = 1;

select *
  from nl.grz_cad_calculo_apr -- campo valor1 traz valor variável sPermanencia 
 where cod_rede IN (10, 30, 40, 50, 70)
   and cod_calculo = 2;

select *
  from nl.grz_cad_calculo_apr -- campo valor1 traz valor variável sLucratividade 
 where cod_rede IN (10, 30, 40, 50, 70)
   and cod_calculo = 3;

select *
  from nl.grz_cad_calculo_apr -- campo valor1 traz valor variável sInventario
 where cod_rede IN (10, 30, 40, 50, 70)
   and cod_calculo = 4;

select *
  from nl.grz_cad_calculo_apr -- campo valor1 traz valor variável sPreventiva
 where cod_rede IN (10, 30, 40, 50, 70)
   and cod_calculo = 5;






SELECT DISTINCT
       A.DTA_REF "REFERÊNCIA",
       G.COD_QUEBRA "REGIÃO",
       G.COD_GRUPO,
       A.COD_UNIDADE "UNIDADE",
       P.DES_FANTASIA "NOME",
       TO_CHAR(A.VLR_VENDA_ORC, 'FM999G999G990D00') "ORÇADO VDA",
       TO_CHAR(A.VLR_VENDA_REAL, 'FM999G999G990D00') "VDA REALIZADA",
       DECODE(A.QTD_PONTOS_VDA_ORC, 1, 'OK', 'N') "AV",
       TO_CHAR(A.VLR_MARGEM_ORC, 'FM999G999G990D00') "ORÇ.MARGEM",
       TO_CHAR(A.VLR_MARGEM_REAL, 'FM999G999G990D00') "MARGEM REALIZ.",
       DECODE(A.QTD_PONTOS_MARGEM, 1, 'OK', 'N') "AV",
       /*CASE 
           WHEN G.COD_NIVEL2 = 810 AND C.COD_REDE = 10 THEN C.VALOR1
           WHEN G.COD_NIVEL2 = 830 AND C.COD_REDE = 30 THEN C.VALOR1
           WHEN G.COD_NIVEL2 = 840 AND C.COD_REDE = 40 THEN C.VALOR1
           WHEN G.COD_NIVEL2 = 850 AND C.COD_REDE = 50 THEN C.VALOR1
           WHEN G.COD_NIVEL2 = 870 AND C.COD_REDE = 70 THEN C.VALOR1
           ELSE
           0
       END AS "MARGEM PLAN",*/
       DECODE(G.COD_NIVEL2,
              810,
              '47,5',
              830,
              '52,7',
              840,
              '57,5',
              850,
              '49,0',
              870,
              '53,0',
              '0') "MARGEM PLAN",
       A.PER_MARGEM "MARGEM LOJA",
       DECODE(G.COD_NIVEL2,
              810,
              '60 A 80',
              830,
              '60 A 80',
              840,
              '60 A 80',
              850,
              '60 A 90',
              870,
              '60 A 90',
              '0') "PERM.PLAN",
       A.VLR_PERM "PERM.LOJA",
       DECODE(A.QTD_PONTOS_PERM, 1, 'OK', 'N') "AV",
       DECODE(G.COD_NIVEL2,
              810,
              '12,0',
              830,
              '12,0',
              840,
              '11,0',
              850,
              '12,0',
              870,
              '11,0',
              '0') "PREV.PLAN",
       A.PER_PREVENTIVA_CRE "PREVENTIVA",
       DECODE(A.QTD_PONTOS_PREVENTIVA_CRE, 1, 'OK', 'N') "AV",
       DECODE(G.COD_NIVEL2,
              810,
              '1,0',
              830,
              '1,0',
              840,
              '1,0',
              850,
              '1,0',
              870,
              '1,0',
              '0') "INVENTARIO PLAN",
       A.PER_INVENTARIO "INVENTARIO LOJA",
       DECODE(A.QTD_PONTOS_INVENTARIO, 1, 'OK', 'N') "AV",      
       DECODE((A.QTD_PONTOS_VDA_ORC + A.QTD_PONTOS_MARGEM +
              A.QTD_PONTOS_PERM + A.QTD_PONTOS_PREVENTIVA_CRE + A.QTD_PONTOS_INVENTARIO),
              4,
              'OK',
              'N') "AV.FINAL"
  FROM NL.GRZ_DADOS_CALCULO_APR A, NL.GE_GRUPOS_UNIDADES G, NL.PS_PESSOAS P, NL.V_UNIDADES_ATIVAS V, NL.GRZ_CAD_CALCULO_APR C
 WHERE P.COD_PESSOA = A.COD_UNIDADE
   AND G.COD_UNIDADE = A.COD_UNIDADE
   --AND V.COD_UNIDADE = A.COD_UNIDADE(+)
   --AND C.COD_REDE = V.REDE(+)
   AND G.COD_GRUPO IN (910, 930, 940, 950, 970)
   AND G.COD_EMP = 1
   AND A.DTA_REF = '31/03/2025'
   --AND A.IND_ANO = 2025
   --AND A.COD_UNIDADE = 4
   AND A.COD_UNIDADE BETWEEN 0000 AND 9999
   AND NOT EXISTS (SELECT 1
          FROM NL.GRZ_LOJAS_UNIFICADAS_CIA CIA
         WHERE CIA.COD_UNIDADE_PARA = A.COD_UNIDADE)
 ORDER BY G.COD_QUEBRA, A.COD_UNIDADE;
 
 
 
 SELECT *
 FROM NL.GE_GRUPOS_UNIDADES