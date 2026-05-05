<?php

declare(strict_types=1);

require __DIR__ . '/_app.php';

app_send_headers();
app_handle_options();

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$user = $method === 'POST' ? app_require_admin() : app_require_user();
unset($user);

function project_summary_select(): string
{
    return <<<SQL
        SELECT
            idProgetto,
            idIstitutoCapofila,
            codice,
            progetto,
            tipologia,
            istitutoCapofila,
            tipoFinanziamento,
            finanziamento,
            idCampus,
            campus,
            tipoAggregazione,
            ambientiMinimi,
            partecipantiMinimi,
            ambienti,
            moduli,
            partecipantiTotali,
            budgetAllocato,
            vincoloCampusRispettato,
            vincoloAmbientiRispettato,
            vincoloPartecipantiRispettato,
            vincoliRispettati
        FROM VerificaVincoliProgetto
    SQL;
}

if ($method === 'GET') {
    if (isset($_GET['lookups'])) {
        $pdo = app_pdo();
        $finanziamenti = $pdo->query('SELECT id, denominazione AS label FROM Finanziamento ORDER BY denominazione')->fetchAll();
        $istituti = $pdo->query('SELECT id, istituto AS label FROM Istituto ORDER BY istituto')->fetchAll();
        $plessi = $pdo->query('SELECT id, plesso AS label FROM Plesso ORDER BY plesso')->fetchAll();
        $target = $pdo->query('SELECT id, abbreviazione AS label FROM Target ORDER BY abbreviazione')->fetchAll();
        $curriculum = $pdo->query('SELECT id, curriculum AS label FROM Curriculum ORDER BY curriculum')->fetchAll();
        app_json([
            'finanziamenti' => $finanziamenti,
            'istituti' => $istituti,
            'plessi' => $plessi,
            'target' => $target,
            'curriculum' => $curriculum,
        ]);
    }

    $pdo = app_pdo();

    if (isset($_GET['id'])) {
        $projectId = (int) $_GET['id'];
        if ($projectId <= 0) {
            app_fail(400, 'Identificativo progetto non valido.');
        }

        $statement = $pdo->prepare(project_summary_select() . ' WHERE idProgetto = :id');
        $statement->execute(['id' => $projectId]);
        $project = $statement->fetch();
        if ($project === false) {
            app_fail(404, 'Progetto non trovato.');
        }

        $laboratoriStatement = $pdo->prepare(
            <<<SQL
                SELECT
                    l.id,
                    l.idPlesso,
                    l.laboratorio,
                    l.aula,
                    l.descrizione,
                    p.plesso,
                    p.indirizzo,
                    COALESCE(ct.costoTotale, 0) AS costoTotale
                FROM Laboratorio l
                INNER JOIN Plesso p ON p.id = l.idPlesso
                LEFT JOIN CostoTotalePerLaboratorio ct ON ct.idLaboratorio = l.id
                WHERE l.idProgetto = :id
                ORDER BY l.laboratorio
            SQL
        );
        $laboratoriStatement->execute(['id' => $projectId]);

        $moduliStatement = $pdo->prepare(
            <<<SQL
                SELECT
                    m.id,
                    m.idLaboratorio,
                    m.idTarget,
                    m.modulo,
                    m.descrizione,
                    m.discipline,
                    m.professione,
                    l.laboratorio,
                    t.abbreviazione AS target
                FROM Modulo m
                INNER JOIN Laboratorio l ON l.id = m.idLaboratorio
                INNER JOIN Target t ON t.id = m.idTarget
                WHERE l.idProgetto = :id
                ORDER BY l.laboratorio, m.modulo
            SQL
        );
        $moduliStatement->execute(['id' => $projectId]);

        app_json([
            'project' => $project,
            'laboratori' => $laboratoriStatement->fetchAll(),
            'moduli' => $moduliStatement->fetchAll(),
        ]);
    }

    $projects = $pdo->query(project_summary_select() . ' ORDER BY progetto')->fetchAll();
    app_json(['records' => $projects]);
}

