const IAuthRepository = require('../../domain/repositories/IAuthRepository');

class SupabaseAuthRepository extends IAuthRepository {
  constructor(supabase) {
    super();
    this.supabase = supabase;
  }

  async findDriverById(id) {
    const { data, error } = await this.supabase
      .from('drivers')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;
    return data;
  }

  async createRefreshToken(driverId, token, expiresAt) {
    const { error } = await this.supabase.from('refresh_tokens').insert({
      driver_id: driverId,
      token,
      expires_at: expiresAt,
    });
    if (error) throw error;
  }

  async deleteRefreshToken(driverId, token) {
    const { error } = await this.supabase
      .from('refresh_tokens')
      .delete()
      .eq('token', token)
      .eq('driver_id', driverId);
    if (error) throw error;
  }

  async deleteAllRefreshTokens(driverId) {
    const { error } = await this.supabase
      .from('refresh_tokens')
      .delete()
      .eq('driver_id', driverId);
    if (error) throw error;
  }

  async findRefreshTokenWithDriver(token) {
    const { data, error } = await this.supabase
      .from('refresh_tokens')
      .select('*, drivers(*)')
      .eq('token', token)
      .single();

    if (error || !data) return null;

    return {
      id: data.id,
      expires_at: data.expires_at,
      driver: data.drivers,
    };
  }

  async deleteRefreshTokenById(id) {
    const { error } = await this.supabase
      .from('refresh_tokens')
      .delete()
      .eq('id', id);
    if (error) throw error;
  }
}

module.exports = SupabaseAuthRepository;
