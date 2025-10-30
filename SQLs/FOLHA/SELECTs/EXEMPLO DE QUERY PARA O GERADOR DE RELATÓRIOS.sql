IF(queryrel.COD_RACA_COR = 2,'Brancos',IF(queryrel.COD_RACA_COR = 4,'Pretos',IF(queryrel.COD_RACA_COR = 8,'Pardos')))


SUM(IF(queryrel.COD_RACA_COR = '2' , 1, 0))