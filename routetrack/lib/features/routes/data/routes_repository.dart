import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/route_model.dart';
import 'routes_remote_datasource.dart';

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository(RoutesRemoteDatasource(ref.read(dioClientProvider)));
});

class RoutesRepository {
  final RoutesRemoteDatasource _remote;
  RoutesRepository(this._remote);

  Future<List<RouteModel>> getTodayRoutes() => _remote.getTodayRoutes();
  Future<RouteModel> getRouteById(String id) => _remote.getRouteById(id);
}
