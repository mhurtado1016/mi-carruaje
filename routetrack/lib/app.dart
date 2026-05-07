import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/routes/presentation/routes_home_screen.dart';
import 'features/routes/presentation/route_detail_screen.dart';
import 'features/tracking/presentation/active_trip_screen.dart';
import 'features/history/presentation/trip_summary_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/gps_settings_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'shared/theme/app_theme.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final onLogin = state.matchedLocation == '/login';
      if (!auth.isAuthenticated && !onLogin) return '/login';
      if (auth.isAuthenticated && onLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home',  builder: (_, __) => const RoutesHomeScreen()),
      GoRoute(path: '/routes/:id', builder: (_, s) => RouteDetailScreen(routeId: s.pathParameters['id']!)),
      GoRoute(path: '/trip/active', builder: (_, __) => const ActiveTripScreen()),
      GoRoute(path: '/trip/active/map', builder: (_, __) => const ActiveTripScreen()),
      GoRoute(path: '/trip/:id/summary', builder: (_, s) => TripSummaryScreen(tripId: s.pathParameters['id']!)),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/history/:id', builder: (_, s) => TripSummaryScreen(tripId: s.pathParameters['id']!)),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile/gps-settings', builder: (_, __) => const GpsSettingsScreen()),
    ],
  );
});

class RouteTrackApp extends ConsumerWidget {
  const RouteTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'RouteTrack',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
