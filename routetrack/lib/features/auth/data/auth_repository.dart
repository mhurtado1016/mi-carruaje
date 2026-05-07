import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/driver_model.dart';
import 'auth_remote_datasource.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    AuthRemoteDatasource(ref.read(dioClientProvider)),
    ref.read(secureStorageProvider),
  );
});

class AuthRepository {
  final AuthRemoteDatasource _remote;
  final SecureStorageService _storage;

  AuthRepository(this._remote, this._storage);

  Future<DriverModel> login(String employeeId, String password) async {
    final driver = await _remote.login(employeeId, password);
    await _storage.saveToken(driver.token);
    await _storage.saveDriverId(driver.id);
    return driver;
  }

  Future<void> logout() async {
    await _remote.logout();
    await _storage.clearAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null;
  }
}
