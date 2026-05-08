const IAuthRepository = require('../../domain/repositories/IAuthRepository');

/**
 * HTTP-based implementation of IAuthRepository.
 * Assumes the external API exposes:
 *   GET    /drivers/:id
 *   POST   /refresh-tokens
 *   DELETE /refresh-tokens              { driver_id, token }
 *   DELETE /refresh-tokens/all/:driverId
 *   GET    /refresh-tokens/:token/with-driver
 *   DELETE /refresh-tokens/:id
 */
class MyApiAuthRepository extends IAuthRepository {
  /** @param {import('./HttpClient')} http */
  constructor(http) {
    super();
    this.http = http;
  }

  async findDriverById(id) {
    try {
      return await this.http.get(`/drivers/${id}`);
    } catch (err) {
      if (err.status === 404) return null;
      throw err;
    }
  }

  async createRefreshToken(driverId, token, expiresAt) {
    await this.http.post('/refresh-tokens', {
      driver_id:  driverId,
      token,
      expires_at: expiresAt,
    });
  }

  async deleteRefreshToken(driverId, token) {
    await this.http.delete('/refresh-tokens', { driver_id: driverId, token });
  }

  async deleteAllRefreshTokens(driverId) {
    await this.http.delete(`/refresh-tokens/all/${driverId}`);
  }

  async findRefreshTokenWithDriver(token) {
    try {
      // Expected shape: { id, expires_at, driver: { ...driverFields } }
      return await this.http.get(`/refresh-tokens/${encodeURIComponent(token)}/with-driver`);
    } catch (err) {
      if (err.status === 404) return null;
      throw err;
    }
  }

  async deleteRefreshTokenById(id) {
    await this.http.delete(`/refresh-tokens/${id}`);
  }
}

module.exports = MyApiAuthRepository;
