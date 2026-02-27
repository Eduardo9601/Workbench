--=========================================================================================================--
-- VIEW DE PESSOAS DEMITIDAS = V_DADOS_PESSOA_DEMITIDAS
--=========================================================================================================--

CREATE OR REPLACE VIEW V_DADOS_PESSOA_DEMITIDA AS
SELECT fp03.cod_contrato cod_contrato
      ,initcap(p.cod_pessoa) cod_pessoa
      ,initcap(p.nome_pessoa) des_pessoa
      ,initcap(substr(p.nome_pessoa,1,instr(p.nome_pessoa,' ')-1)) des_nome
      ,initcap(substr(p.nome_pessoa,instr(p.nome_pessoa,' ')+1,50)) des_sobrenome
      ,funcoes.cod_clh cod_funcao
      ,funcoes.nome_clh des_funcao
      ,to_char(fp02.data_nascimento,'ddmmyyyy') data_nascimento_old
      ,senha.des_senha data_nascimento
      ,initcap(mun.nome_munic) des_munic
      ,decode(fis.cod_uf,'RS','BR','SC','BR','PR','BR') des_pais
      ,fp03.cod_contrato||'@grazziotin.com.br' des_email
      ,organograma.nome_organograma
      ,initcap(org_custo_ctb.nome_custo_contabil) nome_custo_contabil
      ,org_custo_ctb.custo_contabil cod_unidade
      ,nvl(org_custo_ctb.edicao_nivel3,0) cod_grupo
      ,decode(org_custo_ctb.edicao_nivel3,1,'GRAZZIOTIN',2,'TOTTAL',3,'PORMENOS',4,'FRANCO GIORGI',276,'CENTRO SHOPPING') des_grupo
      ,org_emp.cod_nivel2 cod_emp
      ,senha.cod_grupo cod_grupo_unidade
      ,fp03.data_fim dta_demissao
      ,fp03.data_inicio dta_admissao
      ,fis.cpf
      ,fp02.nro_pis_pasep
from rhfp0200 fp02
   , rhfp0300 fp03
   , pessoa p
   , munici mun
   , fisica fis
   , rhfp0310 contr_organograma
   , RHFP0400 organograma
   , rhfp0401 org_emp
   , rhfp0402 org_custo_ctb
   , rhfp0500 funcoes
   , rhfp0340 contrfunc
   , mdl_usuario senha
WHERE p.cod_pessoa = fp02.cod_func
and fis.cod_pessoa = fp02.cod_func
and fp02.cod_func = fp03.cod_func
and fp03.cod_contrato = contrfunc.cod_contrato
and funcoes.cod_clh = contrfunc.cod_clh
and fp03.cod_contrato = contr_organograma.cod_contrato 
and fp03.cod_contrato = senha.cod_contrato(+)
and fis.cod_munic = mun.cod_munic
and contr_organograma.cod_organograma= organograma.cod_organograma
and organograma.cod_organograma = org_emp.cod_organograma
and organograma.cod_custo_contabil = org_custo_ctb.cod_custo_contabil(+)
and contr_organograma.data_fim > sysdate
and org_emp.cod_nivel2 in (8,282,276)
and fp03.data_fim >= '01/01/2010'
--and fp03.cod_contrato = '353671'
and contrfunc.data_fim >= sysdate
--D to_char(data_nascimento,'ddmmyyyy') = '04121976'

--=========================================================================================================--
--=========================================================================================================--