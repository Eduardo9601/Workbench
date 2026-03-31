CREATE OR REPLACE VIEW V_REGIAO_UNIDADES_AVT AS
SELECT A.COD_EMP,
       A.COD_GRUPO,
       A.COD_QUEBRA AS COD_REGIAO,
       CASE
           /*AQUI AS REGIÕES PADRÃO*/ --OBS: Sujeito a alterações
           WHEN A.COD_QUEBRA = 8701 THEN
            'REGIÃO I'
           WHEN A.COD_QUEBRA = 8702 THEN
            'REGIÃO II'
           WHEN A.COD_QUEBRA = 8703 THEN
            'REGIÃO III'
           WHEN A.COD_QUEBRA = 8704 THEN
            'REGIÃO IV'
           WHEN A.COD_QUEBRA = 8705 THEN
            'REGIÃO V'
           WHEN A.COD_QUEBRA = 8706 THEN
            'REGIÃO VI'
           WHEN A.COD_QUEBRA = 8707 THEN
            'REGIÃO VII'
           WHEN A.COD_QUEBRA = 8708 THEN
            'REGIÃO VIII'
           WHEN A.COD_QUEBRA = 8709 THEN
            'REGIÃO IX'
           WHEN A.COD_QUEBRA = 8710 THEN
            'REGIÃO X'
           WHEN A.COD_QUEBRA = 8711 THEN
            'REGIÃO XI'
            /*aqui inicia as regiões da PORMENOS*/ --OBS: Sujeito a alterações
           WHEN A.COD_QUEBRA = 9301 THEN
            'REGIÃO PORMENOS I'
           WHEN A.COD_QUEBRA = 9302 THEN
            'REGIÃO PORMENOS II'
           WHEN A.COD_QUEBRA = 9303 THEN
            'REGIÃO PORMENOS III'
           WHEN A.COD_QUEBRA = 9304 THEN
            'REGIÃO PORMENOS IV'
           WHEN A.COD_QUEBRA = 9305 THEN
            'REGIÃO PORMENOS V'
           WHEN A.COD_QUEBRA = 9306 THEN
            'REGIÃO PORMENOS VI'
           WHEN A.COD_QUEBRA = 9307 THEN
            'REGIÃO PORMENOS VII'
           WHEN A.COD_QUEBRA = 9308 THEN
            'REGIÃO PORMENOS VIII'
           WHEN A.COD_QUEBRA = 9309 THEN
            'REGIÃO PORMENOS IX'
           /*AQUI FICA A REGIÃO DA FRANCO*/ --OBS: Sujeito a alterações
           WHEN A.COD_QUEBRA = 941 THEN
            'REGIÃO FRANCO GIORGI'
           WHEN A.COD_QUEBRA = 8730 THEN
            'E-COMERCE'
           ELSE
            NULL
       END AS DES_REGIAO,
       B.DES_GRUPO,
       A.COD_UNIDADE,
       UPPER(GRZ_UTIL.BUSCA_DES_UNIDADE(COD_UNIDADE)) DES_UNIDADE,
       CASE
           WHEN A.COD_NIVEL2 = 810 THEN
            10
           WHEN A.COD_NIVEL2 = 830 THEN
            30
           WHEN A.COD_NIVEL2 = 840 THEN
            40
           WHEN A.COD_NIVEL2 = 850 THEN
            50
           WHEN A.COD_NIVEL2 = 870 THEN
            70
           ELSE
            NULL
       END AS COD_REDE,
       A.COD_NIVEL3
FROM NL.GE_GRUPOS_UNIDADES A
LEFT JOIN NL.GE_GRUPOS B ON A.COD_QUEBRA = B.COD_GRUPO
WHERE A.COD_GRUPO IN (910, 930, 940, 950, 970)
AND A.COD_NIVEL2 IN (810, 830, 840, 850, 870)
AND A.COD_QUEBRA NOT IN (9999)
--AND COD_UNIDADE = 140
ORDER BY A.COD_UNIDADE
;
