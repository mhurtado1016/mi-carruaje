<?php
class RoutesController {
    public function __construct(private PDO $db) {}

    public function getTodayRoutes(): void {
        $driverId = $_GET['driver_id'] ?? null;
        $from     = $_GET['from']      ?? null;
        $to       = $_GET['to']        ?? null;

        if (!$driverId || !$from || !$to) {
            Response::error('driver_id, from y to son requeridos');
        }

        $stmt = $this->db->prepare(
            'SELECT r.*, COUNT(s.id) AS total_stops
             FROM routes r
             LEFT JOIN stops s ON s.route_id = r.id
             WHERE r.driver_id = ?
               AND r.scheduled_start >= ?
               AND r.scheduled_start <  ?
             GROUP BY r.id
             ORDER BY r.scheduled_start ASC'
        );
        $stmt->execute([$driverId, $from, $to]);
        Response::json($stmt->fetchAll());
    }

    public function getById(string $id): void {
        $stmt = $this->db->prepare('SELECT * FROM routes WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $route = $stmt->fetch();

        if (!$route) Response::error('Route not found', 404);

        $stmt2 = $this->db->prepare(
            'SELECT * FROM stops WHERE route_id = ? ORDER BY stop_order ASC'
        );
        $stmt2->execute([$id]);
        $route['stops'] = $stmt2->fetchAll();

        Response::json($route);
    }

    public function updateStatus(string $id): void {
        $body   = json_decode(file_get_contents('php://input'), true) ?? [];
        $status = $body['status'] ?? null;

        if (!$status) Response::error('status es requerido');

        $stmt = $this->db->prepare(
            'UPDATE routes SET status = ? WHERE id = ?'
        );
        $stmt->execute([$status, $id]);

        $stmt2 = $this->db->prepare('SELECT * FROM routes WHERE id = ? LIMIT 1');
        $stmt2->execute([$id]);
        Response::json($stmt2->fetch());
    }

    public function update(string $id): void {
        $fields  = json_decode(file_get_contents('php://input'), true) ?? [];
        $allowed = ['name', 'scheduled_start', 'status', 'total_stops',
                    'estimated_km', 'estimated_duration_minutes', 'active_trip_id'];

        $set  = [];
        $vals = [];
        foreach ($allowed as $col) {
            if (array_key_exists($col, $fields)) {
                $set[]  = "$col = ?";
                $vals[] = $fields[$col];
            }
        }

        if (!$set) Response::error('Ningún campo válido para actualizar');

        $vals[] = $id;
        $this->db->prepare('UPDATE routes SET ' . implode(', ', $set) . ' WHERE id = ?')
                 ->execute($vals);
        Response::json(null, 204);
    }
}
