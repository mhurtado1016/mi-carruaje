import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/distance_calculator.dart';
import '../features/tracking/domain/gps_point_model.dart';

class GpsBackgroundService {
  static const _channelId = 'routetrack_gps';

  static Future<void> initialize() async {
    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'RouteTrack',
        initialNotificationContent: 'Iniciando GPS...',
        foregroundServiceNotificationId: 1001,
      ),
      iosConfiguration: IosConfiguration(autoStart: false),
    );
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    final hive = await Hive.openBox<GpsPointHive>(HiveBoxes.gpsQueue);

    String? tripId;
    double totalDistance = 0;
    GpsPointHive? lastPoint;
    DateTime? startTime;

    service.on('setTripId').listen((data) {
      tripId = data?['tripId'] as String?;
      startTime = DateTime.now();
    });

    service.on('stopService').listen((_) => service.stopSelf());

    Timer.periodic(Duration(milliseconds: ApiConstants.gpsIntervalMs), (timer) async {
      if (tripId == null) return;

      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (pos.accuracy > 50) return;

        if (lastPoint != null) {
          totalDistance += haversineDistanceKm(lastPoint!.lat, lastPoint!.lng, pos.latitude, pos.longitude);
        }

        final point = GpsPointHive()
          ..tripId = tripId!
          ..lat = pos.latitude
          ..lng = pos.longitude
          ..accuracy = pos.accuracy
          ..speed = pos.speed * 3.6
          ..timestamp = pos.timestamp.millisecondsSinceEpoch
          ..synced = false;

        hive.add(point);
        lastPoint = point;

        final elapsed = startTime != null ? DateTime.now().difference(startTime!) : Duration.zero;

        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'RouteTrack · En recorrido',
            content: '${totalDistance.toStringAsFixed(1)} km · ${_fmt(elapsed)}',
          );
        }

        service.invoke('locationUpdate', {
          'lat': pos.latitude,
          'lng': pos.longitude,
          'speed': pos.speed * 3.6,
          'distance': totalDistance,
          'elapsed': elapsed.inSeconds,
          'pending': hive.values.where((p) => !p.synced).length,
        });
      } catch (_) {}
    });
  }

  static String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  static Future<void> start(String tripId) async {
    final svc = FlutterBackgroundService();
    await svc.startService();
    svc.invoke('setTripId', {'tripId': tripId});
  }

  static void stop() => FlutterBackgroundService().invoke('stopService');
}
