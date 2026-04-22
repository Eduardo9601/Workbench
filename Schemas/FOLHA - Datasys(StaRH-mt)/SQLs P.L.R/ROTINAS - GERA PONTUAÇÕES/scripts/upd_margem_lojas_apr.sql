                 update GRZ_VALORES_REGIOES_APR_ANUAL a set a.margem_perc = round((a.vlr_margem_real / a.vlr_venda_liquida) * 100,1)
                 where a.ano = 2016
                 and a.vlr_venda_liquida > 0