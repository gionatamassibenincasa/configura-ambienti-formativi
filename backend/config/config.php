<?php

declare(strict_types=1);

$envPath = dirname(__DIR__) . '/.env';
if (is_file($envPath)) {
    $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
    foreach ($lines as $line) {
        $trimmed = trim($line);
        if ($trimmed === '' || str_starts_with($trimmed, '#') || !str_contains($trimmed, '=')) {
            continue;
        }
        [$name, $value] = explode('=', $trimmed, 2);
        $name = trim($name);
        $value = trim($value);
        if ($name === '' || getenv($name) !== false) {
            continue;
        }
        putenv(sprintf('%s=%s', $name, $value));
        $_ENV[$name] = $value;
        $_SERVER[$name] = $value;
    }
}

$env = static function (string $name, ?string $default = null): ?string {
    $value = getenv($name);
    if ($value === false || $value === '') {
        return $default;
    }
    return $value;
};

return [
    'driver' => $env('APP_DB_DRIVER', 'mysql'),
    'address' => $env('APP_DB_HOST', 'localhost'),
    'port' => $env('APP_DB_PORT', '3306'),
    'username' => $env('APP_DB_USER', 'gim'),
    'password' => $env('APP_DB_PASSWORD', ''),
    'database' => $env('APP_DB_NAME', 'my_gim'),
    'command' => 'SET NAMES utf8mb4',
    'tables' => implode(',', [
        'Ordinamento',
        'Corso',
        'Indirizzo',
        'Articolazione',
        'Curriculum',
        'Istituto',
        'Target',
        'Plesso',
        'Finanziamento',
        'Laboratorio',
        'TipoObiettivo',
        'Obiettivo',
        'Modulo',
        'ObiettiviModulo',
        'Fornitore',
        'TipoFornitura',
        'Fornitura',
        'Voce',
        'Costo',
        'CostoTotalePerLaboratorio',
        'CostoPerVoce',
        'DettaglioForniture',
    ]),
    'middlewares' => 'cors',
    'controllers' => 'records,openapi,status',
    'openApiBase' => json_encode([
        'info' => [
            'title' => 'Ambienti laboratoriali API',
            'version' => '1.0.0',
            'description' => 'API CRUD per progettazione laboratori e piano acquisti',
        ],
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
    'debug' => filter_var($env('APP_DEBUG', 'false'), FILTER_VALIDATE_BOOL),
];
