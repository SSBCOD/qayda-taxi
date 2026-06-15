import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/extensions/num_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import 'application/driver_earnings_providers.dart';
import 'widgets/earnings_chart.dart';

/// Driver earnings statistics (Stitch `driver_earnings_statistics_bilingual`).
///
/// Period filter (day/week/month), total income in ₸, performance grid, chart
/// and recent trips. Mock data synced with [driverControllerProvider] for today.
class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final period = ref.watch(driverEarningsPeriodProvider);
    final stats = ref.watch(driverEarningsStatsProvider);
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: QaydaAppBar(
        title: 'Статистика / Статистика',
        glass: false,
        onBack: () => context.popOrGo(Routes.dDashboard),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          _PeriodSelector(
            selected: period,
            onSelect: (p) =>
                ref.read(driverEarningsPeriodProvider.notifier).state = p,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Main earnings card.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              children: [
                Text(
                  'Общий доход / Жалпы табыс',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stats.totalTenge.tenge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.displayLg.copyWith(
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up,
                          size: 16, color: scheme.onPrimary),
                      const SizedBox(width: 4),
                      Text(
                        '+${stats.changePercent.toStringAsFixed(1)}%',
                        style: AppTypography.labelMd
                            .copyWith(color: scheme.onPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Performance grid.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: compact ? AppSpacing.sm : AppSpacing.md,
            crossAxisSpacing: compact ? AppSpacing.sm : AppSpacing.md,
            childAspectRatio: compact ? 1.05 : 1.35,
            children: [
              _StatCard(
                icon: Icons.local_taxi_outlined,
                label: 'Поездки / Сапарлар',
                value: '${stats.trips}',
              ),
              _StatCard(
                icon: Icons.schedule_outlined,
                label: 'В сети / Желіде',
                value: stats.onlineTime,
              ),
              _StatCard(
                icon: Icons.star,
                iconFilled: true,
                label: 'Рейтинг / Рейтинг',
                value: stats.rating.toStringAsFixed(2),
                delta: '+${stats.ratingDelta.toStringAsFixed(2)}',
                deltaColor: AppColors.online,
              ),
              _StatCard(
                icon: Icons.check_circle_outline,
                label: 'Принято / Қабылданды',
                value: '${stats.acceptancePercent}%',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'График / График',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMd,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  period == EarningsPeriod.day
                      ? 'Сегодня / Бүгін'
                      : period.labelRu,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppTypography.labelMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          EarningsChart(
            points: stats.chartPoints,
            labels: stats.chartLabels,
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text(
            'Последние / Соңғы',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineMd,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...stats.recent.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ActivityRow(activity: a),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final EarningsPeriod selected;
  final ValueChanged<EarningsPeriod> onSelect;

  const _PeriodSelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
      child: Row(
        children: EarningsPeriod.values.map((p) {
          final active = p == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${p.labelRu} / ${p.labelKk}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? delta;
  final Color? deltaColor;
  final bool iconFilled;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.delta,
    this.deltaColor,
    this.iconFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, fill: iconFilled ? 1.0 : 0.0),
          const Spacer(),
          Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMd
                  .copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineMd,
                  ),
                ),
              ),
              if (delta != null) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    delta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd.copyWith(
                      color: deltaColor ?? scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final EarningsActivity activity;
  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activity.tierRu} / ${activity.tierKk}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLg,
                ),
                Text(
                  '${activity.time} • ${activity.location}',
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
              maxWidth: MediaQuery.sizeOf(context).width * 0.28,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                activity.amountTenge.tenge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.priceDisplay,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
