enum TripStatus { active, paused, completed }

class TripModel {
  final String id;
  final String routeId;
  final String driverId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final TripStatus status;
  final double distanceKm;
  final int? totalDurationMinutes;
  final double avgSpeedKmh;
  final int stopsCompleted;

  const TripModel({
    required this.id,
    required this.routeId,
    required this.driverId,
    required this.startedAt,
    this.endedAt,
    required this.status,
    required this.distanceKm,
    this.totalDurationMinutes,
    required this.avgSpeedKmh,
    required this.stopsCompleted,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        id: json['id'] as String,
        routeId: json['route_id'] as String,
        driverId: json['driver_id'] as String,
        startedAt: DateTime.parse(json['started_at'] as String),
        endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'] as String) : null,
        status: _parseStatus(json['status'] as String? ?? 'active'),
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
        totalDurationMinutes: json['total_duration_minutes'] as int?,
        avgSpeedKmh: (json['avg_speed_kmh'] as num?)?.toDouble() ?? 0.0,
        stopsCompleted: json['stops_completed'] as int? ?? 0,
      );

  static TripStatus _parseStatus(String s) => switch (s) {
        'paused'    => TripStatus.paused,
        'completed' => TripStatus.completed,
        _           => TripStatus.active,
      };

  Duration? get totalDuration =>
      totalDurationMinutes != null ? Duration(minutes: totalDurationMinutes!) : null;
}
