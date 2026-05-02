# Frontend Svelte

SPA Svelte che consuma il backend PHP esclusivamente tramite `fetch`.

## Comandi

```bash
npm install
npm run dev
npm run check
npm run build
```

## Configurazione API

Variabile usata dal frontend:

```env
VITE_API_BASE=/api.php
```

In sviluppo Vite esegue il proxy verso:

```text
http://127.0.0.1:8080
```

## Funzionalita'

- dashboard con riepiloghi economici
- CRUD per catalogo scolastico
- CRUD per progettazione dei laboratori
- CRUD per forniture, voci e costi
