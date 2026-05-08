class IAuthRepository {
  async findDriverById(id) {
    throw new Error('Not implemented');
  }

  async createRefreshToken(driverId, token, expiresAt) {
    throw new Error('Not implemented');
  }

  async deleteRefreshToken(driverId, token) {
    throw new Error('Not implemented');
  }

  async deleteAllRefreshTokens(driverId) {
    throw new Error('Not implemented');
  }

  async findRefreshTokenWithDriver(token) {
    throw new Error('Not implemented');
  }

  async deleteRefreshTokenById(id) {
    throw new Error('Not implemented');
  }
}

module.exports = IAuthRepository;
