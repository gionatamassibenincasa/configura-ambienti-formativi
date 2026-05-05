<?php

declare(strict_types=1);

$apiUrl = './api.php';
$openApiUrl = './api.php/openapi';
$statusUrl = './api.php/status';

?><!doctype html>
<html lang="it">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Ambienti laboratoriali - Backend PHP</title>
    <style>
        body {
            font-family: system-ui, sans-serif;
            margin: 0;
            background: #0f172a;
            color: #e2e8f0;
        }
        main {
            max-width: 900px;
            margin: 0 auto;
            padding: 3rem 1.25rem;
        }
        .card {
            background: #111827;
            border: 1px solid #334155;
            border-radius: 12px;
            padding: 1.25rem;
            margin-top: 1rem;
        }
        a {
            color: #7dd3fc;
        }
        code {
            background: #1e293b;
            padding: 0.15rem 0.4rem;
            border-radius: 6px;
        }
    </style>
</head>
<body>
<main>
    <h1>Backend PHP pronto</h1>
    <p>Questa directory espone il backend della nuova app tramite <strong>PHP-CRUD-API</strong>.</p>

    <div class="card">
        <h2>Endpoint principali</h2>
        <ul>
            <li><a href="<?= htmlspecialchars($apiUrl, ENT_QUOTES) ?>"><?= htmlspecialchars($apiUrl, ENT_QUOTES) ?></a></li>
            <li><a href="<?= htmlspecialchars($openApiUrl, ENT_QUOTES) ?>"><?= htmlspecialchars($openApiUrl, ENT_QUOTES) ?></a></li>
            <li><a href="<?= htmlspecialchars($statusUrl, ENT_QUOTES) ?>"><?= htmlspecialchars($statusUrl, ENT_QUOTES) ?></a></li>
        </ul>
        <p>Esempio CRUD: <code>/api.php/records/Progetto</code></p>
    </div>

    <div class="card">
        <h2>Avvio locale</h2>
        <p><code>php -S 127.0.0.1:8080 -t backend/public</code></p>
    </div>
</main>
</body>
</html>
