import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../tracking/domain/trip_model.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.read(dioClientProvider));
});

class HistoryRepository {
  final DioClient _client;
  HistoryRepository(this._client);

  Future<List<TripModel>> getHistory({int page = 1, int limit = 20}) async {
    final res = await _client.get('/trips/history', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final body = res.data as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>? ?? [];
    return list.map((e) => TripModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TripModel> getTripById(String id) async {
    final res = await _client.get('/trips/$id');
    return TripModel.fromJson(res.data as Map<String, dynamic>);
  }
}
