import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(children: [
              GestureDetector(onTap: () => context.pop(), child: const Text('←', style: TextStyle(fontSize: 22))),
              const SizedBox(width: 12),
              const Expanded(child: Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                _NotifItem(icon: '🗺', title: 'Ruta asignada', body: 'Se te asignó Ruta Norte — A para hoy 09:00', time: 'Hace 2h', unread: true),
                _NotifItem(icon: '🚦', title: 'Tráfico en ruta', body: 'Demora estimada de 15 min en Av. Principal', time: 'Hace 3h', unread: true),
                _NotifItem(icon: '✅', title: 'Sincronización completa', body: '24 puntos GPS sincronizados exitosamente', time: 'Hace 1d'),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final String icon;
  final String title;
  final String body;
  final String time;
  final bool unread;

  const _NotifItem({required this.icon, required this.title, required this.body, required this.time, this.unread = false});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          border: Border.all(color: unread ? AppColors.accent.withOpacity(0.2) : AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(body, style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted, height: 1.5)),
              const SizedBox(height: 5),
              Text(time, style: const TextStyle(fontSize: 9, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
            ]),
          ),
          if (unread)
            Container(width: 7, height: 7, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
        ]),
      );
}
