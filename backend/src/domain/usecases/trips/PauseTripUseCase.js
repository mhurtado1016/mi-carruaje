class PauseTripUseCase {
  constructor(tripsRepository) {
    this.tripsRepository = tripsRepository;
  }

  async execute(tripId, driverId) {
    const existing = await this.tripsRepository.getTripById(tripId);
    if (!existing) {
      throw new Error('Trip not found');
    }
    if (existing.driver_id !== driverId) {
      throw new Error('Forbidden');
    }

    return this.tripsRepository.updateTrip(tripId, {
      paused_at: new Date().toISOString(),
      status: 'paused',
    });
  }
}

module.exports = PauseTripUseCase;
