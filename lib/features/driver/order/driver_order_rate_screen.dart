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
import '../../../data/models/tariff.dart';
import '../dashboard/application/driver_controller.dart';

/// Post-ride passenger rating (Stitch `ride_summary_rating_driver`).
///
/// Fare recap, star rating, optional comment and report CTA. Submitting clears
/// the order and returns the driver to the dashboard (still online).
class DriverOrderRateScreen extends ConsumerStatefulWidget {
  const DriverOrderRateScreen({super.key});

  @override
  ConsumerState<DriverOrderRateScreen> createState() =>
      _DriverOrderRateScreenState();
}

class _DriverOrderRateScreenState extends ConsumerState<DriverOrderRateScreen> {
  int _stars = 5;
  late final TextEditingController _commentCtrl;

  @override
  void initState() {
    super.initState();
    _commentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentCtrl.text.trim();
    ref.read(driverControllerProvider.notifier).submitPassengerRating(
          stars: _stars,
          comment: comment.isEmpty ? null : comment,
        );
    context.go(Routes.dDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final order = ref.watch(driverControllerProvider).order;

    if (order == null) {
      return const Scaffold(body: Center(child: AppLoader(size: 32)));
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: QaydaAppBar(
        title: 'Qayda',
        glass: false,
        onBack: () => context.go(Routes.dOrderSummary),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          120,
        ),
        children: [
          // Success header.
          Column(
            children: [
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
                style: AppTypography.bodyMd.copyWith(color: scheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Fare recap card.
          QaydaCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: scheme.onPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'ИТОГО / БАРЛЫҒЫ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    order.incomeTenge.tenge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.displayLg,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Дистанция / Қашықтық',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelMd.copyWith(
                              color: scheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${order.tripDistanceKm} км',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.priceDisplay,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Время / Уақыт',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelMd.copyWith(
                              color: scheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${order.tripDurationMin} мин',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.priceDisplay,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Passenger rating section.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: AppRadii.cardRadius,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: scheme.surfaceContainerHighest,
                      child: Text(
                        order.passengerName[0],
                        style: AppTypography.headlineMd,
                      ),
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
                            style: AppTypography.headlineMd.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: scheme.primary),
                              const SizedBox(width: 2),
                              Text(
                                order.passengerRating.toStringAsFixed(1),
                                style: AppTypography.labelMd,
                              ),
                              Expanded(
                                child: Text(
                                  ' • ${order.tier.driverClassLabel}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelMd.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child:
                          Icon(Icons.person_outline, color: scheme.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Оцените пассажира / Жолаушыны бағалаңыз',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < _stars;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _stars = i + 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          size: 32,
                          color:
                              filled ? scheme.primary : scheme.outlineVariant,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Comment field.
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
              child: Text(
                'Оставить отзыв / Пікір қалдыру',
                style: AppTypography.labelMd.copyWith(color: scheme.secondary),
              ),
            ),
          ),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Напишите комментарий... / Пікір жазыңыз...',
              filled: true,
              fillColor: scheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.button),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Report issue row.
          Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.button),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Отчёт отправлен / Есеп жіберілді',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppRadii.button),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.report_outlined, color: scheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Text(
                        'Сообщить о проблеме / Мәселе туралы хабарлау',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMd,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: scheme.outlineVariant),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.md,
        ),
        child: PrimaryActionButton(
          label: 'Готово',
          labelSecondary: 'Дайын',
          onPressed: _submit,
        ),
      ),
    );
  }
}
