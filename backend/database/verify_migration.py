#!/usr/bin/env python3

from __future__ import annotations

import os
import sqlite3
import subprocess
import sys
from decimal import Decimal, InvalidOperation
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE_DB = ROOT / "LabCRUD" / "src" / "lib" / "server" / "db" / "labs.sqlite"

MYSQL_HOST = os.getenv("APP_DB_HOST", "localhost")
MYSQL_PORT = os.getenv("APP_DB_PORT", "3306")
MYSQL_DB = os.getenv("APP_DB_NAME", "my_gim")
MYSQL_USER = os.getenv("APP_DB_USER", "gim")
MYSQL_PASSWORD = os.getenv("APP_DB_PASSWORD", "gionata")
EXTRA_FINANZIAMENTI = [
    (
        "PN",
        "PN Scuola e competenze 2021-2027 [...] risorse per l’acquisto di tablet, PC, dispositivi digitali, libri e sussidi didattici da fornire in comodato d’uso al personale della scuola",
        "https://www.mim.gov.it/documents/8099600/8783257/m_pi.AOOGABMI.REGISTRO-UFFICIALEU.0089057.03-06-2025.pdf/02b9f70d-7237-4bf5-59e9-cd63569fb061?version=1.0&t=1749458687505",
        "0",
    ),
]
EXTRA_PROGETTI = [
    (
        "3",
        "1",
        "PN21-27",
        "Allestimento aula colloqui plesso Benincasa",
        "laboratorio",
        "Dispositivi per lo svolgimento dei colloqui online. Laboratorio rilocabile composto da SBC, monitor portatili, webcam, cuffie e microfoni. Una workstation agisce da server per la distribuzione del sistema operativo tramite Linux Terminal Server Project.",
        "1",
        "1",
    ),
]
EXTRA_LABORATORI = [
    (
        "1",
        "2",
        "Aula colloqui",
        "4.09",
        "Allestimento aula per colloqui online oppure per cedere in comodato d'uso ai docenti",
    ),
]
EXTRA_OBIETTIVI = [
    (
        "1",
        "Sviluppare competenze digitali, collaborative e organizzative coerenti con il contesto laboratoriale del progetto.",
    ),
    (
        "1",
        "Promuovere l'uso consapevole delle tecnologie per attivita' didattiche, progettuali e di documentazione.",
    ),
    (
        "2",
        "Configurare e utilizzare dispositivi hardware, software e servizi di rete funzionali alle attivita' del laboratorio.",
    ),
    (
        "2",
        "Realizzare elaborati, prototipi o prodotti digitali coerenti con il target formativo del modulo.",
    ),
    (
        "2",
        "Analizzare problemi operativi del contesto scolastico o professionale e proporre soluzioni supportate da strumenti digitali.",
    ),
    (
        "2",
        "Documentare fasi, risultati e criticita' delle attivita' svolte nel laboratorio con linguaggio tecnico appropriato.",
    ),
]

DIRECT_TABLES: list[tuple[str, list[str]]] = [
    ("Ordinamento", ["id", "ordinamento"]),
    ("Corso", ["id", "idOrdinamento", "corso"]),
    ("Indirizzo", ["id", "idCorso", "indirizzo"]),
    ("Articolazione", ["id", "idIndirizzo", "articolazione"]),
    ("Curriculum", ["id", "codice", "idIndirizzo", "idArticolazione", "curriculum"]),
    ("Istituto", ["id", "istituto"]),
    ("Target", ["id", "idCurriculum", "idIstituto", "abbreviazione", "target"]),
    ("Plesso", ["id", "idIstituto", "plesso"]),
    ("TipoObiettivo", ["id", "tipoObiettivo", "descrizione"]),
    ("Modulo", ["id", "idLaboratorio", "idTarget", "modulo", "descrizione", "discipline", "professione"]),
    ("Fornitore", ["id", "fornitore", "PIVA", "indirizzo", "telefono"]),
    ("TipoFornitura", ["id", "tipoFornitura"]),
    ("Fornitura", ["id", "idTipoFornitura", "idFornitore", "fornitura", "prezzo", "codiceMepa", "link", "SKU"]),
    ("Voce", ["id", "lettera", "voce", "descrizione", "minimale", "massimale"]),
    ("Costo", ["id", "idVoce", "idLaboratorio", "idFornitura", "descrizione", "quantita"]),
]

