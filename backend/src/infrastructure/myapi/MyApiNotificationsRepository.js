const INotificationsRepository = require('../../domain/repositories/INotificationsRepository');

/**
 * HTTP-based implementation of INotificationsRepository.
 * Assumes the external API exposes:
 *   GET   /notifications?driver_id=&unread=true|false
 *   PATCH /notifications/mark-all-read  { driver_id }
 */
class MyApiNotificationsRepository extends INotificationsRepository {
  /** @param {import('./HttpClient')} http */
  constructor(http) {
    super();
    this.http = http;
  }

  async getNotifications(driverId, onlyUnread) {
    const qs = new URLSearchParams({ driver_id: driverId });
    if (onlyUnread) qs.set('unread', 'true');
    const data = await this.http.get(`/notifications?${qs}`);
    return data || [];
  }

  async markAllRead(driverId) {
    await this.http.patch('/notifications/mark-all-read', { driver_id: driverId });
  }
}

module.exports = MyApiNotificationsRepository;
