class Route {
  constructor({ id, driver_id, status, scheduled_start, active_trip_id, total_stops, stops }) {
    this.id = id;
    this.driver_id = driver_id;
    this.status = status;
    this.scheduled_start = scheduled_start;
    this.active_trip_id = active_trip_id ?? null;
    this.total_stops = total_stops ?? 0;
    this.stops = stops ?? [];
  }
}

module.exports = Route;
