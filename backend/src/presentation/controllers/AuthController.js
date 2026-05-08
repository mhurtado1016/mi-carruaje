class AuthController {
  constructor(loginUseCase, logoutUseCase, refreshTokenUseCase) {
    this.loginUseCase = loginUseCase;
    this.logoutUseCase = logoutUseCase;
    this.refreshTokenUseCase = refreshTokenUseCase;
  }

  async login(req, res, next) {
    try {
      const { employee_id, password } = req.body;
      const result = await this.loginUseCase.execute(employee_id, password);
      return res.json(result);
    } catch (err) {
      if (
        err.message === 'employee_id and password are required' ||
        err.message.includes('required')
      ) {
        return res.status(400).json({ error: err.message });
      }
      if (err.message === 'Invalid credentials') {
        return res.status(401).json({ error: err.message });
      }
      next(err);
    }
  }

  async logout(req, res, next) {
    try {
      const { refresh_token } = req.body;
      await this.logoutUseCase.execute(req.driver.id, refresh_token);
      return res.json({ message: 'Logged out successfully' });
    } catch (err) {
      next(err);
    }
  }

  async refresh(req, res, next) {
    try {
      const { refresh_token } = req.body;
      const result = await this.refreshTokenUseCase.execute(refresh_token);
      return res.json(result);
    } catch (err) {
      if (
        err.message === 'refresh_token is required' ||
        err.message.includes('required')
      ) {
        return res.status(400).json({ error: err.message });
      }
      if (
        err.message === 'Invalid refresh token' ||
        err.message === 'Refresh token expired'
      ) {
        return res.status(401).json({ error: err.message });
      }
      next(err);
    }
  }
}

module.exports = AuthController;
