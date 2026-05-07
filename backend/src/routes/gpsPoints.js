const express = require('express');
const supabase = require('../config/supabase');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

// POST /v1/gps-points/batch
router.post('/batch', async (req, res, next) => {
  try {
    const { trip_id, points } = req.body;

    if (!trip_id || !Array.isArray(points) || points.length === 0) {
      return res.status(400).json({ error: 'trip_id and a non-empty points array are required' });
    }

    const rows = points.map((p) => ({
      trip_id,
      latitude: p.lat,
      longitude: p.lng,
      accuracy: p.accuracy ?? null,
      speed_kmh: p.speed_kmh ?? null,
      heading: p.heading ?? null,
      recorded_at: typeof p.timestamp === 'number'
        ? new Date(p.timestamp).toISOString()
        : p.timestamp,
    }));

    const { error, count } = await supabase
      .from('gps_points')
      .insert(rows, { count: 'exact' });

    if (error) throw error;

    return res.status(201).json({ inserted: count ?? rows.length });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
