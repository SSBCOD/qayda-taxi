import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/ride.dart';
import '../../ride/application/ride_controller.dart';
import '../../ride/map/map_controller.dart';

/// Active ride — trip in progress. Map background with the live (simulated)
/// car, plus a bottom sheet with remaining time/distance, the destination,
/// the driver line and quick actions. When the shared status becomes
/// `completed`, the summary/payment screen takes over.
class RideActiveScreen extends ConsumerWidget {
  const RideActiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<Ride?>(rideControllerProvider, (prev, next) {
      if (prev?.status != RideStatus.completed &&
          next?.status == RideStatus.completed) {
        context.go(Routes.paymentBinding);
      }
    });

    final ride = ref.watch(rideControllerProvider);
    if (ride == null) {
      return const Scaffold(body: Center(child: AppLoader(size: 32)));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: QaydaAppBar(
        title: 'Поездка в процессе',
        subtitle: 'Сапар үстінде',
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.sos, color: context.colors.error),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: QaydaMap()),
          Align(
            alignment: Alignment.bottomCenter,
            child: _ActiveSheet(ride: ride),
          ),
        ],
      ),
    );
  }
}

class _ActiveSheet extends ConsumerWidget {
  final Ride ride;
  const _ActiveSheet({required this.ride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final driver = ride.driver;
    final map = ref.watch(mapControllerProvider);
    final etaMin = map.isSimulating ? map.remainingEtaMin : ride.durationMin;
    final distanceKm =
        map.isSimulating ? map.remainingDistanceKm : ride.distanceKm;

    final maxHeight = MediaQuery.sizeOf(context).height * 0.64;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DragHandle(),
                  // Time + nav chip.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$etaMin мин',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineMobile,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Осталось $distanceKm км',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMd
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.navigation,
                                size: 16, color: scheme.primary),
                            const SizedBox(width: 6),
                            const Flexible(
                              child: Text(
                                'Навигация',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelMd,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Destination card.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.button),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.location_on,
                              color: scheme.onPrimary, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.gutter),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride.destination.titleRu,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyLg
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (ride.destination.titleKk != null)
                                Text(
                                  ride.destination.titleKk!,
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
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (driver != null)
                    DriverCard(
                      name: driver.name,
                      rating: driver.rating,
                      vehicle: driver.vehicleLineRu,
                      plate: driver.plate,
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _NeutralAction(
                            icon: Icons.call, label: 'Звонок', onTap: () {}),
                      ),
                      Expanded(
                        child: _NeutralAction(
                            icon: Icons.chat_bubble_outline,
                            label: 'Чат',
                            onTap: () {}),
                      ),
                      Expanded(
                        child: _NeutralAction(
                            icon: Icons.ios_share,
                            label: 'Поделиться',
                            onTap: () {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: 'Safety / Қауіпсіздік',
                    icon: Icons.security,
                    onPressed: () {},
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

class _NeutralAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NeutralAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd,
          ),
        ],
      ),
    );
  }
}
