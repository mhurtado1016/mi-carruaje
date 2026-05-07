import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/rt_button.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idCtrl  = TextEditingController();
  final _pwCtrl  = TextEditingController();
  bool _pwVisible = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      if (next.isAuthenticated) context.go('/home');
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!, style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 12)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 32),

            // Brand
            Column(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(child: Text('🚛', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 14),
              const Text(
                'RouteTrack',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Portal de conductores',
                style: TextStyle(fontSize: 11, fontFamily: 'SpaceMono', color: AppColors.textMuted),
              ),
            ]),

            const SizedBox(height: 40),

            // Empleado
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('EMPLEADO / USUARIO', style: TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _idCtrl,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrim),
                decoration: InputDecoration(
                  hintText: 'ej. carlos.martinez',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
                  filled: true, fillColor: AppColors.surface2,
                ),
              ),
            ]),

            const SizedBox(height: 14),

            // Contraseña
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CONTRASEÑA', style: TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _pwCtrl,
                obscureText: !_pwVisible,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrim),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
                  filled: true, fillColor: AppColors.surface2,
                  suffixIcon: IconButton(
                    icon: Icon(_pwVisible ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 18),
                    onPressed: () => setState(() => _pwVisible = !_pwVisible),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            RtButton(
              label: '▶ Ingresar',
              isLoading: auth.isLoading,
              onPressed: () => ref.read(authProvider.notifier).login(_idCtrl.text.trim(), _pwCtrl.text),
            ),

            const SizedBox(height: 12),

            RtButton(
              label: '⚡ Modo Demo',
              variant: RtButtonVariant.outline,
              height: 44,
              onPressed: () => ref.read(authProvider.notifier).loginDemo(),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text('v1.0 · Empresa Logística SA', style: TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
            ),
          ]),
        ),
      ),
    );
  }
}
