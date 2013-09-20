SELECT `grupo` , `fez_estagio_durante_o_bcc` , COUNT( * )
FROM completos
GROUP BY `grupo` , `fez_estagio_durante_o_bcc`
