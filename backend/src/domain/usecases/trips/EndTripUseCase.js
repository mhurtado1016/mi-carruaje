class EndTripUseCase {
  constructor(tripsRepository, routesRepository) {
    this.tripsRepository = tripsRepository;
    this.routesRepository = routesRepository;
  }

  async execute(tripId, driverId, { ended_at, distance_km, avg_speed_kmh, stops_completed }) {
    const existing = await this.tripsRepository.getTripById(tripId);
    if (!existing) {
      throw new Error('Trip not found');
    }
    if (existing.driver_id !== driverId) {
      throw new Error('Forbidden');
    }

    const endedAt = ended_at || new Date().toISOString();
    const durationMinutes = existing.started_at
      ? Math.round((new Date(endedAt) - new Date(existing.started_at)) / 60000)
      : null;

    const trip = await this.tripsRepository.updateTrip(tripId, {
      ended_at: endedAt,
      distance_km: distance_km ?? existing.distance_km,
      avg_speed_kmh: avg_speed_kmh ?? existing.avg_speed_kmh,
      stops_completed: stops_completed ?? existing.stops_completed,
      status: 'completed',
      total_duration_minutes: durationMinutes,
    });

    await this.routesRepository.updateRoute(existing.route_id, {
      status: 'completed',
      active_trip_id: null,
    });

    return trip;
  }
}

module.exports = EndTripUseCase;
