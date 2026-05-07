import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatsBox extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;

  const StatsBox({super.key, required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'SpaceMono',
            color: color ?? AppColors.accent,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontFamily: 'SpaceMono',
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ]),
    );
  }
}
