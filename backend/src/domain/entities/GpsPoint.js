class GpsPoint {
  constructor({ id, trip_id, latitude, longitude, accuracy, speed_kmh, heading, recorded_at }) {
    this.id = id;
    this.trip_id = trip_id;
    this.latitude = latitude;
    this.longitude = longitude;
    this.accuracy = accuracy ?? null;
    this.speed_kmh = speed_kmh ?? null;
    this.heading = heading ?? null;
    this.recorded_at = recorded_at;
  }
}

module.exports = GpsPoint;
