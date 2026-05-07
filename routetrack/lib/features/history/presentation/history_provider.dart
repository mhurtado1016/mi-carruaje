import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/history_repository.dart';
import '../../tracking/domain/trip_model.dart';

final tripHistoryProvider = FutureProvider<List<TripModel>>((ref) async {
  return ref.read(historyRepositoryProvider).getHistory();
});

final tripSummaryProvider = FutureProvider.family<TripModel, String>((ref, tripId) async {
  return ref.read(historyRepositoryProvider).getTripById(tripId);
});