if ($method === 'POST') {
    $input = app_input();

    $idFinanziamento = (int) ($input['idFinanziamento'] ?? 0);
    $nuovoFinanziamento = isset($input['nuovoFinanziamento']) && is_array($input['nuovoFinanziamento']) ? $input['nuovoFinanziamento'] : null;
    $idIstitutoCapofila = (int) ($input['idIstitutoCapofila'] ?? 0);
    $codice = trim((string) ($input['codice'] ?? ''));
    $progetto = trim((string) ($input['progetto'] ?? ''));
    $tipologia = trim((string) ($input['tipologia'] ?? 'laboratorio'));
    $descrizione = trim((string) ($input['descrizione'] ?? ''));
    $ambientiMinimi = (int) ($input['ambientiMinimi'] ?? 1);
    $partecipantiMinimi = (int) ($input['partecipantiMinimi'] ?? 1);

    if ($idIstitutoCapofila <= 0 || $codice === '' || $progetto === '') {
        app_fail(400, 'Compila tutti i campi obbligatori del progetto.');
    }
    if ($idFinanziamento <= 0 && $nuovoFinanziamento === null) {
        app_fail(400, 'Seleziona un finanziamento esistente oppure creane uno nuovo.');
    }
    if (!in_array($tipologia, ['laboratorio', 'campus'], true)) {
        app_fail(400, 'Tipologia progetto non valida.');
    }
    if ($ambientiMinimi < 1 || $partecipantiMinimi < 1) {
        app_fail(400, 'I valori minimi devono essere maggiori o uguali a 1.');
    }

    $pdo = app_pdo();
    $projectId = 0;

    $exists = $pdo->prepare('SELECT COUNT(*) FROM Progetto WHERE codice = :codice');
    $exists->execute(['codice' => $codice]);
    if ((int) $exists->fetchColumn() > 0) {
        app_fail(409, 'Esiste gia\' un progetto con questo codice.');
    }

    $pdo->beginTransaction();

    try {
        if ($idFinanziamento <= 0 && $nuovoFinanziamento !== null) {
            $tipo = trim((string) ($nuovoFinanziamento['tipo'] ?? ''));
            $denominazione = trim((string) ($nuovoFinanziamento['denominazione'] ?? ''));
            $urlAvviso = trim((string) ($nuovoFinanziamento['urlAvviso'] ?? ''));
            $importo = (float) ($nuovoFinanziamento['importo'] ?? 0);

            if ($tipo === '' || $denominazione === '') {
                app_fail(400, 'Compila tipo e denominazione del nuovo finanziamento.');
            }
            if ($importo < 0) {
                app_fail(400, 'L\'importo del finanziamento non puo\' essere negativo.');
            }

            $insertFinanziamento = $pdo->prepare(
                <<<SQL
                    INSERT INTO Finanziamento (tipo, denominazione, urlAvviso, importo)
                    VALUES (:tipo, :denominazione, :urlAvviso, :importo)
                SQL
            );
            $insertFinanziamento->execute([
                'tipo' => $tipo,
                'denominazione' => $denominazione,
                'urlAvviso' => $urlAvviso === '' ? null : $urlAvviso,
                'importo' => $importo,
            ]);
            $idFinanziamento = (int) $pdo->lastInsertId();
        }

        $statement = $pdo->prepare(
            <<<SQL
                INSERT INTO Progetto (
                    idFinanziamento,
                    idIstitutoCapofila,
                    codice,
                    progetto,
                    tipologia,
                    descrizione,
                    ambientiMinimi,
                    partecipantiMinimi
                ) VALUES (
                    :idFinanziamento,
                    :idIstitutoCapofila,
                    :codice,
                    :progetto,
                    :tipologia,
                    :descrizione,
                    :ambientiMinimi,
                    :partecipantiMinimi
                )
            SQL
        );
        $statement->execute([
            'idFinanziamento' => $idFinanziamento,
            'idIstitutoCapofila' => $idIstitutoCapofila,
            'codice' => $codice,
            'progetto' => $progetto,
            'tipologia' => $tipologia,
            'descrizione' => $descrizione === '' ? null : $descrizione,
            'ambientiMinimi' => $ambientiMinimi,
            'partecipantiMinimi' => $partecipantiMinimi,
        ]);
        $projectId = (int) $pdo->lastInsertId();
        $pdo->commit();
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }

    $created = $pdo->prepare(project_summary_select() . ' WHERE idProgetto = :id');
    $created->execute(['id' => $projectId]);

    app_json([
        'project' => $created->fetch(),
    ], 201);
}

app_fail(405, 'Metodo non supportato.');
