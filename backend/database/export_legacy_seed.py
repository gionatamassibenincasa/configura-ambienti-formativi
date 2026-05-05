#!/usr/bin/env python3

from __future__ import annotations

import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE_DB = ROOT / "LabCRUD" / "src" / "lib" / "server" / "db" / "labs.sqlite"
TARGET_FILE = ROOT / "backend" / "database" / "seed.sql"
ADMIN_PASSWORD_HASH = "$2y$12$c2IpSqJGZOJ/AxEI7fOLkusZA7qngo18b/qwEeTXUGrIpsElgzysy"
DOCENTE_PASSWORD_HASH = "$2y$12$gUlPBHKkkuYp5t9sQFbja.5Ewz6UDCWAxzjSaylxhpEV.hOmyTMZm"
EXTRA_FINANZIAMENTI = [
    (
        "PN",
        "PN Scuola e competenze 2021-2027 [...] risorse per l’acquisto di tablet, PC, dispositivi digitali, libri e sussidi didattici da fornire in comodato d’uso al personale della scuola",
        "https://www.mim.gov.it/documents/8099600/8783257/m_pi.AOOGABMI.REGISTRO-UFFICIALEU.0089057.03-06-2025.pdf/02b9f70d-7237-4bf5-59e9-cd63569fb061?version=1.0&t=1749458687505",
        0,
    ),
]
EXTRA_PROGETTI = [
    (
        3,
        1,
        "PN21-27",
        "Allestimento aula colloqui plesso Benincasa",
        "laboratorio",
        "Dispositivi per lo svolgimento dei colloqui online. Laboratorio rilocabile composto da SBC, monitor portatili, webcam, cuffie e microfoni. Una workstation agisce da server per la distribuzione del sistema operativo tramite Linux Terminal Server Project.",
        1,
        1,
    ),
]
EXTRA_LABORATORI = [
    (
        1,
        2,
        "Aula colloqui",
        "4.09",
        "Allestimento aula per colloqui online oppure per cedere in comodato d'uso ai docenti",
    ),
]
EXTRA_OBIETTIVI = [
    (
        1,
        "Sviluppare competenze digitali, collaborative e organizzative coerenti con il contesto laboratoriale del progetto.",
    ),
    (
        1,
        "Promuovere l'uso consapevole delle tecnologie per attivita' didattiche, progettuali e di documentazione.",
    ),
    (
        2,
        "Configurare e utilizzare dispositivi hardware, software e servizi di rete funzionali alle attivita' del laboratorio.",
    ),
    (
        2,
        "Realizzare elaborati, prototipi o prodotti digitali coerenti con il target formativo del modulo.",
    ),
    (
        2,
        "Analizzare problemi operativi del contesto scolastico o professionale e proporre soluzioni supportate da strumenti digitali.",
    ),
    (
        2,
        "Documentare fasi, risultati e criticita' delle attivita' svolte nel laboratorio con linguaggio tecnico appropriato.",
    ),
]

BASE_TABLES: list[tuple[str, list[str], str | None]] = [
    ("Ordinamento", ["id", "ordinamento"], "descrizione"),
    ("Corso", ["id", "idOrdinamento", "corso"], "descrizione"),
    ("Indirizzo", ["id", "idCorso", "indirizzo"], "descrizione"),
    ("Articolazione", ["id", "idIndirizzo", "articolazione"], None),
    ("Curriculum", ["id", "codice", "idIndirizzo", "idArticolazione", "curriculum"], None),
    ("Istituto", ["id", "istituto"], "comune"),
    ("Target", ["id", "idCurriculum", "idIstituto", "abbreviazione", "target"], None),
    ("Plesso", ["id", "idIstituto", "plesso"], "indirizzo"),
    ("Finanziamento", ["id", "tipo", "denominazione", "urlAvviso", "importo"], None),
    ("TipoObiettivo", ["id", "tipoObiettivo", "descrizione"], None),
    ("Obiettivo", ["id", "idTipoObiettivo", "obiettivo"], None),
    ("Modulo", ["id", "idLaboratorio", "idTarget", "modulo", "descrizione", "discipline", "professione"], None),
    ("Fornitore", ["id", "fornitore", "PIVA", "indirizzo", "telefono"], None),
    ("TipoFornitura", ["id", "tipoFornitura"], None),
    ("Fornitura", ["id", "idTipoFornitura", "idFornitore", "fornitura", "prezzo", "codiceMepa", "link", "SKU"], "note"),
    ("Voce", ["id", "lettera", "voce", "descrizione", "minimale", "massimale"], None),
    ("Costo", ["id", "idVoce", "idLaboratorio", "idFornitura", "descrizione", "quantita"], None),
]


def sql_value(value):
    if value is None:
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("\\", "\\\\").replace("'", "''") + "'"


