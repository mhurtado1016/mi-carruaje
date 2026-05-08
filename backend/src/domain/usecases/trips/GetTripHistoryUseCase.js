class GetTripHistoryUseCase {
  constructor(tripsRepository) {
    this.tripsRepository = tripsRepository;
  }

  async execute(driverId, rawPage, rawLimit) {
    const page = Math.max(1, parseInt(rawPage, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(rawLimit, 10) || 20));

    return this.tripsRepository.getTripHistory(driverId, page, limit);
  }
}

module.exports = GetTripHistoryUseCase;
