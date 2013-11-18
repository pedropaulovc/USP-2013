--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: aula5; Type: SCHEMA; Schema: -; Owner: u7538743
--

CREATE SCHEMA aula5;


ALTER SCHEMA aula5 OWNER TO u7538743;

--
-- Name: aula6_ex_1; Type: SCHEMA; Schema: -; Owner: u7538743
--

CREATE SCHEMA aula6_ex_1;


ALTER SCHEMA aula6_ex_1 OWNER TO u7538743;

--
-- Name: aula8; Type: SCHEMA; Schema: -; Owner: u7538743
--

CREATE SCHEMA aula8;


ALTER SCHEMA aula8 OWNER TO u7538743;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: createship(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION createship() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

INSERT INTO Ships

VALUES (NEW.class, NEW.class, NULL);

RETURN NULL;

END;

$$;


ALTER FUNCTION public.createship() OWNER TO u7538743;

--
-- Name: delete_newpc(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION delete_newpc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   DELETE FROM Product WHERE model=OLD.model;
   DELETE FROM PC WHERE model=OLD.model;
   RETURN NULL;
END;
$$;


ALTER FUNCTION public.delete_newpc() OWNER TO u7538743;

--
-- Name: findprice(character, integer); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION findprice(character, integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$
DECLARE 
makerIn ALIAS FOR $1;
modelIn ALIAS FOR $2;
typeFind CHARACTER(20);
BEGIN
typeFind = (SELECT type
FROM Product
WHERE maker = makerIn
AND model = modelIn
LIMIT 1);
IF (typeFind = 'pc') THEN
RETURN (SELECT price FROM PC WHERE model = modelIn);
ELSIF (typeFind = 'laptop') THEN
RETURN (SELECT price FROM Laptop WHERE model = modelIn);
ELSE
RETURN (SELECT price FROM Printer WHERE model = modelIn);
END IF;
END;
$_$;


ALTER FUNCTION public.findprice(character, integer) OWNER TO u7538743;

--
-- Name: func(integer); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION func(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE 
priceIn ALIAS FOR $1;
BEGIN
RETURN (SELECT Product.model 
       FROM Product, PC
       WHERE Product.model = PC.model
       ORDER BY abs(PC.price - priceIn)
       LIMIT 1);
END;
$_$;


ALTER FUNCTION public.func(integer) OWNER TO u7538743;

--
-- Name: getnumberproducts(integer); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION getnumberproducts(pricein integer) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN NEXT (SELECT COUNT(*)
FROM PC
WHERE price > priceIn);

RETURN NEXT (SELECT COUNT(*)
FROM Laptop
WHERE price > priceIn);

RETURN NEXT (SELECT COUNT(*)
FROM Printer
WHERE price > priceIn);

END;
$$;


ALTER FUNCTION public.getnumberproducts(pricein integer) OWNER TO u7538743;

--
-- Name: insere_newpc(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION insere_newpc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   INSERT INTO Product VALUES (NEW.maker, NEW.model, 'pc');
   INSERT INTO PC VALUES (NEW.model, NEW.speed, NEW.ram, NEW.hd, '5x', NEW.price);
   RETURN NULL;
END;
$$;


ALTER FUNCTION public.insere_newpc() OWNER TO u7538743;

--
-- Name: insertbattlefromoutcome(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION insertbattlefromoutcome() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (NEW.battle NOT IN (SELECT name FROM Battles)) THEN
INSERT INTO Battles

VALUES (NEW.battle, NULL);
END IF;

RETURN NULL;

END;

$$;


ALTER FUNCTION public.insertbattlefromoutcome() OWNER TO u7538743;

--
-- Name: insertemployeename(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION insertemployeename() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   INSERT INTO Employees(ename, dept, salary) VALUES (NEW.ename, NULL, NULL);
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.insertemployeename() OWNER TO u7538743;

--
-- Name: insertpc(integer, integer, real, numeric); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION insertpc(m integer, r integer, h real, p numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    LOOP
        BEGIN
            insert into pc values (m, null, r, h, null, p);
            return;
        EXCEPTION WHEN unique_violation THEN
            m = m + 1;
        END;
    END LOOP;
    RETURN;
    END; $$;


ALTER FUNCTION public.insertpc(m integer, r integer, h real, p numeric) OWNER TO u7538743;

--
-- Name: insertpc(integer, integer, integer, real, numeric); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION insertpc(m integer, s integer, r integer, h real, p numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    LOOP
        BEGIN
        INSERT INTO Product VALUES (null, m, 'pc');
            INSERT INTO PC VALUES (m, s, r, h, '10x', p);
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            m = m + 1;
        END;
    END LOOP;
    RETURN;
    END; $$;


ALTER FUNCTION public.insertpc(m integer, s integer, r integer, h real, p numeric) OWNER TO u7538743;

--
-- Name: insertshipfromoutcome(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION insertshipfromoutcome() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (NEW.ship NOT IN (SELECT name FROM Ships)) THEN
INSERT INTO Ships

VALUES (NEW.ship, NULL, NULL);
END IF;

RETURN NULL;

END;

$$;


ALTER FUNCTION public.insertshipfromoutcome() OWNER TO u7538743;

--
-- Name: insertshiporbattlefromoutcome(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION insertshiporbattlefromoutcome() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.insertshiporbattlefromoutcome() OWNER TO u7538743;

--
-- Name: setdisplacement35000(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION setdisplacement35000() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

UPDATE Classes

SET displacement = 35000
WHERE class = NEW.class;

RETURN NULL;

END;

$$;


ALTER FUNCTION public.setdisplacement35000() OWNER TO u7538743;

--
-- Name: sunkcheck(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION sunkcheck() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF (EXISTS (SELECT true
FROM (SELECT ship, date
FROM Battles, Outcomes
WHERE Battles.name = Outcomes.battle AND Outcomes.result = 'sunk') S
WHERE EXISTS (SELECT true
FROM Battles, Outcomes 
WHERE Outcomes.ship = S.ship AND date > S.date AND Battles.name = Outcomes.battle))) THEN

RAISE EXCEPTION 'Violation';
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.sunkcheck() OWNER TO u7538743;

--
-- Name: update_newpc(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION update_newpc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   UPDATE Product SET maker=NEW.maker, model=NEW.model WHERE model=OLD.model;
   UPDATE PC SET model=NEW.model, speed=NEW.speed, ram=NEW.ram, hd=NEW.hd, price=NEW.price WHERE model=OLD.model;
   RETURN NULL;
END;
$$;


ALTER FUNCTION public.update_newpc() OWNER TO u7538743;

--
-- Name: verifica_20_navios(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION verifica_20_navios() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
IF (EXISTS(SELECT 1 
           FROM Ships s, Classes c
           WHERE s.class = c.class
           GROUP BY country
           HAVING count(*) > 8)) THEN
            RAISE EXCEPTION 'A country has more than 20 ships';
            END IF;
            RETURN NEW;
    END;
$$;


ALTER FUNCTION public.verifica_20_navios() OWNER TO u7538743;

--
-- Name: verifica_sunk(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION verifica_sunk() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF (EXISTS (SELECT 1
FROM (SELECT ship, date
FROM Battles B1, Outcomes O1
WHERE B1.name = O1.battle AND O1.result = 'sunk') S
WHERE EXISTS (SELECT 1
FROM Battles B2, Outcomes O2
WHERE O2.ship = S.ship AND date > S.date AND B2.name = O2.battle))) THEN

RAISE EXCEPTION 'There is a ship with date of battle after the moment it sunk';
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.verifica_sunk() OWNER TO u7538743;

--
-- Name: verifica_sunk_outcome(); Type: FUNCTION; Schema: public; Owner: u7538743
--

CREATE FUNCTION verifica_sunk_outcome() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF (EXISTS (SELECT 1
FROM (SELECT ship, date
FROM Battles B1, Outcomes O1
WHERE B1.name = O1.battle AND O1.result = 'sunk') S
WHERE EXISTS (SELECT 1
FROM Battles B2, Outcomes O2
WHERE O2.ship = S.ship AND date > S.date AND B2.name = O2.battle))) THEN

RAISE EXCEPTION 'There is a ship with date of battle after the moment it sunk';
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.verifica_sunk_outcome() OWNER TO u7538743;

SET search_path = aula5, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: funcionario; Type: TABLE; Schema: aula5; Owner: u7538743; Tablespace: 
--

CREATE TABLE funcionario (
    nome character varying(50),
    cpf character(1),
    data_nascimento date
);


ALTER TABLE aula5.funcionario OWNER TO u7538743;

SET search_path = aula8, pg_catalog;

--
-- Name: laptop; Type: TABLE; Schema: aula8; Owner: u7538743; Tablespace: 
--

CREATE TABLE laptop (
    model integer,
    speed integer,
    ram integer,
    hd real,
    screen real,
    price numeric(6,2)
);


ALTER TABLE aula8.laptop OWNER TO u7538743;

--
-- Name: pc; Type: TABLE; Schema: aula8; Owner: u7538743; Tablespace: 
--

CREATE TABLE pc (
    model integer NOT NULL,
    speed integer,
    ram integer,
    hd real,
    cd character(2),
    price numeric(6,2)
);


ALTER TABLE aula8.pc OWNER TO u7538743;

--
-- Name: printer; Type: TABLE; Schema: aula8; Owner: u7538743; Tablespace: 
--

CREATE TABLE printer (
    model integer,
    color boolean,
    type character varying(15),
    price numeric(6,2)
);


ALTER TABLE aula8.printer OWNER TO u7538743;

--
-- Name: product; Type: TABLE; Schema: aula8; Owner: u7538743; Tablespace: 
--

CREATE TABLE product (
    maker character(1),
    model integer,
    type character(20)
);


ALTER TABLE aula8.product OWNER TO u7538743;

SET search_path = public, pg_catalog;

--
-- Name: aluno; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE aluno (
    nroaluno numeric(9,0) NOT NULL,
    nomealuno character varying(30),
    formacao character varying(25),
    nivel character varying(2),
    idade numeric(3,0)
);


ALTER TABLE public.aluno OWNER TO u7538743;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE authors (
    author_name character varying(50) NOT NULL
);


ALTER TABLE public.authors OWNER TO u7538743;

--
-- Name: battles; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE battles (
    name character varying(20) NOT NULL,
    date date
);


ALTER TABLE public.battles OWNER TO u7538743;

--
-- Name: books; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE books (
    isbn character varying(20) NOT NULL,
    author_name character varying(50),
    title character varying(255),
    publisher_name character varying(50),
    publication_year integer,
    binding character varying(55),
    source_numb integer,
    retail_price numeric(8,2),
    number_on_hand integer
);


ALTER TABLE public.books OWNER TO u7538743;

--
-- Name: classes; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE classes (
    class character varying(20) NOT NULL,
    type character(2),
    country character varying(20),
    numguns integer,
    bore integer,
    displacement integer
);


ALTER TABLE public.classes OWNER TO u7538743;

--
-- Name: ships; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE ships (
    name character varying(20) NOT NULL,
    class character varying(20),
    launched integer
);


ALTER TABLE public.ships OWNER TO u7538743;

--
-- Name: britishships; Type: VIEW; Schema: public; Owner: u7538743
--

CREATE VIEW britishships AS
    SELECT classes.class, classes.type, classes.numguns, classes.bore, classes.displacement, ships.launched FROM classes, ships WHERE (((classes.country)::text = 'Gt. Britain'::text) AND ((ships.class)::text = (classes.class)::text));


ALTER TABLE public.britishships OWNER TO u7538743;

--
-- Name: clientes; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE clientes (
    cpf character(1)[] NOT NULL,
    nome character varying[],
    dt_nascimento date,
    endereco text,
    cep character varying[],
    ddd_telefone character(1)[],
    num_telefone character varying[]
);


ALTER TABLE public.clientes OWNER TO u7538743;

--
-- Name: curso; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE curso (
    nome character varying(40) NOT NULL,
    horario character varying(20),
    sala character varying(10),
    idprof numeric(9,0)
);


ALTER TABLE public.curso OWNER TO u7538743;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE customers (
    customer_numb integer NOT NULL,
    customer_first_name character varying(15),
    customer_last_name character varying(25),
    customer_street character varying(55),
    customer_city character varying(55),
    customer_state character(2),
    customer_zip character varying(5),
    customer_phone character varying(12),
    customer_email character varying(55),
    referred_by integer
);


ALTER TABLE public.customers OWNER TO u7538743;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE employees (
    ename character varying(20),
    dept character varying(20),
    salary integer
);


ALTER TABLE public.employees OWNER TO u7538743;

--
-- Name: employeenames; Type: VIEW; Schema: public; Owner: u7538743
--

CREATE VIEW employeenames AS
    SELECT employees.ename FROM employees;


ALTER TABLE public.employeenames OWNER TO u7538743;

--
-- Name: movieexec; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE movieexec (
    cert integer NOT NULL,
    name character(30),
    address character varying(255),
    networth integer
);


ALTER TABLE public.movieexec OWNER TO u7538743;

--
-- Name: moviestar; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE moviestar (
    name character(30) NOT NULL,
    address character varying(255),
    gender character(1),
    birthdate timestamp with time zone
);


ALTER TABLE public.moviestar OWNER TO u7538743;

--
-- Name: executivestar; Type: VIEW; Schema: public; Owner: u7538743
--

CREATE VIEW executivestar AS
    SELECT movieexec.name, movieexec.address, moviestar.gender, moviestar.birthdate, movieexec.cert, movieexec.networth FROM movieexec, moviestar WHERE (movieexec.name = moviestar.name);


ALTER TABLE public.executivestar OWNER TO u7538743;

--
-- Name: filme_sequencia; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE filme_sequencia (
    filme character varying(30) NOT NULL,
    seq_filme character varying(30) NOT NULL
);


ALTER TABLE public.filme_sequencia OWNER TO u7538743;

--
-- Name: laptop; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE laptop (
    model integer NOT NULL,
    speed integer NOT NULL,
    ram integer NOT NULL,
    hd real NOT NULL,
    screen real NOT NULL,
    price numeric(6,2) NOT NULL
);


ALTER TABLE public.laptop OWNER TO u7538743;

--
-- Name: livros; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE livros (
    id_livro integer NOT NULL,
    titulo character varying[] NOT NULL,
    author_id integer,
    subject_id integer
);


ALTER TABLE public.livros OWNER TO u7538743;

--
-- Name: matriculado; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE matriculado (
    nroaluno numeric(9,0) NOT NULL,
    nomecurso character varying(40) NOT NULL
);


ALTER TABLE public.matriculado OWNER TO u7538743;

--
-- Name: movie; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE movie (
    title character varying(255) NOT NULL,
    year integer NOT NULL,
    length integer,
    incolor character(1),
    studioname character(50),
    producerc integer
);


ALTER TABLE public.movie OWNER TO u7538743;

--
-- Name: pc; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE pc (
    model integer NOT NULL,
    speed integer NOT NULL,
    ram integer NOT NULL,
    hd real NOT NULL,
    cd character(3) NOT NULL,
    price numeric(6,2) NOT NULL
);


ALTER TABLE public.pc OWNER TO u7538743;

--
-- Name: product; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE product (
    maker character(1),
    model integer NOT NULL,
    type character(20)
);


ALTER TABLE public.product OWNER TO u7538743;

--
-- Name: newpc; Type: VIEW; Schema: public; Owner: u7538743
--

CREATE VIEW newpc AS
    SELECT product.maker, pc.model, pc.speed, pc.ram, pc.hd, pc.price FROM product, pc WHERE ((product.model = pc.model) AND (product.type = 'pc'::bpchar));


ALTER TABLE public.newpc OWNER TO u7538743;

--
-- Name: order_lines; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE order_lines (
    order_numb integer NOT NULL,
    isbn character varying(20) NOT NULL,
    quantity integer,
    cost_each numeric(8,2),
    cost_line numeric(8,2),
    shipped character(1)
);


ALTER TABLE public.order_lines OWNER TO u7538743;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE orders (
    order_numb integer NOT NULL,
    customer_numb integer NOT NULL,
    order_date timestamp without time zone,
    credit_card_numb character varying(50),
    order_filled character varying(3),
    credit_card_exp_date timestamp without time zone
);


ALTER TABLE public.orders OWNER TO u7538743;

--
-- Name: outcomes; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE outcomes (
    ship character varying(20) NOT NULL,
    battle character varying(20) NOT NULL,
    result character varying(10) NOT NULL
);


ALTER TABLE public.outcomes OWNER TO u7538743;

--
-- Name: printer; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE printer (
    model integer NOT NULL,
    color boolean NOT NULL,
    type character varying(15) DEFAULT 'coco'::character varying NOT NULL,
    price numeric(6,2) NOT NULL
);


ALTER TABLE public.printer OWNER TO u7538743;

--
-- Name: professor; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE professor (
    idprof numeric(9,0) NOT NULL,
    nomeprof character varying(30),
    iddepto numeric(2,0)
);


ALTER TABLE public.professor OWNER TO u7538743;

--
-- Name: publishers; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE publishers (
    publisher_name character varying(50) NOT NULL
);


ALTER TABLE public.publishers OWNER TO u7538743;

--
-- Name: richexec; Type: VIEW; Schema: public; Owner: u7538743
--

CREATE VIEW richexec AS
    SELECT movieexec.name, movieexec.address, movieexec.cert, movieexec.networth FROM movieexec WHERE (movieexec.networth >= 10000000);


ALTER TABLE public.richexec OWNER TO u7538743;

--
-- Name: sources; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE sources (
    source_numb integer NOT NULL,
    source_name character varying(55),
    source_street character varying(55),
    source_city character varying(55),
    source_state character(2),
    source_zip character(5),
    source_phone character(12)
);


ALTER TABLE public.sources OWNER TO u7538743;

--
-- Name: starsin; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE starsin (
    movietitle character varying(255) NOT NULL,
    movieyear integer NOT NULL,
    starname character(30) NOT NULL
);


ALTER TABLE public.starsin OWNER TO u7538743;

--
-- Name: stock; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE stock (
    isbn text NOT NULL,
    cost numeric(5,2),
    retail numeric(5,2),
    stock integer
);


ALTER TABLE public.stock OWNER TO u7538743;

--
-- Name: studio; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE studio (
    name character(50) NOT NULL,
    address character varying(255),
    presc integer
);


ALTER TABLE public.studio OWNER TO u7538743;

--
-- Name: studiopres; Type: VIEW; Schema: public; Owner: u7538743
--

CREATE VIEW studiopres AS
    SELECT movieexec.name, movieexec.address, movieexec.cert FROM movieexec, studio WHERE (studio.presc = movieexec.cert);


ALTER TABLE public.studiopres OWNER TO u7538743;

--
-- Name: voo; Type: TABLE; Schema: public; Owner: u7538743; Tablespace: 
--

CREATE TABLE voo (
    nvoo integer NOT NULL,
    origem character varying(30) NOT NULL,
    destino character varying(30) NOT NULL,
    partida time without time zone NOT NULL,
    chegada time without time zone NOT NULL
);


ALTER TABLE public.voo OWNER TO u7538743;

SET search_path = aula5, pg_catalog;

--
-- Data for Name: funcionario; Type: TABLE DATA; Schema: aula5; Owner: u7538743
--

COPY funcionario (nome, cpf, data_nascimento) FROM stdin;
\.


SET search_path = aula8, pg_catalog;

--
-- Data for Name: laptop; Type: TABLE DATA; Schema: aula8; Owner: u7538743
--

COPY laptop (model, speed, ram, hd, screen, price) FROM stdin;
2001	100	20	1.10000002	9.5	1999.00
2002	117	12	0.75	11.3000002	2499.00
2003	117	32	1	10.3999996	3599.00
2004	133	16	1.10000002	11.1999998	3499.00
2005	133	16	1	11.3000002	2599.00
2006	120	8	0.810000002	12.1000004	1999.00
2007	150	16	1.35000002	12.1000004	4799.00
2008	120	16	1.10000002	12.1000004	2099.00
\.


--
-- Data for Name: pc; Type: TABLE DATA; Schema: aula8; Owner: u7538743
--

COPY pc (model, speed, ram, hd, cd, price) FROM stdin;
1001	133	16	1.60000002	6x	1595.00
1002	120	16	1.60000002	6x	1399.00
1003	166	24	2.5	6x	1899.00
1004	166	32	2.5	8x	1999.00
1005	166	16	2	8x	1999.00
1006	200	32	3.0999999	8x	2099.00
1007	200	32	3.20000005	8x	2349.00
1008	180	32	2	8x	3699.00
1009	200	32	2.5	8x	2599.00
1010	160	16	1.20000005	8x	1495.00
\.


--
-- Data for Name: printer; Type: TABLE DATA; Schema: aula8; Owner: u7538743
--

COPY printer (model, color, type, price) FROM stdin;
3001	t	ink-jet	275.00
3002	t	ink-jet	269.00
3003	f	laser	829.00
3004	f	laser	879.00
3005	f	ink-jet	180.00
3006	t	dry	470.00
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: aula8; Owner: u7538743
--

COPY product (maker, model, type) FROM stdin;
A	1001	pc                  
A	1002	pc                  
A	1003	pc                  
B	1004	pc                  
B	1006	pc                  
B	3002	printer             
B	3004	printer             
C	1005	pc                  
C	1007	pc                  
D	1008	pc                  
D	1009	pc                  
D	1010	pc                  
D	2001	laptop              
D	2002	laptop              
D	2003	laptop              
D	3001	printer             
D	3003	printer             
E	2004	laptop              
E	2008	laptop              
F	2005	laptop              
G	2006	laptop              
G	2007	laptop              
H	3005	printer             
I	3006	printer             
\.


SET search_path = public, pg_catalog;

--
-- Data for Name: aluno; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY aluno (nroaluno, nomealuno, formacao, nivel, idade) FROM stdin;
51135593	Maria White	English	SR	21
60839453	Charles Harris	Architecture	SR	22
99354543	Susan Martin	Law	JR	20
112348546	Joseph Thompson	Computer Science	SO	19
115987938	Christopher Garcia	Computer Science	JR	20
132977562	Angela Martinez	History	SR	20
269734834	Thomas Robinson	Psychology	SO	18
280158572	Margaret Clark	Animal Science	FR	18
301221823	Juan Rodriguez	Psychology	JR	20
318548912	Dorthy Lewis	Finance	FR	18
320874981	Daniel Lee	Electrical Engineering	FR	17
322654189	Lisa Walker	Computer Science	SO	17
348121549	Paul Hall	Computer Science	JR	18
351565322	Nancy Allen	Accounting	JR	19
451519864	Mark Young	Finance	FR	18
455798411	Luis Hernandez	Electrical Engineering	FR	17
462156489	Donald King	Mechanical Engineering	SO	19
550156548	George Wright	Education	SR	21
552455318	Ana Lopez	Computer Engineering	SR	19
556784565	Kenneth Hill	Civil Engineering	SR	21
567354612	Karen Scott	Computer Engineering	FR	18
573284895	Steven Green	Kinesiology	SO	19
574489456	Betty Adams	Economics	JR	20
578875478	Edward Baker	Veterinary Medicine	SR	21
\.


--
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY authors (author_name) FROM stdin;
Barth, John
Burroughs, Edgar Rice
Butler, Octavia
Cherryh, C. J.
author_name
Bronte, Charlotte
Bronte, Emily
Clavell, James
Dumas, Alexandre
Lee, Tanith
Ludlum, Rober
McCaffrey, Anne
Rice, Anne
Scott, Sir Walter
Stevenson, Robert Louis
Twain, Mark
\.


--
-- Data for Name: battles; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY battles (name, date) FROM stdin;
North Atlantic	2041-05-24
Guadalacanal	2042-11-15
North Cape	2043-12-26
Surigao Strait	2044-10-25
Blous	\N
B	\N
\.


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY books (isbn, author_name, title, publisher_name, publication_year, binding, source_numb, retail_price, number_on_hand) FROM stdin;
0-123-1233-0	Dumas, Alexandre	Three Musketeers, The	Grosset & Dunlap	1953	hc	1	15.95	10
0-124-2999-9	Twain, Mark	Celebrated Jumping Frog of Calaveras County	Harper	1903	hc	1	18.95	5
0-124-5544-X	Dumas, Alexandre	Titans, The	Harper	1957	hc	1	18.95	4
0-124-7989-1	Twain, Mark	Dog\\"s Tale, A	Harper	1904	hc	1	19.95	5
0-125-3344-1	Dumas, Alexandre	Black Tulip, The	P. F. Collier & So	1902	hc	1	18.95	3
0-126-3367-2	Dumas, Alexandre	Count of Monte Cristo, The	Platt & Munk	1968	hc	1	21.95	12
0-127-3948-2	Dumas, Alexandre	Corsican Brothers, The	Metheu	1970	hc	1	15.95	5
0-128-3939-2	Clavell, James	Gai-Ji	Delacorte	1993	hc	1	25.95	15
0-128-3939-X	Clavell, James	Noble House	Delacorte	1981	hc	1	22.95	6
0-128-4321-1	Clavell, James	Tai-Pa	Delacorte	1966	hc	1	22.95	12
0-129-4567-1	McCaffrey, Anne	Dragonsong	Atheneum	1976	hc	2	18.95	12
0-129-4912-0	McCaffrey, Anne	Dragonsinger	Atheneum	1977	hc	2	19.95	13
0-129-9293-2	Lee, Tanith	Black Unicor	Atheneum	1991	hc	3	21.95	6
0-129-9876-5	Clavell, James	Shogu	Atheneum	1975	hc	1	24.95	12
0-130-2939-4	McCaffrey, Anne	White Dragon, The	Ballantine Books	1978	hc	2	21.95	8
0-130-2943-2	McCaffrey, Anne	Dragonflight	Ballantine Books	1978	hc	1	15.95	12
0-130-3941-7	Rice, Anne	Feast of All Saints, The	Ballantine Books	1992	hc	2	24.95	18
0-130-9483-1	McCaffrey, Anne	Dragonquest	Ballantine Books	1979	hc	2	21.95	9
0-131-1458-9	Rice, Anne	Interview with the Vampire	Knopf	1976	hc	2	23.95	12
0-131-3021-2	Rice, Anne	Tale of the Body Thief, The	Knopf	1992	hc	2	24.95	18
0-131-4809-X	Rice, Anne	Vampire Lestat, The	Knopf	1985	hc	2	22.95	12
0-131-4912-X	Rice, Anne	Taltos	Knopf	1994	hc	2	24.95	6
0-131-4966-9	Rice, Anne	Lasher	Knopf	1993	hc	1	23.95	15
0-131-9456-2	Rice, Anne	Cry to Heave	Knopf	1982	hc	2	25.95	16
0-132-3949-2	Twain, Mark	Prince and the Pauper, The	James R. Osgood and Co.	1882	hc	3	19.95	10
0-132-9876-4	Twain, Mark	Life on the Mississippi	James R. Osgood and Co.	1883	hc	3	19.95	11
0-133-2956-6	Twain, Mark	Inoocents Abroad, The	American Publishing Co.	1869	hc	3	19.95	6
0-133-5935-2	Twain, Mark	Pudd\\"nhead Wilso	American Publishing Co.	1894	hc	3	17.95	8
0-134-3945-7	Stevenson, Robert Louis	Child\\"s Garden of Verses, A	Scribner	1905	hc	4	21.95	12
0-135-2222-2	Stevenson, Robert Louis	Treasure Island	J. W. Lovell Co.	1886	hc	4	24.95	8
0-136-3956-1	Stevenson, Robert Louis	Kidnapped	Dodd, Mead	1949	hc	2	22.95	12
0-136-3966-7	Stevenson, Robert Louis	Strange Case of Dr. Jekyll and Mr. Hyde	Dodd, Mead	1964	hc	2	23.95	18
0-137-1293-9	Scott, Sir Walter	Rob Roy	D. Appleton & Co.	1898	hc	4	21.95	22
0-138-1379-8	Scott, Sir Walter	Ivanhoe	Hart Publishing Co.	1977	hc	1	22.95	6
0-140-3877-0	Scott, Sir Walter	Waverly Novels	University of Nebraska Press	1978	hc	4	27.95	3
0-141-9876-4	Bronte, Emily	Complete Poems of Emily Jane Bronte, The	Columbia University Press	1941	hc	4	21.95	5
0-142-0084-2	Butler, Octavia	Clay\\"s Ark	St. Martin\\"s Press	1984	hc	2	21.95	12
0-142-3867-8	Bronte, Emily	Wuthering Heights	St. Martin\\"s Press	1968	hc	3	21.95	8
0-142-3988-2	Lee, Tanith	East of Midnight	St. Martin\\"s Press	1978	hc	2	19.95	15
0-150-3765-2	Ludlum, Robert	Aquitaine Progression, The	Random House	1984	hc	3	25.95	6
0-150-3949-9	Ludlum, Robert	Parsifal Mosaic, The	Random House	1982	hc	1	24.95	14
0-150-5948-9	Bronte, Charlotte	Jane Eyre	Random House	1943	hc	3	19.95	15
0-151-9876-2	Bronte, Charlotte	Vilette	Clarendon Press	1984	hc	3	21.95	15
0-155-2346-5	Burroughs, Edgar Rice	Tarzan and the Forbidden City	E. R. burroughs, Inc.	1938	hc	2	18.95	12
0-157-3849-X	Burroughs, Edgar Rice	People that Time Forgot, The	Tandem	1975	hc	3	19.95	8
0-157-9876-2	Burroughs, Edgar Rice	Out of Time\\"s Abyss	Tandem	1973	hc	3	21.95	4
0-158-0493-2	Burroughs, Edgar Rice	Tarzan the Magnificent	New English Library	1974	hc	4	21.95	3
0-158-8374-3	Burroughs, Edgar Rice	Tarzan of the Apes	New English Library	1975	hc	4	21.95	3
0-159-2948-2	Burroughs, Edgar Rice	War Chief, The	Gregg Press	1927	hc	2	19.95	6
0-159-3845-3	Burroughs, Edgar Rice	Bandit of Hell\\"s Bend, The	Gregg Press	1925	hc	2	19.95	12
0-159-5839-3	Burroughs, Edgar Rice	Apache Devil	Gregg Press	1933	hc	2	19.95	4
0-160-3456-7	Ludlum, Robert	Gemini Contenders, The	Dial Press	1976	hc	3	24.95	22
0-160-8325-7	Ludlum, Robert	Chancellor Manuscript, The	Dial Press	1977	hc	3	23.95	18
0-161-0123-9	Ludlum, Robert	Bourne Identify, The	R. Marek Publishers	1980	hc	3	23.95	10
0-161-8478-1	Ludlum, Robert	Holcroft Covenant, The	R. Marek Publishers	1978	hc	2	24.95	16
0-162-3948-0	Barth, Joh	Chimera	Deutsch	1974	hc	3	17.95	6
0-164-4857-2	Barth, Joh	Sabbatical: A Romance	Putnam	1982	hc	4	24.95	7
0-164-5968-0	Barth, Joh	Letters: A Novel	Putnam	1979	hc	3	27.95	5
0-166-8394-3	Barth, Joh	Sot-Weed Factor, The	Franklin Library	1980	hc	3	27.95	6
0-167-1945-1	Barth, Joh	Floating Opera and The End of the Road, The	Anchor Press	1988	hc	4	24.95	9
0-167-3965-2	Barth, Joh	Giles Goat-Boy	Anchor Press	1987	hc	3	24.95	8
0-180-2945-9	Lee, Tanith	Electric Forest	Doubleday	1979	hc	2	19.95	21
0-180-3948-2	Butler, Octavia	Patternmaster	Doubleday	1976	hc	4	18.95	19
0-180-4567-3	Butler, Octavia	Survivor	Doubleday	1978	hc	3	15.95	8
0-180-4712-X	Butler, Octavia	Mind of My Mind	Doubleday	1977	hc	1	19.95	4
0-180-4921-4	Cherryh, C. J.	Hunter of Worlds	Doubleday	1977	hc	3	21.95	18
0-180-4977-5	Cherryh, C. J.	Brothers of Earth	Doubleday	1976	hc	3	23.95	12
0-180-6464-4	Cherryh, C. J.	Serpent\\"s Reach	Doubleday	1980	hc	3	19.95	9
0-180-7388-1	Cherryh, C. J.	Faded Sun, Kesrith, The	Doubleday	1978	hc	3	21.95	8
0-180-7400-X	Cherryh, C. J.	Faded Sun, Shon\\"jir, The	Doubleday	1978	hc	3	21.95	5
0-180-8644-2	Butler, Octavia	Wild Seed	Doubleday	1980	hc	3	19.95	9
0-180-8655-0	Butler, Octavia	Kindred	Doubleday	1979	hc	3	18.95	8
0-185-8776-2	Lee, Tanith	Castle of Dark, The	Macmilla	1978	hc	4	21.95	6
0-185-9855-2	Lee, Tanith	Winter Players, The	Macmilla	1977	hc	2	15.95	12
0-190-2345-2	Lee, Tanith	Book of the Damned, The	Overlook Press	1990	hc	4	21.95	5
0-190-3956-1	Lee, Tanith	Book of the Beast, The	Overlook Press	1991	hc	4	22.95	8
0-190-3967-5	Lee, Tanith	Book of the Dead, The	Overlook Press	1991	hc	4	22.95	3
0-191-4893-0	Cherryh, C. J.	Rimrunners	Warner Books	1989	hc	2	19.95	2
0-191-4934-8	Cherryh, C. J.	Heavy Time	Warner Books	1991	hc	2	23.95	7
0-191-4959-2	Cherryh, C. J.	Cytee	Warner Books	1988	hc	2	18.95	5
0-191-8654-3	Cherryh, C. J.	Hellburner	Warner Books	1992	hc	2	23.95	10
0-200-3939-2	Bronte, Emily	My Very Best Work	Harper	1810	hb	2	18.95	6
\.


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY classes (class, type, country, numguns, bore, displacement) FROM stdin;
Bismark	bb	Germany	8	95	50820
Iowa	bb	USA	9	100	55660
Kongo	bc	Japan	8	88	38720
North Carolina	bb	USA	9	100	44770
Renown	bc	Gt. Britain	6	95	38720
Revenge	bb	Gt. Britain	8	95	38720
Tennessee	bb	USA	12	88	38720
Yamato	bb	Japan	9	113	78650
Lorem	bb	Ipsum	10	100	35000
\.


--
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY clientes (cpf, nome, dt_nascimento, endereco, cep, ddd_telefone, num_telefone) FROM stdin;
\.


--
-- Data for Name: curso; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY curso (nome, horario, sala, idprof) FROM stdin;
Data Structures	MWF 10	R128	489456522
Database Systems	MWF 12:30-1:45	1320 DCL	142519864
Operating System Design	TuTh 12:30-1:45	20 AVW	489456522
Archaeology of the Incas	MWF 3-4:15	R128	248965255
Aviation Accident Investigation	TuTh 1-2:50	Q3	11564812
Air Quality Engineering	TuTh 10:30-11:45	R15	11564812
Introductory Latin	MWF 3-4:15	R12	248965255
American Political Parties	TuTh 2-3:15	20 AVW	619023588
Social Cognition	Tu 6:30-8:40	R15	159542516
Perception	MTuWTh 3	Q3	489221823
Multivariate Analysis	TuTh 2-3:15	R15	90873519
Patent Law	F 1-2:50	R128	90873519
Urban Economics	MWF 11	20 AVW	489221823
Organic Chemistry	TuTh 12:30-1:45	R12	489221823
Marketing Research	MW 10-11:15	1320 DCL	489221823
Seminar in American Art	M 4	R15	489221823
Orbital Mechanics	MWF 8	1320 DCL	11564812
Dairy Herd Management	TuTh 12:30-1:45	R128	356187925
Communication Networks	MW 9:30-10:45	20 AVW	141582651
Optical Electronics	TuTh 12:30-1:45	R15	254099823
Intoduction to Math	TuTh 8-9:30	R128	489221823
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY customers (customer_numb, customer_first_name, customer_last_name, customer_street, customer_city, customer_state, customer_zip, customer_phone, customer_email, referred_by) FROM stdin;
1	Jane	Jones	125 W. 88th Blvd.	Anytown	NJ	10110	552-555-1234	jane_jones@anywhere.net	\N
2	Tom	Smith	4592 Maple Lane	Some City	NY	12345	555-555-4321	tom_smith@this.net	\N
3	Mary	Johnson	98 Elm St.	Little Town	M 	23456	551-555-4567	mary_johnson@somewhere.net	\N
4	John	Smith	867 Apple Tree Road	Anytown	NJ	10111	552-555-9876	john_smith@somewhere.net	\N
5	Emily	Jones	7921 Fir Road	Anytown	NY	12344	555-555-7654	emily_jones@somewhere.net	\N
6	Peter	Johnson	\N	Some City	NY	12345	555-555-3456	peter_johnson@anywhere.net	\N
7	Edna	Hayes	158 Oak Road	Some City	M 	23458	551-555-1234	edna_hayes@this.net	\N
8	Franklin	Hayes	1990 Pine St.	Little Town	M 	23456	551-555-3939	franklin_hayes@this.net	\N
9	Mary	Collins	RR1 Box 297	Rural Area	CO	45678	553-555-1234	mary_collins@rural.net	\N
10	Peter	Collins	170 Dogwood Lane	Little Town	M 	23456	551-555-8484	peter_collins@anywhere.net	\N
11	Anne	Smith	RR 2 Box 9	Rural Area	CO	45678	553-555-9090	anne_smith@rural.net	\N
12	Peter	Smith	21 Elm St.	Anytown	NJ	10111	552-555-3459	peter_smith@somewhere.net	\N
13	Jerry	Brown	9745 Main Street	Anytown	NJ	10111	552-555-9876	jerry_brown@somewhere.net	\N
14	Helen	Brown	2588 North Road	Some City	NY	12555	555-552-3939	helen_brown@somewhere.net	\N
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY employees (ename, dept, salary) FROM stdin;
lorem	ipsum	20
\N	\N	20
\N	\N	20
blabous	\N	\N
\.


--
-- Data for Name: filme_sequencia; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY filme_sequencia (filme, seq_filme) FROM stdin;
Matrix Reloaded	Matrix Revolutions
Rocky II	Rocky III
Rocky	Rocky II
Mad Max	Mad Max 2
Toy Story	Toy Story 2
Matrix	Matrix Reloaded
Rocky III	Rocky IV
Toy Story 2	Toy Story 3
F1	F2.1
F1	F2.2
F1	F2.3
\.


--
-- Data for Name: laptop; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY laptop (model, speed, ram, hd, screen, price) FROM stdin;
2001	100	20	1.10000002	9.5	1999.00
2002	117	12	0.75	11.3000002	2499.00
2003	117	32	1	10.3999996	3599.00
2004	133	16	1.10000002	11.1999998	3499.00
2005	133	16	1	11.3000002	2599.00
2006	120	8	0.810000002	12.1000004	1999.00
2007	150	16	1.35000002	12.1000004	4799.00
2008	120	16	1.10000002	12.1000004	2099.00
2101	133	16	1.60000002	15	2095.00
2102	120	16	1.60000002	15	1899.00
2103	166	24	2.5	15	2399.00
2104	166	32	2.5	15	2499.00
2105	166	16	2	15	2499.00
2106	200	32	3.0999999	15	2599.00
2107	200	32	3.20000005	15	2849.00
2108	180	32	2	15	4199.00
2109	200	32	2.5	15	3099.00
2110	160	16	1.20000005	15	1995.00
2200	240	32	2.5	15	2999.00
\.


--
-- Data for Name: livros; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY livros (id_livro, titulo, author_id, subject_id) FROM stdin;
\.


--
-- Data for Name: matriculado; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY matriculado (nroaluno, nomecurso) FROM stdin;
112348546	Database Systems
115987938	Database Systems
348121549	Database Systems
322654189	Database Systems
552455318	Database Systems
455798411	Operating System Design
552455318	Operating System Design
567354612	Operating System Design
112348546	Operating System Design
115987938	Operating System Design
322654189	Operating System Design
567354612	Data Structures
552455318	Communication Networks
455798411	Optical Electronics
301221823	Perception
301221823	Social Cognition
301221823	American Political Parties
556784565	Air Quality Engineering
99354543	Patent Law
574489456	Urban Economics
\.


--
-- Data for Name: movie; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY movie (title, year, length, incolor, studioname, producerc) FROM stdin;
Pretty Woman	1990	119	Y	Disney                                            	199
The Man Who Wasn't There	2001	116	N	USA Entertainm.                                   	555
Logan's run	1976	\N	Y	Fox                                               	333
Star Wars	1977	124	Y	Fox                                               	555
Empire Strikes Back	1980	111	Y	Fox                                               	555
Star Trek	1979	132	Y	Paramount                                         	222
Star Trek: Nemesis	2002	116	Y	Paramount                                         	123
Terms of Endearment	1983	132	Y	MGM                                               	123
The Usual Suspects	1995	106	Y	MGM                                               	199
Gone With the Wind	1938	238	Y	MGM                                               	123
\.


--
-- Data for Name: movieexec; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY movieexec (cert, name, address, networth) FROM stdin;
555	George Lucas                  	Oak Rd.	200000000
333	Ted Turner                    	Turner Av.	125000000
222	Stephen Spielberg             	123 ET road	100000000
199	Merv Griffin                  	Riot Rd.	112000000
123	Calvin Coolidge               	Fast Lane	20000000
\.


--
-- Data for Name: moviestar; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY moviestar (name, address, gender, birthdate) FROM stdin;
Jane Fonda                    	Turner Av.	F	1977-07-07 00:00:00+00
Alec Baldwin                  	Baldwin Av.	M	1977-07-06 00:00:00+00
Kim Basinger                  	Baldwin Av.	F	1979-07-05 00:00:00+00
Harrison Ford                 	Prefect Rd.	M	1955-05-05 00:00:00+00
Debra Winger                  	A way	F	1978-06-05 00:00:00+00
Jack Nicholson                	X path	M	1949-05-05 00:00:00+00
Sandra Bullock                	X path	F	1948-12-05 00:00:00+00
\.


--
-- Data for Name: order_lines; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY order_lines (order_numb, isbn, quantity, cost_each, cost_line, shipped) FROM stdin;
1	0-123-1233-0	1	15.95	15.95	Y
15	0-123-1233-0	1	15.95	15.95	N
5	0-124-2999-9	1	18.95	18.95	N
21	0-126-3367-2	1	21.95	21.95	N
8	0-127-3948-2	1	15.95	15.95	Y
11	0-127-3948-2	1	15.95	15.95	Y
23	0-128-3939-2	1	25.95	25.95	N
16	0-128-4321-1	1	22.95	22.95	Y
18	0-128-4321-1	1	22.95	22.95	N
1	0-129-4912-0	1	19.95	19.95	Y
23	0-129-9293-2	1	21.95	21.95	N
25	0-129-9293-2	1	21.95	21.95	Y
12	0-130-2939-4	1	21.95	21.95	N
8	0-130-2939-4	1	21.95	21.95	Y
22	0-130-2943-2	2	15.95	31.90	Y
14	0-130-3941-7	1	24.95	24.95	Y
16	0-131-3021-2	1	24.95	24.95	Y
19	0-131-3021-2	1	24.95	24.95	Y
17	0-131-3021-2	1	24.95	24.95	N
2	0-131-4912-X	1	24.95	24.95	N
8	0-131-4912-X	1	24.95	24.95	Y
14	0-131-4912-X	1	24.95	24.95	Y
3	0-131-4966-9	1	23.95	23.95	Y
23	0-131-4966-9	1	23.95	23.95	N
21	0-131-4966-9	1	23.95	23.95	N
24	0-131-4966-9	1	23.95	23.95	N
6	0-132-3949-2	2	15.95	31.90	Y
10	0-132-3949-2	1	19.95	19.95	N
16	0-132-9876-4	2	19.95	39.90	Y
8	0-133-5935-2	1	17.95	17.95	Y
11	0-134-3945-7	1	21.95	21.95	Y
16	0-134-3945-7	1	21.95	21.95	Y
21	0-134-3945-7	1	21.95	21.95	N
18	0-134-3945-7	1	21.95	21.95	N
7	0-135-2222-2	5	24.95	124.75	Y
23	0-135-2222-2	1	24.95	24.95	N
10	0-136-3956-1	1	22.95	22.95	Y
1	0-136-3966-7	1	23.95	23.95	Y
14	0-137-1293-9	1	21.95	21.95	Y
4	0-140-3877-0	1	27.95	27.95	N
5	0-140-3877-0	1	27.95	27.95	N
9	0-140-3877-0	1	27.95	27.95	N
7	0-141-9876-4	5	21.95	109.75	Y
6	0-142-0084-2	1	21.95	21.95	Y
12	0-142-0084-2	1	21.95	21.95	N
10	0-142-0084-2	1	21.95	21.95	N
13	0-142-0084-2	1	21.95	21.95	N
20	0-142-3988-2	1	19.95	19.95	Y
19	0-150-3765-2	1	25.95	25.95	Y
3	0-150-5948-9	1	19.95	19.95	Y
19	0-150-5948-9	1	19.95	19.95	Y
6	0-151-9876-2	1	21.95	21.95	Y
10	0-155-2346-5	1	18.95	18.95	Y
12	0-157-3849-X	1	19.95	19.95	N
14	0-157-3849-X	1	19.95	19.95	Y
23	0-157-3849-X	1	19.95	19.95	N
16	0-157-9876-2	1	21.95	21.95	Y
2	0-159-3845-3	2	19.95	39.95	N
9	0-159-5839-3	1	19.95	19.95	N
14	0-159-5839-3	1	19.95	19.95	Y
25	0-159-5839-3	1	19.95	19.95	Y
13	0-160-3456-7	1	24.95	24.95	Y
8	0-161-0123-9	1	21.95	21.95	Y
17	0-161-0123-9	1	23.95	23.95	Y
12	0-161-8478-1	1	24.95	24.95	N
19	0-161-8478-1	1	24.95	24.95	Y
23	0-164-5968-0	1	27.95	27.95	N
24	0-164-5968-0	1	27.95	27.95	N
11	0-166-8394-3	1	27.95	27.95	Y
23	0-166-8394-3	1	27.95	27.95	N
8	0-167-1945-1	1	24.95	24.95	Y
18	0-180-4567-3	1	15.95	15.95	N
3	0-180-4712-X	2	19.95	39.90	Y
8	0-180-4712-X	1	19.95	19.95	Y
5	0-180-7388-1	1	21.95	21.95	N
6	0-180-7400-X	1	21.95	21.95	Y
13	0-180-8655-0	1	18.95	18.95	Y
17	0-190-3956-1	1	22.95	22.95	Y
8	0-190-3967-5	1	22.95	22.95	Y
18	0-190-3967-5	1	22.95	22.95	N
19	0-191-4893-0	1	19.95	19.95	Y
3	0-191-4934-8	1	23.95	23.95	Y
7	0-191-4934-8	1	23.95	23.95	Y
6	0-191-4934-8	1	23.95	23.95	Y
13	0-191-4959-2	1	18.95	18.95	Y
20	0-191-8654-3	1	23.95	23.95	Y
24	0-191-8654-3	1	23.95	23.95	N
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY orders (order_numb, customer_numb, order_date, credit_card_numb, order_filled, credit_card_exp_date) FROM stdin;
1	1	1999-12-05 00:00:00	123 123 123 123	Yes	2001-07-01 00:00:00
2	1	2000-07-06 00:00:00	123 123 123 123	No	2001-07-01 00:00:00
3	2	1999-11-12 00:00:00	234 234 234 234	No	2000-11-01 00:00:00
4	2	2000-03-18 00:00:00	234 234 234 234	No	2000-11-01 00:00:00
5	2	2000-07-06 00:00:00	234 234 234 234	Yes	2000-11-01 00:00:00
6	3	1999-08-15 00:00:00	345 345 345 345	Yes	2001-01-02 00:00:00
7	3	1999-12-02 00:00:00	345 345 345 345	Yes	2001-01-02 00:00:00
8	4	1999-11-22 00:00:00	456 456 456 456	No	2001-04-01 00:00:00
9	4	2000-01-06 00:00:00	456 456 456 456	No	2001-04-01 00:00:00
10	5	2000-03-12 00:00:00	567 567 567 567	Yes	2000-05-01 00:00:00
11	6	1999-09-19 00:00:00	678 678 678 678	No	2000-12-01 00:00:00
12	6	2000-03-12 00:00:00	678 678 678 678	No	2000-12-01 00:00:00
13	6	2000-07-21 00:00:00	678 678 678 678	Yes	2000-12-01 00:00:00
14	7	1999-12-13 00:00:00	789 789 789 789	No	2001-12-02 00:00:00
15	7	2000-01-09 00:00:00	789 789 789 789	Yes	2001-12-02 00:00:00
16	8	1999-10-12 00:00:00	890 890 890 890	No	2001-11-02 00:00:00
17	8	2000-02-22 00:00:00	890 890 890 890	No	2001-11-02 00:00:00
18	8	2000-05-13 00:00:00	890 890 890 890	Yes	2001-11-02 00:00:00
19	9	2005-07-15 00:00:00	901 901 901 901	Yes	1999-12-01 00:00:00
20	10	2005-11-15 00:00:00	1000 1000 1000	No	2001-10-02 00:00:00
21	10	2006-03-04 00:00:00	1000 1000 1000	Yes	2001-10-02 00:00:00
22	11	2006-09-19 00:00:00	1100 1100 1100 	Yes	2000-02-01 00:00:00
23	11	2007-02-21 00:00:00	1100 1100 1100	No	2000-02-01 00:00:00
24	11	2007-05-14 00:00:00	1100 1100 1100	No	2000-02-01 00:00:00
25	12	2007-10-10 00:00:00	1200 1200 1200	Yes	2001-09-01 00:00:00
26	1	2007-11-14 00:00:00	123 123 123 123	Yes	1997-11-01 00:00:00
\.


--
-- Data for Name: outcomes; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY outcomes (ship, battle, result) FROM stdin;
California	Surigao Strait	ok
Kirishima	Guadalacanal	sunk
Tennessee	Surigao Strait	ok
Washington	Guadalacanal	ok
A	B	ok
\.


--
-- Data for Name: pc; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY pc (model, speed, ram, hd, cd, price) FROM stdin;
1003	166	48	3.5	6x 	1899.00
1004	166	64	3.5	8x 	1999.00
1005	166	32	3	8x 	1999.00
1006	200	64	4.0999999	8x 	2099.00
1007	200	64	4.19999981	8x 	2349.00
1008	180	64	3	8x 	3699.00
1009	200	64	3.5	8x 	2599.00
1100	240	64	3.5	12x	2499.00
1011	10	20	1000	10x	8000.00
\.


--
-- Data for Name: printer; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY printer (model, color, type, price) FROM stdin;
3001	t	ink-jet	275.00
3002	t	ink-jet	269.00
3003	f	laser	829.00
3004	f	laser	879.00
3005	f	ink-jet	180.00
3006	t	dry	470.00
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY product (maker, model, type) FROM stdin;
A	1001	pc                  
A	1002	pc                  
A	1003	pc                  
B	1004	pc                  
B	1006	pc                  
B	3002	printer             
B	3004	printer             
C	1005	pc                  
C	1007	pc                  
D	1008	pc                  
D	1009	pc                  
D	1010	pc                  
D	2001	laptop              
D	2002	laptop              
D	2003	laptop              
D	3001	printer             
D	3003	printer             
E	2004	laptop              
E	2008	laptop              
F	2005	laptop              
G	2006	laptop              
G	2007	laptop              
H	3005	printer             
I	3006	printer             
C	1100	pc                  
A	2101	laptop              
A	2102	laptop              
A	2103	laptop              
B	2104	laptop              
B	2106	laptop              
C	2105	laptop              
C	2107	laptop              
D	2108	laptop              
D	2109	laptop              
D	2110	laptop              
C	2200	laptop              
\N	1011	pc                  
\.


--
-- Data for Name: professor; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY professor (idprof, nomeprof, iddepto) FROM stdin;
142519864	Ivana Teach	20
242518965	James Smith	68
141582651	Mary Johnson	20
11564812	John Williams	68
254099823	Patricia Jones	68
356187925	Robert Brown	12
489456522	Linda Davis	20
287321212	Michael Miller	12
248965255	Barbara Wilson	12
159542516	William Moore	33
90873519	Elizabeth Taylor	11
486512566	David Anderson	20
619023588	Jennifer Thomas	11
489221823	Richard Jackson	33
548977562	Ulysses Teach	20
\.


--
-- Data for Name: publishers; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY publishers (publisher_name) FROM stdin;
American Publishing Co
Anchor Press
Atheneum
Ballantine Books
Clarendon Press
Columbia University Press
D. Appleton & Co
Delacorte
Deutsch
Dial Press
Dodd, Mead
Doubleday
E. R. Burroughs, Inc.
Franklin Library
Gregg Press
Grosset & Dunlap
Harper
Hart Publishing Co.
J. W. Lovell Co.
James R. Osgood and Co.
Knopf
Macmillan
Metheun
New English Library
Overlook Press
P. F. Collier & Son
Platt & Munk
Putnam
R. Marek Publishers
Random House
Scribner
St. Martin's Press
Tandem
University of Nebraska Press
Warner Books
World Pub. Co.
\.


--
-- Data for Name: ships; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY ships (name, class, launched) FROM stdin;
California	Tennessee	1921
Haruna	Kongo	1915
Hiei	Kongo	1914
Iowa	Iowa	1943
Kirishima	Kongo	1915
Kongo	Kongo	1913
Missouri	Iowa	1944
Musashi	Yamato	1942
New Jersey	Iowa	1941
North Carolina	North Carolina	1921
Ramillies	Revenge	1917
Renown	Renown	1916
Repulse	Renown	1916
Resolution	Revenge	1916
Revenge	Revenge	1916
Royal Oak	Revenge	1916
Royal Sovereign	Revenge	1916
Tennessee	Tennessee	1920
Washington	North Carolina	1941
Wisconsin	Iowa	1944
Yamato	Yamato	1941
Lorem	Lorem	\N
Bla	\N	\N
California2	Tennessee	\N
A	\N	\N
\.


--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY sources (source_numb, source_name, source_street, source_city, source_state, source_zip, source_phone) FROM stdin;
1	Ingram	123 West 99th	Philadelphia	PA	19112	555-555-1111
2	Baker and Taylor	99 256th Ave	Minneapolis	MN	68112	551-555-2222
3	Jostens	19594 Highway 28	Seattle	WA	98333	552-555-3333
4	Brodart	1944 Bayview Blvd	Los Angeles	CA	96111	553-555-4444
\.


--
-- Data for Name: starsin; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY starsin (movietitle, movieyear, starname) FROM stdin;
Star Wars	1977	Kim Basinger                  
Star Wars	1977	Alec Baldwin                  
Star Wars	1977	Harrison Ford                 
Empire Strikes Back	1980	Harrison Ford                 
\.


--
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY stock (isbn, cost, retail, stock) FROM stdin;
\.


--
-- Data for Name: studio; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY studio (name, address, presc) FROM stdin;
Disney                                            	500 S. Buena Vista Street	555
USA Entertainm.                                   		333
Fox                                               	10201 Pico Boulevard	222
Paramount                                         	5555 Melrose Ave	199
MGM                                               	MGM Boulevard	123
\.


--
-- Data for Name: voo; Type: TABLE DATA; Schema: public; Owner: u7538743
--

COPY voo (nvoo, origem, destino, partida, chegada) FROM stdin;
105	Chicago	Pittsburgh	08:00:00	09:15:00
104	Chicago	Detroit	08:50:00	09:30:00
107	Detroit	New York	11:00:00	12:30:00
109	Pittsburgh	Nova York	10:00:00	12:00:00
205	Chicago Las	Vegas	14:00:00	17:00:00
101	Los Angeles	Chicago	05:30:00	07:30:00
201	Las Vegas	Tucson	17:40:00	19:00:00
210	Tucson	Albuquerque	19:30:00	20:30:00
310	Dallas	Albuquerque	09:30:00	11:00:00
325	Los Angeles	Dallas	06:15:00	08:15:00
425	Albuquerque	Los Angeles	21:30:00	23:00:00
\.


--
-- Name: aluno_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY aluno
    ADD CONSTRAINT aluno_pkey PRIMARY KEY (nroaluno);


--
-- Name: authors_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (author_name);


--
-- Name: chpbattle; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY battles
    ADD CONSTRAINT chpbattle PRIMARY KEY (name);


--
-- Name: chpclasses; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY classes
    ADD CONSTRAINT chpclasses PRIMARY KEY (class);


--
-- Name: chpoutcomes; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY outcomes
    ADD CONSTRAINT chpoutcomes PRIMARY KEY (ship, battle);


--
-- Name: chpship; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY ships
    ADD CONSTRAINT chpship PRIMARY KEY (name);


--
-- Name: curso_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY curso
    ADD CONSTRAINT curso_pkey PRIMARY KEY (nome);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_numb);


--
-- Name: filme_sequencia_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY filme_sequencia
    ADD CONSTRAINT filme_sequencia_pkey PRIMARY KEY (filme, seq_filme);


--
-- Name: laptop_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY laptop
    ADD CONSTRAINT laptop_pkey PRIMARY KEY (model, speed, ram, hd, screen, price);


--
-- Name: livros_id_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY livros
    ADD CONSTRAINT livros_id_pkey PRIMARY KEY (id_livro);


--
-- Name: matriculado_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY matriculado
    ADD CONSTRAINT matriculado_pkey PRIMARY KEY (nroaluno, nomecurso);


--
-- Name: pc_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY pc
    ADD CONSTRAINT pc_pkey PRIMARY KEY (model, speed, ram, hd, cd, price);


--
-- Name: pk_books; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY books
    ADD CONSTRAINT pk_books PRIMARY KEY (isbn);


--
-- Name: pk_movie; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY movie
    ADD CONSTRAINT pk_movie PRIMARY KEY (title, year);


--
-- Name: pk_movieexec; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY movieexec
    ADD CONSTRAINT pk_movieexec PRIMARY KEY (cert);


--
-- Name: pk_moviestar; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY moviestar
    ADD CONSTRAINT pk_moviestar PRIMARY KEY (name);


--
-- Name: pk_order_lines; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY order_lines
    ADD CONSTRAINT pk_order_lines PRIMARY KEY (order_numb, isbn);


--
-- Name: pk_orders; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT pk_orders PRIMARY KEY (order_numb);


--
-- Name: pk_starsin; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY starsin
    ADD CONSTRAINT pk_starsin PRIMARY KEY (movietitle, movieyear, starname);


--
-- Name: pk_studio; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY studio
    ADD CONSTRAINT pk_studio PRIMARY KEY (name);


--
-- Name: printer_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY printer
    ADD CONSTRAINT printer_pkey PRIMARY KEY (model, color, type, price);


--
-- Name: product_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_pkey PRIMARY KEY (model);


--
-- Name: professor_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY professor
    ADD CONSTRAINT professor_pkey PRIMARY KEY (idprof);


--
-- Name: publishers_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY publishers
    ADD CONSTRAINT publishers_pkey PRIMARY KEY (publisher_name);


--
-- Name: sources_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (source_numb);


--
-- Name: voo_pkey; Type: CONSTRAINT; Schema: public; Owner: u7538743; Tablespace: 
--

ALTER TABLE ONLY voo
    ADD CONSTRAINT voo_pkey PRIMARY KEY (nvoo);


--
-- Name: checkdisplacement35000; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER checkdisplacement35000 AFTER INSERT ON classes FOR EACH ROW WHEN ((new.displacement > 35000)) EXECUTE PROCEDURE setdisplacement35000();


--
-- Name: checkshipexists; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER checkshipexists BEFORE INSERT ON outcomes FOR EACH ROW WHEN (true) EXECUTE PROCEDURE insertshiporbattlefromoutcome();


--
-- Name: delete_newpc; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER delete_newpc INSTEAD OF DELETE ON newpc FOR EACH ROW EXECUTE PROCEDURE delete_newpc();


--
-- Name: insert_employee_name; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER insert_employee_name INSTEAD OF INSERT ON employeenames FOR EACH ROW EXECUTE PROCEDURE insertemployeename();


--
-- Name: newclass; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER newclass AFTER INSERT ON classes FOR EACH ROW WHEN (true) EXECUTE PROCEDURE createship();


--
-- Name: trigger_battles_check; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER trigger_battles_check BEFORE INSERT OR DELETE OR UPDATE ON battles FOR EACH ROW EXECUTE PROCEDURE sunkcheck();


--
-- Name: trigger_newpc; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER trigger_newpc INSTEAD OF INSERT ON newpc FOR EACH ROW EXECUTE PROCEDURE insere_newpc();


--
-- Name: trigger_outcomes_check; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER trigger_outcomes_check BEFORE INSERT OR DELETE OR UPDATE ON outcomes FOR EACH ROW EXECUTE PROCEDURE sunkcheck();


--
-- Name: update_newpc; Type: TRIGGER; Schema: public; Owner: u7538743
--

CREATE TRIGGER update_newpc INSTEAD OF UPDATE ON newpc FOR EACH ROW EXECUTE PROCEDURE update_newpc();


--
-- Name: cheoutcomes1; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY outcomes
    ADD CONSTRAINT cheoutcomes1 FOREIGN KEY (ship) REFERENCES ships(name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cheoutcomes2; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY outcomes
    ADD CONSTRAINT cheoutcomes2 FOREIGN KEY (battle) REFERENCES battles(name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cheship; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY ships
    ADD CONSTRAINT cheship FOREIGN KEY (class) REFERENCES classes(class) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: curso_idprof_fkey; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY curso
    ADD CONSTRAINT curso_idprof_fkey FOREIGN KEY (idprof) REFERENCES professor(idprof);


--
-- Name: fk_laptop_product; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY laptop
    ADD CONSTRAINT fk_laptop_product FOREIGN KEY (model) REFERENCES product(model) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_movie_movieexec; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY movie
    ADD CONSTRAINT fk_movie_movieexec FOREIGN KEY (producerc) REFERENCES movieexec(cert);


--
-- Name: fk_movie_studio; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY movie
    ADD CONSTRAINT fk_movie_studio FOREIGN KEY (studioname) REFERENCES studio(name);


--
-- Name: fk_pc_product; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY pc
    ADD CONSTRAINT fk_pc_product FOREIGN KEY (model) REFERENCES product(model) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_printer_product; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY printer
    ADD CONSTRAINT fk_printer_product FOREIGN KEY (model) REFERENCES product(model) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_starsin_movie; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY starsin
    ADD CONSTRAINT fk_starsin_movie FOREIGN KEY (movietitle, movieyear) REFERENCES movie(title, year);


--
-- Name: fk_starsin_moviestar; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY starsin
    ADD CONSTRAINT fk_starsin_moviestar FOREIGN KEY (starname) REFERENCES moviestar(name);


--
-- Name: matriculado_nomecurso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY matriculado
    ADD CONSTRAINT matriculado_nomecurso_fkey FOREIGN KEY (nomecurso) REFERENCES curso(nome);


--
-- Name: matriculado_nroaluno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: u7538743
--

ALTER TABLE ONLY matriculado
    ADD CONSTRAINT matriculado_nroaluno_fkey FOREIGN KEY (nroaluno) REFERENCES aluno(nroaluno);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