def emit_insert(table: str, columns: list[str], rows: list[tuple]) -> str:
    if not rows:
        return f"-- {table}: nessun record da importare\n\n"
    values = ",\n".join(
        "    (" + ", ".join(sql_value(value) for value in row) + ")" for row in rows
    )
    return f"INSERT INTO {table} ({', '.join(columns)}) VALUES\n{values};\n\n"


def fetch_rows(cursor: sqlite3.Cursor, table: str, source_columns: list[str], extra_column: str | None) -> tuple[list[str], list[tuple]]:
    rows = [
        tuple(row[column] for column in source_columns)
        for row in cursor.execute(f"SELECT {', '.join(source_columns)} FROM {table} ORDER BY id")
    ]
    if extra_column:
        return source_columns + [extra_column], [row + (None,) for row in rows]
    return source_columns, rows


def build_projects(cursor: sqlite3.Cursor) -> tuple[list[tuple], dict[tuple[int, int], int]]:
    project_rows: list[tuple] = []
    project_map: dict[tuple[int, int], int] = {}

    query = """
        SELECT
            l.idFinanziamento,
            p.idIstituto,
            f.tipo,
            f.denominazione,
            i.istituto
        FROM Laboratorio l
        INNER JOIN Plesso p ON p.id = l.idPlesso
        INNER JOIN Finanziamento f ON f.id = l.idFinanziamento
        INNER JOIN Istituto i ON i.id = p.idIstituto
        GROUP BY l.idFinanziamento, p.idIstituto, f.tipo, f.denominazione, i.istituto
        ORDER BY MIN(l.id)
    """

    for project_id, row in enumerate(cursor.execute(query), start=1):
        financing_id = int(row["idFinanziamento"])
        institute_id = int(row["idIstituto"])
        project_type = "campus" if str(row["tipo"]).upper() == "PNRR" else "laboratorio"
        project_rows.append(
            (
                project_id,
                financing_id,
                institute_id,
                f"PRG-{financing_id:02d}-{institute_id:02d}",
                f"{row['denominazione']} - {row['istituto']}",
                project_type,
                None,
                4 if project_type == "campus" else 1,
                2 if project_type == "campus" else 1,
            )
        )
        project_map[(financing_id, institute_id)] = project_id

    next_id = max((int(row[0]) for row in project_rows), default=0) + 1
    for (
        financing_id,
        institute_id,
        codice,
        progetto,
        tipologia,
        descrizione,
        ambienti_minimi,
        partecipanti_minimi,
    ) in EXTRA_PROGETTI:
        project_rows.append(
            (
                next_id,
                financing_id,
                institute_id,
                codice,
                progetto,
                tipologia,
                descrizione,
                ambienti_minimi,
                partecipanti_minimi,
            )
        )
        next_id += 1

    return project_rows, project_map


def build_laboratori(cursor: sqlite3.Cursor, project_map: dict[tuple[int, int], int]) -> list[tuple]:
    rows: list[tuple] = []
    query = """
        SELECT
            l.id,
            l.idPlesso,
            p.idIstituto,
            l.idFinanziamento,
            l.laboratorio,
            l.aula
        FROM Laboratorio l
        INNER JOIN Plesso p ON p.id = l.idPlesso
        ORDER BY l.id
    """

    for row in cursor.execute(query):
        project_id = project_map[(int(row["idFinanziamento"]), int(row["idIstituto"]))]
        rows.append(
            (
                row["id"],
                row["idPlesso"],
                project_id,
                row["laboratorio"],
                row["aula"],
                None,
            )
        )

    next_id = max((int(row[0]) for row in rows), default=0) + 1
    for id_plesso, id_progetto, laboratorio, aula, descrizione in EXTRA_LABORATORI:
        rows.append(
            (
                next_id,
                id_plesso,
                id_progetto,
                laboratorio,
                aula,
                descrizione,
            )
        )
        next_id += 1

    return rows


def build_auth_seed() -> tuple[list[tuple], list[tuple], list[tuple]]:
    role_rows = [
        (1, "amministratore", "Utente che puo' creare nuovi progetti e amministrare l'applicazione."),
        (2, "docente", "Docente progettista che opera sui progetti e sui laboratori di pertinenza."),
    ]
    user_rows = [
        (1, "massi", ADMIN_PASSWORD_HASH, "Massi", 1),
        (2, "bernacchia", DOCENTE_PASSWORD_HASH, "Bernacchia", 1),
    ]
    role_user_rows = [
        (1, 1, 1),
        (2, 2, 2),
    ]
    return role_rows, user_rows, role_user_rows


