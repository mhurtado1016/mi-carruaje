import 'package:hive/hive.dart';

part 'gps_point_model.g.dart';

class GpsPointModel {
  final String id;
  final String tripId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? speedKmh;
  final double? heading;
  final DateTime timestamp;
  final bool synced;

  const GpsPointModel({
    required this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.speedKmh,
    this.heading,
    required this.timestamp,
    required this.synced,
  });
}

@HiveType(typeId: 0)
class GpsPointHive extends HiveObject {
  @HiveField(0) late String tripId;
  @HiveField(1) late double lat;
  @HiveField(2) late double lng;
  @HiveField(3) late double accuracy;
  @HiveField(4) late double? speed;
  @HiveField(5) late int timestamp;
  @HiveField(6) late bool synced;
}
