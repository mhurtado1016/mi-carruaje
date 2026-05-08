const ITripsRepository = require('../../domain/repositories/ITripsRepository');

/**
 * HTTP-based implementation of ITripsRepository.
 * Assumes the external API exposes:
 *   POST  /trips
 *   GET   /trips/:id
 *   GET   /trips?driver_id=&page=&limit=   → { data, page, limit, total }
 *   PATCH /trips/:id                        { ...fields }
 *   GET   /trips/:id/gps-points
 */
class MyApiTripsRepository extends ITripsRepository {
  /** @param {import('./HttpClient')} http */
  constructor(http) {
    super();
    this.http = http;
  }

  async createTrip(tripData) {
    return this.http.post('/trips', tripData);
  }

  async getTripById(id) {
    try {
      return await this.http.get(`/trips/${id}`);
    } catch (err) {
      if (err.status === 404) return null;
      throw err;
    }
  }

  async getTripHistory(driverId, page, limit) {
    const qs = new URLSearchParams({
      driver_id: driverId,
      page:      String(page),
      limit:     String(limit),
    });
    // Remote must return { data: [], page, limit, total }
    return this.http.get(`/trips?${qs}`);
  }

  async updateTrip(id, fields) {
    return this.http.patch(`/trips/${id}`, fields);
  }

  async getTripGpsPoints(tripId) {
    const data = await this.http.get(`/trips/${tripId}/gps-points`);
    return data || [];
  }
}

module.exports = MyApiTripsRepository;
