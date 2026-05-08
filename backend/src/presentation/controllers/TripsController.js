class TripsController {
  constructor(
    startTripUseCase,
    endTripUseCase,
    getTripHistoryUseCase,
    getTripByIdUseCase,
    pauseTripUseCase,
    resumeTripUseCase
  ) {
    this.startTripUseCase = startTripUseCase;
    this.endTripUseCase = endTripUseCase;
    this.getTripHistoryUseCase = getTripHistoryUseCase;
    this.getTripByIdUseCase = getTripByIdUseCase;
    this.pauseTripUseCase = pauseTripUseCase;
    this.resumeTripUseCase = resumeTripUseCase;
  }

  async start(req, res, next) {
    try {
      const { route_id, started_at } = req.body;
      const trip = await this.startTripUseCase.execute(req.driver.id, route_id, started_at);
      return res.status(201).json(trip);
    } catch (err) {
      if (err.message.includes('required')) {
        return res.status(400).json({ error: err.message });
      }
      next(err);
    }
  }

  async end(req, res, next) {
    try {
      const trip = await this.endTripUseCase.execute(req.params.id, req.driver.id, req.body);
      return res.json(trip);
    } catch (err) {
      if (err.message === 'Trip not found') {
        return res.status(404).json({ error: err.message });
      }
      if (err.message === 'Forbidden') {
        return res.status(403).json({ error: err.message });
      }
      next(err);
    }
  }

  async history(req, res, next) {
    try {
      const result = await this.getTripHistoryUseCase.execute(
        req.driver.id,
        req.query.page,
        req.query.limit
      );
      return res.json(result);
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const includeTrack = req.query.includes_track === 'true';
      const trip = await this.getTripByIdUseCase.execute(
        req.params.id,
        req.driver.id,
        includeTrack
      );
      return res.json(trip);
    } catch (err) {
      if (err.message === 'Trip not found') {
        return res.status(404).json({ error: err.message });
      }
      if (err.message === 'Forbidden') {
        return res.status(403).json({ error: err.message });
      }
      next(err);
    }
  }

  async pause(req, res, next) {
    try {
      const trip = await this.pauseTripUseCase.execute(req.params.id, req.driver.id);
      return res.json(trip);
    } catch (err) {
      if (err.message === 'Trip not found') {
        return res.status(404).json({ error: err.message });
      }
      if (err.message === 'Forbidden') {
        return res.status(403).json({ error: err.message });
      }
      next(err);
    }
  }

  async resume(req, res, next) {
    try {
      const trip = await this.resumeTripUseCase.execute(req.params.id, req.driver.id);
      return res.json(trip);
    } catch (err) {
      if (err.message === 'Trip not found') {
        return res.status(404).json({ error: err.message });
      }
      if (err.message === 'Forbidden') {
        return res.status(403).json({ error: err.message });
      }
      next(err);
    }
  }
}

module.exports = TripsController;
