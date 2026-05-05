<?php

declare(strict_types=1);

function app_config(): array
{
    static $config = null;
    if ($config === null) {
        $config = require dirname(__DIR__) . '/config/config.php';
    }
    return $config;
}

function app_send_headers(): void
{
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    if ($origin !== '') {
        header('Access-Control-Allow-Origin: ' . $origin);
        header('Access-Control-Allow-Credentials: true');
        header('Vary: Origin');
    }
    header('Access-Control-Allow-Headers: Content-Type');
    header('Access-Control-Allow-Methods: GET,POST,DELETE,OPTIONS');
}

function app_handle_options(): void
{
    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}

function app_start_session(): void
{
    if (session_status() === PHP_SESSION_NONE) {
        session_name('ambienti_formativi_session');
        session_set_cookie_params([
            'httponly' => true,
            'samesite' => 'Lax',
            'path' => '/',
        ]);
        session_start();
    }
}

function app_json(array $payload, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function app_fail(int $status, string $message): never
{
    app_json(['error' => $message], $status);
}

function app_input(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return [];
    }
    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        app_fail(400, 'Payload JSON non valido.');
    }
    return $decoded;
}

function app_pdo(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $config = app_config();
    $dsn = sprintf(
        '%s:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        $config['driver'],
        $config['address'],
        $config['port'],
        $config['database']
    );

    $pdo = new PDO(
        $dsn,
        $config['username'],
        $config['password'],
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );

    if (!empty($config['command'])) {
        $pdo->exec($config['command']);
    }

    return $pdo;
}

function app_fetch_user(string $field, string|int $value): ?array
{
    $sql = <<<SQL
        SELECT
            u.id,
            u.username,
            u.passwordHash,
            u.nome,
            u.attivo,
            GROUP_CONCAT(r.ruolo ORDER BY r.ruolo SEPARATOR ',') AS ruoli
        FROM Utente u
        LEFT JOIN RuoloUtente ru ON ru.idUtente = u.id
        LEFT JOIN Ruolo r ON r.id = ru.idRuolo
        WHERE u.%s = :value
        GROUP BY u.id, u.username, u.passwordHash, u.nome, u.attivo
        LIMIT 1
    SQL;

    $allowedFields = ['id', 'username'];
    if (!in_array($field, $allowedFields, true)) {
        app_fail(500, 'Campo utente non supportato.');
    }

    $statement = app_pdo()->prepare(sprintf($sql, $field));
    $statement->execute(['value' => $value]);
    $row = $statement->fetch();
    return $row === false ? null : $row;
}

function app_public_user(array $row): array
{
    $roles = [];
    if (!empty($row['ruoli'])) {
        $roles = array_values(array_filter(explode(',', (string) $row['ruoli'])));
    }

    return [
        'id' => (int) $row['id'],
        'username' => (string) $row['username'],
        'nome' => (string) $row['nome'],
        'roles' => $roles,
        'isAdmin' => in_array('amministratore', $roles, true),
    ];
}

function app_current_user(): ?array
{
    app_start_session();
    $userId = $_SESSION['user_id'] ?? null;
    if (!is_int($userId) && !ctype_digit((string) $userId)) {
        return null;
    }

    $row = app_fetch_user('id', (int) $userId);
    if ($row === null || (int) $row['attivo'] !== 1) {
        unset($_SESSION['user_id']);
        return null;
    }

    return app_public_user($row);
}

function app_require_user(): array
{
    $user = app_current_user();
    if ($user === null) {
        app_fail(401, 'Autenticazione richiesta.');
    }
    return $user;
}

function app_require_admin(): array
{
    $user = app_require_user();
    if (!in_array('amministratore', $user['roles'], true)) {
        app_fail(403, 'Operazione riservata agli amministratori.');
    }
    return $user;
}
