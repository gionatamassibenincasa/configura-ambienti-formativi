CREATE DATABASE IF NOT EXISTS my_gim CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE my_gim;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS DettaglioForniture;
DROP VIEW IF EXISTS CostoPerVoce;
DROP VIEW IF EXISTS CostoTotalePerLaboratorio;

DROP TABLE IF EXISTS Costo;
DROP TABLE IF EXISTS ObiettiviModulo;
DROP TABLE IF EXISTS Modulo;
DROP TABLE IF EXISTS Obiettivo;
DROP TABLE IF EXISTS TipoObiettivo;
DROP TABLE IF EXISTS Fornitura;
DROP TABLE IF EXISTS TipoFornitura;
DROP TABLE IF EXISTS Fornitore;
DROP TABLE IF EXISTS Voce;
DROP TABLE IF EXISTS Laboratorio;
DROP TABLE IF EXISTS Finanziamento;
DROP TABLE IF EXISTS Plesso;
DROP TABLE IF EXISTS Target;
DROP TABLE IF EXISTS Istituto;
DROP TABLE IF EXISTS Curriculum;
DROP TABLE IF EXISTS Articolazione;
DROP TABLE IF EXISTS Indirizzo;
DROP TABLE IF EXISTS Corso;
DROP TABLE IF EXISTS Ordinamento;
DROP TABLE IF EXISTS Sessione;
DROP TABLE IF EXISTS PreferenzaUtente;
DROP TABLE IF EXISTS TipoPreferenza;
DROP TABLE IF EXISTS RuoloUtente;
DROP TABLE IF EXISTS Ruolo;
DROP TABLE IF EXISTS Utente;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Ordinamento (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ordinamento VARCHAR(191) NOT NULL UNIQUE,
    descrizione TEXT NULL
);

