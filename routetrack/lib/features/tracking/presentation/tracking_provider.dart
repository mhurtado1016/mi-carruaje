import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tracking_repository.dart';
import '../domain/trip_model.dart';

class TrackingState {
  final bool isTracking;
  final bool isPaused;
  final String? activeTripId;
  final String? activeRouteId;
  final double currentLat;
  final double currentLng;
  final double distanceKm;
  final Duration elapsed;
  final double speedKmh;
  final int pendingPoints;
  final bool isLoading;
  final String? error;

  const TrackingState({
    this.isTracking = false,
    this.isPaused = false,
    this.activeTripId,
    this.activeRouteId,
    this.currentLat = 0,
    this.currentLng = 0,
    this.distanceKm = 0,
    this.elapsed = Duration.zero,
    this.speedKmh = 0,
    this.pendingPoints = 0,
    this.isLoading = false,
    this.error,
  });

  TrackingState copyWith({
    bool? isTracking,
    bool? isPaused,
    String? activeTripId,
    String? activeRouteId,
    double? currentLat,
    double? currentLng,
    double? distanceKm,
    Duration? elapsed,
    double? speedKmh,
    int? pendingPoints,
    bool? isLoading,
    String? error,
  }) => TrackingState(
        isTracking: isTracking ?? this.isTracking,
        isPaused: isPaused ?? this.isPaused,
        activeTripId: activeTripId ?? this.activeTripId,
        activeRouteId: activeRouteId ?? this.activeRouteId,
        currentLat: currentLat ?? this.currentLat,
        currentLng: currentLng ?? this.currentLng,
        distanceKm: distanceKm ?? this.distanceKm,
        elapsed: elapsed ?? this.elapsed,
        speedKmh: speedKmh ?? this.speedKmh,
        pendingPoints: pendingPoints ?? this.pendingPoints,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(ref.read(trackingRepositoryProvider));
});

class TrackingNotifier extends StateNotifier<TrackingState> {
  final TrackingRepository _repo;

  TrackingNotifier(this._repo) : super(const TrackingState());

  Future<void> startTrip(String routeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final trip = await _repo.startTrip(routeId);
      state = state.copyWith(
        isTracking: true,
        activeTripId: trip.id,
        activeRouteId: routeId,
        distanceKm: 0,
        elapsed: Duration.zero,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<TripModel?> endTrip() async {
    if (state.activeTripId == null) return null;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final duration = state.elapsed.inHours > 0 ? state.elapsed.inHours.toDouble() : 1;
      final avgSpeed = state.distanceKm / duration;
      final trip = await _repo.endTrip(
        state.activeTripId!,
        distanceKm: state.distanceKm,
        avgSpeedKmh: avgSpeed,
        stopsCompleted: 0,
      );
      state = const TrackingState();
      return trip;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void updateLocation({
    required double lat,
    required double lng,
    required double speed,
    required double distance,
    required Duration elapsed,
    required int pendingPoints,
  }) {
    state = state.copyWith(
      currentLat: lat,
      currentLng: lng,
      speedKmh: speed,
      distanceKm: distance,
      elapsed: elapsed,
      pendingPoints: pendingPoints,
    );
  }
}
