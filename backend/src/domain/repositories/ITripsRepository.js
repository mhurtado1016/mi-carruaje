class ITripsRepository {
  async createTrip(tripData) {
    throw new Error('Not implemented');
  }

  async getTripById(id) {
    throw new Error('Not implemented');
  }

  async getTripHistory(driverId, page, limit) {
    throw new Error('Not implemented');
  }

  async updateTrip(id, fields) {
    throw new Error('Not implemented');
  }

  async getTripGpsPoints(tripId) {
    throw new Error('Not implemented');
  }
}

module.exports = ITripsRepository;
