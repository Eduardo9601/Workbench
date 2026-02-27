select a.CPF '+
                      ',a.cod_contrato UserClientUniqueIdentifier '+
                      ',lpad(to_char(b.codigo),3,''0'') BusinessUnitClientUnique '+
                      ',case when a.cod_funcao in (1,3,4,12,13,5,16,131) then '+
                      '      1  '+
                      'else '+
                      '  case when a.cod_funcao in (14,77,78,79,80,81,86,87,88,90,128,137,184,185,186,188,189,190,191,192,283,294,266,280,292,89,138,139,148,247,255,268,275,278,299,301,302,304,307,318) then '+
                      '       3  '+
                      '  else '+
                      '     case when a.cod_funcao in (132,133,134,135,7,15,17,325) then '+
                      '        2 '+
                      '     else '+
                      '        case when a.cod_funcao in (68) then '+
                      '           6 '+
                      '        else '+
                      '           5 '+
                      '        end '+
                      '     end '+
                      '  end '+
                      'end OccupationArea '+
                      ',a.des_funcao PositionName '+
                      ','''' DirectSuperiorClient '+
                      ',to_char(a.dta_admissao,''yyyy-MM-dd HH:mm:ss'') as admissiondate '+
                      'from V_dados_pessoa_demitida@grzfolha a , v_organograma_portal@grzfolha b '+
                      'where b.codigo = decode(a.cod_contrato,377248,''000'',379038,''000'',a.cod_unidade) '+
                      'and a.cod_contrato not in (382219,386518,382989,386102,379135,381482,380404,385960,297305,364126) '+
         
                      'union '+
                      'select c.CPF '+
                      ',c.cod_contrato UserClientUniqueIdentifier '+
                      ',case when length(d.cod_unidade) < 3 then '+
                      '    lpad(to_char(d.cod_unidade),3,''0'') '+
                      'else '+
                      '    to_char(d.cod_unidade) '+
                      'end BusinessUnitClientUnique  '+
                      ',case when c.cod_funcao in (1,3,4,12,13,5,16,131) then '+
                      '      1     '+
                      'else '+
                      '  case when c.cod_funcao in (14,77,78,79,80,81,86,87,88,90,128,137,184,185,186,188,189,190,191,192,283,294,266,280,292,89,138,139,148,247,255,268,275,278,299,301,302,304,307,318) then '+
                      '       3    '+
                      '  else '+
                      '    case when c.cod_funcao in (132,133,134,135,7,15,17,325) then '+
                      '        2    '+
                      '    else '+
                      '       case when c.cod_funcao in (68) then '+
                      '          6 '+
                      '       else '+
                      '          5 '+
                      '       end '+
                      '    end '+
                      '  end '+
                      'end OccupationArea '+
                      ',c.des_funcao PositionName '+
                      ','''' DirectSuperiorClient '+
                      ',to_char(c.dta_admissao,''yyyy-MM-dd HH:mm:ss'') as admissiondate '+
                      'from V_dados_pessoa_demitida@grzfolha c, ge_grupos_unidades d '+
                      'where c.cod_unidade = d.cod_unidade '+
                      'and d.cod_grupo in (910,930,940,950,970) '+
          
                      'union '+
                      'select a1.CPF '+
                      ',a1.cod_contrato UserClientUniqueIdentifier '+
                      ',lpad(to_char(b1.codigo),3,''0'') BusinessUnitClientUnique '+
                      ',4 OccupationArea '+
                      ',a1.des_funcao PositionName '+
                      ','''' DirectSuperiorClient '+
                      ',to_char(a1.dta_admissao,''yyyy-MM-dd HH:mm:ss'') as admissiondate '+
                      ' from V_dados_pessoa_demitida@grzfolha a1 , v_organograma_portal@grzfolha b1 '+
                      ' where b1.codigo = decode(a1.cod_contrato,377248,''0'',379038,''0'',a1.cod_unidade) '+
                      ' and a1.cod_contrato in (382219,386518,382989,386102,379135,381482,380404,385960,297305,364126) '+
                      'ORDER BY 2