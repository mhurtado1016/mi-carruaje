class Notification {
  constructor({ id, driver_id, title, body, read, created_at }) {
    this.id = id;
    this.driver_id = driver_id;
    this.title = title;
    this.body = body;
    this.read = read ?? false;
    this.created_at = created_at;
  }
}

module.exports = Notification;
