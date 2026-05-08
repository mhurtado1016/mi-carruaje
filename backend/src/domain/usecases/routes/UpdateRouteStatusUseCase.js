class UpdateRouteStatusUseCase {
  constructor(routesRepository) {
    this.routesRepository = routesRepository;
  }

  async execute(routeId, driverId, status) {
    if (!status) {
      throw new Error('status is required');
    }

    const route = await this.routesRepository.getRouteById(routeId);
    if (!route) {
      throw new Error('Route not found');
    }
    if (route.driver_id !== driverId) {
      throw new Error('Forbidden');
    }

    return this.routesRepository.updateRouteStatus(routeId, status);
  }
}

module.exports = UpdateRouteStatusUseCase;
