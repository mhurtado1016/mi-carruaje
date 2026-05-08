<?php
class TripsController {
    public function __construct(private PDO $db) {}

    public function create(): void {
        $body     = json_decode(file_get_contents('php://input'), true) ?? [];
        $allowed  = ['route_id', 'driver_id', 'started_at', 'status',
                     'distance_km', 'avg_speed_kmh', 'stops_completed'];
        $cols     = [];
        $vals     = [];

        foreach ($allowed as $col) {
            if (array_key_exists($col, $body)) {
                $cols[] = $col;
                $vals[] = $body[$col];
            }
        }

        if (!in_array('route_id', $cols) || !in_array('driver_id', $cols)) {
            Response::error('route_id y driver_id son requeridos');
        }

        $id       = $this->uuid();
        $colsList = implode(', ', array_merge(['id'], $cols));
        $phList   = implode(', ', array_fill(0, count($cols) + 1, '?'));

        $this->db->prepare("INSERT INTO trips ($colsList) VALUES ($phList)")
                 ->execute(array_merge([$id], $vals));

        $stmt = $this->db->prepare('SELECT * FROM trips WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        Response::json($stmt->fetch(), 201);
    }

    public function getHistory(): void {
        $driverId = $_GET['driver_id'] ?? null;
        $page     = max(1, (int)($_GET['page']  ?? 1));
        $limit    = max(1, (int)($_GET['limit'] ?? 20));
        $offset   = ($page - 1) * $limit;

        if (!$driverId) Response::error('driver_id es requerido');

        $countStmt = $this->db->prepare('SELECT COUNT(*) FROM trips WHERE driver_id = ?');
        $countStmt->execute([$driverId]);
        $total = (int)$countStmt->fetchColumn();

        $stmt = $this->db->prepare(
            'SELECT * FROM trips WHERE driver_id = ?
             ORDER BY started_at DESC LIMIT ? OFFSET ?'
        );
        $stmt->execute([$driverId, $limit, $offset]);

        Response::json([
            'data'  => $stmt->fetchAll(),
            'page'  => $page,
            'limit' => $limit,
            'total' => $total,
        ]);
    }

    public function getById(string $id): void {
        $stmt = $this->db->prepare('SELECT * FROM trips WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $trip = $stmt->fetch();

        if (!$trip) Response::error('Trip not found', 404);
        Response::json($trip);
    }

    public function update(string $id): void {
        $fields  = json_decode(file_get_contents('php://input'), true) ?? [];
        $allowed = ['status', 'ended_at', 'paused_at', 'resumed_at',
                    'distance_km', 'avg_speed_kmh', 'total_duration_minutes', 'stops_completed'];

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
        $this->db->prepare('UPDATE trips SET ' . implode(', ', $set) . ' WHERE id = ?')
                 ->execute($vals);

        $stmt = $this->db->prepare('SELECT * FROM trips WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        Response::json($stmt->fetch());
    }

    public function getGpsPoints(string $tripId): void {
        $stmt = $this->db->prepare(
            'SELECT * FROM gps_points WHERE trip_id = ? ORDER BY recorded_at ASC'
        );
        $stmt->execute([$tripId]);
        Response::json($stmt->fetchAll());
    }

    private function uuid(): string {
        $stmt = $this->db->query('SELECT UUID()');
        return $stmt->fetchColumn();
    }
}
