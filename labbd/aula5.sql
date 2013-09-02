/*******************************************************************************
MAC0439 - 2013 - Laboratório de Bancos de Dados
Aula 5 - Comandos SQL
Aluno: Pedro Paulo Vezzá Campos - 7538743
*******************************************************************************/

CREATE TABLE AEROPORTO (
	Codigo_aeroporto           CHAR(3),
	Nome                       VARCHAR(32) NOT NULL,
	Cidade                     VARCHAR(32) NOT NULL,
	Estado                     CHAR(2) NOT NULL,
	PRIMARY KEY (Codigo_aeroporto)
);

CREATE TABLE VOO (
	Numero_voo                  NUMERIC(4),
	Companhia_aerea             VARCHAR(32) NOT NULL,
	Dias_da_semana              BIT(7) NOT NULL,
	PRIMARY KEY (Numero_voo)
);

CREATE TABLE TRECHO_VOO (
	Numero_voo                  NUMERIC(4),
	Numero_trecho               NUMERIC(4),
	Codigo_aeroporto_partida    CHAR(3) NOT NULL,
	Codigo_aeroporto_chegada    CHAR(3) NOT NULL,
	Horario_partida_previsto    TIME NOT NULL,
	Horario_aeroporto_previsto  TIME NOT NULL,
	PRIMARY KEY (Numero_voo, Numero_trecho),
	FOREIGN KEY (Numero_voo) REFERENCES VOO(Numero_voo) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Codigo_aeroporto_partida) REFERENCES AEROPORTO(Codigo_aeroporto) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Codigo_aeroporto_chegada) REFERENCES AEROPORTO(Codigo_aeroporto) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE INSTANCIA_TRECHO (
	Numero_voo                       NUMERIC(4),
	Numero_trecho                    NUMERIC(4),
	Data                             DATE,
	Numero_assentos_disponiveis      NUMERIC(3) NOT NULL,
	Codigo_aeronave                  NUMERIC(4) NOT NULL,
	Codigo_aeroporto_partida         CHAR(3) NOT NULL,
	Horario_partida                  TIME NOT NULL,
	Codigo_aeroporto_chegada         CHAR(3) NOT NULL,
	Horario_chegada                  TIME NOT NULL,
	PRIMARY KEY (Data, Numero_voo, Numero_trecho),
	FOREIGN KEY (Numero_trecho, Numero_voo) REFERENCES TRECHO_VOO(Numero_trecho, Numero_voo) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Codigo_aeroporto_partida) REFERENCES AEROPORTO(Codigo_aeroporto) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Codigo_aeroporto_chegada) REFERENCES AEROPORTO(Codigo_aeroporto) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TIPO_AERONAVE (
	Nome_tipo_aeronave              VARCHAR(32),
	Qtd_max_assentos                NUMERIC(3) NOT NULL,
	Companhia                       VARCHAR(32) NOT NULL,
	PRIMARY KEY (Nome_tipo_aeronave)
);

CREATE TABLE AERONAVE (
	Codigo_aeronave                 CHAR(6),
	Numero_total_assentos           NUMERIC(3) NOT NULL,
	Tipo_aeronave                   VARCHAR(32) NOT NULL,
	PRIMARY KEY (Codigo_aeronave),
	FOREIGN KEY (Tipo_aeronave) REFERENCES TIPO_AERONAVE(Nome_tipo_aeronave) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TARIFA (
	Numero_voo                      NUMERIC(4),
	Codigo_tarifa                   NUMERIC(4),
	Quantidade                      NUMERIC(3) NOT NULL,
	Restricoes                      TEXT NOT NULL,
	PRIMARY KEY (Numero_voo, Codigo_tarifa),
	FOREIGN KEY (Numero_voo) REFERENCES VOO(Numero_voo) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PODE_POUSAR (
	Nome_tipo_aeronave              VARCHAR(32),
	Codigo_aeroporto                CHAR(3),
	PRIMARY KEY (Nome_tipo_aeronave, Codigo_aeroporto),
	FOREIGN KEY (Nome_tipo_aeronave) REFERENCES TIPO_AERONAVE(Nome_tipo_aeronave) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Codigo_aeroporto) REFERENCES AEROPORTO(Codigo_aeroporto) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE RESERVA_ASSENTO (
	Numero_voo                      NUMERIC(4),
	Numero_trecho                   NUMERIC(4),
	Data                            DATE,
	Numero_assento                  CHAR(3),
	Nome_cliente                    VARCHAR(64) NOT NULL,
	Telefone_cliente                NUMERIC(15) NOT NULL,
	PRIMARY KEY (Numero_voo, Numero_trecho, Data, Numero_assento),
	FOREIGN KEY (Numero_voo, Data, Numero_trecho) REFERENCES INSTANCIA_TRECHO(Numero_voo, Data, Numero_trecho) ON DELETE CASCADE ON UPDATE CASCADE
);