SPECIAL_QUERIES = {
    "ObiettiviModulo": (
        "SELECT idModulo, idObiettivo FROM ObiettiviModulo ORDER BY idModulo, idObiettivo",
        "SELECT idModulo, idObiettivo FROM ObiettiviModulo ORDER BY idModulo, idObiettivo",
    ),
}


def sqlite_rows(query: str) -> list[tuple[str, ...]]:
    connection = sqlite3.connect(str(SOURCE_DB))
    cursor = connection.cursor()
    rows = cursor.execute(query).fetchall()
    connection.close()
    return [tuple(normalize_value(value) for value in row) for row in rows]


def mysql_rows(query: str) -> list[tuple[str, ...]]:
    command = [
        "mariadb",
        f"-h{MYSQL_HOST}",
        f"-P{MYSQL_PORT}",
        f"-u{MYSQL_USER}",
        "-N",
        "-B",
        "--raw",
        MYSQL_DB,
        "-e",
        "SET NAMES utf8mb4; " + query,
    ]
    env = os.environ.copy()
    env["MYSQL_PWD"] = MYSQL_PASSWORD
    result = subprocess.run(command, check=True, capture_output=True, text=True, env=env)
    lines = [line for line in result.stdout.splitlines() if line.strip() != ""]
    return [tuple(normalize_value(part) for part in line.split("\t")) for line in lines]


def normalize_value(value: object) -> str:
    if value is None:
        return ""

    text = str(value)
    if text == "NULL":
        return ""

    try:
        decimal_value = Decimal(text)
    except (InvalidOperation, ValueError):
        return text

    normalized = format(decimal_value.normalize(), "f")
    if "." in normalized:
        normalized = normalized.rstrip("0").rstrip(".")
    return normalized or "0"


def compare_table(label: str, sqlite_query: str, mysql_query: str) -> list[str]:
    source = sqlite_rows(sqlite_query)
    target = mysql_rows(mysql_query)
    if source != target:
        return [
            f"{label}: mismatch",
            f"  source rows: {len(source)}",
            f"  target rows: {len(target)}",
        ]
    return []


