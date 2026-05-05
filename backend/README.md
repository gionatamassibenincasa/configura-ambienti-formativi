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
5. verifica la migrazione

## Endpoint

- `./api.php/status/ping`
- `./api.php/openapi`
- `./auth.php`
- `./projects.php`

## Account seed di esempio

| Ruolo | Username | Password |
| --- | --- | --- |
| amministratore | `massi` | `gionata` |
| docente | `bernacchia` | `andrea` |

## Import database

```bash
python database/export_legacy_seed.py
cat database/schema.sql database/seed.sql | mariadb -u gim -p my_gim
python database/verify_migration.py
```
