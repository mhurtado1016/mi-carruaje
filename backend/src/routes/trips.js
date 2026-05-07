const express = require('express');
const supabase = require('../config/supabase');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

// POST /v1/trips/start
router.post('/start', async (req, res, next) => {
  try {
    const { route_id, started_at } = req.body;
    if (!route_id) {
      return res.status(400).json({ error: 'route_id is required' });
    }

    const { data: trip, error: tripError } = await supabase
      .from('trips')
      .insert({
        route_id,
        driver_id: req.driver.id,
        started_at: started_at || new Date().toISOString(),
        status: 'active',
      })
      .select()
      .single();

    if (tripError) throw tripError;

    await supabase
      .from('routes')
      .update({ status: 'in_progress', active_trip_id: trip.id })
      .eq('id', route_id);

    return res.status(201).json(trip);
  } catch (err) {
    next(err);
  }
});

// GET /v1/trips/history  — must be defined BEFORE /:id
router.get('/history', async (req, res, next) => {
  try {
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit, 10) || 20));
    const offset = (page - 1) * limit;

    const { data, error, count } = await supabase
      .from('trips')
      .select('*', { count: 'exact' })
      .eq('driver_id', req.driver.id)
      .order('started_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return res.json({
      data: data || [],
      page,
      limit,
      total: count ?? 0,
    });
  } catch (err) {
    next(err);
  }
});

// GET /v1/trips/:id
router.get('/:id', async (req, res, next) => {
  try {
    const includeTrack = req.query.includes_track === 'true';

    let query = supabase.from('trips').select('*').eq('id', req.params.id).single();

    const { data: trip, error } = await query;

    if (error || !trip) {
      return res.status(404).json({ error: 'Trip not found' });
    }

    if (trip.driver_id !== req.driver.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    if (includeTrack) {
      const { data: points } = await supabase
        .from('gps_points')
        .select('*')
        .eq('trip_id', trip.id)
        .order('recorded_at', { ascending: true });
      trip.gps_points = points || [];
    }

    return res.json(trip);
  } catch (err) {
    next(err);
  }
});

// POST /v1/trips/:id/end
router.post('/:id/end', async (req, res, next) => {
  try {
    const { ended_at, distance_km, avg_speed_kmh, stops_completed } = req.body;

    const { data: existing, error: fetchError } = await supabase
      .from('trips')
      .select('*')
      .eq('id', req.params.id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({ error: 'Trip not found' });
    }

    if (existing.driver_id !== req.driver.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const endedAt = ended_at || new Date().toISOString();
    const startedAt = existing.started_at;
    const durationMinutes = startedAt
      ? Math.round((new Date(endedAt) - new Date(startedAt)) / 60000)
      : null;

    const { data: trip, error } = await supabase
      .from('trips')
      .update({
        ended_at: endedAt,
        distance_km: distance_km ?? existing.distance_km,
        avg_speed_kmh: avg_speed_kmh ?? existing.avg_speed_kmh,
        stops_completed: stops_completed ?? existing.stops_completed,
        status: 'completed',
        total_duration_minutes: durationMinutes,
      })
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw error;

    await supabase
      .from('routes')
      .update({ status: 'completed', active_trip_id: null })
      .eq('id', existing.route_id);

    return res.json(trip);
  } catch (err) {
    next(err);
  }
});

// PATCH /v1/trips/:id/pause
router.patch('/:id/pause', async (req, res, next) => {
  try {
    const { data: existing, error: fetchError } = await supabase
      .from('trips')
      .select('id, driver_id')
      .eq('id', req.params.id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({ error: 'Trip not found' });
    }

    if (existing.driver_id !== req.driver.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { data, error } = await supabase
      .from('trips')
      .update({ paused_at: new Date().toISOString(), status: 'paused' })
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw error;

    return res.json(data);
  } catch (err) {
    next(err);
  }
});

// PATCH /v1/trips/:id/resume
router.patch('/:id/resume', async (req, res, next) => {
  try {
    const { data: existing, error: fetchError } = await supabase
      .from('trips')
      .select('id, driver_id')
      .eq('id', req.params.id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({ error: 'Trip not found' });
    }

    if (existing.driver_id !== req.driver.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { data, error } = await supabase
      .from('trips')
      .update({ resumed_at: new Date().toISOString(), status: 'active', paused_at: null })
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw error;

    return res.json(data);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
