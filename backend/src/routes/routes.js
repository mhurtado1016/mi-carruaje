const express = require('express');
const supabase = require('../config/supabase');
const authMiddleware = require('../middleware/auth');

const routesRouter = express.Router();

routesRouter.use(authMiddleware);

// GET /v1/routes/today
routesRouter.get('/today', async (req, res, next) => {
  try {
    const today = new Date().toISOString().slice(0, 10);

    const { data, error } = await supabase
      .from('routes')
      .select(`
        *,
        stops(count)
      `)
      .eq('driver_id', req.driver.id)
      .gte('scheduled_start', `${today}T00:00:00Z`)
      .lt('scheduled_start', `${today}T23:59:59Z`)
      .order('scheduled_start', { ascending: true });

    if (error) throw error;

    const routes = (data || []).map((route) => {
      const { stops, ...rest } = route;
      return {
        ...rest,
        total_stops: stops?.[0]?.count ?? rest.total_stops ?? 0,
      };
    });

    return res.json(routes);
  } catch (err) {
    next(err);
  }
});

// GET /v1/routes/:id
routesRouter.get('/:id', async (req, res, next) => {
  try {
    const { data: route, error } = await supabase
      .from('routes')
      .select(`*, stops(*)`)
      .eq('id', req.params.id)
      .single();

    if (error || !route) {
      return res.status(404).json({ error: 'Route not found' });
    }

    if (route.driver_id !== req.driver.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    route.stops = (route.stops || []).sort((a, b) => a.order - b.order);

    return res.json(route);
  } catch (err) {
    next(err);
  }
});

// PATCH /v1/routes/:id/status
routesRouter.patch('/:id/status', async (req, res, next) => {
  try {
    const { status } = req.body;
    if (!status) {
      return res.status(400).json({ error: 'status is required' });
    }

    const { data: existing, error: fetchError } = await supabase
      .from('routes')
      .select('id, driver_id')
      .eq('id', req.params.id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({ error: 'Route not found' });
    }

    if (existing.driver_id !== req.driver.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { data, error } = await supabase
      .from('routes')
      .update({ status })
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw error;

    return res.json(data);
  } catch (err) {
    next(err);
  }
});

module.exports = routesRouter;
