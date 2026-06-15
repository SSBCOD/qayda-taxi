import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/extensions/num_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/enums.dart';
import 'application/driver_daily_history_providers.dart';

/// Driver daily trip history (Stitch `driver_daily_history`).
///
/// Today's earnings summary, hourly bar chart and completed trips list in ₸.
/// Opened from the dashboard drawer «Мои поездки».
class DriverDailyHistoryScreen extends ConsumerWidget {
  const DriverDailyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final history = ref.watch(driverDailyHistoryProvider);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.page,
              top + 80,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            children: [
              // ── Summary card ────────────────────────────────────────────
              Container(
                height: 176,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      bottom: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.onPrimary.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Заработок / Табыс',
                          style: AppTypography.labelMd.copyWith(
                            color: scheme.onPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          history.earningsTenge.tenge,
                          style: AppTypography.displayLg.copyWith(
                            color: scheme.onPrimary,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${history.tripCount} поездок / ${history.tripCount} сапар',
                              style: AppTypography.labelMd.copyWith(
                                color: scheme.onPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${history.onlineTimeRu} / ${history.onlineTimeKk}',
                              style: AppTypography.labelMd.copyWith(
                                color: scheme.onPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Hourly chart ────────────────────────────────────────────
              _HourlyChart(
                bars: history.hourlyBars,
                labels: history.hourLabels,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Trip list header ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Поездки / Сапарлар',
                    style: AppTypography.headlineMd,
                  ),
                  Icon(Icons.filter_list, color: scheme.outline),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              ...history.trips.map(
                (trip) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _TripCard(trip: trip),
                ),
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
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'История за сегодня',
                        style: AppTypography.headlineMd,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Бүгінгі тарих',
                        style: AppTypography.bodyMd.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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

class _HourlyChart extends StatelessWidget {
  final List<double> bars;
  final List<String> labels;

  const _HourlyChart({required this.bars, required this.labels});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    const peakIndices = {2, 6};

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: scheme.surfaceContainerHighest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ПО ЧАСАМ / САҒАТ БОЙЫНША',
            style: AppTypography.labelMd.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (i) {
                final isPeak = peakIndices.contains(i);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      height: 96 * bars[i],
                      decoration: BoxDecoration(
                        color: isPeak
                            ? scheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (l) => Text(
                    l,
                    style: AppTypography.labelMd.copyWith(
                      fontSize: 10,
                      color: scheme.outline,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final DriverDailyTrip trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isBusiness = trip.tier == RideTier.business;

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: scheme.surfaceContainerHighest),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  trip.passengerRu[0],
                  style: AppTypography.headlineMd,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip.passengerRu} / ${trip.passengerKk}',
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isBusiness
                                ? scheme.primary
                                : scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${trip.tierRu} / ${trip.tierKk}',
                            style: AppTypography.labelMd.copyWith(
                              fontSize: 10,
                              color: isBusiness
                                  ? scheme.onPrimary
                                  : scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          trip.time,
                          style: AppTypography.labelMd.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(trip.incomeTenge.tenge,
                      style: AppTypography.priceDisplay),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route,
                          size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text(
                        '${trip.distanceKm.toStringAsFixed(1)} км',
                        style: AppTypography.labelMd.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
