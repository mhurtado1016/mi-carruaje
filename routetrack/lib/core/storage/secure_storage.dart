import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: 'jwt_token', value: token);
  Future<String?> getToken() => _storage.read(key: 'jwt_token');
  Future<void> deleteToken() => _storage.delete(key: 'jwt_token');

  Future<void> saveDriverId(String id) => _storage.write(key: 'driver_id', value: id);
  Future<String?> getDriverId() => _storage.read(key: 'driver_id');

  Future<void> clearAll() => _storage.deleteAll();
}
