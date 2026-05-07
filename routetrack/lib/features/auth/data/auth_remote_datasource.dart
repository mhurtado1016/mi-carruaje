import '../../../core/network/dio_client.dart';
import '../domain/driver_model.dart';

class AuthRemoteDatasource {
  final DioClient _client;
  AuthRemoteDatasource(this._client);

  Future<DriverModel> login(String employeeId, String password) async {
    final res = await _client.post('/auth/login', data: {
      'employee_id': employeeId,
      'password': password,
    });
    return DriverModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() => _client.post('/auth/logout');
}
