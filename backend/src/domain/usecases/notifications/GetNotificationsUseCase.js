class GetNotificationsUseCase {
  constructor(notificationsRepository) {
    this.notificationsRepository = notificationsRepository;
  }

  async execute(driverId, onlyUnread) {
    return this.notificationsRepository.getNotifications(driverId, onlyUnread === 'true');
  }
}

module.exports = GetNotificationsUseCase;
