--OFICIAL

SELECT TP.COD_CONTRATO,
       TP.COD_OPERADOR,
       TP.DTA_CRIACAO,
       TP.NOME_PESSOA,
       TO_DATE(TP.DTA_CRIACAO, 'DD/MM/YY') + 70 AS DTA_VENCIMENTO,
       FLOOR((TO_DATE(TP.DTA_CRIACAO, 'DD/MM/YY') + 70 - SYSDATE)) AS DIAS_RESTANTES
  FROM (SELECT D.COD_CONTRATO,
               A.COD_OPERADOR,
               MAX(A.DATA_CRIACAO) AS DTA_CRIACAO,
               C.NOME_PESSOA
          FROM OPSENHA A, OPERADOR B, PESSOA C, RHFP0300 D, V_DADOS_PESSOA E
         WHERE A.COD_OPERADOR = B.COD_OPERADOR
           AND B.IND_INATIVO = 'N'
           AND B.COD_PESSOA = C.COD_PESSOA
           AND D.COD_FUNC = C.COD_PESSOA
           AND D.DATA_FIM IS NULL
           AND E.COD_CONTRATO = D.COD_CONTRATO
           --AND E.COD_UNIDADE <> '900'
         GROUP BY D.COD_CONTRATO, A.COD_OPERADOR, C.NOME_PESSOA) TP
 WHERE TO_DATE(TP.DTA_CRIACAO, 'DD/MM/YY') + 70 BETWEEN SYSDATE AND SYSDATE + 10
 ORDER BY 2




--=============================================================================================--
--=============================================================================================--

--SQL ORIGINAL

select TP.COD_CONTRATO,TP.COD_OPERADOR,TP.dta_criacao, TP.nome_pessoa, TO_DATE(TP.dta_criacao,  'dd/mm/yy') + 90 AS dta_vencimento  from (
select D.COD_CONTRATO,A.COD_OPERADOR,MAX(A.DATA_CRIACAO) AS dta_criacao, c.nome_pessoa
             from OPSENHA A,
                     OPERADOR B,
                     pessoa c,
                     RHFP0300 D,
                     V_DADOS_PESSOA E
where a.cod_operador = b.cod_operador
and b.ind_inativo = 'N'
and b.cod_pessoa = c.cod_pessoa
and d.cod_func = c.cod_pessoa
and d.data_fim is null
AND E.COD_CONTRATO = D.COD_CONTRATO
and e.cod_unidade <> '900'
GROUP BY D.COD_CONTRATO,A.COD_OPERADOR, c.nome_pessoa ) TP
where TP.dta_criacao >= :DATA_REFERENCIA - :NRO_DIAS
and TP.dta_criacao <= :DATA_REFERENCIA - 80
order by 2