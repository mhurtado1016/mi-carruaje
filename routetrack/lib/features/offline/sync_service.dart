import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tracking/data/tracking_repository.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.read(trackingRepositoryProvider));
});

class SyncService {
  final TrackingRepository _repo;
  SyncService(this._repo);

  Future<void> syncPendingPoints() => _repo.syncPendingPoints();
}
