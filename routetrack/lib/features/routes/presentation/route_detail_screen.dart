import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/rt_button.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../tracking/presentation/tracking_provider.dart';
import '../domain/route_model.dart';
import '../domain/stop_model.dart';
import 'routes_provider.dart';

class RouteDetailScreen extends ConsumerWidget {
  final String routeId;
  const RouteDetailScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeDetailProvider(routeId));
    final tracking = ref.watch(trackingProvider);

    return Scaffold(
      body: SafeArea(
        child: routeAsync.when(
          data: (route) => _Body(route: route, tracking: tracking, ref: ref),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.danger))),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final RouteModel route;
  final TrackingState tracking;
  final WidgetRef ref;

  const _Body({required this.route, required this.tracking, required this.ref});

  @override
  Widget build(BuildContext context) {
    final canStart = route.status == RouteStatus.pending && !tracking.isTracking;
    final isActive = route.status == RouteStatus.inProgress;

    return Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Text('←', style: TextStyle(fontSize: 20, color: AppColors.textPrim)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(route.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
          ),
          StatusPill(label: _statusLabel(route.status), status: route.status),
        ]),
      ),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(route.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm · dd MMM', 'es').format(route.scheduledStart),
                  style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  _StatChip('${route.totalStops}', 'paradas'),
                  const SizedBox(width: 8),
                  _StatChip('${route.estimatedKm.toStringAsFixed(0)}km', 'distancia'),
                  const SizedBox(width: 8),
                  _StatChip('${route.estimatedDurationMinutes}m', 'estimado'),
                ]),
              ]),
            ),

            const SizedBox(height: 20),

            // Stops
            const Text('PARADAS', style: TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted, letterSpacing: 1)),
            const SizedBox(height: 12),

            if (route.stops.isEmpty)
              const Text('Sin paradas', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'SpaceMono'))
            else
              ...route.stops.asMap().entries.map((e) => _StopItem(
                    stop: e.value,
                    isLast: e.key == route.stops.length - 1,
                  )),

            const SizedBox(height: 24),
          ]),
        ),
      ),

      // Actions
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(children: [
          if (canStart)
            RtButton(
              label: '▶ Iniciar recorrido',
              isLoading: tracking.isLoading,
              onPressed: () async {
                await ref.read(trackingProvider.notifier).startTrip(route.id);
                if (context.mounted) context.go('/trip/active');
              },
            ),
          if (isActive)
            RtButton(
              label: '📍 Ver recorrido activo',
              onPressed: () => context.go('/trip/active'),
            ),
          const SizedBox(height: 8),
          RtButton(
            label: 'Volver',
            variant: RtButtonVariant.outline,
            height: 44,
            onPressed: () => context.pop(),
          ),
        ]),
      ),
    ]);
  }

  String _statusLabel(RouteStatus s) => switch (s) {
        RouteStatus.inProgress => '● EN CURSO',
        RouteStatus.completed  => '✓ COMPLETADA',
        RouteStatus.cancelled  => 'CANCELADA',
        RouteStatus.pending    => 'PENDIENTE',
      };
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'SpaceMono')),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontFamily: 'SpaceMono')),
          ]),
        ),
      );
}

class _StopItem extends StatelessWidget {
  final StopModel stop;
  final bool isLast;
  const _StopItem({required this.stop, required this.isLast});

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    switch (stop.status) {
      case StopStatus.completed: dotColor = AppColors.green; break;
      case StopStatus.arrived:   dotColor = AppColors.accent; break;
      case StopStatus.skipped:   dotColor = AppColors.textMuted; break;
      default:                   dotColor = AppColors.textMuted;
    }
    if (stop.order == 1) dotColor = AppColors.accent;

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 3), decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        if (!isLast)
          Container(width: 2, height: 36, color: AppColors.border),
      ]),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stop.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(stop.address, style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
          ]),
        ),
      ),
    ]);
  }
}
