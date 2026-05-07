import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../features/routes/domain/route_model.dart';
import 'status_pill.dart';

class RouteCardWidget extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onTap;

  const RouteCardWidget({super.key, required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = route.status == RouteStatus.inProgress;
    final isDone   = route.status == RouteStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDone ? 0.55 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: isActive ? AppColors.accent : AppColors.border),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: IntrinsicHeight(
              child: Row(children: [
                Container(
                  width: 4,
                  color: isActive
                      ? AppColors.accent
                      : isDone
                          ? AppColors.green
                          : AppColors.border,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              route.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrim),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusPill(label: _pillLabel(route.status), status: route.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(spacing: 14, children: [
                        _meta('🕐', DateFormat('HH:mm').format(route.scheduledStart)),
                        _meta('📍', '${route.totalStops} paradas'),
                        _meta('📏', '${route.estimatedKm.toStringAsFixed(0)} km'),
                      ]),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(String icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
        ],
      );

  String _pillLabel(RouteStatus s) => switch (s) {
        RouteStatus.inProgress => '● EN CURSO',
        RouteStatus.completed  => '✓ COMPLETADA',
        RouteStatus.cancelled  => 'CANCELADA',
        RouteStatus.pending    => 'PENDIENTE',
      };
}
