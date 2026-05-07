import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/rt_button.dart';
import '../../tracking/domain/trip_model.dart';
import 'history_provider.dart';

class TripSummaryScreen extends ConsumerWidget {
  final String tripId;
  const TripSummaryScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripSummaryProvider(tripId));

    return Scaffold(
      body: SafeArea(
        child: tripAsync.when(
          data: (trip) => _Body(trip: trip),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.danger))),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final TripModel trip;
  const _Body({required this.trip});

  @override
  Widget build(BuildContext context) {
    final duration = trip.totalDuration ?? Duration.zero;
    final hh = duration.inHours.toString().padLeft(2, '0');
    final mm = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    return Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(children: [
          GestureDetector(onTap: () => context.go('/history'), child: const Text('←', style: TextStyle(fontSize: 22))),
          const SizedBox(width: 12),
          const Expanded(child: Text('Resumen de viaje', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
        ]),
      ),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Top card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x1400E5A0), Color(0x140080FF)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.accent.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                const Text('Recorrido completado', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy · HH:mm', 'es').format(trip.startedAt),
                  style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted),
                ),
              ]),
            ),

            const SizedBox(height: 14),

            // Metrics grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.6,
              children: [
                _MetricCard('⏱', '$hh:$mm', 'Duración'),
                _MetricCard('📏', '${trip.distanceKm.toStringAsFixed(1)} km', 'Distancia'),
                _MetricCard('⚡', '${trip.avgSpeedKmh.toStringAsFixed(0)} km/h', 'Vel. prom.'),
                _MetricCard('📍', '${trip.stopsCompleted}', 'Paradas'),
              ],
            ),

            const SizedBox(height: 16),

            // Share
            RtButton(
              label: '↑ Compartir resumen',
              variant: RtButtonVariant.outline,
              height: 46,
              onPressed: () => Share.share(
                'Recorrido completado\n'
                'Duración: $hh:$mm\n'
                'Distancia: ${trip.distanceKm.toStringAsFixed(1)} km\n'
                'Velocidad prom: ${trip.avgSpeedKmh.toStringAsFixed(0)} km/h\n'
                'Paradas: ${trip.stopsCompleted}',
              ),
            ),
            const SizedBox(height: 8),
            RtButton(
              label: 'Volver al inicio',
              onPressed: () => context.go('/home'),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _MetricCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  const _MetricCard(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'SpaceMono', letterSpacing: -0.5)),
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontFamily: 'SpaceMono')),
        ]),
      );
}
