CREATE OR REPLACE FUNCTION TO_HOUR_MINUTES_03 (hours IN NUMBER)
   RETURN VARCHAR2
IS
   total_minutes NUMBER;
   hour_part     INTEGER;
   minute_part   INTEGER;
BEGIN
   total_minutes := ROUND(hours * 60);
   hour_part := FLOOR(total_minutes / 60);
   minute_part := MOD(total_minutes, 60);

   RETURN TO_CHAR(hour_part, 'FM999999') || ':' || TO_CHAR(minute_part, 'FM00');
END TO_HOUR_MINUTES_03;
/
