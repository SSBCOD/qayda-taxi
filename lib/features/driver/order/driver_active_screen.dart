import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/driver_order.dart';
import '../../ride/map/map_controller.dart';
import '../dashboard/application/driver_controller.dart';

/// Active ride — driver view (Stitch `ride_in_progress_driver`).
///
/// Map with the simulated trip + a floating ETA header + bottom sheet with the
/// passenger, destination and "Завершить поездку" to finish.
class DriverActiveScreen extends ConsumerWidget {
  const DriverActiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(driverControllerProvider).order;

    if (order == null) {
      return const Scaffold(body: Center(child: AppLoader(size: 32)));
    }

    void onFinish() {
      HapticFeedback.mediumImpact();
      ref.read(driverControllerProvider.notifier).finishTrip();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: QaydaMap()),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.page),
              child: _ActiveHeader(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _ActiveSheet(order: order, onFinish: onFinish),
          ),
        ],
      ),
    );
  }
}

class _ActiveHeader extends ConsumerWidget {
  const _ActiveHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final order = ref.watch(driverControllerProvider).order;
    if (order == null) return const SizedBox.shrink();
    final map = ref.watch(mapControllerProvider);
    final etaMin =
        map.isSimulating ? map.remainingEtaMin : order.tripDurationMin;
    final distanceKm =
        map.isSimulating ? map.remainingDistanceKm : order.tripDistanceKm;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: scheme.primary, shape: BoxShape.circle),
                child:
                    Icon(Icons.navigation, color: scheme.onPrimary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$etaMin мин • $distanceKm км',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd,
                    ),
                    Text(
                      'Активная поездка / Белсенді сапар',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSheet extends StatelessWidget {
  final DriverOrder order;
  final VoidCallback onFinish;
  const _ActiveSheet({required this.order, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.58;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 30,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DragHandle(),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: scheme.surfaceContainerHigh,
                        child:
                            Icon(Icons.person, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.passengerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineMobile,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF007AFF),
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'В пути / Жолда',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.labelMd.copyWith(
                                        color: scheme.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _Circle(
                          icon: Icons.chat_bubble_outline,
                          background: scheme.surfaceContainer,
                          color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      _Circle(
                          icon: Icons.emergency_outlined,
                          background: scheme.error.withValues(alpha: 0.12),
                          color: scheme.error),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF007AFF)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'КУДА / БАРАТЫН ЖЕРІ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelMd
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                            Text(
                              order.destTitleRu,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineMobile,
                            ),
                            Text(
                              order.destSubtitleRu,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMd
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryActionButton(
                    label: 'Завершить поездку',
                    labelSecondary: 'Сапарды аяқтау',
                    onPressed: onFinish,
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

class _Circle extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color color;
  const _Circle(
      {required this.icon, required this.background, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
