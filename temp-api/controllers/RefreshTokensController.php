<?php
class RefreshTokensController {
    public function __construct(private PDO $db) {}

    public function create(): void {
        $body      = $this->body();
        $driverId  = $body['driver_id']  ?? null;
        $token     = $body['token']      ?? null;
        $expiresAt = $body['expires_at'] ?? null;

        if (!$driverId || !$token || !$expiresAt) {
            Response::error('driver_id, token y expires_at son requeridos');
        }

        $stmt = $this->db->prepare(
            'INSERT INTO refresh_tokens (id, driver_id, token, expires_at)
             VALUES (UUID(), ?, ?, ?)'
        );
        $stmt->execute([$driverId, $token, $expiresAt]);
        Response::json(null, 204);
    }

    public function deleteByDriverAndToken(): void {
        $body     = $this->body();
        $driverId = $body['driver_id'] ?? null;
        $token    = $body['token']     ?? null;

        if (!$driverId || !$token) Response::error('driver_id y token son requeridos');

        $this->db->prepare('DELETE FROM refresh_tokens WHERE driver_id = ? AND token = ?')
                 ->execute([$driverId, $token]);
        Response::json(null, 204);
    }

    public function deleteAllByDriver(string $driverId): void {
        $this->db->prepare('DELETE FROM refresh_tokens WHERE driver_id = ?')
                 ->execute([$driverId]);
        Response::json(null, 204);
    }

    public function getWithDriver(string $token): void {
        $stmt = $this->db->prepare('SELECT * FROM refresh_tokens WHERE token = ? LIMIT 1');
        $stmt->execute([$token]);
        $rt = $stmt->fetch();

        if (!$rt) Response::error('Token not found', 404);

        $stmt2 = $this->db->prepare('SELECT * FROM drivers WHERE id = ? LIMIT 1');
        $stmt2->execute([$rt['driver_id']]);
        $driver = $stmt2->fetch();

        Response::json([
            'id'         => $rt['id'],
            'expires_at' => $rt['expires_at'],
            'driver'     => $driver ?: null,
        ]);
    }

    public function deleteById(string $id): void {
        $this->db->prepare('DELETE FROM refresh_tokens WHERE id = ?')->execute([$id]);
        Response::json(null, 204);
    }

    private function body(): array {
        return json_decode(file_get_contents('php://input'), true) ?? [];
    }
}
