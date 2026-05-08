const INotificationsRepository = require('../../domain/repositories/INotificationsRepository');

class SupabaseNotificationsRepository extends INotificationsRepository {
  constructor(supabase) {
    super();
    this.supabase = supabase;
  }

  async getNotifications(driverId, onlyUnread) {
    let query = this.supabase
      .from('notifications')
      .select('*')
      .eq('driver_id', driverId)
      .order('created_at', { ascending: false });

    if (onlyUnread) {
      query = query.eq('read', false);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  }

  async markAllRead(driverId) {
    const { error } = await this.supabase
      .from('notifications')
      .update({ read: true })
      .eq('driver_id', driverId)
      .eq('read', false);

    if (error) throw error;
  }
}

module.exports = SupabaseNotificationsRepository;
