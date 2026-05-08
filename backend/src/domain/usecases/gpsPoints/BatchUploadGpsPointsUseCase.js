class BatchUploadGpsPointsUseCase {
  constructor(gpsPointsRepository) {
    this.gpsPointsRepository = gpsPointsRepository;
  }

  async execute(tripId, points) {
    if (!tripId || !Array.isArray(points) || points.length === 0) {
      throw new Error('trip_id and a non-empty points array are required');
    }

    const rows = points.map((p) => ({
      trip_id: tripId,
      latitude: p.lat,
      longitude: p.lng,
      accuracy: p.accuracy ?? null,
      speed_kmh: p.speed_kmh ?? null,
      heading: p.heading ?? null,
      recorded_at:
        typeof p.timestamp === 'number'
          ? new Date(p.timestamp).toISOString()
          : p.timestamp,
    }));

    return this.gpsPointsRepository.batchInsert(rows);
  }
}

module.exports = BatchUploadGpsPointsUseCase;
