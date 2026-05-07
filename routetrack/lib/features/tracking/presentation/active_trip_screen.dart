import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/rt_button.dart';
import '../../../shared/widgets/stats_box.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../core/network/connectivity_service.dart' as connSvc;
import 'tracking_provider.dart';

class ActiveTripScreen extends ConsumerWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingProvider);
    final connectivity = ref.watch(connSvc.connectivityProvider);

    if (!tracking.isTracking) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('📍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('Sin recorrido activo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Inicia un recorrido desde la lista de rutas.', style: TextStyle(fontSize: 12, fontFamily: 'SpaceMono', color: AppColors.textMuted), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: RtButton(label: 'Ver rutas', onPressed: () => context.go('/home')),
              ),
            ]),
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.go('/home'),
                  child: const Text('←', style: TextStyle(fontSize: 22)),
                ),
                const Text('Recorrido activo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(width: 22),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Offline banner
                connectivity.when(
                  data: (online) => online ? const SizedBox.shrink() : _OfflineBanner(pending: tracking.pendingPoints),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Map placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Stack(children: [
                    CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
                    const Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('📍', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text('GPS activo', style: TextStyle(fontSize: 11, color: AppColors.accent)),
                      ]),
                    ),
                    Positioned(
                      top: 8, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('● EN VIVO', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 14),

                // Recording pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    _BlinkDot(),
                    const SizedBox(width: 8),
                    const Text('Grabando recorrido', style: TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.accent)),
                    const Spacer(),
                    Text(
                      _formatElapsed(tracking.elapsed),
                      style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted),
                    ),
                  ]),
                ),

                const SizedBox(height: 14),

                // Stats
                Row(children: [
                  Expanded(child: StatsBox(value: _formatElapsed(tracking.elapsed), label: 'tiempo')),
                  const SizedBox(width: 8),
                  Expanded(child: StatsBox(value: '${tracking.distanceKm.toStringAsFixed(1)}km', label: 'distancia')),
                  const SizedBox(width: 8),
                  Expanded(child: StatsBox(value: '${tracking.speedKmh.toStringAsFixed(0)}km/h', label: 'velocidad')),
                ]),

                const SizedBox(height: 24),

                RtButton(
                  label: '⏹ Finalizar recorrido',
                  variant: RtButtonVariant.danger,
                  isLoading: tracking.isLoading,
                  onPressed: () => _confirmEnd(context, ref),
                ),
                const SizedBox(height: 8),
                RtButton(
                  label: 'Ver mapa completo',
                  variant: RtButtonVariant.outline,
                  height: 44,
                  onPressed: () => context.push('/trip/active/map'),
                ),
              ]),
            ),
          ),
          const AppBottomNavBar(currentIndex: 1),
        ]),
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context, WidgetRef ref) async {
    final tracking = ref.read(trackingProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Finalizar recorrido', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Confirmas que quieres finalizar?', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          _SummaryRow('⏱ Tiempo', _formatElapsed(tracking.elapsed)),
          _SummaryRow('📏 Distancia', '${tracking.distanceKm.toStringAsFixed(1)} km'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warn, foregroundColor: Colors.white),
            child: const Text('Finalizar', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final trip = await ref.read(trackingProvider.notifier).endTrip();
      if (trip != null && context.mounted) {
        context.go('/trip/${trip.id}/summary');
      }
    }
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'SpaceMono')),
          ],
        ),
      );
}

class _OfflineBanner extends StatelessWidget {
  final int pending;
  const _OfflineBanner({required this.pending});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warn.withOpacity(0.12),
          border: Border.all(color: AppColors.warn.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Text('📶', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sin conexión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warn)),
              Text('$pending puntos en cola', style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
            ]),
          ),
        ]),
      );
}

class _BlinkDot extends StatefulWidget {
  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _ctrl,
        child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
      );
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.15)
      ..strokeWidth = 1;
    const step = 22.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
