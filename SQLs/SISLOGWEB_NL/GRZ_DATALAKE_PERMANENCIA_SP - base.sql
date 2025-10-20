/*ROTINA DO PERMANENCIA PARA ME BASEAR NA CRIAÇÃO DA ROTINA QUE INSERE OS KPI*/

CREATE OR REPLACE PROCEDURE GRZ_DATALAKE_PERMANENCIA_SP(PI_DTA_MVTO DATE) IS
BEGIN
  declare
    cursor c_permanencia is
      SELECT a.cod_emp,
             a.cod_unidade,
             a.cod_item,
             a.dta_mvto,
             SUM(NVL(a.vlr_custo, 0)) vlr_custo_perm,
			 SUM(NVL(a.vlr_custo_cd, 0)) vlr_custo_perm_cd,
             SUM(NVL(a.vlr_estoque_ant, 0) + NVL(a.vlr_medio_emp, 0)) vlr_estmedio_perm
        FROM nl.es_0124_ce_estmedio a
        JOIN nl.ie_itens t ON a.cod_item = t.cod_item
        JOIN nl.ie_mascaras e ON t.cod_item = e.cod_item
       WHERE a.dta_mvto BETWEEN add_months(PI_DTA_MVTO, -11) AND
             PI_DTA_MVTO
            --AND a.cod_unidade = 33
         AND a.cod_item not in (344356) --item que veio a mais do que o NL
         and e.cod_mascara = 170
         and e.cod_niv0 = '1'
       group by a.cod_emp, a.cod_unidade, a.cod_item, a.dta_mvto;
    r_permanencia c_permanencia%rowtype;

  BEGIN

    open c_permanencia;
    fetch c_permanencia
      into r_permanencia;
    while c_permanencia%found loop

      BEGIN
        INSERT INTO SISLOGWEB.GRZ_DATALAKE_PERMANENCIA
          (COD_EMP,
           COD_UNIDADE,
           DTA_MVTO_ORIG,
           COD_ITEM,
           DTA_MVTO,
           VLR_CUSTO_PERM,
           VLR_ESTMEDIO_PERM,
		   VLR_CUSTO_PERM_CD)
        VALUES
          (r_permanencia.cod_emp,
           r_permanencia.cod_unidade,
           r_permanencia.dta_mvto,
           r_permanencia.cod_item,
           PI_DTA_MVTO,
           r_permanencia.vlr_custo_perm,
           r_permanencia.vlr_estmedio_perm,
		   r_permanencia.vlr_custo_perm_cd);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          UPDATE SISLOGWEB.GRZ_DATALAKE_PERMANENCIA
             SET vlr_custo_perm    = r_permanencia.vlr_custo_perm,
			     vlr_custo_perm_cd = r_permanencia.vlr_custo_perm_cd,
                 vlr_estmedio_perm = r_permanencia.vlr_estmedio_perm
           WHERE cod_emp = r_permanencia.cod_emp
             AND cod_unidade = r_permanencia.cod_unidade
             AND dta_mvto_orig = r_permanencia.dta_mvto
             AND cod_item = r_permanencia.cod_item
             AND dta_mvto = PI_DTA_MVTO;
      END;
      fetch c_permanencia
        into r_permanencia;
    end loop;
    close c_permanencia;
    commit;

  END;
END GRZ_DATALAKE_PERMANENCIA_SP;
