class IRoutesRepository {
  async getTodayRoutes(driverId, todayStart, todayEnd) {
    throw new Error('Not implemented');
  }

  async getRouteById(id) {
    throw new Error('Not implemented');
  }

  async updateRouteStatus(id, status) {
    throw new Error('Not implemented');
  }

  async updateRoute(id, fields) {
    throw new Error('Not implemented');
  }
}

module.exports = IRoutesRepository;
