class INotificationsRepository {
  async getNotifications(driverId, onlyUnread) {
    throw new Error('Not implemented');
  }

  async markAllRead(driverId) {
    throw new Error('Not implemented');
  }
}

module.exports = INotificationsRepository;
