import '../../../core/network/dio_client.dart';
import '../domain/route_model.dart';

class RoutesRemoteDatasource {
  final DioClient _client;
  RoutesRemoteDatasource(this._client);

  Future<List<RouteModel>> getTodayRoutes() async {
    final res = await _client.get('/routes/today');
    return (res.data as List<dynamic>)
        .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RouteModel> getRouteById(String id) async {
    final res = await _client.get('/routes/$id');
    return RouteModel.fromJson(res.data as Map<String, dynamic>);
  }
}
