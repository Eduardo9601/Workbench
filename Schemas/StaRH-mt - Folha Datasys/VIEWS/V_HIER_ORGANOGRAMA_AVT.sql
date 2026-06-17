CREATE OR REPLACE VIEW V_HIER_ORGANOGRAMA_AVT AS
SELECT LPAD('  ', 6 * (LEVEL - 1)) || CASE LEVEL
         WHEN 1 THEN
          '' -- Grupo
         WHEN 2 THEN
          ' >  ' -- Empresa
         WHEN 3 THEN
          ' >  ' -- Filial
         WHEN 4 THEN
          ' >  ' -- Divisão
         WHEN 5 THEN
          ' >  ' -- Departamento
         ELSE
          ' >  ' -- Setor
       END || /*TO_CHAR(EDICAO_ORG) || ' - ' ||*/NOME_ORGANOGRAMA_B AS ESTRUTURA
  FROM V_EST_ORG_AVT
 --WHERE COD_TIPO IN (1, 2, 3) -- inclui 1 conforme pedido
 START WITH COD_NIVEL_ORG = 1 -- raiz (Grupo). Use ORG_PAI IS NULL se preferir
CONNECT BY PRIOR COD_ORGANOGRAMA = COD_ORGANOGRAMA_SUB
-- Ordem entre irmãos: EDICAO_ORG numérico; em empate, usa ID único para não misturar ramos
 ORDER SIBLINGS BY TO_NUMBER(REGEXP_SUBSTR(EDICAO_ORG, '^\d+')), -- extrai números do começo com segurança
COD_ORGANOGRAMA;

