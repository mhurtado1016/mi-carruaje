const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

class LoginUseCase {
  constructor(authRepository) {
    this.authRepository = authRepository;
  }

  async execute(employeeId, password) {
    if (!employeeId || !password) {
      throw new Error('employee_id and password are required');
    }

    const driver = await this.authRepository.findDriverById(employeeId);
    if (!driver) {
      throw new Error('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(password, driver.password_hash);
    if (!passwordMatch) {
      throw new Error('Invalid credentials');
    }

    const accessToken = jwt.sign(
      { id: driver.id, name: driver.name, email: driver.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '8h' }
    );

    const refreshToken = crypto.randomUUID();
    const expiresAt = new Date();
    expiresAt.setDate(
      expiresAt.getDate() + parseInt(process.env.REFRESH_TOKEN_EXPIRES_DAYS || '30', 10)
    );

    await this.authRepository.createRefreshToken(driver.id, refreshToken, expiresAt.toISOString());

    return {
      id: driver.id,
      name: driver.name,
      email: driver.email,
      zone: driver.zone,
      shift: driver.shift,
      status: driver.status,
      avatar_url: driver.avatar_url,
      token: accessToken,
      refresh_token: refreshToken,
    };
  }
}

module.exports = LoginUseCase;
