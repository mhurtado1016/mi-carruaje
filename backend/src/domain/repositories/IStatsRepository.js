class IStatsRepository {
  async getCompletedTrips(driverId, start, end) {
    throw new Error('Not implemented');
  }
}

module.exports = IStatsRepository;
