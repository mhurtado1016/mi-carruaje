class GetRouteByIdUseCase {
  constructor(routesRepository) {
    this.routesRepository = routesRepository;
  }

  async execute(routeId, driverId) {
    const route = await this.routesRepository.getRouteById(routeId);
    if (!route) {
      throw new Error('Route not found');
    }
    if (route.driver_id !== driverId) {
      throw new Error('Forbidden');
    }
    return route;
  }
}

module.exports = GetRouteByIdUseCase;
