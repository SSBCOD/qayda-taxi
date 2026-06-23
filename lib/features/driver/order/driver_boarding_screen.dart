import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../dashboard/application/driver_controller.dart';
import '../../../core/utils/launcher.dart';

/// Passenger boarding / verification (Stitch `passenger_boarding_verification`).
///
/// Shown once the driver is at pickup: passenger identity, verified IIN,
/// destination and a free-wait countdown. "Начать поездку" starts the trip.
class DriverBoardingScreen extends ConsumerStatefulWidget {
  const DriverBoardingScreen({super.key});

  @override
  ConsumerState<DriverBoardingScreen> createState() =>
      _DriverBoardingScreenState();
}

class _DriverBoardingScreenState extends ConsumerState<DriverBoardingScreen> {
  Timer? _ticker;
  int _waitLeft = 165; // 02:45 free wait

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _waitLeft = _waitLeft > 0 ? _waitLeft - 1 : 0);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _waitLabel {
    final m = (_waitLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_waitLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startTrip() {
    HapticFeedback.mediumImpact();
    ref.read(driverControllerProvider.notifier).startTrip();
    context.go(Routes.dOrderActive);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final order = ref.watch(driverControllerProvider).order;

    if (order == null) {
      return const Scaffold(body: Center(child: AppLoader(size: 32)));
    }

    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Посадка',
        subtitle: 'Отырғызу',
        onBack: () {
          ref.read(driverControllerProvider.notifier).revertToEnRoute();
          context.go(Routes.dOrderEnroute);
        },
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.lg),
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: scheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Вы прибыли по адресу / Мекенжайға келдіңіз',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd
                              .copyWith(color: scheme.onSurfaceVariant)),
                      Text(
                        order.pickupTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineMobile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            QaydaCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: scheme.surfaceContainerHigh,
                        child:
                            Icon(Icons.person, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    order.passengerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.headlineMobile,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                StatusPill(
                                    text: order.passengerRating
                                        .toStringAsFixed(1)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.tierLabelRu} • Пассажир',
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
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.input),
                      border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.badge_outlined, color: scheme.primary),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ИИН верифицирован',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelMd,
                              ),
                              Text(
                                'ЖСН расталды',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelMd
                                    .copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified, color: Color(0xFF16A34A)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Пункт назначения / Баратын жері',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trip_origin, size: 20, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(order.destTitleRu,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyLg
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 20, color: scheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _waitLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.displayLg.copyWith(
                            color: _waitLeft == 0 ? scheme.error : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'БЕСПЛАТНОЕ ОЖИДАНИЕ / ТЕГІН КҮТУ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryActionButton(
                label: 'Начать поездку',
                labelSecondary: 'Сапарды бастау',
                onPressed: _startTrip,
              ),
              const SizedBox(height: AppSpacing.gutter),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Чат',
                      icon: Icons.chat_bubble_outline,
                      expanded: false,
                      onPressed: () => context.push(Routes.supportChat),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Звонок',
                      icon: Icons.call,
                      expanded: false,
                      onPressed: () => Launcher.call(context, '+77000000000'),
                    ),
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
