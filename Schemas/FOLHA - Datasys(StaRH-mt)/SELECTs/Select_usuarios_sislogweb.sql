---base do folha para atualizar grz_usuario_web----
SELECT * FROM GRZ_FOLHA.V_LOJAS_WEB@NLGZT 
where cod_grupo_unidade>=8701
and cod_grupo_unidade<=8717
ORDER BY COD_CONTRATO
/

---usuarios sislogweb----
select * from nl.grz_usuario_web
where cod_grupo>=8701
and cod_grupo<=8720
and ind_ativo=1
order by cod_grupo
/


----colaboradores folha---
select * from v_Dados_pessoa@grzfolha
where cod_funcao in (325,7)
and cod_emp  =8
order by cod_contrato
/