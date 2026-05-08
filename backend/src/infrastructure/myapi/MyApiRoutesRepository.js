const IRoutesRepository = require('../../domain/repositories/IRoutesRepository');

/**
 * HTTP-based implementation of IRoutesRepository.
 * Assumes the external API exposes:
 *   GET   /routes?driver_id=&from=&to=
 *   GET   /routes/:id
 *   PATCH /routes/:id/status    { status }
 *   PATCH /routes/:id           { ...fields }
 */
class MyApiRoutesRepository extends IRoutesRepository {
  /** @param {import('./HttpClient')} http */
  constructor(http) {
    super();
    this.http = http;
  }

  async getTodayRoutes(driverId, todayStart, todayEnd) {
    const qs = new URLSearchParams({
      driver_id: driverId,
      from:      todayStart,
      to:        todayEnd,
    });
    const data = await this.http.get(`/routes?${qs}`);
    return data || [];
  }

  async getRouteById(id) {
    try {
      return await this.http.get(`/routes/${id}`);
    } catch (err) {
      if (err.status === 404) return null;
      throw err;
    }
  }

  async updateRouteStatus(id, status) {
    return this.http.patch(`/routes/${id}/status`, { status });
  }

  async updateRoute(id, fields) {
    await this.http.patch(`/routes/${id}`, fields);
  }
}

module.exports = MyApiRoutesRepository;
