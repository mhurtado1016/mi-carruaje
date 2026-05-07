import 'stop_model.dart';

enum RouteStatus { pending, inProgress, completed, cancelled }

class RouteModel {
  final String id;
  final String name;
  final String driverId;
  final DateTime scheduledStart;
  final RouteStatus status;
  final int totalStops;
  final double estimatedKm;
  final int estimatedDurationMinutes;
  final List<StopModel> stops;
  final String? activeTripId;

  const RouteModel({
    required this.id,
    required this.name,
    required this.driverId,
    required this.scheduledStart,
    required this.status,
    required this.totalStops,
    required this.estimatedKm,
    required this.estimatedDurationMinutes,
    required this.stops,
    this.activeTripId,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'] as String,
        name: json['name'] as String,
        driverId: json['driver_id'] as String,
        scheduledStart: DateTime.parse(json['scheduled_start'] as String),
        status: _parseStatus(json['status'] as String? ?? 'pending'),
        totalStops: json['total_stops'] as int? ?? 0,
        estimatedKm: (json['estimated_km'] as num?)?.toDouble() ?? 0.0,
        estimatedDurationMinutes: json['estimated_duration_minutes'] as int? ?? 0,
        stops: (json['stops'] as List<dynamic>?)
                ?.map((s) => StopModel.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        activeTripId: json['active_trip_id'] as String?,
      );

  static RouteStatus _parseStatus(String s) => switch (s) {
        'in_progress' => RouteStatus.inProgress,
        'completed'   => RouteStatus.completed,
        'cancelled'   => RouteStatus.cancelled,
        _             => RouteStatus.pending,
      };
}
