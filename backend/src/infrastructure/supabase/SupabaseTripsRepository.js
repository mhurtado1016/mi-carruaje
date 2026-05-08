const ITripsRepository = require('../../domain/repositories/ITripsRepository');

class SupabaseTripsRepository extends ITripsRepository {
  constructor(supabase) {
    super();
    this.supabase = supabase;
  }

  async createTrip(tripData) {
    const { data, error } = await this.supabase
      .from('trips')
      .insert(tripData)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async getTripById(id) {
    const { data, error } = await this.supabase
      .from('trips')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return data;
  }

  async getTripHistory(driverId, page, limit) {
    const offset = (page - 1) * limit;

    const { data, error, count } = await this.supabase
      .from('trips')
      .select('*', { count: 'exact' })
      .eq('driver_id', driverId)
      .order('started_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return {
      data: data || [],
      page,
      limit,
      total: count ?? 0,
    };
  }

  async updateTrip(id, fields) {
    const { data, error } = await this.supabase
      .from('trips')
      .update(fields)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async getTripGpsPoints(tripId) {
    const { data } = await this.supabase
      .from('gps_points')
      .select('*')
      .eq('trip_id', tripId)
      .order('recorded_at', { ascending: true });

    return data || [];
  }
}

module.exports = SupabaseTripsRepository;