def main() -> int:
    errors: list[str] = []

    for table, columns in DIRECT_TABLES:
        select = f"SELECT {', '.join(columns)} FROM {table} ORDER BY id"
        errors.extend(compare_table(table, select, select))

    for table, (source_query, target_query) in SPECIAL_QUERIES.items():
        errors.extend(compare_table(table, source_query, target_query))

    source_finanziamenti = sqlite_rows(
        "SELECT tipo, denominazione, urlAvviso, importo FROM Finanziamento ORDER BY id"
    )
    target_finanziamenti = mysql_rows(
        "SELECT tipo, denominazione, urlAvviso, importo FROM Finanziamento ORDER BY id"
    )
    for row in source_finanziamenti:
        if row not in target_finanziamenti:
            errors.append("Finanziamento: missing legacy financing row in target")
            break

    expected_financing_count = len(source_finanziamenti) + len(EXTRA_FINANZIAMENTI)
    if len(target_finanziamenti) != expected_financing_count:
        errors.append(
            f"Finanziamento: expected {expected_financing_count} rows including extras, found {len(target_finanziamenti)}"
        )

    for extra_row in EXTRA_FINANZIAMENTI:
        if extra_row not in target_finanziamenti:
            errors.append("Finanziamento: missing configured extra financing row")
            break

    source_project_groups = sqlite_rows(
        """
        SELECT l.idFinanziamento, p.idIstituto
        FROM Laboratorio l
        INNER JOIN Plesso p ON p.id = l.idPlesso
        GROUP BY l.idFinanziamento, p.idIstituto
        ORDER BY MIN(l.id)
        """
    )
    target_project_count = mysql_rows("SELECT COUNT(*) FROM Progetto")
    expected_project_count = len(source_project_groups) + len(EXTRA_PROGETTI)
    if target_project_count != [(str(expected_project_count),)]:
        errors.append(
            f"Progetto: expected {expected_project_count} rows including extras, found {target_project_count[0][0] if target_project_count else '0'}"
        )

    target_projects = mysql_rows(
        "SELECT idFinanziamento, idIstitutoCapofila, codice, progetto, tipologia, descrizione, ambientiMinimi, partecipantiMinimi FROM Progetto ORDER BY id"
    )
    for extra_row in EXTRA_PROGETTI:
        if extra_row not in target_projects:
            errors.append("Progetto: missing configured extra project row")
            break

    source_laboratori = sqlite_rows(
        "SELECT id, idPlesso, idFinanziamento, laboratorio, aula FROM Laboratorio ORDER BY id"
    )
    target_laboratori = mysql_rows(
        """
        SELECT
            l.id,
            l.idPlesso,
            p.idFinanziamento,
            l.laboratorio,
            l.aula
        FROM Laboratorio l
        INNER JOIN Progetto p ON p.id = l.idProgetto
        ORDER BY l.id
        """
    )
    for row in source_laboratori:
        if row not in target_laboratori:
            errors.append("Laboratorio: missing legacy laboratory row in target")
            break

    expected_laboratory_count = len(source_laboratori) + len(EXTRA_LABORATORI)
    if len(target_laboratori) != expected_laboratory_count:
        errors.append(
            f"Laboratorio: expected {expected_laboratory_count} rows including extras, found {len(target_laboratori)}"
        )

    target_extra_laboratori = mysql_rows(
        "SELECT idPlesso, idProgetto, laboratorio, aula, descrizione FROM Laboratorio ORDER BY id"
    )
    for extra_row in EXTRA_LABORATORI:
        if extra_row not in target_extra_laboratori:
            errors.append("Laboratorio: missing configured extra laboratory row")
            break

    null_project_rows = mysql_rows("SELECT COUNT(*) FROM Laboratorio WHERE idProgetto IS NULL")
    if null_project_rows != [("0",)]:
        errors.append("Laboratorio: found rows without idProgetto")

    source_obiettivi = sqlite_rows("SELECT idTipoObiettivo, obiettivo FROM Obiettivo ORDER BY id")
    target_obiettivi = mysql_rows("SELECT idTipoObiettivo, obiettivo FROM Obiettivo ORDER BY id")
    for row in source_obiettivi:
        if row not in target_obiettivi:
            errors.append("Obiettivo: missing legacy objective row in target")
            break

    expected_obiettivo_count = len(source_obiettivi) + len(EXTRA_OBIETTIVI)
    if len(target_obiettivi) != expected_obiettivo_count:
        errors.append(
            f"Obiettivo: expected {expected_obiettivo_count} rows including extras, found {len(target_obiettivi)}"
        )

    for extra_row in EXTRA_OBIETTIVI:
        if extra_row not in target_obiettivi:
            errors.append("Obiettivo: missing configured extra objective row")
            break

    invalid_structural_rows = mysql_rows(
        "SELECT COUNT(*) FROM VerificaVincoliProgetto WHERE vincoliRispettati = 0 AND codice NOT IN ('PN21-27')"
    )
    if invalid_structural_rows != [("0",)]:
        errors.append("VerificaVincoliProgetto: found migrated projects that violate structural constraints")

    if errors:
        print("\n".join(errors))
        return 1

    print("Migrazione verificata senza perdita di informazione sui dati legacy in ambito.")
    print(f"Tabelle confrontate: {len(DIRECT_TABLES) + len(SPECIAL_QUERIES)}")
    print(f"Progetti derivati: {len(source_project_groups)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