def build_finanziamenti(cursor: sqlite3.Cursor) -> list[tuple]:
    rows = [
        tuple(row[column] for column in ["id", "tipo", "denominazione", "urlAvviso", "importo"])
        for row in cursor.execute("SELECT id, tipo, denominazione, urlAvviso, importo FROM Finanziamento ORDER BY id")
    ]

    next_id = max((int(row[0]) for row in rows), default=0) + 1
    for tipo, denominazione, url_avviso, importo in EXTRA_FINANZIAMENTI:
        rows.append((next_id, tipo, denominazione, url_avviso, importo))
        next_id += 1

    return rows


def build_obiettivi(cursor: sqlite3.Cursor) -> list[tuple]:
    rows = [
        tuple(row[column] for column in ["id", "idTipoObiettivo", "obiettivo"])
        for row in cursor.execute("SELECT id, idTipoObiettivo, obiettivo FROM Obiettivo ORDER BY id")
    ]

    next_id = max((int(row[0]) for row in rows), default=0) + 1
    for id_tipo_obiettivo, obiettivo in EXTRA_OBIETTIVI:
        rows.append((next_id, id_tipo_obiettivo, obiettivo))
        next_id += 1

    return rows


def main() -> None:
    connection = sqlite3.connect(str(SOURCE_DB))
    connection.row_factory = sqlite3.Row
    cursor = connection.cursor()

    finanziamenti_rows = build_finanziamenti(cursor)
    project_rows, project_map = build_projects(cursor)
    laboratori_rows = build_laboratori(cursor, project_map)
    obiettivi_rows = build_obiettivi(cursor)
    role_rows, user_rows, role_user_rows = build_auth_seed()

    chunks: list[str] = [
        "USE my_gim;\n\n",
        "-- Seed generato automaticamente da LabCRUD/src/lib/server/db/labs.sqlite\n\n",
    ]

    for table, source_columns, extra_column in BASE_TABLES[:8]:
        target_columns, rows = fetch_rows(cursor, table, source_columns, extra_column)
        chunks.append(emit_insert(table, target_columns, rows))

    chunks.append(
        emit_insert(
            "Finanziamento",
            ["id", "tipo", "denominazione", "urlAvviso", "importo"],
            finanziamenti_rows,
        )
    )

    chunks.append(
        emit_insert(
            "Utente",
            ["id", "username", "passwordHash", "nome", "attivo"],
            user_rows,
        )
    )
    chunks.append(
        emit_insert(
            "Ruolo",
            ["id", "ruolo", "descrizione"],
            role_rows,
        )
    )
    chunks.append(
        emit_insert(
            "RuoloUtente",
            ["id", "idUtente", "idRuolo"],
            role_user_rows,
        )
    )
    chunks.append(
        emit_insert(
            "Progetto",
            [
                "id",
                "idFinanziamento",
                "idIstitutoCapofila",
                "codice",
                "progetto",
                "tipologia",
                "descrizione",
                "ambientiMinimi",
                "partecipantiMinimi",
            ],
            project_rows,
        )
    )
    chunks.append(
        emit_insert(
            "TipoAggregazione",
            ["id", "tipoAggregazione", "descrizione"],
            [
                (1, "partenariato", "Collaborazione formale tra capofila e altri istituti aderenti al campus."),
                (2, "rete", "Rete organizzata di istituti partecipanti al campus."),
            ],
        )
    )
    chunks.append(emit_insert("Campus", ["id", "idProgetto", "idTipoAggregazione", "campus", "descrizione"], []))
    chunks.append(emit_insert("CampusPartecipante", ["id", "idCampus", "idIstituto", "ruolo"], []))
    chunks.append(
        emit_insert(
            "Laboratorio",
            ["id", "idPlesso", "idProgetto", "laboratorio", "aula", "descrizione"],
            laboratori_rows,
        )
    )

    for table, source_columns, extra_column in BASE_TABLES[9:10]:
        target_columns, rows = fetch_rows(cursor, table, source_columns, extra_column)
        chunks.append(emit_insert(table, target_columns, rows))
    chunks.append(
        emit_insert(
            "Obiettivo",
            ["id", "idTipoObiettivo", "obiettivo"],
            obiettivi_rows,
        )
    )
    for table, source_columns, extra_column in BASE_TABLES[11:]:
        target_columns, rows = fetch_rows(cursor, table, source_columns, extra_column)
        chunks.append(emit_insert(table, target_columns, rows))

    obiettivi_modulo_rows = [
        (index, row["idModulo"], row["idObiettivo"], 1)
        for index, row in enumerate(
            cursor.execute("SELECT idModulo, idObiettivo FROM ObiettiviModulo ORDER BY idModulo, idObiettivo"),
            start=1,
        )
    ]
    chunks.append(
        emit_insert(
            "ObiettiviModulo",
            ["id", "idModulo", "idObiettivo", "priorita"],
            obiettivi_modulo_rows,
        )
    )

    TARGET_FILE.write_text("".join(chunks), encoding="utf-8")


if __name__ == "__main__":
    main()
