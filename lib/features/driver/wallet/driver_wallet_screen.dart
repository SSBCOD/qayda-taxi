import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/extensions/num_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/payment_method.dart';
import '../../payment/widgets/payment_brand_icon.dart';
import 'application/driver_wallet_providers.dart';

/// Driver wallet & payouts (Stitch `driver_wallet_payouts`).
///
/// Available balance in ₸, Kaspi Gold payout method, transaction history and
/// fake withdraw CTA.
class DriverWalletScreen extends ConsumerWidget {
  const DriverWalletScreen({super.key});

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final balance = ref.read(driverWalletBalanceProvider);
    final scheme = context.colors;

    final amount = await showDialog<num>(
      context: context,
      builder: (ctx) => _WithdrawDialog(maxAmount: balance),
    );
    if (amount == null || amount <= 0 || !context.mounted) return;

    final ok = await ref
        .read(driverWalletBalanceProvider.notifier)
        .withdraw(amount: amount);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Выведено ${amount.tenge} на Kaspi Gold / '
                    'Kaspi Gold-ға ${amount.tenge} шығарылды'
                : 'Недостаточно средств / Қаражат жеткіліксіз',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? null : scheme.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final wallet = ref.watch(driverWalletProvider);
    final balance = ref.watch(driverWalletBalanceProvider);
    final top = MediaQuery.paddingOf(context).top;

    const kaspiMethod = PaymentMethod(
      id: 'kaspi_payout',
      kind: PaymentMethodKind.kaspiGold,
      labelRu: 'Kaspi Gold',
      labelKk: 'Kaspi Gold',
      lastFour: '4422',
      brandColor: Color(0xFFE31E24),
      brandShort: 'K',
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.page,
              top + 72,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            children: [
              Text(
                'Кошелёк / Әмиян',
                style: AppTypography.labelMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        balance.tenge,
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
                      'Доступно / Қолжетімді',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryActionButton(
                label: 'Вывести средства',
                labelSecondary: 'Қаражатты шығару',
                onPressed: () => _withdraw(context, ref),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Способы выплаты / Төлем әдістері',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: TextButton(
                      onPressed: () => context.push(Routes.payment),
                      child: const Text(
                        'Изменить / Өзгерту',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Material(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  onTap: () => context.push(Routes.payment),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const PaymentBrandIcon(method: kaspiMethod, size: 48),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${wallet.payoutLabelRu} / ${wallet.payoutLabelKk}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyLg.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '• ${wallet.payoutLastFour}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMd.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: scheme.outline),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'История транзакций / Транзакциялар тарихы',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.filter_list, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...wallet.transactions.map(
                (tx) => _TransactionRow(transaction: tx),
              ),
            ],
          ),

          // Glass top bar.
          Positioned(
            top: top + AppSpacing.sm,
            left: AppSpacing.page,
            right: AppSpacing.page,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassFloatingButton(
                  icon: Icons.arrow_back,
                  size: 40,
                  onPressed: () => context.popOrGo(Routes.dDashboard),
                ),
                GlassFloatingButton(
                  icon: Icons.more_vert,
                  size: 40,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final WalletTransaction transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final tx = transaction;
    final amountPrefix = tx.isCredit ? '+' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.type == WalletTxType.ride
                  ? Icons.local_taxi
                  : Icons.account_balance_wallet_outlined,
              color: scheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx.titleRu} / ${tx.titleKk}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLg
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${tx.dateRu} / ${tx.dateKk}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$amountPrefix${tx.amountTenge.tenge}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.priceDisplay,
                  ),
                ),
                if (tx.statusRu != null)
                  Text(
                    '${tx.statusRu} / ${tx.statusKk}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawDialog extends StatefulWidget {
  final num maxAmount;
  const _WithdrawDialog({required this.maxAmount});

  @override
  State<_WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<_WithdrawDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.maxAmount.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Вывод на Kaspi / Kaspi-ға шығару',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Доступно: ${widget.maxAmount.tenge}',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Сумма (₸) / Сома (₸)',
              suffixText: '₸',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена / Болдырмау'),
        ),
        FilledButton(
          onPressed: () {
            final v = num.tryParse(_ctrl.text) ?? 0;
            Navigator.of(context).pop(v);
          },
          child: const Text('Вывести / Шығару'),
        ),
      ],
    );
  }
}
