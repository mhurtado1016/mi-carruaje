const IGpsPointsRepository = require('../../domain/repositories/IGpsPointsRepository');

/**
 * HTTP-based implementation of IGpsPointsRepository.
 * Assumes the external API exposes:
 *   POST /gps-points/batch   { points: [...] }  → { inserted: N }
 */
class MyApiGpsPointsRepository extends IGpsPointsRepository {
  /** @param {import('./HttpClient')} http */
  constructor(http) {
    super();
    this.http = http;
  }

  async batchInsert(points) {
    // Expected response: { inserted: N }
    return this.http.post('/gps-points/batch', { points });
  }
}

module.exports = MyApiGpsPointsRepository;
