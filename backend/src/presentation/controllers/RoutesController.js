class RoutesController {
  constructor(getTodayRoutesUseCase, getRouteByIdUseCase, updateRouteStatusUseCase) {
    this.getTodayRoutesUseCase = getTodayRoutesUseCase;
    this.getRouteByIdUseCase = getRouteByIdUseCase;
    this.updateRouteStatusUseCase = updateRouteStatusUseCase;
  }

  async getToday(req, res, next) {
    try {
      const routes = await this.getTodayRoutesUseCase.execute(req.driver.id);
      return res.json(routes);
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const route = await this.getRouteByIdUseCase.execute(req.params.id, req.driver.id);
      return res.json(route);
    } catch (err) {
      if (err.message === 'Route not found') {
        return res.status(404).json({ error: err.message });
      }
      if (err.message === 'Forbidden') {
        return res.status(403).json({ error: err.message });
      }
      next(err);
    }
  }

  async updateStatus(req, res, next) {
    try {
      const { status } = req.body;
      const route = await this.updateRouteStatusUseCase.execute(
        req.params.id,
        req.driver.id,
        status
      );
      return res.json(route);
    } catch (err) {
      if (err.message === 'status is required' || err.message.includes('required')) {
        return res.status(400).json({ error: err.message });
      }
      if (err.message === 'Route not found') {
        return res.status(404).json({ error: err.message });
      }
      if (err.message === 'Forbidden') {
        return res.status(403).json({ error: err.message });
      }
      next(err);
    }
  }
}

module.exports = RoutesController;
