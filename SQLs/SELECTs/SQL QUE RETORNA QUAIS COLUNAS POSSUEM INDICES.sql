/*SQL QUE RETORNA QUAIS COLUNAS POSSUEM INDICES*/

SELECT 
    uc.table_name,
    uc.column_name,
    ui.index_name,
    ui.index_type,
    ui.uniqueness
FROM 
    user_ind_columns uc
JOIN 
    user_indexes ui ON uc.index_name = ui.index_name
WHERE 
    uc.table_name IN ('RHFP0300', 'RHFP0200', 'PESSOA_FISICA', 'RHFP0310', 
                      'RHFP0400', 'RHFP0401', 'RHFP0402', 'RHFP0340', 
                      'RHFP0500', 'RHFP0309', 'RHAF1119', 'RHAF1145', 
                      'V_HORAS_COLAB_AVT', 'V_SUPERIOR_IMEDIATO_AVT', 
                      'V_AFAST_COLAB_AVT', 'RHFP0102', 'V_CARGO_CONTRATO_AVT', 
                      'V_ORGANOGRAMA_CONTRATO_AVT', 'RHFP0107')
AND 
    uc.column_name IN ('COD_FUNC', 'COD_PESSOA', 'COD_CONTRATO', 'DATA_INICIO', 
                       'DATA_FIM', 'COD_ORGANOGRAMA', 'COD_CLH', 
                       'COD_TURNO', 'EDICAO_NIVEL2', 'EDICAO_NIVEL3',
                       'COD_NACIONALIDADE')
ORDER BY 
    uc.table_name, uc.column_name;