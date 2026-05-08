<?php
declare(strict_types=1);

// ── 1. Cargar .env ────────────────────────────────────────────────────────────
$envFile = __DIR__ . '/.env';
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#')) continue;
        [$key, $val] = explode('=', $line, 2) + [1 => ''];
        putenv(trim($key) . '=' . trim($val));
    }
}

// ── 2. CORS ───────────────────────────────────────────────────────────────────
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// ── 3. Autoload simple ────────────────────────────────────────────────────────
spl_autoload_register(function (string $class): void {
    $dirs = [
        __DIR__ . '/helpers/',
        __DIR__ . '/config/',
        __DIR__ . '/controllers/',
    ];
    foreach ($dirs as $dir) {
        $file = $dir . $class . '.php';
        if (file_exists($file)) {
            require_once $file;
            return;
        }
    }
});

require_once __DIR__ . '/helpers/Response.php';
require_once __DIR__ . '/helpers/Auth.php';
require_once __DIR__ . '/config/Database.php';

// ── 4. Autenticación ──────────────────────────────────────────────────────────
Auth::verify();

// ── 5. Parsear método y URI ───────────────────────────────────────────────────
$method = $_SERVER['REQUEST_METHOD'];
$uri    = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri    = '/' . trim($uri, '/');

// Quitar prefijo si el proyecto no está en la raíz del servidor
// $base = '/temp-api';
// $uri  = str_starts_with($uri, $base) ? substr($uri, strlen($base)) : $uri;

$db = Database::getConnection();

// ── 6. Helper de rutas ────────────────────────────────────────────────────────
/**
 * Compara $uri contra un patrón con segmentos /:param y rellena $params.
 * Ejemplo: matchRoute('/trips/:id/gps-points', '/trips/abc/gps-points', $p)
 */
function matchRoute(string $pattern, string $uri, array &$params): bool {
    $regex = preg_replace('/\/:([^\/]+)/', '/(?P<$1>[^/]+)', $pattern);
    $regex = '#^' . $regex . '$#';
    if (preg_match($regex, $uri, $m)) {
        foreach ($m as $k => $v) {
            if (is_string($k)) $params[$k] = $v;
        }
        return true;
    }
    return false;
}

$p = []; // params del path

// ── 7. Router ─────────────────────────────────────────────────────────────────

// Drivers ─────────────────────────────────────────────────────────────────────
if ($method === 'GET' && matchRoute('/drivers/:id', $uri, $p)) {
    (new DriversController($db))->getById($p['id']);
}

// Refresh Tokens ──────────────────────────────────────────────────────────────
elseif ($method === 'POST' && $uri === '/refresh-tokens') {
    (new RefreshTokensController($db))->create();
}
// Más específico primero: /all/:driverId antes que /:id
elseif ($method === 'DELETE' && matchRoute('/refresh-tokens/all/:driverId', $uri, $p)) {
    (new RefreshTokensController($db))->deleteAllByDriver($p['driverId']);
}
// GET /:token/with-driver antes que /:id
elseif ($method === 'GET' && matchRoute('/refresh-tokens/:token/with-driver', $uri, $p)) {
    (new RefreshTokensController($db))->getWithDriver($p['token']);
}
elseif ($method === 'DELETE' && matchRoute('/refresh-tokens/:id', $uri, $p)) {
    (new RefreshTokensController($db))->deleteById($p['id']);
}
elseif ($method === 'DELETE' && $uri === '/refresh-tokens') {
    (new RefreshTokensController($db))->deleteByDriverAndToken();
}

// Routes ──────────────────────────────────────────────────────────────────────
elseif ($method === 'GET' && $uri === '/routes') {
    (new RoutesController($db))->getTodayRoutes();
}
// PATCH /routes/:id/status más específico que /routes/:id
elseif ($method === 'PATCH' && matchRoute('/routes/:id/status', $uri, $p)) {
    (new RoutesController($db))->updateStatus($p['id']);
}
elseif ($method === 'GET' && matchRoute('/routes/:id', $uri, $p)) {
    (new RoutesController($db))->getById($p['id']);
}
elseif ($method === 'PATCH' && matchRoute('/routes/:id', $uri, $p)) {
    (new RoutesController($db))->update($p['id']);
}

// Trips ───────────────────────────────────────────────────────────────────────
elseif ($method === 'POST' && $uri === '/trips') {
    (new TripsController($db))->create();
}
elseif ($method === 'GET' && $uri === '/trips') {
    (new TripsController($db))->getHistory();
}
// GET /trips/:id/gps-points más específico que /trips/:id
elseif ($method === 'GET' && matchRoute('/trips/:id/gps-points', $uri, $p)) {
    (new TripsController($db))->getGpsPoints($p['id']);
}
elseif ($method === 'GET' && matchRoute('/trips/:id', $uri, $p)) {
    (new TripsController($db))->getById($p['id']);
}
elseif ($method === 'PATCH' && matchRoute('/trips/:id', $uri, $p)) {
    (new TripsController($db))->update($p['id']);
}

// GPS Points ──────────────────────────────────────────────────────────────────
elseif ($method === 'POST' && $uri === '/gps-points/batch') {
    (new GpsPointsController($db))->batchInsert();
}

// Notifications ───────────────────────────────────────────────────────────────
elseif ($method === 'PATCH' && $uri === '/notifications/mark-all-read') {
    (new NotificationsController($db))->markAllRead();
}
elseif ($method === 'GET' && $uri === '/notifications') {
    (new NotificationsController($db))->getNotifications();
}

// Stats ───────────────────────────────────────────────────────────────────────
elseif ($method === 'GET' && $uri === '/stats/trips') {
    (new StatsController($db))->getCompletedTrips();
}

// 404 ─────────────────────────────────────────────────────────────────────────
else {
    Response::error("$method $uri — ruta no encontrada", 404);
}
