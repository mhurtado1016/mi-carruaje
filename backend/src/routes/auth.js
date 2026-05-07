const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const supabase = require('../config/supabase');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

function generateRefreshToken() {
  return crypto.randomUUID();
}

function signAccessToken(driver) {
  return jwt.sign(
    { id: driver.id, name: driver.name, email: driver.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '8h' }
  );
}

// POST /v1/auth/login
router.post('/login', async (req, res, next) => {
  try {
    const { employee_id, password } = req.body;
    if (!employee_id || !password) {
      return res.status(400).json({ error: 'employee_id and password are required' });
    }

    const { data: driver, error } = await supabase
      .from('drivers')
      .select('*')
      .eq('id', employee_id)
      .single();

    if (error || !driver) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const passwordMatch = await bcrypt.compare(password, driver.password_hash);
    if (!passwordMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const accessToken = signAccessToken(driver);
    const refreshToken = generateRefreshToken();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + parseInt(process.env.REFRESH_TOKEN_EXPIRES_DAYS || '30', 10));

    await supabase.from('refresh_tokens').insert({
      driver_id: driver.id,
      token: refreshToken,
      expires_at: expiresAt.toISOString(),
    });

    return res.json({
      id: driver.id,
      name: driver.name,
      email: driver.email,
      zone: driver.zone,
      shift: driver.shift,
      status: driver.status,
      avatar_url: driver.avatar_url,
      token: accessToken,
      refresh_token: refreshToken,
    });
  } catch (err) {
    next(err);
  }
});

// POST /v1/auth/logout
router.post('/logout', authMiddleware, async (req, res, next) => {
  try {
    const { refresh_token } = req.body;
    if (refresh_token) {
      await supabase
        .from('refresh_tokens')
        .delete()
        .eq('token', refresh_token)
        .eq('driver_id', req.driver.id);
    } else {
      await supabase
        .from('refresh_tokens')
        .delete()
        .eq('driver_id', req.driver.id);
    }
    return res.json({ message: 'Logged out successfully' });
  } catch (err) {
    next(err);
  }
});

// POST /v1/auth/refresh
router.post('/refresh', async (req, res, next) => {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      return res.status(400).json({ error: 'refresh_token is required' });
    }

    const { data: tokenRecord, error } = await supabase
      .from('refresh_tokens')
      .select('*, drivers(*)')
      .eq('token', refresh_token)
      .single();

    if (error || !tokenRecord) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    if (new Date(tokenRecord.expires_at) < new Date()) {
      await supabase.from('refresh_tokens').delete().eq('id', tokenRecord.id);
      return res.status(401).json({ error: 'Refresh token expired' });
    }

    const driver = tokenRecord.drivers;
    const accessToken = signAccessToken(driver);

    return res.json({ token: accessToken });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
