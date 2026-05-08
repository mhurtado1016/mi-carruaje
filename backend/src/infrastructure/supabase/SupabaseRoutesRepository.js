const IRoutesRepository = require('../../domain/repositories/IRoutesRepository');

class SupabaseRoutesRepository extends IRoutesRepository {
  constructor(supabase) {
    super();
    this.supabase = supabase;
  }

  async getTodayRoutes(driverId, todayStart, todayEnd) {
    const { data, error } = await this.supabase
      .from('routes')
      .select('*, stops(count)')
      .eq('driver_id', driverId)
      .gte('scheduled_start', todayStart)
      .lt('scheduled_start', todayEnd)
      .order('scheduled_start', { ascending: true });

    if (error) throw error;

    return (data || []).map((route) => {
      const { stops, ...rest } = route;
      return {
        ...rest,
        total_stops: stops?.[0]?.count ?? rest.total_stops ?? 0,
      };
    });
  }

  async getRouteById(id) {
    const { data, error } = await this.supabase
      .from('routes')
      .select('*, stops(*)')
      .eq('id', id)
      .single();

    if (error || !data) return null;

    data.stops = (data.stops || []).sort((a, b) => a.order - b.order);
    return data;
  }

  async updateRouteStatus(id, status) {
    const { data, error } = await this.supabase
      .from('routes')
      .update({ status })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async updateRoute(id, fields) {
    const { error } = await this.supabase
      .from('routes')
      .update(fields)
      .eq('id', id);

    if (error) throw error;
  }
}

module.exports = SupabaseRoutesRepository;
