const IGpsPointsRepository = require('../../domain/repositories/IGpsPointsRepository');

class SupabaseGpsPointsRepository extends IGpsPointsRepository {
  constructor(supabase) {
    super();
    this.supabase = supabase;
  }

  async batchInsert(points) {
    const { error, count } = await this.supabase
      .from('gps_points')
      .insert(points, { count: 'exact' });

    if (error) throw error;
    return { inserted: count ?? points.length };
  }
}

module.exports = SupabaseGpsPointsRepository;
