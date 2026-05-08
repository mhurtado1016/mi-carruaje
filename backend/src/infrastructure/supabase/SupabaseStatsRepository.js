const IStatsRepository = require('../../domain/repositories/IStatsRepository');

class SupabaseStatsRepository extends IStatsRepository {
  constructor(supabase) {
    super();
    this.supabase = supabase;
  }

  async getCompletedTrips(driverId, start, end) {
    const { data, error } = await this.supabase
      .from('trips')
      .select(
        'id, started_at, ended_at, distance_km, avg_speed_kmh, total_duration_minutes, stops_completed'
      )
      .eq('driver_id', driverId)
      .eq('status', 'completed')
      .gte('started_at', start)
      .lte('started_at', end)
      .order('started_at', { ascending: true });

    if (error) throw error;
    return data || [];
  }
}

module.exports = SupabaseStatsRepository;
