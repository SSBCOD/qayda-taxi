import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../ride/map/map_controller.dart';
import '../dashboard/application/driver_controller.dart';

/// En route to passenger (Stitch `en_route_to_passenger`).
///
/// Navigation banner + live map (simulated car driving to pickup) + a bottom
/// sheet with the ETA, passenger and pickup address. "Я на месте" confirms
/// arrival and moves to boarding.
class DriverEnrouteScreen extends ConsumerWidget {
  const DriverEnrouteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(driverControllerProvider).order;

    if (order == null) {
      return const Scaffold(body: Center(child: AppLoader(size: 32)));
    }

    void onArrived() {
      HapticFeedback.mediumImpact();
      ref.read(driverControllerProvider.notifier).arrivedAtPickup();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: QaydaMap()),
          // Floating navigation banner.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: _NavBanner(streetRu: order.pickupTitle),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _EnrouteSheet(onArrived: onArrived),
          ),
        ],
      ),
    );
  }
}

class _NavBanner extends StatelessWidget {
  final String streetRu;
  const _NavBanner({required this.streetRu});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.turn_right, color: scheme.onPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ЧЕРЕЗ 200 М / 200 М КЕЙІН',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMd
                            .copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(streetRu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineMd),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.sensors, size: 20, color: scheme.primary),
                  const SizedBox(height: 2),
                  Text('LIVE',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnrouteSheet extends ConsumerWidget {
  final VoidCallback onArrived;
  const _EnrouteSheet({required this.onArrived});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final order = ref.watch(driverControllerProvider).order;
    if (order == null) return const SizedBox.shrink();
    final map = ref.watch(mapControllerProvider);
    final etaMin = map.isSimulating ? map.remainingEtaMin : order.pickupEtaMin;
    final distanceKm =
        map.isSimulating ? map.remainingDistanceKm : order.pickupDistanceKm;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.58;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$etaMin мин',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.displayLg,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '$distanceKm км',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyLg
                              .copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      const Spacer(),
                      _CircleIcon(
                        icon: Icons.sos,
                        color: scheme.error,
                        background: scheme.error.withValues(alpha: 0.1),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: AppSpacing.md),
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
                              style: AppTypography.headlineMd,
                            ),
                            Text(order.pickupTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMd
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      _CircleIcon(
                        icon: Icons.chat_bubble_outline,
                        color: scheme.primary,
                        background: scheme.surfaceContainerHigh,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Позвонить / Хабарласу',
                          icon: Icons.call,
                          expanded: false,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gutter),
                      Expanded(
                        flex: 2,
                        child: PrimaryActionButton(
                          label: 'Я на месте',
                          labelSecondary: 'Мен келдім',
                          onPressed: onArrived,
                        ),
                      ),
                    ],
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

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  const _CircleIcon({
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
            width: 48, height: 48, child: Icon(icon, color: color, size: 22)),
      ),
    );
  }
}
