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
          // Glass top header.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => _GlassCircleButton(
                      icon: Icons.menu,
                      onTap: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Center(
                      child: _StatusPill(online: state.isOnline),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _GlassCircleButton(
                    icon: Icons.more_vert,
                    onTap: () => _showMore(context),
                  ),
                ],
              ),
            ),
          ),
          // Right-side map controls — bottom right, above the sheet.
          Positioned(
            right: AppSpacing.page,
            bottom: 230,
            child: MapControls(
              onLayers: () {},
              onMyLocation: () =>
                  ref.read(mapControllerProvider.notifier).locateUser(),
            ),
          ),
          // Draggable bottom sheet.
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.22,
            maxChildSize: 0.65,
            snap: true,
            snapSizes: const [0.22, 0.32, 0.65],
            builder: (context, scrollController) =>
                _DashboardSheet(state: state, scrollController: scrollController),
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
  const _DashboardSheet({required this.state, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final online = state.isOnline;
    final notifier = ref.read(driverControllerProvider.notifier);
    final compact = MediaQuery.sizeOf(context).width < 360;
    final metricGap = compact ? AppSpacing.sm : AppSpacing.gutter;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.56;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DragHandle(),
                  Text(
                    online ? 'Вы в сети' : 'Вы не в сети',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineMobile,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    online ? 'Желідесіз' : 'Желіде емес',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMd
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: MetricTile(
                          value: state.rating.toStringAsFixed(2),
                          label: 'Рейтинг',
                          icon: Icons.star,
                        ),
                      ),
                      SizedBox(width: metricGap),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(Routes.dEarnings),
                          child: MetricTile(
                            value: state.earningsToday.tenge,
                            label: 'Табыс',
                          ),
                        ),
                      ),
                      SizedBox(width: metricGap),
                      Expanded(
                        child: MetricTile(
                          value: '${state.tripsToday}',
                          label: 'Заказы',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (online)
                    _OfflineToggle(onTap: notifier.goOffline)
                  else
                    PrimaryActionButton(
                      label: 'Выйти на линию',
                      labelSecondary: 'Желіге шығу',
                      onPressed: notifier.goOnline,
                    ),
                ],
              ),
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
