import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

class GpsSettingsScreen extends StatefulWidget {
  const GpsSettingsScreen({super.key});

  @override
  State<GpsSettingsScreen> createState() => _GpsSettingsScreenState();
}

class _GpsSettingsScreenState extends State<GpsSettingsScreen> {
  int _intervalSeconds = 8;
  bool _backgroundTracking = true;
  bool _filterNoise = true;
  bool _batteryOptimization = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Configuración GPS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader('INTERVALO DE CAPTURA'),
          const SizedBox(height: 12),
          _Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Cada cuántos segundos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text('${_intervalSeconds}s', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent)),
              ]),
              const SizedBox(height: 8),
              Slider(
                value: _intervalSeconds.toDouble(),
                min: 3, max: 30, divisions: 9,
                activeColor: AppColors.accent,
                inactiveColor: AppColors.border,
                onChanged: (v) => setState(() => _intervalSeconds = v.round()),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('3s (preciso)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                Text('30s (batería)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          _SectionHeader('OPCIONES'),
          const SizedBox(height: 12),
          _Card(
            child: Column(children: [
              _Toggle(
                title: 'Tracking en segundo plano',
                subtitle: 'GPS activo con pantalla apagada',
                value: _backgroundTracking,
                onChanged: (v) => setState(() => _backgroundTracking = v),
              ),
              const Divider(height: 1),
              _Toggle(
                title: 'Filtrar ruido GPS',
                subtitle: 'Descartar puntos con precisión > 50m',
                value: _filterNoise,
                onChanged: (v) => setState(() => _filterNoise = v),
              ),
              const Divider(height: 1),
              _Toggle(
                title: 'Optimización de batería',
                subtitle: 'Aumentar intervalo cuando batería < 15%',
                value: _batteryOptimization,
                onChanged: (v) => setState(() => _batteryOptimization = v),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración guardada'), backgroundColor: AppColors.green),
              );
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Guardar cambios', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      );
}

class _Toggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrim)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ]),
      );
}