CREATE TABLE Corso (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idOrdinamento INT NOT NULL,
    corso VARCHAR(191) NOT NULL UNIQUE,
    descrizione TEXT NULL,
    CONSTRAINT fk_Corso_Ordinamento FOREIGN KEY (idOrdinamento) REFERENCES Ordinamento(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Indirizzo (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idCorso INT NOT NULL,
    indirizzo VARCHAR(191) NOT NULL,
    descrizione TEXT NULL,
    UNIQUE KEY uq_Indirizzo (idCorso, indirizzo),
    CONSTRAINT fk_Indirizzo_Corso FOREIGN KEY (idCorso) REFERENCES Corso(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Articolazione (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idIndirizzo INT NOT NULL,
    articolazione VARCHAR(191) NOT NULL,
    UNIQUE KEY uq_Articolazione (idIndirizzo, articolazione),
    CONSTRAINT fk_Articolazione_Indirizzo FOREIGN KEY (idIndirizzo) REFERENCES Indirizzo(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Curriculum (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    codice VARCHAR(32) NOT NULL UNIQUE,
    idIndirizzo INT NOT NULL,
    idArticolazione INT NULL,
    curriculum VARCHAR(191) NOT NULL UNIQUE,
    CONSTRAINT fk_Curriculum_Indirizzo FOREIGN KEY (idIndirizzo) REFERENCES Indirizzo(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Curriculum_Articolazione FOREIGN KEY (idArticolazione) REFERENCES Articolazione(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Istituto (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    istituto VARCHAR(191) NOT NULL UNIQUE,
    comune VARCHAR(120) NULL
);

CREATE TABLE Target (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idCurriculum INT NOT NULL,
    idIstituto INT NOT NULL,
    abbreviazione VARCHAR(100) NOT NULL UNIQUE,
    target VARCHAR(191) NOT NULL,
    CONSTRAINT fk_Target_Curriculum FOREIGN KEY (idCurriculum) REFERENCES Curriculum(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Target_Istituto FOREIGN KEY (idIstituto) REFERENCES Istituto(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Plesso (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idIstituto INT NOT NULL,
    plesso VARCHAR(191) NOT NULL,
    indirizzo VARCHAR(191) NULL,
    UNIQUE KEY uq_Plesso (idIstituto, plesso),
    CONSTRAINT fk_Plesso_Istituto FOREIGN KEY (idIstituto) REFERENCES Istituto(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Finanziamento (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(64) NOT NULL,
    denominazione VARCHAR(255) NOT NULL,
    urlAvviso VARCHAR(2048) NULL,
    importo DECIMAL(12,2) NOT NULL DEFAULT 0.00
);

CREATE TABLE Laboratorio (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idPlesso INT NOT NULL,
    idFinanziamento INT NOT NULL,
    laboratorio VARCHAR(191) NOT NULL UNIQUE,
    aula VARCHAR(120) NULL,
    descrizione TEXT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_Laboratorio_Plesso FOREIGN KEY (idPlesso) REFERENCES Plesso(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Laboratorio_Finanziamento FOREIGN KEY (idFinanziamento) REFERENCES Finanziamento(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TipoObiettivo (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tipoObiettivo VARCHAR(100) NOT NULL UNIQUE,
    descrizione TEXT NULL
);

CREATE TABLE Obiettivo (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idTipoObiettivo INT NOT NULL,
    obiettivo TEXT NOT NULL,
    CONSTRAINT fk_Obiettivo_TipoObiettivo FOREIGN KEY (idTipoObiettivo) REFERENCES TipoObiettivo(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Modulo (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idLaboratorio INT NOT NULL,
    idTarget INT NOT NULL,
    modulo VARCHAR(191) NOT NULL UNIQUE,
    descrizione TEXT NULL,
    discipline VARCHAR(255) NULL,
    professione VARCHAR(191) NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_Modulo_Laboratorio FOREIGN KEY (idLaboratorio) REFERENCES Laboratorio(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Modulo_Target FOREIGN KEY (idTarget) REFERENCES Target(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ObiettiviModulo (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idModulo INT NOT NULL,
    idObiettivo INT NOT NULL,
    priorita TINYINT NOT NULL DEFAULT 1,
    UNIQUE KEY uq_ObiettiviModulo (idModulo, idObiettivo),
    CONSTRAINT fk_ObiettiviModulo_Modulo FOREIGN KEY (idModulo) REFERENCES Modulo(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ObiettiviModulo_Obiettivo FOREIGN KEY (idObiettivo) REFERENCES Obiettivo(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Fornitore (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fornitore VARCHAR(191) NOT NULL UNIQUE,
    PIVA VARCHAR(32) NULL,
    indirizzo VARCHAR(191) NULL,
    telefono VARCHAR(64) NULL
);

CREATE TABLE TipoFornitura (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tipoFornitura VARCHAR(191) NOT NULL UNIQUE
);

CREATE TABLE Fornitura (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idTipoFornitura INT NOT NULL,
    idFornitore INT NOT NULL,
    fornitura VARCHAR(255) NOT NULL,
    prezzo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    codiceMepa VARCHAR(191) NULL,
    link VARCHAR(2048) NULL,
    SKU VARCHAR(191) NULL,
    note TEXT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_Fornitura_Tipo FOREIGN KEY (idTipoFornitura) REFERENCES TipoFornitura(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Fornitura_Fornitore FOREIGN KEY (idFornitore) REFERENCES Fornitore(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Voce (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    lettera CHAR(1) NOT NULL UNIQUE,
    voce VARCHAR(191) NOT NULL UNIQUE,
    descrizione TEXT NULL,
    minimale INT NOT NULL DEFAULT 0,
    massimale INT NOT NULL DEFAULT 100
);

CREATE TABLE Costo (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idVoce INT NOT NULL DEFAULT 3,
    idLaboratorio INT NOT NULL,
    idFornitura INT NOT NULL,
    descrizione TEXT NULL,
    quantita INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_Costo_Voce FOREIGN KEY (idVoce) REFERENCES Voce(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Costo_Laboratorio FOREIGN KEY (idLaboratorio) REFERENCES Laboratorio(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Costo_Fornitura FOREIGN KEY (idFornitura) REFERENCES Fornitura(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- I dati vengono caricati da seed.sql, generato automaticamente dalla sorgente SQLite legacy.

CREATE VIEW CostoTotalePerLaboratorio AS
SELECT
    l.id AS idLaboratorio,
    l.laboratorio,
    COALESCE(SUM(c.quantita * f.prezzo), 0) AS costoTotale
FROM Laboratorio l
LEFT JOIN Costo c ON c.idLaboratorio = l.id
LEFT JOIN Fornitura f ON f.id = c.idFornitura
GROUP BY l.id, l.laboratorio;

CREATE VIEW CostoPerVoce AS
SELECT
    l.id AS idLaboratorio,
    l.laboratorio,
    v.voce,
    COALESCE(SUM(c.quantita * f.prezzo), 0) AS costoTotaleVoce
FROM Costo c
INNER JOIN Laboratorio l ON l.id = c.idLaboratorio
INNER JOIN Voce v ON v.id = c.idVoce
INNER JOIN Fornitura f ON f.id = c.idFornitura
GROUP BY l.id, l.laboratorio, v.voce;

CREATE VIEW DettaglioForniture AS
SELECT
    l.id AS idLaboratorio,
    l.laboratorio,
    v.voce,
    f.fornitura,
    c.descrizione,
    c.quantita,
    f.prezzo,
    (c.quantita * f.prezzo) AS costoTotale
FROM Costo c
INNER JOIN Laboratorio l ON l.id = c.idLaboratorio
INNER JOIN Voce v ON v.id = c.idVoce
INNER JOIN Fornitura f ON f.id = c.idFornitura
ORDER BY l.laboratorio, v.voce, f.fornitura;
