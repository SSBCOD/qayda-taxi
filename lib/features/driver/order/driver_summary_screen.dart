import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/extensions/num_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../dashboard/application/driver_controller.dart';

/// Ride summary / earnings — driver (Stitch `ride_summary_earnings_driver`).
///
/// Confirms completion, shows the driver's income + a trip breakdown.
/// "Оценить пассажира" advances to `/d/order/rate`.
class DriverSummaryScreen extends ConsumerWidget {
  const DriverSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final order = ref.watch(driverControllerProvider).order;

    if (order == null) {
      return const Scaffold(body: Center(child: AppLoader(size: 32)));
    }

    void onRate() {
      HapticFeedback.mediumImpact();
      context.go(Routes.dOrderRate);
    }

    return Scaffold(
      appBar: const QaydaAppBar(title: 'Qayda'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: scheme.primary, shape: BoxShape.circle),
                    child: Icon(Icons.check_circle,
                        size: 40, color: scheme.onPrimary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Поездка завершена',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineMobile,
                  ),
                  Text(
                    'Сапар аяқталды',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineMd
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            QaydaCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      order.incomeTenge.tenge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.displayLg,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ВАШ ДОХОД / СІЗДІҢ ТАБЫСЫҢЫЗ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gutter),
            QaydaCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.surfaceContainerLow,
                    child: Icon(Icons.person, color: scheme.onSurfaceVariant),
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
                          style: AppTypography.bodyLg,
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: scheme.primary),
                            const SizedBox(width: 4),
                            Text(order.passengerRating.toStringAsFixed(1),
                                style: AppTypography.labelMd),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const _Circle(icon: Icons.chat_bubble_outline),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gutter),
            QaydaCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _BreakdownRow(
                    icon: Icons.route,
                    label: 'Дистанция / Қашықтық',
                    value: '${order.tripDistanceKm} км',
                    emphasize: true,
                  ),
                  _divider(scheme),
                  _BreakdownRow(
                    icon: Icons.schedule,
                    label: 'Время / Ұзақтығы',
                    value: '${order.tripDurationMin} мин',
                    emphasize: true,
                  ),
                  _divider(scheme),
                  _BreakdownRow(
                    label: 'Тариф / Тариф',
                    value: order.fareTenge.tenge,
                  ),
                  const SizedBox(height: AppSpacing.gutter),
                  _BreakdownRow(
                    label: 'Бонусы / Бонустар',
                    value: '+${order.bonusTenge.tenge}',
                    valueColor: scheme.primary,
                  ),
                  _divider(scheme),
                  _BreakdownRow(
                    icon: Icons.credit_card,
                    label: 'Оплата / Төлем',
                    valueWidget: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${order.paymentLabelRu} / ${order.paymentLabelKk}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMd
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
          child: PrimaryActionButton(
            label: 'Оценить пассажира',
            labelSecondary: 'Жолаушыны бағалау',
            onPressed: onRate,
          ),
        ),
      ),
    );
  }

  Widget _divider(ColorScheme scheme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.gutter),
        child: Divider(
            height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
      );
}

class _BreakdownRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool emphasize;
  final Color? valueColor;

  const _BreakdownRow({
    this.icon,
    required this.label,
    this.value,
    this.valueWidget,
    this.emphasize = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.gutter),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        if (valueWidget != null)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.42,
            ),
            child: valueWidget!,
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.34,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: emphasize
                    ? AppTypography.priceDisplay
                    : AppTypography.bodyMd.copyWith(
                        color: valueColor ?? scheme.onSurface,
                        fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final IconData icon;
  const _Circle({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Icon(icon, size: 20, color: scheme.primary),
    );
  }
}
