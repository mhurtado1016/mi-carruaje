const express = require('express');
const supabase = require('../config/supabase');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

function getPeriodRange(period) {
  const now = new Date();
  const start = new Date(now);

  switch (period) {
    case 'day':
      start.setHours(0, 0, 0, 0);
      break;
    case 'week':
      start.setDate(now.getDate() - now.getDay());
      start.setHours(0, 0, 0, 0);
      break;
    case 'month':
    default:
      start.setDate(1);
      start.setHours(0, 0, 0, 0);
      break;
  }

  return { start: start.toISOString(), end: now.toISOString() };
}

// GET /v1/stats/driver/:id
router.get('/driver/:id', async (req, res, next) => {
  try {
    const period = req.query.period || 'month';
    const { start, end } = getPeriodRange(period);
    const driverId = req.params.id;

    const { data: trips, error } = await supabase
      .from('trips')
      .select('id, started_at, ended_at, distance_km, avg_speed_kmh, total_duration_minutes, stops_completed')
      .eq('driver_id', driverId)
      .eq('status', 'completed')
      .gte('started_at', start)
      .lte('started_at', end)
      .order('started_at', { ascending: true });

    if (error) throw error;

    const tripList = trips || [];

    const total_trips = tripList.length;
    const total_km = tripList.reduce((sum, t) => sum + (t.distance_km || 0), 0);
    const total_duration_minutes = tripList.reduce((sum, t) => sum + (t.total_duration_minutes || 0), 0);
    const avg_speed = total_trips > 0
      ? tripList.reduce((sum, t) => sum + (t.avg_speed_kmh || 0), 0) / total_trips
      : 0;

    // Aggregate by date
    const dayMap = {};
    for (const trip of tripList) {
      const date = trip.started_at ? trip.started_at.slice(0, 10) : null;
      if (!date) continue;
      if (!dayMap[date]) dayMap[date] = { date, trips: 0, km: 0 };
      dayMap[date].trips += 1;
      dayMap[date].km += trip.distance_km || 0;
    }
    const trips_by_day = Object.values(dayMap).sort((a, b) => a.date.localeCompare(b.date));

    return res.json({
      total_trips,
      total_km: Math.round(total_km * 10) / 10,
      avg_speed: Math.round(avg_speed * 10) / 10,
      total_duration_minutes,
      trips_by_day,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
