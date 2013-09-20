SELECT `grupo` , `em_que_tipo_de_escola_cursou_o_ensino_medio` , COUNT(*)
FROM completos
GROUP BY `grupo` , `em_que_tipo_de_escola_cursou_o_ensino_medio` 
