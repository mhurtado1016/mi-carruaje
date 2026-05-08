<?php
class StatsController {
    public function __construct(private PDO $db) {}

    public function getCompletedTrips(): void {
        $driverId = $_GET['driver_id'] ?? null;
        $from     = $_GET['from']      ?? null;
        $to       = $_GET['to']        ?? null;

        if (!$driverId || !$from || !$to) {
            Response::error('driver_id, from y to son requeridos');
        }

        $stmt = $this->db->prepare(
            'SELECT id, started_at, ended_at, distance_km, avg_speed_kmh,
                    total_duration_minutes, stops_completed
             FROM trips
             WHERE driver_id = ?
               AND status     = "completed"
               AND started_at >= ?
               AND started_at <= ?
             ORDER BY started_at ASC'
        );
        $stmt->execute([$driverId, $from, $to]);
        Response::json($stmt->fetchAll());
    }
}
