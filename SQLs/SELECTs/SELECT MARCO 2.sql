SELECT 
    CASE 
        WHEN GROUPING(cod_regiao) = 1 AND GROUPING(cod_grupo_macro) = 1 THEN NULL 
        WHEN GROUPING(cod_regiao) = 1 THEN cod_grupo_macro 
        ELSE cod_regiao 
    END AS "cod_regiao", 
    CASE 
        WHEN GROUPING(cod_grupo_macro) = 1 AND GROUPING(cod_regiao) = 1 THEN 'Total Geral' 
        WHEN GROUPING(cod_regiao) = 1 THEN 'Total ' || MAX(des_grupo_macro) 
        ELSE MAX(des_regiao) 
    END AS "des_regiao", 
    to_char(sum(vlr_vd), '9G999G999G990D00') "Valor da Venda", 
    to_char(sum(qtd_negocio), '9G999G999G990D00') "Quantidade Negocio", 
    to_char(sum(ticket_medio), '9G999G999G990D00') "Ticket Médio", 
    to_char(sum(vlr_vd_whats), '9G999G999G990D00') "Vlr_Venda_Whats", 
    TO_CHAR(SUM(vlr_vd_whats) * 100 / SUM(vlr_vd),'9G999G999G990D00') "Perc_Whats", 
    to_char(sum(vlr_demost), '9G999G999G990D00') "Vlr_Demostração", 
    TO_CHAR(SUM(vlr_demost) * 100 / SUM(vlr_vd),'9G999G999G990D00') "Perc_Demost", 
    to_char(sum(vlr_vd_prazo), '9G999G999G990D00') "Vlr_Venda_Prazo", 
    TO_CHAR(SUM(vlr_vd_prazo) * 100 / SUM(vlr_vd),'9G999G999G990D00') "Perc_Vda_Prazo", 
    to_char(sum(vlr_acresc), '9G999G999G990D00') "Vlr_Acrescimo", 
    TO_CHAR(SUM(vlr_acresc) * 100 / SUM(vlr_vd_prazo),'9G999G999G990D00') "Perc_Acresc", 
    to_char(sum(vlr_cpp), '9G999G999G990D00') "Valor CPP", 
    to_char(sum(qtd_cpp), '9G999G999G990') "Quantidade CPP", 
    to_char(sum(qtd_cartoes_novos), '9G999G999G990') "Qtd_Cartões_Novos", 
    NVL(TO_CHAR(SUM(NVL(qtd_kit_meia, 0)),'9G999G999G990'), '0') "Qtd_Kit_Meia", 
    TO_CHAR(SUM(NVL(qtd_kit_meia, 0)) * 100 / SUM(NVL(qtd_negocio, 0)),'9G999G999G990D00') "Perc_Kit_Meia", 
    TO_CHAR(SUM(NVL(a.vlr_vda_quarta_intima, 0)),'9G999G999G990D00') "Vlr_Venda_Quarta_Intima", 
    NVL(TO_CHAR(SUM(CASE WHEN TO_CHAR(a.dta_movimento, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') = 'WED' THEN a.vlr_vda_quarta_intima ELSE 0 END) / SUM(a.vlr_vd) * 100, '9G999G999G990D00'), '0') "Perc_Quarta_Intima", 
    TO_CHAR(SUM(NVL(a.qtd_bonus_vencidos, 0)),'9G999G999G990') "Qtd_Bonus_Vencidos", 
    NVL(TO_CHAR(SUM(a.qtd_bonus_vencidos) / SUM(a.qtd_bonus_venc_ret) * 100,'9G999G999G990D00'), '0') "Perc_Bonus_Vencidos", 
    to_char(sum(vlr_vale_presente), '9G999G999G990D00') "Vlr_Vale_Presente", 
    to_char(sum(qtd_vale_presente), '9G999G999G990') "Qtd_Vale_Presente", 
    MAX( 
        (SELECT SUM(CASE WHEN b.COD_QUEBRA = 52 THEN b.PER_IND_COBRANCA ELSE 0 END) 
         FROM GRZ_KPI_VENDAS_TOT_REGIAO b 
         WHERE b.cod_regiao = a.cod_regiao 
         AND b.ano_mes BETWEEN TO_CHAR(TO_DATE(:sDataIni, 'dd/mm/yyyy'), 'yyyymm') AND TO_CHAR(TO_DATE(:sDataFim, 'dd/mm/yyyy'), 'yyyymm') 
        ) 
    ) as CPP, 
    MAX( 
        (SELECT SUM(CASE WHEN b.COD_QUEBRA = 51 THEN b.PER_IND_COBRANCA ELSE 0 END) 
         FROM GRZ_KPI_VENDAS_TOT_REGIAO b 
         WHERE b.cod_regiao = a.cod_regiao 
         AND b.ano_mes BETWEEN TO_CHAR(TO_DATE(:sDataIni, 'dd/mm/yyyy'), 'yyyymm') AND TO_CHAR(TO_DATE(:sDataFim, 'dd/mm/yyyy'), 'yyyymm') 
        ) 
    ) as CRE, 
    to_char(sum(vlr_cre_seguro), '9G999G999G990D00') "Vlr_CRE", 
    TO_CHAR(SUM(vlr_cre_seguro) * 100 / SUM(vlr_vd_prazo),'9G999G999G990D00') "Perc_CRE", 
    CASE 
        WHEN sum(qtd_cre_seguro) > 0 AND sum(qtd_cre_elegiveis) > 0 THEN 
            TO_CHAR(SUM(qtd_cre_seguro) / SUM(qtd_cre_elegiveis) * 100,'9G999G999G990D00') 
        ELSE '0' 
    END "Conv_CRE", 
    to_char(sum(vlr_cpp_seguro), '9G999G999G990D00') "Vlr_CPP", 
    TO_CHAR(SUM(vlr_cpp_seguro) * 100 / SUM(vlr_vd_prazo),'9G999G999G990D00') "Perc_CPP", 
    CASE 
        WHEN sum(qtd_cpp_seguro) > 0 AND sum(qtd_cpp_elegiveis) > 0 THEN 
            TO_CHAR(SUM(qtd_cpp_seguro) / SUM(qtd_cpp_elegiveis) * 100,'9G999G999G990D00') 
        ELSE '0' 
    END "Conv_CPP", 
    to_char(sum(vlr_dih_seguro), '9G999G999G990D00') "Vlr_DIH", 
    TO_CHAR(SUM(vlr_dih_seguro) * 100 / SUM(vlr_vd_prazo),'9G999G999G990D00') "Perc_DIH", 
    CASE 
        WHEN sum(qtd_dih_seguro) > 0 AND sum(qtd_dih_elegiveis) > 0 THEN 
            TO_CHAR(SUM(qtd_dih_seguro) / SUM(qtd_dih_elegiveis) * 100,'9G999G999G990D00') 
        ELSE '0' 
    END "Conv_DIH", 
    to_char(sum(vlr_ge_seguro), '9G999G999G990D00') "Vlr_GE", 
    TO_CHAR(SUM(vlr_ge_seguro) * 100 / SUM(vlr_vd_prazo),'9G999G999G990D00') "Perc_GE", 
    CASE 
        WHEN sum(qtd_ge_seguro) > 0 AND sum(qtd_ge_elegiveis) > 0 THEN 
            TO_CHAR(SUM(qtd_ge_seguro) / SUM(qtd_ge_elegiveis) * 100,'9G999G999G990D00') 
        ELSE '0' 
    END "Conv_GE", 
    to_char(sum(vlr_rfq_seguro), '9G999G999G990D00') "Vlr_RFQ", 
    TO_CHAR(SUM(vlr_rfq_seguro) * 100 / SUM(vlr_vd_prazo),'9G999G999G990D00') "Perc_RFQ", 
    CASE 
        WHEN sum(qtd_rfq_seguro) > 0 AND sum(qtd_rfq_elegiveis) > 0 THEN 
            TO_CHAR(SUM(qtd_rfq_seguro) / SUM(qtd_rfq_elegiveis) * 100,'9G999G999G990D00') 
        ELSE '0' 
    END "Conv_RFQ" 
FROM grz_rel_kpi_vendas a 
WHERE ((:sRedeAno = 999 AND cod_grupo_macro IN (1739,1740,1741)) OR (:sRedeAno <> 999 AND cod_grupo_macro = :sRedeAno)) 
AND a.dta_movimento between :sDataIni and :sDataFim 
GROUP BY ROLLUP (cod_grupo_macro, cod_regiao) 
ORDER BY cod_grupo_macro, cod_regiao';
