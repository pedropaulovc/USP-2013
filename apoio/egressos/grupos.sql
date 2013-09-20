SELECT grupo, MIN( `em_que_ano_concluiu_o_bcc` ) , MAX( `em_que_ano_concluiu_o_bcc` ) , COUNT( grupo )
FROM completos
GROUP BY grupo
