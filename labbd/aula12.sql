/***************************************************************
 * MAC0439 - Laboratório de Bancos de Dados
 * Aula 12 - Triggers
 * Aluno: Pedro Paulo Vezzá Campos - 7538743
 **************************************************************/
-- Exercício 1: 
-- a) When a new class is inserted into Classes, also insert a ship with the name of that class and a
-- NULL launch date.

CREATE OR REPLACE FUNCTION CreateShip()
	RETURNS TRIGGER AS $CreateShip$
BEGIN
	INSERT INTO Ships
	VALUES (NEW.class, NEW.class, NULL);
	RETURN NULL;
END;
$CreateShip$ LANGUAGE plpgsql;

CREATE TRIGGER NewClass
AFTER INSERT ON Classes
FOR EACH ROW
WHEN ( TRUE )
	EXECUTE PROCEDURE CreateShip();

-- b) When a new class is inserted with a displacement greater than 35,000 tons, allow the insertion,
-- but change the displacement to 35,000.

CREATE OR REPLACE FUNCTION SetDisplacement35000()
	RETURNS TRIGGER AS $SetDisplacement35000$
BEGIN
	UPDATE Classes
	SET displacement = 35000
	WHERE class = NEW.class;
	RETURN NULL;
END;
$SetDisplacement35000$ LANGUAGE plpgsql;

CREATE TRIGGER CheckDisplacement35000
AFTER INSERT ON Classes
FOR EACH ROW
WHEN ( NEW.displacement > 35000 )
	EXECUTE PROCEDURE SetDisplacement35000();


-- c) If a tuple is inserted into Outcomes, check that the ship and battle are listed in Ships and Battles,
-- respectively, and if not, insert tuples into one or both of these relations, with NULL components
-- where necessary.

CREATE OR REPLACE FUNCTION InsertShipOrBattleFromOutcome()
	RETURNS TRIGGER AS $InsertShipOrBattleFromOutcome$
BEGIN
	IF (NEW.ship NOT IN (SELECT name FROM Ships)) THEN
		INSERT INTO Ships
		VALUES (NEW.ship, NULL, NULL);
	END IF;
	
	IF (NEW.battle NOT IN (SELECT name FROM Battles)) THEN
		INSERT INTO Battles
		VALUES (NEW.battle, NULL);
	END IF;
	RETURN NEW;
END;
$InsertShipOrBattleFromOutcome$ LANGUAGE plpgsql;


CREATE TRIGGER CheckShipExists
BEFORE INSERT ON Outcomes
FOR EACH ROW
WHEN ( TRUE )
	EXECUTE PROCEDURE InsertShipOrBattleFromOutcome();


-- d) When there is an insertion into Ships or an update of the class attribute of Ships, check that no
-- country has more than 20 ships.

CREATE OR REPLACE FUNCTION verifica_20_navios() RETURNS TRIGGER AS $verifica_20_navios$
    BEGIN
		IF (EXISTS(SELECT 1 
		           FROM Ships s, Classes c
		           WHERE s.class = c.class
		           GROUP BY country
		           HAVING count(*) > 20)) THEN
        	RAISE EXCEPTION 'A country has more than 20 ships';
        END IF;
        RETURN NEW;
    END;
$verifica_20_navios$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_20_navios BEFORE INSERT OR UPDATE ON Ships
    FOR EACH ROW EXECUTE PROCEDURE verifica_20_navios();

-- e) Check, under all circumstances that could cause a violation, that no ship fought in a battle that
-- was at a later date than another battle in which that ship was sunk.

CREATE OR REPLACE FUNCTION verifica_sunk() RETURNS TRIGGER AS $$
	BEGIN
		IF (EXISTS (SELECT 1
					FROM	(SELECT ship, date
							FROM Battles B1, Outcomes O1
							WHERE B1.name = O1.battle AND O1.result = 'sunk') S
					WHERE EXISTS (SELECT 1
									FROM Battles B2, Outcomes O2
									WHERE O2.ship = S.ship AND date > S.date AND B2.name = O2.battle))) THEN
		
			RAISE EXCEPTION 'There is a ship with date of battle after the moment it sunk';
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_outcomes_check INSTEAD OF INSERT OR UPDATE OR DELETE ON Outcomes
    FOR EACH ROW EXECUTE PROCEDURE verifica_sunk();
CREATE TRIGGER trigger_battles_check BEFORE INSERT OR UPDATE OR DELETE ON Battles
    FOR EACH ROW EXECUTE PROCEDURE verifica_sunk();

-- Exercício 2:
-- a) Is this view updatable? Why?

Esta visão não é atualizável pois há modificações possíveis na
visão que são ambíguas ao SGBD.

-- b) Write an instead-of trigger to handle an insertion into this view.
CREATE OR REPLACE FUNCTION insere_NewPC()
   RETURNS TRIGGER AS $insere_NewPC$
BEGIN
   INSERT INTO Product VALUES (NEW.maker, NEW.model, 'pc');
   INSERT INTO PC VALUES (NEW.model, NEW.speed, NEW.ram, NEW.hd, NEW.price);
   RETURN NULL;
END;
$insere_NewPC$ LANGUAGE plpgsql;

CREATE TRIGGER insert_NewPC INSTEAD OF INSERT ON NewPC
    FOR EACH ROW EXECUTE PROCEDURE insere_NewPC();

-- c) Write an instead-of trigger to handle an update of the price.
CREATE OR REPLACE FUNCTION update_NewPC()
   RETURNS TRIGGER AS $update_NewPC$
BEGIN
   UPDATE Product SET maker=NEW.maker, model=NEW.model WHERE model=OLD.model;
   UPDATE PC SET model=NEW.model, speed=NEW.speed, ram=NEW.ram, hd=NEW.hd, price=NEW.price WHERE model=OLD.model;
   RETURN NULL;
END;
$update_NewPC$ LANGUAGE plpgsql;

CREATE TRIGGER update_NewPC INSTEAD OF UPDATE ON NewPC
    FOR EACH ROW EXECUTE PROCEDURE update_NewPC();


-- d) Write an instead-of trigger to handle a deletion of a specified tuple from this view.
CREATE OR REPLACE FUNCTION delete_NewPC()
   RETURNS TRIGGER AS $delete_NewPC$
BEGIN
   DELETE FROM Product WHERE model=OLD.model;
   DELETE FROM PC WHERE model=OLD.model;
   RETURN NULL;
END;
$delete_NewPC$ LANGUAGE plpgsql;

CREATE TRIGGER delete_NewPC INSTEAD OF DELETE ON NewPC
    FOR EACH ROW EXECUTE PROCEDURE delete_NewPC();




