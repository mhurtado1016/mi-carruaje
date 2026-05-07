enum StopStatus { pending, arrived, completed, skipped }

class StopModel {
  final String id;
  final int order;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final StopStatus status;
  final DateTime? arrivedAt;
  final int? durationMinutes;

  const StopModel({
    required this.id,
    required this.order,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.arrivedAt,
    this.durationMinutes,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) => StopModel(
        id: json['id'] as String,
        order: json['order'] as int,
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        status: _parseStatus(json['status'] as String? ?? 'pending'),
        arrivedAt: json['arrived_at'] != null ? DateTime.parse(json['arrived_at'] as String) : null,
        durationMinutes: json['duration_minutes'] as int?,
      );

  static StopStatus _parseStatus(String s) => switch (s) {
        'arrived'   => StopStatus.arrived,
        'completed' => StopStatus.completed,
        'skipped'   => StopStatus.skipped,
        _           => StopStatus.pending,
      };
}
