import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/driver_model.dart';

class AuthState {
  final bool isAuthenticated;
  final DriverModel? driver;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.driver,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    DriverModel? driver,
    bool? isLoading,
    String? error,
  }) => AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        driver: driver ?? this.driver,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authenticated = await _repo.isAuthenticated();
    state = state.copyWith(isAuthenticated: authenticated);
  }

  Future<void> login(String employeeId, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final driver = await _repo.login(employeeId, password);
      state = state.copyWith(isAuthenticated: true, driver: driver, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void loginDemo() {
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      error: null,
      driver: const DriverModel(
        id: 'demo-001',
        name: 'Carlos Martinez',
        email: 'carlos.martinez@efrata.com',
        zone: 'Zona Norte',
        shift: 'day',
        status: 'active',
        token: 'demo-token',
      ),
    );
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    state = const AuthState();
  }
}
