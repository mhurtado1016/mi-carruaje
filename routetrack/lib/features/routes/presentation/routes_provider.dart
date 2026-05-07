import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/routes_repository.dart';
import '../domain/route_model.dart';

final todayRoutesProvider = FutureProvider<List<RouteModel>>((ref) async {
  return ref.read(routesRepositoryProvider).getTodayRoutes();
});

final routeDetailProvider = FutureProvider.family<RouteModel, String>((ref, id) async {
  return ref.read(routesRepositoryProvider).getRouteById(id);
});
