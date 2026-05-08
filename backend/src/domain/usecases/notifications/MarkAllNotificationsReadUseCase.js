class MarkAllNotificationsReadUseCase {
  constructor(notificationsRepository) {
    this.notificationsRepository = notificationsRepository;
  }

  async execute(driverId) {
    return this.notificationsRepository.markAllRead(driverId);
  }
}

module.exports = MarkAllNotificationsReadUseCase;
