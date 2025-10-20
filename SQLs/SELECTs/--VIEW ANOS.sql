--view anos

create or replace view apex_040200.wwv_flow_years
(year_value)
as
select i+1919 from wwv_flow_dual100
union all
select i+2019 from wwv_flow_dual100 where i < 32

--view horas

create or replace view apex_040200.wwv_flow_hours_24
(hour_value)
as
select i-1 from wwv_flow_dual100 where i < 25

----v2
create or replace view apex_040200.wwv_flow_hours_12
(hour_value)
as
select i from wwv_flow_dual100 where i < 13
