import '../../../core/network/dio_client.dart';
import '../domain/gps_point_model.dart';
import '../domain/trip_model.dart';

class TrackingRemoteDatasource {
  final DioClient _client;
  TrackingRemoteDatasource(this._client);

  Future<TripModel> startTrip(String routeId) async {
    final res = await _client.post('/trips/start', data: {
      'route_id': routeId,
      'started_at': DateTime.now().toUtc().toIso8601String(),
    });
    return TripModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TripModel> endTrip(
    String tripId, {
    required double distanceKm,
    required double avgSpeedKmh,
    required int stopsCompleted,
  }) async {
    final res = await _client.post('/trips/$tripId/end', data: {
      'ended_at': DateTime.now().toUtc().toIso8601String(),
      'distance_km': distanceKm,
      'avg_speed_kmh': avgSpeedKmh,
      'stops_completed': stopsCompleted,
    });
    return TripModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TripModel> getTrip(String tripId) async {
    final res = await _client.get('/trips/$tripId');
    return TripModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> syncGpsPoints(String tripId, List<GpsPointHive> points) async {
    await _client.post('/gps-points/batch', data: {
      'trip_id': tripId,
      'points': points.map((p) => {
        'lat': p.lat,
        'lng': p.lng,
        'accuracy': p.accuracy,
        'speed_kmh': p.speed,
        'timestamp': p.timestamp,
      }).toList(),
    });
  }
}
