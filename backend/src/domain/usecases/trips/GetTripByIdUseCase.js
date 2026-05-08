class GetTripByIdUseCase {
  constructor(tripsRepository) {
    this.tripsRepository = tripsRepository;
  }

  async execute(tripId, driverId, includeTrack) {
    const trip = await this.tripsRepository.getTripById(tripId);
    if (!trip) {
      throw new Error('Trip not found');
    }
    if (trip.driver_id !== driverId) {
      throw new Error('Forbidden');
    }

    if (includeTrack) {
      trip.gps_points = await this.tripsRepository.getTripGpsPoints(tripId);
    }

    return trip;
  }
}

module.exports = GetTripByIdUseCase;
