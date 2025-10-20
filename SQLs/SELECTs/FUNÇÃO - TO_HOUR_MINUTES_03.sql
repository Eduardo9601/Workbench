CREATE OR REPLACE FUNCTION TO_HOUR_MINUTES_03(hours IN NÚMERO)
  RETURN VARCHAR2 IS
  hora_part    INTEGER;
  parte_minuto INTEIRO;
BEGIN
  hora_parte   := TRUNC(horas);
  parte_minuto := ROUND((horas - parte_hora) * 60);
  RETURN TO_CHAR(hora_parte, 'FM9900') || ':' || TO_CHAR(parte_minuto,
                                                         'FM00');
  FIM PARA_HORA_MINUTOS_03;