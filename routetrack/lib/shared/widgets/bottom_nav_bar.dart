import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.surface,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            _NavItem(icon: '🗺', label: 'Rutas',    index: 0, current: currentIndex, onTap: () => context.go('/home')),
            _NavItem(icon: '📍', label: 'GPS',      index: 1, current: currentIndex, onTap: () => context.go('/trip/active')),
            _NavItem(icon: '📊', label: 'Historial', index: 2, current: currentIndex, onTap: () => context.go('/history')),
            _NavItem(icon: '👤', label: 'Perfil',   index: 3, current: currentIndex, onTap: () => context.go('/profile')),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontFamily: 'SpaceMono',
              color: active ? AppColors.accent : AppColors.textMuted,
            ),
          ),
        ]),
      ),
    );
  }
}
