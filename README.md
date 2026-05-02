# configura-ambienti-formativi

Web app per la progettazione di ambienti laboratoriali con:

- backend PHP basato su PHP-CRUD-API
- frontend Svelte SPA
- database MySQL 8.0

La cartella `LabCRUD/` resta un riferimento legacy per dominio e dati. L'applicazione corrente e' nelle directory:

- `backend/`
- `frontend/`

## Struttura

### `backend/`

- `public/api.php`: endpoint REST
- `public/index.php`: pagina backend di servizio
- `config/config.php`: configurazione runtime
- `database/schema.sql`: schema MySQL
- `database/seed.sql`: dati iniziali
- `.env.example`: esempio configurazione locale

### `frontend/`

- SPA Svelte + TypeScript + Vite
- build statico in `frontend/dist`
- chiamate API verso `/api.php`

## Configurazione database

Database target:

- host: `localhost`
- database: `my_gim`
- utente: `gim`

Le credenziali locali vanno salvate in `backend/.env`, che deve restare escluso dal versionamento.

Esempio:

```env
APP_DB_DRIVER=mysql
APP_DB_HOST=localhost
APP_DB_PORT=3306
APP_DB_NAME=my_gim
APP_DB_USER=gim
APP_DB_PASSWORD=
APP_DEBUG=false
```

## Preparazione dati

1. Copia `backend/.env.example` in `backend/.env`.
2. Imposta le credenziali MySQL 8.0.
3. Rigenera il seed legacy.
4. Importa schema e dati.

```bash
python backend/database/export_legacy_seed.py
cat backend/database/schema.sql backend/database/seed.sql | mysql -u gim -p my_gim
```

## Avvio su host Apache2 + PHP

Il modo piu' semplice e' pubblicare tutto da `backend/public`, lasciando `api.php` e copiando dentro anche il frontend buildato.

### 1. Requisiti host

- Apache2
- PHP 8.2+ con estensione `pdo_mysql`
- MySQL 8.0
- Node.js solo per generare la build frontend

### 2. Build del frontend

```bash
cd frontend
npm install
npm run build
```

### 3. Pubblica il frontend dentro `backend/public`

Dal root del repository:

```bash
cp -r frontend/dist/* backend/public/
```

Dopo la copia:

- `backend/public/index.html` serve la SPA
- `backend/public/api.php` continua a servire le API PHP

### 4. Configura Apache

Esempio VirtualHost:

```apache
<VirtualHost *:80>
    ServerName ambienti-formativi.local
    DocumentRoot /var/www/configura-ambienti-formativi/backend/public

    <Directory /var/www/configura-ambienti-formativi/backend/public>
        AllowOverride All
        Require all granted
        DirectoryIndex index.html index.php
        AcceptPathInfo On
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/ambienti-formativi-error.log
    CustomLog ${APACHE_LOG_DIR}/ambienti-formativi-access.log combined
</VirtualHost>
```

Se usi PHP-FPM, abilita anche il relativo handler PHP gia' previsto dal tuo host.

### 5. Abilita il sito e ricarica Apache

```bash
sudo a2ensite ambienti-formativi.conf
sudo systemctl reload apache2
```

### 6. Verifica endpoint e frontend

URL utili:

- `http://ambienti-formativi.local/`
- `http://ambienti-formativi.local/api.php/status/ping`
- `http://ambienti-formativi.local/api.php/openapi`
- `http://ambienti-formativi.local/api.php/records/Laboratorio`

## Avvio locale senza Apache

### Backend

```bash
php -S 127.0.0.1:8080 -t backend/public
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

In sviluppo, Vite fa proxy verso `http://127.0.0.1:8080`.

## TODO

- riprogettare i moduli con una navigazione lineare guidata, ad esempio: `Finanziamento > Istituto > Laboratorio > Forniture`
- riprogettare le viste con aggregazioni piu' orientate al dominio, ad esempio una vista del singolo laboratorio con tutte le forniture collegate
