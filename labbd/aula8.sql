/*******************************************************************************
 * MAC0439 - Laboratório de Bancos de Dados - 2013
 * Aluno: Pedro Paulo Vezzá Campos - 7538743
 * Aula 8: Comandos para consultas envolvendo União, Intersecção, Diferença
 *         Comandos para modificação dos dados (Inserção, Remoção e Alteração)
 ******************************************************************************/

-- Exercício 1
-- a) Find the model number and price of all products (of any type) made by manufacturer B.
((SELECT model, price
FROM pc
WHERE model in (SELECT model FROM product WHERE maker = 'B'))

UNION 

(SELECT model, price
FROM laptop
WHERE model in (SELECT model FROM product WHERE maker = 'B'))

UNION 

(SELECT model, price
FROM printer
WHERE model in (SELECT model FROM product WHERE maker = 'B')));


-- b) Find those manufacturers that sell Laptops, but not PC's.
((SELECT DISTINCT maker
FROM product, laptop
WHERE product.model = laptop.model)

EXCEPT ALL

(SELECT DISTINCT maker
FROM product, pc
WHERE product.model = pc.model));

-- c) Find the model number of the item (PC, laptop, or printer) with the highest price.
SELECT model
FROM ((SELECT model, price FROM pc) UNION (SELECT model, price FROM laptop) UNION (SELECT model, price FROM printer)) AS models_prices
WHERE price >= ALL((SELECT price FROM pc) UNION (SELECT price FROM laptop) UNION (SELECT price FROM printer));

-- d) Find those manufacturers of at least two different computers (PC’s or laptops) with speeds of at least 133.
((SELECT maker
FROM product, ((SELECT model, speed FROM pc) UNION (SELECT model, speed FROM laptop)) AS models_speed
WHERE product.model = models_speed.model
  AND models_speed >= 133)

EXCEPT ALL

SELECT maker
FROM product AS p1, pc as pc1
WHERE p1.model = pc1.model
  AND pc1.speed >= 133
  AND maker NOT IN (SELECT maker FROM product AS p2, pc AS pc2 WHERE p2.model = pc2.model AND p2.model <> p1.model)

EXCEPT ALL

SELECT maker
FROM product AS p1, pc as pc1
WHERE p1.model = pc1.model
  AND pc1.speed >= 133
  AND maker NOT IN (SELECT maker FROM product AS p2, pc AS pc2 WHERE p2.model = pc2.model AND p2.model <> p1.model)
SELECT maker

-- e) Find the manufacturer(s) of the computer (PC or laptop) with the highest available speed
SELECT maker
FROM product, ((SELECT model, speed FROM pc) UNION (SELECT model, speed FROM laptop)) AS models_speed
WHERE product.model = models_speed.model
  AND speed >= ALL((SELECT speed FROM pc) UNION (SELECT speed FROM laptop));


-- Exercício 2
-- a) Using two INSERT statements, store in the database the fact that PC model 1100 is made by
--manufacturer C, has speed 240, RAM 32, hard disk 2.5, a 12x CD, and sells for $2499.

INSERT INTO product VALUES('C', 1100, 'pc');
-- Observação: O esquema original aceitava velocidades de CD com apenas 2 caracteres.
ALTER TABLE pc ALTER cd type character(3);
INSERT INTO pc VALUES(1100, 240, 32, 2.5, '12x', 2499.00);

-- b) Insert the facts that for every PC there is a laptop with the same speed, RAM, and hard disk, an
-- 8x CD, a model number 1100 greater, and a price $500 more.

INSERT INTO product (maker, model, type)
(SELECT maker, model + 1100, 'laptop'
FROM product
WHERE type = 'pc');

--Um laptop possui tela, o que não foi especificado, então defini o valor default de 15 polegadas
INSERT INTO laptop (model, speed, ram, hd, screen, price)
(SELECT model + 1100, speed, ram, hd, 15, price + 500
FROM pc);

-- c) Delete all PC ’s with less than 2 gigabytes of hard disk.
DELETE
FROM pc
WHERE hd < 2;

-- d) Delete all laptops made by a manufacturer that doesn’t make printers.
DELETE FROM laptop
WHERE model IN
	(SELECT product.model
     FROM product, laptop
     WHERE product.model = laptop.model
	   AND maker IN 
          ((SELECT DISTINCT maker
           FROM product)

           EXCEPT ALL

          (SELECT DISTINCT maker
           FROM product
           WHERE type = 'printer')));

-- e) Manufacturer A buys manufacturer B. Change all products made by B so they are now made by A.
UPDATE product
SET maker='A'
WHERE maker='B';

-- f) For each PC, double the amount of RAM and add one gigabyte to the amount of hard disk.
-- (Remember that several attributes can be changed by one UPDATE statement.)
UPDATE pc
SET ram = ram * 2, hd = hd + 1;

-- g) For each laptop made by manufacturer E, add one inch to the screen size and subtract $100 from
-- the price.
UPDATE laptop
SET screen = screen + 1, price = price - 100
WHERE model IN 
	(SELECT product.model
	FROM laptop, product
	WHERE laptop.model = product.model
	  AND maker = 'E');

-- Exercício 3
-- a) List all the capital ships mentioned in the database.
(SELECT name
FROM ships)

UNION

(SELECT ship
FROM outcomes);

-- b) Find those countries that had both battleships and battlecruisers.
(SELECT country
FROM classes
WHERE type = 'bb')

INTERSECT

(SELECT country
FROM classes
WHERE type = 'bc');

-- Exercício 4
-- a) The two British battleships of the Nelson class — Nelson and Rodney — were both launched in
-- 1927, had nine 16-inch guns, and a displacement of 34,000 tons. Insert these facts into the database.
INSERT INTO classes
VALUES('Nelson', 'bb', 'Gt. Britain', 9, 16, 34000);

INSERT INTO ships
VALUES('Nelson', 'Nelson', 1927);

INSERT INTO ships
VALUES('Nelson', 'Rodney', 1927);

-- b) Two of the three battleships of the Italian Vittorio Veneto class — Vittorio Veneto and Italia —
-- were launched in 1940; the third ship of that class, Roma, was launched in 1942. Each had nine
-- 15-inch guns and a displacement of 41,000 tons. Insert these facts into the database.
INSERT INTO classes
VALUES('Vittorio Veneto', 'bb', 'Italia', 9, 15, 41000);

INSERT INTO ships
VALUES('Vittorio Veneto', 'Vittorio Veneto', 1940);

INSERT INTO ships
VALUES('Vittorio Veneto', 'Italia', 1940);

INSERT INTO ships
VALUES('Vittorio Veneto', 'Roma', 1942);

-- c) Delete from Ships all ships sunk in battle.
DELETE FROM ships
WHERE name IN
	(SELECT ship
	FROM outcomes
	WHERE result = 'sunk');

-- d) Modify the Classes relation so that gun bores are measured in centimeters (one inch = 2.5
-- centimeters) and displacements are measured in metric tons (one metric ton = 1.1 tons).
UPDATE classes
SET bore = bore * 2.5, displacement = displacement * 1.1;

