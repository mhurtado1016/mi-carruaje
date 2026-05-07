import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../auth/presentation/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(authProvider).driver;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Profile hero
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
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.accent2, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          driver?.initials ?? '?',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(driver?.name ?? 'Conductor', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(driver?.id ?? '', style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, children: [
                      _Tag(driver?.zone ?? 'Zona'),
                      _Tag(driver?.shift == 'day' ? 'Turno día' : 'Turno noche'),
                      _Tag(driver?.status == 'active' ? 'Activo' : 'Inactivo', color: AppColors.green),
                    ]),
                  ]),
                ),

                const SizedBox(height: 16),

                // Menu items
                _MenuItem(icon: '📊', label: 'Estadísticas', onTap: () => context.push('/profile/stats')),
                _MenuItem(icon: '⚙️', label: 'Configuración GPS', onTap: () => context.push('/profile/gps-settings')),
                _MenuItem(icon: '🔔', label: 'Notificaciones', onTap: () => context.push('/notifications')),
                _MenuItem(
                  icon: '🚪',
                  label: 'Cerrar sesión',
                  color: AppColors.danger,
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ]),
            ),
          ),
          const AppBottomNavBar(currentIndex: 3),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? color;
  const _Tag(this.label, {this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (color ?? AppColors.accent2).withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: color ?? AppColors.accent2)),
      );
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrim))),
            Text('›', style: TextStyle(fontSize: 16, color: color ?? AppColors.textMuted)),
          ]),
        ),
      );
}
