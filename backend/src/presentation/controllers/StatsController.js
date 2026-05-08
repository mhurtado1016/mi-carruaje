class StatsController {
  constructor(getDriverStatsUseCase) {
    this.getDriverStatsUseCase = getDriverStatsUseCase;
  }

  async getDriverStats(req, res, next) {
    try {
      const stats = await this.getDriverStatsUseCase.execute(
        req.params.id,
        req.query.period
      );
      return res.json(stats);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = StatsController;
