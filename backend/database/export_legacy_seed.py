#!/usr/bin/env python3

from __future__ import annotations

import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE_DB = ROOT / "LabCRUD" / "src" / "lib" / "server" / "db" / "labs.sqlite"
TARGET_FILE = ROOT / "backend" / "database" / "seed.sql"


TABLES: list[tuple[str, list[str], str | None]] = [
    ("Ordinamento", ["id", "ordinamento"], "descrizione"),
    ("Corso", ["id", "idOrdinamento", "corso"], "descrizione"),
    ("Indirizzo", ["id", "idCorso", "indirizzo"], "descrizione"),
    ("Articolazione", ["id", "idIndirizzo", "articolazione"], None),
    ("Curriculum", ["id", "codice", "idIndirizzo", "idArticolazione", "curriculum"], None),
    ("Istituto", ["id", "istituto"], "comune"),
    ("Target", ["id", "idCurriculum", "idIstituto", "abbreviazione", "target"], None),
    ("Plesso", ["id", "idIstituto", "plesso"], "indirizzo"),
    ("Finanziamento", ["id", "tipo", "denominazione", "urlAvviso", "importo"], None),
    ("Laboratorio", ["id", "idPlesso", "idFinanziamento", "laboratorio", "aula"], "descrizione"),
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
        return f"-- {table}: nessun record da importare\n"
    values = ",\n".join(
        "    (" + ", ".join(sql_value(value) for value in row) + ")" for row in rows
    )
    return f"INSERT INTO {table} ({', '.join(columns)}) VALUES\n{values};\n\n"


def main() -> None:
    connection = sqlite3.connect(str(SOURCE_DB))
    connection.row_factory = sqlite3.Row
    cursor = connection.cursor()

    chunks: list[str] = [
        "USE my_gim;\n\n",
        "-- Seed generato automaticamente da LabCRUD/src/lib/server/db/labs.sqlite\n\n",
    ]

    for table, source_columns, extra_column in TABLES:
        rows = [tuple(row[column] for column in source_columns) for row in cursor.execute(
            f"SELECT {', '.join(source_columns)} FROM {table} ORDER BY id"
        )]
        if extra_column:
            rows = [row + (None,) for row in rows]
            target_columns = source_columns + [extra_column]
        else:
            target_columns = source_columns
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
