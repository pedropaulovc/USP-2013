/***************************************************************
 * MAC0439 - Laboratório de Bancos de Dados
 * Aluno: Pedro Paulo Vezzá Campos - 7538743
 * Aula 11: Consultas recursivas em SQL
***************************************************************/

-- (a) Escreva uma consulta SQL que retorna os pares (x,y) tais que y é uma continuação de x.
WITH
	RECURSIVE continuacao(de, para) AS (
		(SELECT * FROM filme_sequencia)
	UNION
		(SELECT filme_sequencia.filme, continuacao.para
		 FROM filme_sequencia, continuacao
		 WHERE filme_sequencia.seq_filme = continuacao.de)
	)
SELECT *
FROM continuacao;


-- (b) Escreva uma consulta SQL que retorna os pares (x,y) tais que y é uma continuação de x, mas
-- não uma sequência imediata de x.
WITH
	RECURSIVE continuacao(de, para) AS (
		(SELECT * FROM filme_sequencia)
	UNION
		(SELECT filme_sequencia.filme, continuacao.para
		 FROM filme_sequencia, continuacao
		 WHERE filme_sequencia.seq_filme = continuacao.de)
	)

(SELECT * FROM continuacao)

EXCEPT ALL

(SELECT * FROM filme_sequencia);


-- (c) Escreva uma consulta SQL que retorna os pares (x,y) tais que y é uma continuação de x, mas
-- não uma sequência imediata de x ou uma sequência de sequência de x.
WITH
	RECURSIVE continuacao(de, para) AS (
		(SELECT * FROM filme_sequencia)
	UNION
		(SELECT filme_sequencia.filme, continuacao.para
		 FROM filme_sequencia, continuacao
		 WHERE filme_sequencia.seq_filme = continuacao.de)
	)

(SELECT * FROM continuacao)

EXCEPT ALL (
	(SELECT * FROM filme_sequencia)

	UNION

	(SELECT f1.filme, f2.seq_filme 
	FROM filme_sequencia f1, filme_sequencia f2 
	WHERE f1.seq_filme = f2.filme)
);


-- (d) Escreva uma consulta SQL que retorna o conjunto de filmes x que possuem pelo menos duas
-- sequências diretas. Isto é, existe t e s distintos tais que t e s são sequências diretas de x.

SELECT DISTINCT f1.filme
FROM filme_sequencia f1, filme_sequencia f2
WHERE f1.filme = f2.filme
  AND f1.seq_filme <> f2.seq_filme;

-- (e) Escreva uma consulta SQL3 que retorna o conjunto de filmes x que possuem pelo menos duas
-- continuações. Observe que ambas podem ser sequências diretas, em vez de uma ser uma sequência
-- direta e outra ser uma sequência de sequência.

WITH 
    RECURSIVE continuacao(de, para) AS (
		(SELECT * FROM filme_sequencia)

		UNION
	
		(SELECT filme_sequencia.filme, continuacao.para
		 FROM filme_sequencia, continuacao
		 WHERE filme_sequencia.seq_filme = continuacao.de)
	),
	
	duas_sequencias_diretas(filme) AS (
		SELECT DISTINCT f1.filme
		FROM filme_sequencia f1, filme_sequencia f2
		WHERE f1.filme = f2.filme
		  AND f1.seq_filme <> f2.seq_filme
	),

	duas_sequencias(filme) AS (
		(SELECT * FROM continuacao)

		EXCEPT ALL

		(SELECT * FROM filme_sequencia)
	)

	((SELECT filme FROM duas_sequencias_diretas)
	
	UNION
	
	(SELECT filme FROM duas_sequencias));


-- (f) Escreva uma consulta SQL3 que retorna o conjunto de pares de filmes (x,y) tais que y é uma
-- continuação de x e y tem no máximo uma continuação.
WITH 
    RECURSIVE continuacao(de, para) AS (
		(SELECT * FROM filme_sequencia)

		UNION
	
		(SELECT filme_sequencia.filme, continuacao.para
		 FROM filme_sequencia, continuacao
		 WHERE filme_sequencia.seq_filme = continuacao.de)
	)
	
SELECT *
FROM continuacao
WHERE para NOT IN (SELECT de FROM continuacao)
  OR para IN (SELECT de FROM continuacao GROUP BY de HAVING COUNT(*) = 1);


