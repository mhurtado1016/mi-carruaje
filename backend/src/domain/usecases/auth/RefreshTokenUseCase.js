const jwt = require('jsonwebtoken');

class RefreshTokenUseCase {
  constructor(authRepository) {
    this.authRepository = authRepository;
  }

  async execute(refreshToken) {
    if (!refreshToken) {
      throw new Error('refresh_token is required');
    }

    const tokenRecord = await this.authRepository.findRefreshTokenWithDriver(refreshToken);
    if (!tokenRecord) {
      throw new Error('Invalid refresh token');
    }

    if (new Date(tokenRecord.expires_at) < new Date()) {
      await this.authRepository.deleteRefreshTokenById(tokenRecord.id);
      throw new Error('Refresh token expired');
    }

    const driver = tokenRecord.driver;
    const accessToken = jwt.sign(
      { id: driver.id, name: driver.name, email: driver.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '8h' }
    );

    return { token: accessToken };
  }
}

module.exports = RefreshTokenUseCase;
