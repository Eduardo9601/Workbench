--SCRIPT RESPONSÁVEL POR ATUALIZAR OS HISTÓRICOS DAS CONTAS CONTABEIS

SELECT DISTINCT*
FROM RHFP0415
WHERE COD_HISTORICO = 099
ORDER BY COD_HISTORICO ASC


UPDATE RHFP0415
SET HISTORICO_COMP = '************************************'
WHERE COD_HISTORICO = 099


---===================================--

SELECT COD_LANCAMENTO,
       COD_CONTA_CONTABIL,
       COD_SELECAO,
       COD_CONTRAPARTIDA,
       COD_CLASSE_CONT,
       COD_HISTORICO,
       COD_HISTORICO_CONTRA
  FROM RHFP0404
 WHERE COD_CLASSE_CONT IN (21, 22, 23, 24)
 ORDER BY COD_HISTORICO ASC


--===========================================================================--

/* HISTÓRICO 035
PGTO A ********** REF. **********

--=========================--

HISTÓRICO 058
CONTR. N/ MÊS

--=========================--

HISTÓRICO 062
VLR. DESC. REF. ANTECIPAÇÃO

--===========================--

HISTÓRICO 068
PAGTO REF. ************ REF. FL. PGTO.

--============================--

HISTÓRICO 069
VLR. RET. EM ********** CFE. FL. PGTO.

--=============================--

HISTÓRICO 070
VLR. PROV. ******** REF. ******** CFE. FL. PGTO.

--==============================--

HISTÓRICO 077
VLR. REF. VALE TRANSPORTE

--=============================--

HISTÓRICO 099
************************************* */






