class GetDriverStatsUseCase {
  constructor(statsRepository) {
    this.statsRepository = statsRepository;
  }

  async execute(driverId, period) {
    const { start, end } = this._getPeriodRange(period || 'month');
    const trips = await this.statsRepository.getCompletedTrips(driverId, start, end);

    const total_trips = trips.length;
    const total_km = trips.reduce((sum, t) => sum + (t.distance_km || 0), 0);
    const total_duration_minutes = trips.reduce(
      (sum, t) => sum + (t.total_duration_minutes || 0),
      0
    );
    const avg_speed =
      total_trips > 0
        ? trips.reduce((sum, t) => sum + (t.avg_speed_kmh || 0), 0) / total_trips
        : 0;

    const dayMap = {};
    for (const trip of trips) {
      const date = trip.started_at ? trip.started_at.slice(0, 10) : null;
      if (!date) continue;
      if (!dayMap[date]) dayMap[date] = { date, trips: 0, km: 0 };
      dayMap[date].trips += 1;
      dayMap[date].km += trip.distance_km || 0;
    }
    const trips_by_day = Object.values(dayMap).sort((a, b) => a.date.localeCompare(b.date));

    return {
      total_trips,
      total_km: Math.round(total_km * 10) / 10,
      avg_speed: Math.round(avg_speed * 10) / 10,
      total_duration_minutes,
      trips_by_day,
    };
  }

  _getPeriodRange(period) {
    const now = new Date();
    const start = new Date(now);

    switch (period) {
      case 'day':
        start.setHours(0, 0, 0, 0);
        break;
      case 'week':
        start.setDate(now.getDate() - now.getDay());
        start.setHours(0, 0, 0, 0);
        break;
      case 'month':
      default:
        start.setDate(1);
        start.setHours(0, 0, 0, 0);
        break;
    }

    return { start: start.toISOString(), end: now.toISOString() };
  }
}

module.exports = GetDriverStatsUseCase;
