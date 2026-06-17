PL/SQL Developer Test script 3.0
6
begin
  -- Call the procedure
  GRZ_EXPORT_EVENTOS_ANO_CSV(p_dt_ini => :p_dt_ini,
                             p_dt_fim => :p_dt_fim,
                             p_prefix => :p_prefix);
end;
3
p_dt_ini
1
01/01/1990
12
p_dt_fim
1
31/12/2026
12
p_prefix
1
1040_Ficha_Financeira_30042026
5
0
