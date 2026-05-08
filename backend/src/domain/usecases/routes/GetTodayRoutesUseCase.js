class GetTodayRoutesUseCase {
  constructor(routesRepository) {
    this.routesRepository = routesRepository;
  }

  async execute(driverId) {
    const today = new Date().toISOString().slice(0, 10);
    const todayStart = `${today}T00:00:00Z`;
    const todayEnd = `${today}T23:59:59Z`;

    return this.routesRepository.getTodayRoutes(driverId, todayStart, todayEnd);
  }
}

module.exports = GetTodayRoutesUseCase;
