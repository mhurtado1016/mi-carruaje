<?php
class NotificationsController {
    public function __construct(private PDO $db) {}

    public function getNotifications(): void {
        $driverId  = $_GET['driver_id'] ?? null;
        $onlyUnread = ($_GET['unread'] ?? '') === 'true';

        if (!$driverId) Response::error('driver_id es requerido');

        $sql  = 'SELECT * FROM notifications WHERE driver_id = ?';
        $vals = [$driverId];

        if ($onlyUnread) {
            $sql  .= ' AND `read` = 0';
        }

        $sql .= ' ORDER BY created_at DESC';

        $stmt = $this->db->prepare($sql);
        $stmt->execute($vals);

        $rows = array_map(function ($row) {
            $row['read'] = (bool)$row['read'];
            return $row;
        }, $stmt->fetchAll());

        Response::json($rows);
    }

    public function markAllRead(): void {
        $body     = json_decode(file_get_contents('php://input'), true) ?? [];
        $driverId = $body['driver_id'] ?? null;

        if (!$driverId) Response::error('driver_id es requerido');

        $this->db->prepare(
            'UPDATE notifications SET `read` = 1 WHERE driver_id = ? AND `read` = 0'
        )->execute([$driverId]);

        Response::json(null, 204);
    }
}
