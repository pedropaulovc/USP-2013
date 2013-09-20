SELECT `grupo` , `em_que_ano_concluiu_o_bcc` , COUNT( * )
FROM completos
GROUP BY `grupo` , `em_que_ano_concluiu_o_bcc` 
