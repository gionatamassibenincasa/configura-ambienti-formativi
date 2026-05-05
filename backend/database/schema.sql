CREATE DATABASE IF NOT EXISTS my_gim CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE my_gim;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS VerificaVincoliProgetto;
DROP VIEW IF EXISTS SintesiProgetto;
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
DROP TABLE IF EXISTS CampusPartecipante;
DROP TABLE IF EXISTS Campus;
DROP TABLE IF EXISTS TipoAggregazione;
DROP TABLE IF EXISTS Progetto;
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

CREATE TABLE Utente (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    passwordHash VARCHAR(255) NOT NULL,
    nome VARCHAR(191) NOT NULL,
    attivo TINYINT(1) NOT NULL DEFAULT 1,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Ruolo (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ruolo VARCHAR(100) NOT NULL UNIQUE,
    descrizione TEXT NULL
);

CREATE TABLE RuoloUtente (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idUtente INT NOT NULL,
    idRuolo INT NOT NULL,
    UNIQUE KEY uq_RuoloUtente (idUtente, idRuolo),
    CONSTRAINT fk_RuoloUtente_Utente FOREIGN KEY (idUtente) REFERENCES Utente(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_RuoloUtente_Ruolo FOREIGN KEY (idRuolo) REFERENCES Ruolo(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Progetto (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idFinanziamento INT NOT NULL,
    idIstitutoCapofila INT NOT NULL,
    codice VARCHAR(64) NOT NULL UNIQUE,
    progetto VARCHAR(191) NOT NULL,
    tipologia VARCHAR(32) NOT NULL DEFAULT 'laboratorio',
    descrizione TEXT NULL,
    ambientiMinimi INT NOT NULL DEFAULT 1,
    partecipantiMinimi INT NOT NULL DEFAULT 1,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_Progetto (idFinanziamento, idIstitutoCapofila, progetto),
    CONSTRAINT fk_Progetto_Finanziamento FOREIGN KEY (idFinanziamento) REFERENCES Finanziamento(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Progetto_Istituto FOREIGN KEY (idIstitutoCapofila) REFERENCES Istituto(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TipoAggregazione (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tipoAggregazione VARCHAR(100) NOT NULL UNIQUE,
    descrizione TEXT NULL
);

CREATE TABLE Campus (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idProgetto INT NOT NULL,
    idTipoAggregazione INT NOT NULL,
    campus VARCHAR(191) NOT NULL,
    descrizione TEXT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_Campus_Progetto (idProgetto),
    CONSTRAINT fk_Campus_Progetto FOREIGN KEY (idProgetto) REFERENCES Progetto(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Campus_TipoAggregazione FOREIGN KEY (idTipoAggregazione) REFERENCES TipoAggregazione(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE CampusPartecipante (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idCampus INT NOT NULL,
    idIstituto INT NOT NULL,
    ruolo VARCHAR(100) NULL,
    UNIQUE KEY uq_CampusPartecipante (idCampus, idIstituto),
    CONSTRAINT fk_CampusPartecipante_Campus FOREIGN KEY (idCampus) REFERENCES Campus(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_CampusPartecipante_Istituto FOREIGN KEY (idIstituto) REFERENCES Istituto(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Laboratorio (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    idPlesso INT NOT NULL,
    idProgetto INT NOT NULL,
    laboratorio VARCHAR(191) NOT NULL,
    aula VARCHAR(120) NULL,
    descrizione TEXT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_Laboratorio (idProgetto, laboratorio),
    CONSTRAINT fk_Laboratorio_Plesso FOREIGN KEY (idPlesso) REFERENCES Plesso(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_Laboratorio_Progetto FOREIGN KEY (idProgetto) REFERENCES Progetto(id) ON UPDATE CASCADE ON DELETE CASCADE
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
    modulo VARCHAR(191) NOT NULL,
    descrizione TEXT NULL,
    discipline VARCHAR(255) NULL,
    professione VARCHAR(191) NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_Modulo (idLaboratorio, modulo),
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
    p.id AS idProgetto,
    p.progetto,
    COALESCE(SUM(c.quantita * f.prezzo), 0) AS costoTotale
FROM Laboratorio l
INNER JOIN Progetto p ON p.id = l.idProgetto
LEFT JOIN Costo c ON c.idLaboratorio = l.id
LEFT JOIN Fornitura f ON f.id = c.idFornitura
GROUP BY l.id, l.laboratorio, p.id, p.progetto;

CREATE VIEW CostoPerVoce AS
SELECT
    l.id AS idLaboratorio,
    l.laboratorio,
    p.id AS idProgetto,
    p.progetto,
    v.voce,
    COALESCE(SUM(c.quantita * f.prezzo), 0) AS costoTotaleVoce
FROM Costo c
INNER JOIN Laboratorio l ON l.id = c.idLaboratorio
INNER JOIN Progetto p ON p.id = l.idProgetto
INNER JOIN Voce v ON v.id = c.idVoce
INNER JOIN Fornitura f ON f.id = c.idFornitura
GROUP BY l.id, l.laboratorio, p.id, p.progetto, v.voce;

CREATE VIEW DettaglioForniture AS
SELECT
    l.id AS idLaboratorio,
    l.laboratorio,
    p.id AS idProgetto,
    p.progetto,
    v.voce,
    f.fornitura,
    c.descrizione,
    c.quantita,
    f.prezzo,
    (c.quantita * f.prezzo) AS costoTotale
FROM Costo c
INNER JOIN Laboratorio l ON l.id = c.idLaboratorio
INNER JOIN Progetto p ON p.id = l.idProgetto
INNER JOIN Voce v ON v.id = c.idVoce
INNER JOIN Fornitura f ON f.id = c.idFornitura
ORDER BY p.progetto, l.laboratorio, v.voce, f.fornitura;

CREATE VIEW SintesiProgetto AS
SELECT
    p.id AS idProgetto,
    p.idIstitutoCapofila,
    p.codice,
    p.progetto,
    p.tipologia,
    i.istituto AS istitutoCapofila,
    f.tipo AS tipoFinanziamento,
    f.denominazione AS finanziamento,
    c.id AS idCampus,
    c.campus,
    ta.tipoAggregazione,
    p.ambientiMinimi,
    p.partecipantiMinimi,
    (
        SELECT COUNT(*)
        FROM Laboratorio l
        WHERE l.idProgetto = p.id
    ) AS ambienti,
    (
        SELECT COUNT(*)
        FROM Modulo m
        INNER JOIN Laboratorio l ON l.id = m.idLaboratorio
        WHERE l.idProgetto = p.id
    ) AS moduli,
    CASE
        WHEN c.id IS NULL THEN 1
        ELSE 1 + (
            SELECT COUNT(*)
            FROM CampusPartecipante cp
            WHERE cp.idCampus = c.id
        )
    END AS partecipantiTotali,
    (
        SELECT COALESCE(SUM(co.quantita * fr.prezzo), 0)
        FROM Costo co
        INNER JOIN Laboratorio l ON l.id = co.idLaboratorio
        INNER JOIN Fornitura fr ON fr.id = co.idFornitura
        WHERE l.idProgetto = p.id
    ) AS budgetAllocato
FROM Progetto p
INNER JOIN Finanziamento f ON f.id = p.idFinanziamento
INNER JOIN Istituto i ON i.id = p.idIstitutoCapofila
LEFT JOIN Campus c ON c.idProgetto = p.id
LEFT JOIN TipoAggregazione ta ON ta.id = c.idTipoAggregazione;

CREATE VIEW VerificaVincoliProgetto AS
SELECT
    sp.*,
    CASE
        WHEN sp.tipologia <> 'campus' OR sp.idCampus IS NOT NULL THEN 1
        ELSE 0
    END AS vincoloCampusRispettato,
    CASE
        WHEN sp.ambienti >= sp.ambientiMinimi THEN 1
        ELSE 0
    END AS vincoloAmbientiRispettato,
    CASE
        WHEN sp.partecipantiTotali >= sp.partecipantiMinimi THEN 1
        ELSE 0
    END AS vincoloPartecipantiRispettato,
    CASE
        WHEN (sp.tipologia <> 'campus' OR sp.idCampus IS NOT NULL)
            AND sp.ambienti >= sp.ambientiMinimi
            AND sp.partecipantiTotali >= sp.partecipantiMinimi THEN 1
        ELSE 0
    END AS vincoliRispettati
FROM SintesiProgetto sp;
