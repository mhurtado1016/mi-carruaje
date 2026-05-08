<?php
class Auth {
    public static function verify(): void {
        self::checkIp();
        self::checkApiKey();
    }

    private static function checkApiKey(): void {
        $apiKey = getenv('API_KEY');
        if (!$apiKey) return; // sin clave configurada = abierto

        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        if (!preg_match('/^Bearer\s+(.+)$/i', $header, $m) || $m[1] !== $apiKey) {
            Response::error('Unauthorized', 401);
        }
    }

    private static function checkIp(): void {
        $allowed = getenv('ALLOWED_IPS');
        if (!$allowed) return; // sin lista configurada = abierto

        $allowedList = array_map('trim', explode(',', $allowed));
        $clientIp    = self::clientIp();

        if (!in_array($clientIp, $allowedList, true)) {
            Response::error('Forbidden', 403);
        }
    }

    private static function clientIp(): string {
        // Soporte para proxies/load balancers: toma la IP más a la izquierda
        // (la del cliente real, no del proxy).
        // Solo activa X-Forwarded-For si el servidor está detrás de un proxy confiable.
        if (getenv('TRUST_PROXY') === 'true') {
            $forwarded = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? '';
            if ($forwarded) {
                return trim(explode(',', $forwarded)[0]);
            }
        }
        return $_SERVER['REMOTE_ADDR'] ?? '';
    }
}
