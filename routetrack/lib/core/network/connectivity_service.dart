import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

final connectivityProvider = StreamProvider<bool>((ref) {
  return ref.read(connectivityServiceProvider).onConnectivityChanged;
});

class ConnectivityService {
  Stream<bool> get onConnectivityChanged => Connectivity()
      .onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));

  Future<bool> get isConnected async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
