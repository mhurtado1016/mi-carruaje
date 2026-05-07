import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../tracking/domain/trip_model.dart';
import 'history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histAsync = ref.watch(tripHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: CustomScrollView(slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Historial', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    // Filter chips
                    Row(children: [
                      _FilterChip(label: 'Semana', active: true),
                      const SizedBox(width: 6),
                      _FilterChip(label: 'Mes'),
                      const SizedBox(width: 6),
                      _FilterChip(label: 'Todo'),
                    ]),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),

              histAsync.when(
                data: (trips) {
                  if (trips.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text('Sin viajes registrados', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, color: AppColors.textMuted)),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _TripItem(trip: trips[i], onTap: () => context.push('/history/${trips[i].id}')),
                        childCount: trips.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.accent))),
                error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.danger)))),
              ),
            ]),
          ),
          const AppBottomNavBar(currentIndex: 2),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.accent.withOpacity(0.1) : AppColors.surface2,
          border: Border.all(color: active ? AppColors.accent.withOpacity(0.3) : AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10, fontFamily: 'SpaceMono',
            color: active ? AppColors.accent : AppColors.textMuted,
          ),
        ),
      );
}

class _TripItem extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  const _TripItem({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('dd').format(trip.startedAt);
    final mon = DateFormat('MMM', 'es').format(trip.startedAt).toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          // Date box
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, height: 1)),
              Text(mon, style: const TextStyle(fontSize: 8, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Viaje #${trip.id.substring(0, 8)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              Text(
                '${DateFormat('HH:mm').format(trip.startedAt)} · ${trip.totalDurationMinutes ?? 0}min',
                style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted),
              ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${trip.distanceKm.toStringAsFixed(1)}km',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'SpaceMono', color: AppColors.accent),
            ),
            const Text('km', style: TextStyle(fontSize: 8, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }
}
