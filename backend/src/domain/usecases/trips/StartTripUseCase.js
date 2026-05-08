class StartTripUseCase {
  constructor(tripsRepository, routesRepository) {
    this.tripsRepository = tripsRepository;
    this.routesRepository = routesRepository;
  }

  async execute(driverId, routeId, startedAt) {
    if (!routeId) {
      throw new Error('route_id is required');
    }

    const trip = await this.tripsRepository.createTrip({
      route_id: routeId,
      driver_id: driverId,
      started_at: startedAt || new Date().toISOString(),
      status: 'active',
    });

    await this.routesRepository.updateRoute(routeId, {
      status: 'in_progress',
      active_trip_id: trip.id,
    });

    return trip;
  }
}

module.exports = StartTripUseCase;
