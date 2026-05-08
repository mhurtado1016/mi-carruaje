const IStatsRepository = require('../../domain/repositories/IStatsRepository');

/**
 * HTTP-based implementation of IStatsRepository.
 * Assumes the external API exposes:
 *   GET /stats/trips?driver_id=&from=&to=
 *   Response: array of { id, started_at, ended_at, distance_km,
 *                        avg_speed_kmh, total_duration_minutes, stops_completed }
 */
class MyApiStatsRepository extends IStatsRepository {
  /** @param {import('./HttpClient')} http */
  constructor(http) {
    super();
    this.http = http;
  }

  async getCompletedTrips(driverId, start, end) {
    const qs = new URLSearchParams({
      driver_id: driverId,
      from:      start,
      to:        end,
    });
    const data = await this.http.get(`/stats/trips?${qs}`);
    return data || [];
  }
}

module.exports = MyApiStatsRepository;
