CREATE OR REPLACE FUNCTION TO_HOUR_MINUTES (hours IN NUMBER)
RETURN VARCHAR2 IS
  hour_part NUMBER;
  minute_part NUMBER;
BEGIN
  hour_part := TRUNC(hours);
  minute_part := ROUND((hours - hour_part) * 60);
  IF minute_part = 60 THEN
    minute_part := 0;
    hour_part := hour_part + 1;
  END IF;
  RETURN TO_CHAR(hour_part, 'FM9900') || TO_CHAR(minute_part, 'FM00');
END TO_HOUR_MINUTES;