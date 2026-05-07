class ApiConstants {
  static const baseUrl       = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/v1');
  static const gpsIntervalMs = int.fromEnvironment('GPS_INTERVAL_MS', defaultValue: 8000);
  static const batchSize     = int.fromEnvironment('GPS_BATCH_SIZE', defaultValue: 20);
  static const batchIntervalS = int.fromEnvironment('GPS_BATCH_INTERVAL_S', defaultValue: 30);
}

class HiveBoxes {
  static const gpsQueue    = 'gps_queue';
  static const sessionBox  = 'session';
}
