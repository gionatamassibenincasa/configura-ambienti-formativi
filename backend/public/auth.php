<?php

declare(strict_types=1);

require __DIR__ . '/_app.php';

app_send_headers();
app_handle_options();
app_start_session();

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    $user = app_current_user();
    app_json([
        'authenticated' => $user !== null,
        'user' => $user,
    ]);
}

if ($method === 'POST') {
    $input = app_input();
    $username = trim((string) ($input['username'] ?? ''));
    $password = (string) ($input['password'] ?? '');

    if ($username === '' || $password === '') {
        app_fail(400, 'Username e password sono obbligatori.');
    }

    $row = app_fetch_user('username', $username);
    if ($row === null || (int) $row['attivo'] !== 1 || !password_verify($password, (string) $row['passwordHash'])) {
        app_fail(401, 'Credenziali non valide.');
    }

    session_regenerate_id(true);
    $_SESSION['user_id'] = (int) $row['id'];

    app_json([
        'authenticated' => true,
        'user' => app_public_user($row),
    ]);
}

if ($method === 'DELETE') {
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 3600, $params['path'], $params['domain'] ?? '', (bool) ($params['secure'] ?? false), (bool) ($params['httponly'] ?? true));
    }
    session_destroy();
    app_json([
        'authenticated' => false,
        'user' => null,
    ]);
}

app_fail(405, 'Metodo non supportato.');
