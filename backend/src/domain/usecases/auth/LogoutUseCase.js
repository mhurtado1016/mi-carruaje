class LogoutUseCase {
  constructor(authRepository) {
    this.authRepository = authRepository;
  }

  async execute(driverId, refreshToken) {
    if (refreshToken) {
      await this.authRepository.deleteRefreshToken(driverId, refreshToken);
    } else {
      await this.authRepository.deleteAllRefreshTokens(driverId);
    }
  }
}

module.exports = LogoutUseCase;
