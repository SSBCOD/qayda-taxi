import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/extensions/num_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/ride.dart';
import '../../../data/models/tariff.dart';
import '../../ride/application/ride_controller.dart';

/// Ride completed + payment summary. Shows the paid price, the driver/vehicle
/// recap, a tariff/method grid, the A→B timeline and the CTA into rating.
class RideCompletedScreen extends ConsumerWidget {
  const RideCompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(rideControllerProvider);
    if (ride == null) {
      return const Scaffold(body: Center(child: AppLoader(size: 32)));
    }

    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Поездка завершена',
        subtitle: 'Сапар аяқталды',
        onBack: () => _home(context, ref),
      ),
      body: Column(
        children: [
          const SizedBox(
              height: 140, width: double.infinity, child: QaydaMap()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: _Summary(ride: ride, onRate: () => _rate(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _home(BuildContext context, WidgetRef ref) {
    ref.read(rideControllerProvider.notifier).reset();
    context.go(Routes.pHome);
  }

  void _rate(BuildContext context) => context.go(Routes.pRideRate);
}

class _Summary extends StatelessWidget {
  final Ride ride;
  final VoidCallback onRate;
  const _Summary({required this.ride, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final driver = ride.driver;

    return Column(
      children: [
        // Paid badge.
        StatusPill(
          text: 'Оплачено | Төленді',
          background: scheme.surfaceContainerHigh,
          foreground: scheme.onSurface,
        ),
        const SizedBox(height: AppSpacing.md),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            ride.priceTenge.tenge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.displayLg,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${ride.durationMin} мин (${ride.distanceKm} км)',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Driver recap.
        if (driver != null)
          QaydaCard(
            color: scheme.surfaceContainerLow,
            child: DriverCard(
              name: driver.name,
              rating: driver.rating,
              vehicle: driver.carModel,
              plate: driver.plate,
            ),
          ),
        const SizedBox(height: AppSpacing.gutter),
        // Tariff / method grid.
        Row(
          children: [
            Expanded(
              child: _MetricBox(
                label: 'ТАРИФ | ТАРИФ',
                value: ride.tier.titleRu,
              ),
            ),
            const SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: _MetricBox(
                label: 'СПОСОБ | ТӘСІЛІ',
                value: ride.paymentLabel,
                icon: Icons.credit_card,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // A → B.
        QaydaCard(
          child: RouteTimeline(
            originLabel: 'Откуда | Қайдан',
            originValue: ride.origin.titleRu,
            destinationLabel: 'Куда | Қайда',
            destinationValue: ride.destination.titleRu,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryActionButton(
          label: 'Оценить и оставить чаевые',
          labelSecondary: 'Бағалау және шайпұл қалдыру',
          onPressed: onRate,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ride.receiptId != null
              ? 'Чек ${ride.receiptId} отправлен на почту | Түбіртек жіберілді'
              : 'Чек отправлен на почту | Түбіртек поштаңызға жіберілді',
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  const _MetricBox({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLg
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
