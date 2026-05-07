import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/routes/domain/route_model.dart';

class StatusPill extends StatefulWidget {
  final String label;
  final RouteStatus status;

  const StatusPill({super.key, required this.label, required this.status});

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (widget.status) {
      case RouteStatus.inProgress:
        bg = AppColors.accent.withOpacity(0.12);
        fg = AppColors.accent;
      case RouteStatus.completed:
        bg = AppColors.green.withOpacity(0.12);
        fg = AppColors.green;
      case RouteStatus.cancelled:
        bg = AppColors.danger.withOpacity(0.12);
        fg = AppColors.danger;
      case RouteStatus.pending:
        bg = AppColors.textMuted.withOpacity(0.12);
        fg = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (widget.status == RouteStatus.inProgress) ...[
          FadeTransition(
            opacity: _ctrl,
            child: Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 9,
            fontFamily: 'SpaceMono',
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ]),
    );
  }
}
