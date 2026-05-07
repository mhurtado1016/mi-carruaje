import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/route_card_widget.dart';
import '../../auth/presentation/auth_provider.dart';
import 'routes_provider.dart';

class RoutesHomeScreen extends ConsumerWidget {
  const RoutesHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(todayRoutesProvider);
    final driver = ref.watch(authProvider).driver;
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.surface2,
              onRefresh: () => ref.refresh(todayRoutesProvider.future),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Buenos días,', style: TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted)),
                              Text(
                                driver != null ? driver.name.split(' ').first : 'Conductor',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ]),
                            Container(
                              width: 38, height: 38,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.accent2, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  driver?.initials ?? '?',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Day card
                        routesAsync.when(
                          data: (routes) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    DateFormat('EEEE dd MMMM yyyy', 'es').format(now),
                                    style: const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text('Rutas asignadas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                ]),
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: Text(
                                      '${routes.length}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'MIS RUTAS',
                          style: TextStyle(fontSize: 10, fontFamily: 'SpaceMono', color: AppColors.textMuted, letterSpacing: 1),
                        ),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),

                  // Routes list
                  routesAsync.when(
                    data: (routes) {
                      if (routes.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No tienes rutas asignadas para hoy',
                              style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => RouteCardWidget(
                              route: routes[i],
                              onTap: () => context.push('/routes/${routes[i].id}'),
                            ),
                            childCount: routes.length,
                          ),
                        ),
                      );
                    },
                    loading: () => SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => _SkeletonCard(),
                          childCount: 3,
                        ),
                      ),
                    ),
                    error: (e, _) => SliverFillRemaining(
                      child: Center(
                        child: Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AppBottomNavBar(currentIndex: 0),
        ]),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}
