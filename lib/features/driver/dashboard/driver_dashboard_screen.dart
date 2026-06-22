import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/navigation/app_menu_config.dart';
import '../../../core/navigation/qayda_nav_drawer.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/extensions/num_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/enums.dart';
import '../../auth/application/auth_controller.dart';
import '../../ride/map/map_controller.dart';
import 'application/driver_controller.dart';

/// Driver home (Stitch `driver_dashboard_online_state_verified`).
///
/// Full-screen map with a glass status header, a fixed bottom sheet showing
/// today's metrics and the online/offline toggle, and a navigation Drawer.
/// Going online surfaces a simulated incoming order, which routes to
/// `/d/order/incoming`.
class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // When an offer arrives, jump to the incoming-order screen.
    ref.listen<DriverState>(driverControllerProvider, (prev, next) {
      final order = next.order;
      if (prev?.order == null &&
          order != null &&
          order.stage == DriverOrderStage.incoming) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(Routes.dOrderIncoming);
        });
      }
    });

    final state = ref.watch(driverControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const _DriverDrawer(),
      body: Stack(
        children: [
          const Positioned.fill(child: QaydaMap()),
          // ── Map controls — TOP RIGHT ─────────────────────────────────
          Positioned(
            right: AppSpacing.page,
            top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
            child: MapControls(
              onLayers: () {},
              onMyLocation: () =>
                  ref.read(mapControllerProvider.notifier).locateUser(),
            ),
          ),

          // ── Draggable bottom sheet (status bar is INSIDE) ───────────
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.30,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.30, 0.42, 0.85],
            builder: (ctx, scrollController) => _DashboardSheet(
              state: state,
              scrollController: scrollController,
              onOpenDrawer: () => Scaffold.of(context).openDrawer(),
              onMore: () => _showMore(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showMore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скоро / Жақын арада')),
    );
  }
}

class _DashboardSheet extends ConsumerWidget {
  final DriverState state;
  final ScrollController? scrollController;
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onMore;

  const _DashboardSheet({
    required this.state,
    this.scrollController,
    this.onOpenDrawer,
    this.onMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final online = state.isOnline;
    final notifier = ref.read(driverControllerProvider.notifier);
    final compact = MediaQuery.sizeOf(context).width < 360;
    final gap = compact ? AppSpacing.sm : AppSpacing.gutter;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.page, 0, AppSpacing.page, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DragHandle(),

                // ── Status row (moves WITH sheet) ──────────────────────
                Row(
                  children: [
                    _GlassCircleButton(
                      icon: Icons.menu,
                      onTap: onOpenDrawer ?? () {},
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Center(child: _StatusPill(online: online)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _GlassCircleButton(
                      icon: Icons.more_vert,
                      onTap: onMore ?? () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Status text ────────────────────────────────────────
                Text(
                  online ? 'Вы в сети' : 'Вы не в сети',
                  style: AppTypography.headlineMobile,
                ),
                const SizedBox(height: 2),
                Text(
                  online ? 'Желідесіз' : 'Желіде емес',
                  style: AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Metrics ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        value: state.rating.toStringAsFixed(2),
                        label: 'Рейтинг',
                        icon: Icons.star,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push(Routes.dEarnings),
                        child: MetricTile(
                          value: state.earningsToday.tenge,
                          label: 'Табыс',
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: MetricTile(
                        value: '${state.tripsToday}',
                        label: 'Заказы',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Online/offline toggle ──────────────────────────────
                if (online)
                  _OfflineToggle(onTap: notifier.goOffline)
                else
                  PrimaryActionButton(
                    label: 'Выйти на линию',
                    labelSecondary: 'Желіге шығу',
                    onPressed: notifier.goOnline,
                  ),

                const SizedBox(height: AppSpacing.lg),
                Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                const SizedBox(height: AppSpacing.md),

                // ── Extra content (visible when sheet expanded) ────────
                Text(
                  'БЫСТРЫЕ ДЕЙСТВИЯ',
                  style: AppTypography.labelMd.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _QuickAction(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Кошелёк',
                      labelKk: 'Əмиян',
                      onTap: () => context.push(Routes.dWallet),
                    ),
                    SizedBox(width: gap),
                    _QuickAction(
                      icon: Icons.bar_chart,
                      label: 'Статистика',
                      labelKk: 'Статистика',
                      onTap: () => context.push(Routes.dEarnings),
                    ),
                    SizedBox(width: gap),
                    _QuickAction(
                      icon: Icons.history,
                      label: 'История',
                      labelKk: 'Тарих',
                      onTap: () => context.push(Routes.dEarningsHistory),
                    ),
                    SizedBox(width: gap),
                    _QuickAction(
                      icon: Icons.person_outline,
                      label: 'Профиль',
                      labelKk: 'Профиль',
                      onTap: () => context.push(Routes.dProfile),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Work zone info ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: online
                        ? AppColors.online.withValues(alpha: 0.1)
                        : scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: online
                          ? AppColors.online.withValues(alpha: 0.3)
                          : scheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        online ? Icons.location_on : Icons.location_off_outlined,
                        color: online ? AppColors.online : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              online ? 'Алматы • Высокий спрос' : 'Алматы • Вы офлайн',
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                                color: online ? AppColors.online : scheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              online
                                  ? 'Медеу: x1.4 • Центр: x1.2'
                                  : 'Выйдите на линию чтобы принимать заказы',
                              style: AppTypography.labelMd.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Black "Уйти с линии" toggle (online → offline).
class _OfflineToggle extends StatelessWidget {
  final VoidCallback onTap;
  const _OfflineToggle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: BilingualText(
            primary: 'Уйти с линии',
            secondary: 'Желіден шығу',
            primaryStyle:
                AppTypography.headlineMd.copyWith(color: scheme.onPrimary),
            secondaryStyle: AppTypography.bodyMd
                .copyWith(color: scheme.onPrimary.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String labelKk;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.labelKk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.purple, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTypography.labelMd.copyWith(fontSize: 10),
              ),
              Text(
                labelKk,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTypography.labelMd.copyWith(
                  fontSize: 9,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool online;
  const _StatusPill({required this.online});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final maxWidth = MediaQuery.sizeOf(context).width -
        (AppSpacing.page * 2) -
        112 -
        (AppSpacing.sm * 2);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth < 96 ? 96 : maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: online ? AppColors.online : scheme.outline,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  online ? 'В СЕТИ • ЖЕЛІДЕ' : 'НЕ В СЕТИ • ЖЕЛІДЕ ЕМЕС',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: scheme.surface.withValues(alpha: 0.75),
          shape: CircleBorder(
            side:
                BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, color: scheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverDrawer extends ConsumerWidget {
  const _DriverDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final auth  = ref.watch(authControllerProvider);
    final phone = auth.phone ?? '+7 ••• ••• •• ••';

    void goProfile() {
      Navigator.of(context).pop();
      context.push(Routes.dProfile);
    }

    return QaydaNavDrawer(
      usePush: true,
      header: InkWell(
        onTap: goProfile,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.surfaceContainerHighest,
                child: Icon(Icons.person, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.displayName.isNotEmpty
                          ? auth.displayName
                          : 'Водитель',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
      entries: kDriverFullDrawerEntries,
      footer: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.logout, color: scheme.error),
        title: Text(
          'Выйти / Шығу',
          style: AppTypography.bodyLg.copyWith(color: scheme.error),
        ),
        onTap: () {
          Navigator.of(context).pop();
          ref.read(authControllerProvider.notifier).signOut();
        },
      ),
    );
  }
}
