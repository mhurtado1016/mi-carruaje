class Trip {
  constructor({
    id,
    route_id,
    driver_id,
    status,
    started_at,
    ended_at,
    paused_at,
    resumed_at,
    distance_km,
    avg_speed_kmh,
    stops_completed,
    total_duration_minutes,
    gps_points,
  }) {
    this.id = id;
    this.route_id = route_id;
    this.driver_id = driver_id;
    this.status = status;
    this.started_at = started_at;
    this.ended_at = ended_at ?? null;
    this.paused_at = paused_at ?? null;
    this.resumed_at = resumed_at ?? null;
    this.distance_km = distance_km ?? null;
    this.avg_speed_kmh = avg_speed_kmh ?? null;
    this.stops_completed = stops_completed ?? null;
    this.total_duration_minutes = total_duration_minutes ?? null;
    this.gps_points = gps_points ?? [];
  }
}

module.exports = Trip;
