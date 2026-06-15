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
import '../../../data/models/driver_order.dart';
import '../dashboard/application/driver_controller.dart';

/// Incoming order alert (Stitch `incoming_order_alert_verified`).
///
/// A modal card over the map: 15s countdown ring, tariff + fare, pickup/trip
/// metrics, route A→B, passenger, and accept/skip actions. The countdown
/// auto-declines on expiry.
class DriverIncomingScreen extends ConsumerStatefulWidget {
  const DriverIncomingScreen({super.key});

  @override
  ConsumerState<DriverIncomingScreen> createState() =>
      _DriverIncomingScreenState();
}

class _DriverIncomingScreenState extends ConsumerState<DriverIncomingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countdown;
  bool _handled = false;

  static const int _seconds = 15;

  @override
  void initState() {
    super.initState();
    _countdown = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _seconds),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) _decline();
      });
    _countdown.forward();
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  void _accept() {
    if (_handled) return;
    _handled = true;
    HapticFeedback.mediumImpact();
    ref.read(driverControllerProvider.notifier).acceptOrder();
    context.go(Routes.dOrderEnroute);
  }

  void _decline() {
    if (_handled) return;
    _handled = true;
    ref.read(driverControllerProvider.notifier).declineOrder();
    context.go(Routes.dDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final order = ref.watch(driverControllerProvider).order;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.15),
                BlendMode.darken,
              ),
              child: const QaydaMap(),
            ),
          ),
          if (order != null)
            Center(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: _OrderCard(
                    order: order,
                    countdown: _countdown,
                    onAccept: _accept,
                    onDecline: _decline,
                  ),
                ),
              ),
            )
          else
            Center(
              child: CircularProgressIndicator(color: scheme.primary),
            ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DriverOrder order;
  final Animation<double> countdown;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _OrderCard({
    required this.order,
    required this.countdown,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Color(0x29000000), blurRadius: 40, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CountdownRing(animation: countdown),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child:
                            StatusPill(text: order.tierLabelRu.toUpperCase()),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: _MetricBox(
                    labelRu: 'Подача',
                    labelKk: 'Жеткізу',
                    icon: Icons.near_me,
                    value: '${order.pickupDistanceKm} км',
                    sub: '~ ${order.pickupEtaMin} мин',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricBox(
                    labelRu: 'Поездка',
                    labelKk: 'Сапар',
                    icon: Icons.route,
                    value: '${order.tripDistanceKm} км',
                    sub: '~ ${order.tripDurationMin} мин',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                RouteTimeline(
                  originLabel: 'Откуда / Қайдан',
                  originValue: order.pickupTitle,
                  destinationLabel: 'Куда / Қайда',
                  destinationValue: order.destTitleRu,
                ),
                const SizedBox(height: AppSpacing.lg),
                _PassengerRow(
                  name: order.passengerName,
                  rating: order.passengerRating,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              children: [
                PrimaryActionButton(
                  label: 'Принять',
                  labelSecondary: 'Қабылдау',
                  onPressed: onAccept,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onDecline,
                  child: Text(
                    'Пропустить / Өткізіп жіберу',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd
                        .copyWith(color: scheme.onSurfaceVariant),
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

class _CountdownRing extends StatelessWidget {
  final Animation<double> animation;
  const _CountdownRing({required this.animation});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return SizedBox(
      width: 72,
      height: 72,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final remaining = ((1 - animation.value) * 15).ceil();
          final danger = remaining <= 5;
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: 1 - animation.value,
                  strokeWidth: 4,
                  backgroundColor: scheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(
                      danger ? scheme.error : scheme.primary),
                ),
              ),
              Text(
                '${remaining}s',
                style: AppTypography.priceDisplay
                    .copyWith(color: danger ? scheme.error : scheme.onSurface),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String labelRu;
  final String labelKk;
  final IconData icon;
  final String value;
  final String sub;

  const _MetricBox({
    required this.labelRu,
    required this.labelKk,
    required this.icon,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$labelRu / $labelKk',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                AppTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.onSurface),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                AppTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PassengerRow extends StatelessWidget {
  final String name;
  final double rating;
  const _PassengerRow({required this.name, required this.rating});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.surfaceContainerHighest,
            child: Icon(Icons.person, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMd,
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: scheme.primary),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1),
                        style: AppTypography.labelMd),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
