<?php
class DriversController {
    public function __construct(private PDO $db) {}

    public function getById(string $id): void {
        $stmt = $this->db->prepare('SELECT * FROM drivers WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $driver = $stmt->fetch();

        if (!$driver) Response::error('Driver not found', 404);
        Response::json($driver);
    }
}
