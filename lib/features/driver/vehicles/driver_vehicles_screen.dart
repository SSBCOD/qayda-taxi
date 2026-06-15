import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import 'application/driver_vehicles_providers.dart';

/// Driver fleet screen (Stitch `my_vehicles_driver`).
///
/// Active vehicle hero card, selectable fleet list, KYC-sourced primary car.
class DriverVehiclesScreen extends ConsumerWidget {
  const DriverVehiclesScreen({super.key});

  void _selectVehicle(BuildContext context, WidgetRef ref, DriverVehicle v) {
    HapticFeedback.selectionClick();
    ref.read(activeDriverVehicleIdProvider.notifier).select(v.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Активен: ${v.brandModel} / Белсенді: ${v.brandModel}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final active = ref.watch(activeDriverVehicleProvider);
    final inactive = ref.watch(inactiveDriverVehiclesProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: QaydaAppBar(
        title: 'Мои автомобили / Менің көліктерім',
        glass: true,
        onBack: () => context.popOrGo(Routes.dDashboard),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          112 + bottomInset,
        ),
        children: [
          // ── Active vehicle ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'АКТИВЕН / БЕЛСЕНДІ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd.copyWith(
                    color: scheme.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Online / Онлайн',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.online,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActiveVehicleCard(vehicle: active),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'СПИСОК АВТО / АВТОКӨЛІК ТІЗІМІ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd.copyWith(
              color: scheme.secondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...inactive.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _FleetListCard(
                vehicle: v,
                onSelect: () => _selectVehicle(context, ref, v),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.button),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: scheme.secondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Все автомобили проходят обязательную проверку '
                    'технического состояния перед активацией. / '
                    'Барлық көліктер белсендіру алдында міндетті '
                    'техникалық тексеруден өтеді.',
                    style:
                        AppTypography.bodyMd.copyWith(color: scheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.page,
        ),
        child: PrimaryActionButton(
          label: 'Добавить автомобиль',
          labelSecondary: 'Көлік қосу',
          onPressed: () => context.push(Routes.kycVehicle),
        ),
      ),
    );
  }
}

class _ActiveVehicleCard extends StatelessWidget {
  final DriverVehicle vehicle;
  const _ActiveVehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.brandModel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headlineLg
                                .copyWith(color: scheme.onPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle.year} • ${vehicle.tierSubtitleRu}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMd.copyWith(
                              color: scheme.onPrimary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _KzPlate(plate: vehicle.plate),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: vehicle.tariffTagsRu.map((tag) {
                    final kk =
                        vehicle.tariffTagsKk[vehicle.tariffTagsRu.indexOf(tag)];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: scheme.onPrimary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '$tag / $kk',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMd
                            .copyWith(color: scheme.onPrimary),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            alignment: Alignment.center,
            child: Icon(
              Icons.directions_car_filled,
              size: 96,
              color: scheme.onPrimary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetListCard extends StatelessWidget {
  final DriverVehicle vehicle;
  final VoidCallback onSelect;

  const _FleetListCard({
    required this.vehicle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final thumbnailSize = compact ? 72.0 : 96.0;

        return Material(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.card),
            onTap: onSelect,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: thumbnailSize,
                    height: thumbnailSize,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    child: Icon(Icons.directions_car,
                        size: compact ? 36 : 48,
                        color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.brandModel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTypography.headlineMd.copyWith(fontSize: 18),
                        ),
                        Text(
                          '${vehicle.year} • ${vehicle.tierSubtitleRu}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd
                              .copyWith(color: scheme.secondary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            _KzPlate(plate: vehicle.plate, compact: true),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: onSelect,
                                  child: const Text(
                                    'Выбрать / Таңдау →',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _KzPlate extends StatelessWidget {
  final String plate;
  final bool compact;

  const _KzPlate({required this.plate, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final maxWidth = compact ? 96.0 : 124.0;
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          plate,
          maxLines: 1,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: compact ? 12 : 14,
            letterSpacing: 1.2,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
