--SELECT DE CONSULTA INDIVIDUAL DA VIEW V_DADOS_LOJAS_AVT


SELECT
    UNI.COD_UNIDADE,
    UNI.REDE,
    CASE
        WHEN UNI.REDE = '10' THEN
            'loja' || UNI.COD_UNIDADE || '@grazziotin.com.br'
        WHEN UNI.REDE = '30' THEN
            'loja' || UNI.COD_UNIDADE || '@pormenos.com.br'
        WHEN UNI.REDE = '50' THEN
            'loja' || UNI.COD_UNIDADE || '@tottal.com.br'
        WHEN UNI.REDE = '40' THEN
            'loja' || UNI.COD_UNIDADE || '@francogiorgi.com.br'
        WHEN UNI.REDE = '70' THEN
            'loja' || UNI.COD_UNIDADE || '@gztstore.com.br'
        ELSE
            'N/A'
    END AS EMAIL_TEST
FROM SISLOGWEB.V_UNIDADES_ATIVAS@NLGRZ UNI
WHERE UNI.COD_UNIDADE = 7638;
