import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../domain/gps_point_model.dart';
import '../domain/trip_model.dart';
import 'tracking_remote_datasource.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(TrackingRemoteDatasource(ref.read(dioClientProvider)));
});

class TrackingRepository {
  final TrackingRemoteDatasource _remote;
  TrackingRepository(this._remote);

  Future<TripModel> startTrip(String routeId) => _remote.startTrip(routeId);

  Future<TripModel> endTrip(
    String tripId, {
    required double distanceKm,
    required double avgSpeedKmh,
    required int stopsCompleted,
  }) => _remote.endTrip(
        tripId,
        distanceKm: distanceKm,
        avgSpeedKmh: avgSpeedKmh,
        stopsCompleted: stopsCompleted,
      );

  Future<TripModel> getTrip(String tripId) => _remote.getTrip(tripId);

  Future<void> syncPendingPoints() async {
    final box = Hive.box<GpsPointHive>(HiveBoxes.gpsQueue);
    final pending = box.values.where((p) => !p.synced).toList();
    if (pending.isEmpty) return;

    final grouped = <String, List<GpsPointHive>>{};
    for (final p in pending) {
      grouped.putIfAbsent(p.tripId, () => []).add(p);
    }

    for (final entry in grouped.entries) {
      try {
        await _remote.syncGpsPoints(entry.key, entry.value);
        for (final p in entry.value) {
          p.synced = true;
          await p.save();
        }
      } catch (_) {
        // Dejar en cola
      }
    }
  }
}
