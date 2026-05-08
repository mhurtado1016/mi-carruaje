<?php
class GpsPointsController {
    public function __construct(private PDO $db) {}

    public function batchInsert(): void {
        $body   = json_decode(file_get_contents('php://input'), true) ?? [];
        $points = $body['points'] ?? [];

        if (!is_array($points) || count($points) === 0) {
            Response::error('Se requiere un array de puntos no vacío');
        }

        $stmt = $this->db->prepare(
            'INSERT INTO gps_points
               (trip_id, latitude, longitude, accuracy, speed_kmh, heading, recorded_at)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );

        $this->db->beginTransaction();
        $inserted = 0;
        foreach ($points as $p) {
            $stmt->execute([
                $p['trip_id']     ?? null,
                $p['latitude']    ?? null,
                $p['longitude']   ?? null,
                $p['accuracy']    ?? null,
                $p['speed_kmh']   ?? null,
                $p['heading']     ?? null,
                $p['recorded_at'] ?? null,
            ]);
            $inserted++;
        }
        $this->db->commit();

        Response::json(['inserted' => $inserted], 201);
    }
}
