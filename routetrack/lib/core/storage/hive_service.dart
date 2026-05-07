import 'package:hive_flutter/hive_flutter.dart';
import '../../features/tracking/domain/gps_point_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(GpsPointHiveAdapter());
    await Hive.openBox<GpsPointHive>('gps_queue');
  }
}
