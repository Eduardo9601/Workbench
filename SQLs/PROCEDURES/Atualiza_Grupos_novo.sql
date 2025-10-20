declare

  /* Informe 1 para sim e 0 para não */

  wAtualizaNL     number(2) := 1;
  wAtualizaFolha  number(2) := 0;
  wAtualizaVendas number(2) := 1;

  /* Cursor principal, busca as lojas de cada grupo*/
  /* Informe os grupos de quebras atualizados*/

  CURSOR C1 IS
    select a.*
      from nl.ge_grupos_unidades a
     where a.cod_grupo in
           (8701, 8702, 8703, 8704, 8705, 8706, 8707, 8708, 8709, 8710, 8711, 8712, 8713, 8714, 8715, 8716)
		  -- and a.cod_unidade = 4
	 order by a.cod_unidade;
  r1 c1 %rowtype;

  CURSOR C2 IS
    select a.cod_grupo
      from nl.ge_grupos_unidades a
     where a.cod_emp   = r1.cod_emp
     and a.cod_unidade = r1.cod_unidade	 
	 and a.cod_grupo  in (910, 930, 940, 950,970,
				     	10910, 10930, 10940, 10950,71010,71030,71040,71050,71070)
	 order by a.cod_grupo;
  r2 c2 %rowtype;
  
  
begin
  OPEN c1;
  FETCH c1 INTO r1;
  WHILE c1%FOUND LOOP
    begin
    
      if wAtualizaVendas = 1 then
     
        update grazz.grz_lojas a
           set a.cod_regiao = r1.cod_grupo
         where a.cod_loja = r1.cod_unidade
           and a.cod_regiao <> 8730;
      
      end if;
    
         
        if wAtualizaNL = 1 then
			OPEN c2;
			FETCH c2 INTO r2;
			WHILE c2%FOUND LOOP
			begin		
				begin
					delete nl.ge_grupos_unidades
					where cod_emp = r1.cod_emp
					and cod_unidade = r1.cod_unidade
					and cod_grupo   = r2.cod_grupo;
				end;
				
				begin
					insert into nl.ge_grupos_unidades (COD_EMP,COD_GRUPO,COD_QUEBRA,COD_UNIDADE,COD_INTEIRO,COD_NIVEL0,COD_NIVEL1,COD_NIVEL2,COD_NIVEL3,COD_NIVEL4,COD_NIVEL5,COD_NIVEL6,IND_SEPARA)
							values (r1.COD_EMP,R2.COD_GRUPO,r1.COD_GRUPO,r1.COD_UNIDADE,r1.COD_INTEIRO,r1.COD_NIVEL0,r1.COD_NIVEL1,r1.COD_NIVEL2,r1.COD_NIVEL3
								,r1.COD_NIVEL4,r1.COD_NIVEL5,r1.COD_NIVEL6,r1.IND_SEPARA);
				end;
			END;	
			FETCH c2 INTO r2;
			END LOOP;
			CLOSE c2;
			
        end if;
      
        if wAtualizaFolha = 1 then
        
          update PE0002@grzfolha
             set VALOR = r1.cod_grupo
           where COD_CAMPO = 1
             and COD_PESSOA =
                 (select b.cod_pessoa
                    from rhfp0401@grzfolha a, rhfp0400@grzfolha b
                   where a.cod_organograma = b.cod_organograma
                     and a.cod_organograma_sub = 8
                     and a.edicao_org = r1.cod_unidade);
          
    
        
        end if;
        
               end;
      
        FETCH c1
          INTO r1;
      END LOOP;
      CLOSE c1;
    
    end;