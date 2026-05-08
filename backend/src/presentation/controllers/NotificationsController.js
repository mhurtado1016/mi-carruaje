class NotificationsController {
  constructor(getNotificationsUseCase, markAllNotificationsReadUseCase) {
    this.getNotificationsUseCase = getNotificationsUseCase;
    this.markAllNotificationsReadUseCase = markAllNotificationsReadUseCase;
  }

  async getAll(req, res, next) {
    try {
      const notifications = await this.getNotificationsUseCase.execute(
        req.driver.id,
        req.query.unread
      );
      return res.json(notifications);
    } catch (err) {
      next(err);
    }
  }

  async readAll(req, res, next) {
    try {
      await this.markAllNotificationsReadUseCase.execute(req.driver.id);
      return res.json({ message: 'All notifications marked as read' });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = NotificationsController;
