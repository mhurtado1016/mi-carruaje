import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum RtButtonVariant { primary, outline, danger, ghost }

class RtButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final RtButtonVariant variant;
  final bool isLoading;
  final double? height;

  const RtButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = RtButtonVariant.primary,
    this.isLoading = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? 52.0;
    switch (variant) {
      case RtButtonVariant.primary:
        return SizedBox(
          width: double.infinity,
          height: h,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        );

      case RtButtonVariant.outline:
        return SizedBox(
          width: double.infinity,
          height: h,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        );

      case RtButtonVariant.danger:
        return SizedBox(
          width: double.infinity,
          height: h,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warn,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(label, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        );

      case RtButtonVariant.ghost:
        return SizedBox(
          width: double.infinity,
          height: h,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(label, style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 12)),
          ),
        );
    }
  }
}
