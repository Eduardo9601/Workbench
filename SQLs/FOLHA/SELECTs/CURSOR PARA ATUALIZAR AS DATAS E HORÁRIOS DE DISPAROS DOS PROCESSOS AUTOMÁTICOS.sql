DECLARE
 wArg number;
 wDiaExec number;
 wMesExec number;
 wAnoExec number;
 wHoraExec number;
 wMinutosExec number;
 wSegundosExec number;
 wDoisPontos string(1);
 wBarra string(1);
 wDataHoraExec timestamp ;

 CURSOR C1 IS
 select  edicao_nivel3,  email, cod_nivel3
         from rhfp0401 a
             ,rhfp0400 b
             ,juridica c
where a.cod_organograma = b.cod_organograma
and c.email is not null
and a.cod_organograma_sub = 8
and a.edicao_nivel3  NOT IN ('013', '001')
and c.cod_pessoa = b.cod_pessoa
AND A.DATA_FIM = '31/12/2999'
 --and a.edicao_nivel3 between '002' and '363'
ORDER BY a.edicao_nivel3;
 r1   C1%ROWTYPE;
	BEGIN

 wDoisPontos := ':';
 wBarra := '/';

 wArg := :COD_ULT_PROCESSO;
 wAnoExec := :ANO_EXEC;
 wMesExec := :MES_EXEC;
 wDiaExec := :DIA_EXEC;

 wSegundosExec := :SEGUNDOS_EXEC;
 wMinutosExec := :MINUTOS_EXEC;
 wHoraExec := :HORA_EXEC;

--wDataHoraExec := '01/02/2022 ' ||  '23:58:00';

    FOR R1 IN C1 LOOP


      wArg := wArg +1;

					if wHoraExec <= 23 and wMinutosExec < 56 then
                        wMinutosExec := wMinutosExec +2;

				    elsif wHoraExec < 23 and wMinutosExec = 56 then
                        wMinutosExec := 0;
				   	    wSegundosExec := 0;
				   	    wHoraExec := wHoraExec +1;

					elsif wHoraExec = 23 and wMinutosExec = 56 then

                        wDiaExec :=  wDiaExec +1;
                        wHoraExec := 10;
                        wMinutosExec := 00;
                        wSegundosExec := 00;
					end if;

	wDataHoraExec := wDiaExec || wBarra || wMesExec || wBarra || wAnoExec || wHoraExec || wDoisPontos || wMinutosExec || wDoisPontos || wSegundosExec;

					UPDATE RHWF0405
					SET DATA_AGENDAMENTO = wDataHoraExec, PROX_EXECUCAO = wDataHoraExec
					WHERE COD_PROCESSO = wArg
                                        AND COD_RELAT_GR <> 'RE0345'
                                        AND COD_RELAT_GR <> 'RE0350D'
                                        AND COD_RELAT_GR <> 'RE0050';
                                        --AND COD_RELAT_GR <> 'DECLRACA';

    END LOOP;
 --COMMIT;
END;