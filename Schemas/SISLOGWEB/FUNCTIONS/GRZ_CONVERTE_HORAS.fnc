CREATE OR REPLACE FUNCTION GRZ_CONVERTE_HORAS (HORA_DBL IN NUMBER, PONTOS IN VARCHAR DEFAULT 'N')
   RETURN VARCHAR2
IS
/*
  Autor       : Eduardo A. Pedro
  Objetivo    : Transformar uma quantidade de horas informada em numero (23,5 ou 125,25)
                para quantidade de horas em string ('2330' ou '12515')
  Observacoes : Retorna '' qdo a quantidade de horas informada for inválida.
  Data        : 18 de Agosto de 2026.
*/
   v_res      VARCHAR2 (10);
   v_hora     INTEGER;
   v_minuto   INTEGER;
BEGIN
   v_res := '';
   v_hora := TRUNC (ABS(HORA_DBL));
   v_minuto := ROUND ( (ABS(HORA_DBL) - v_hora) * 60);

   IF v_minuto = 60
   THEN
      v_minuto := 0;
      v_hora := v_hora + 1;
   END IF;

   IF PONTOS = 'S' THEN
     v_res := TO_CHAR (v_hora) || ':' || SUBSTR (TO_CHAR (v_minuto, '00'), 2, 2);
   ELSE
     v_res := TO_CHAR (v_hora) || SUBSTR (TO_CHAR (v_minuto, '00'), 2, 2);
   END IF;
   IF HORA_DBL < 0 THEN
     v_res := '-'||v_res;
   END IF;
   RETURN v_res;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN ('');
END GRZ_CONVERTE_HORAS;
/
