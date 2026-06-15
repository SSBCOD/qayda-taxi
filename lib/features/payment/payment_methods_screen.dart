import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/payment_method.dart';
import 'application/payment_controller.dart';
import 'widgets/payment_brand_icon.dart';

/// Payment methods list (Stitch `payment_methods`).
///
/// KZ market: cash, Kaspi Gold, Freedom, Halyk — no Apple Pay / USD.
class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final payment = ref.watch(paymentControllerProvider);
    final ctrl = ref.read(paymentControllerProvider.notifier);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: QaydaAppBar(
        title: 'Способ оплаты / Төлем тәсілі',
        glass: false,
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              itemCount: payment.methods.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, i) {
                final m = payment.methods[i];
                final selected = m.id == payment.selectedId;
                return _MethodRow(
                  method: m,
                  selected: selected,
                  onTap: () => ctrl.select(m.id),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: scheme.surfaceContainerLow,
                  borderRadius: AppRadii.cardRadius,
                  child: InkWell(
                    borderRadius: AppRadii.cardRadius,
                    onTap: () => context.push(Routes.paymentAdd),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              'Добавить карту / Карта қосу',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyLg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                PrimaryActionButton(
                  label: 'Готово',
                  labelSecondary: 'Дайын',
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodRow({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            PaymentBrandIcon(method: method),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '${method.displayLabelRu} / ${method.displayLabelKk}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLg,
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF34C759), size: 22),
          ],
        ),
      ),
    );
  }
}
