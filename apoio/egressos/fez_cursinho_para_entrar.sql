SELECT `grupo` , `fez_cursinho_para_entrar` , COUNT( * )
FROM completos
GROUP BY `grupo` , `fez_cursinho_para_entrar`
