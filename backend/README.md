# Backend PHP

Backend REST basato su **PHP-CRUD-API**.

## Avvio

```bash
php -S 127.0.0.1:8080 -t public
```

## Configurazione

1. copia `.env.example` in `.env`
2. imposta le credenziali MySQL/MariaDB
3. rigenera il seed legacy
4. importa schema e seed

## Endpoint

- `./api.php/status/ping`
- `./api.php/openapi`
- `./api.php/records/Laboratorio`

## Import database

```bash
python database/export_legacy_seed.py
cat database/schema.sql database/seed.sql | mariadb -u gim -p my_gim
```
