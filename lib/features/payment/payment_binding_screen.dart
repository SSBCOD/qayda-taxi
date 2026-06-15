import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/extensions/num_ext.dart';
import '../../core/pricing/kz_taxi_pricing.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/enums.dart';
import '../../data/models/payment_method.dart';
import '../../data/models/tariff.dart';
import '../passenger/route_tariff/tariff_providers.dart';
import '../ride/application/ride_controller.dart';
import 'application/payment_controller.dart';
import 'widgets/payment_brand_icon.dart';

/// Post-ride payment + multicard binding (Stitch `payment_multicard_binding`).
///
/// Shows the trip fare in ₸ and lets the user pick a KZ card. Reads the active
/// [Ride] when available; otherwise falls back to the mock Almaty trip price.
class PaymentBindingScreen extends ConsumerWidget {
  const PaymentBindingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final ride = ref.watch(rideControllerProvider);
    final payment = ref.watch(paymentControllerProvider);
    final ctrl = ref.read(paymentControllerProvider.notifier);

    final tier = ride?.tier ?? RideTier.comfort;
    final price = ride?.priceTenge ??
        KzTaxiPricing.fareTenge(
          tier,
          distanceKm: kMockDistanceKm,
          durationMin: kMockDurationMin,
        );
    final tierLabel = '${tier.titleRu} / ${tier.titleKk}';
    final selected = payment.selected;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: QaydaAppBar(
        title: 'Оплата / Төлем',
        glass: false,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          const Text(
            'Спасибо за поездку! / Сапар үшін рахмет!',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineMobile,
          ),
          const SizedBox(height: 4),
          Text(
            'Выберите способ оплаты / Төлем тәсілін таңдаңыз',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Fare summary.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              children: [
                Text(
                  'Тариф $tierLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    price.tenge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.displayLg,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PaymentBrandIcon(method: selected, size: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          selected.displayLabelRu,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd,
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 18, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'ПРИВЯЗАННЫЕ КАРТЫ / ТІРКЕЛГЕН КАРТАЛАР',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd.copyWith(
              color: scheme.secondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ...payment.methods
              .where((m) => m.kind != PaymentMethodKind.cash)
              .map((m) {
            final isSelected = m.id == payment.selectedId;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadii.button),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.button),
                  onTap: () => ctrl.select(m.id),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                      border: Border.all(
                        color: isSelected
                            ? scheme.primary
                            : scheme.outlineVariant.withValues(alpha: 0.4),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        PaymentBrandIcon(method: m),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            '${m.displayLabelRu} / ${m.displayLabelKk}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMd,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF34C759), size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          TextButton(
            onPressed: () => context.push(Routes.paymentAdd),
            child: const Text(
              '+ Добавить новую карту / + Жаңа карта қосу',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          PrimaryActionButton(
            label: 'Оплатить',
            labelSecondary: 'Төлеу',
            onPressed: () async {
              if (ride?.status == RideStatus.completed) {
                await ref
                    .read(rideControllerProvider.notifier)
                    .processPayment();
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Оплачено ${price.tenge} через ${selected.displayLabelRu}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              if (ride != null) {
                context.go(Routes.pRideCompleted);
              } else {
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
