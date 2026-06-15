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
import '../../ride/application/ride_controller.dart';

/// Post-ride rating: star score + optional tip. Submitting moves the ride to
/// `rated`, clears it and returns the passenger to the home map.
class RideRateScreen extends ConsumerStatefulWidget {
  const RideRateScreen({super.key});

  @override
  ConsumerState<RideRateScreen> createState() => _RideRateScreenState();
}

class _RideRateScreenState extends ConsumerState<RideRateScreen> {
  int _stars = 5;
  num _tip = 0;

  static const _tips = <num>[0, 200, 500, 1000];

  bool _submitted = false;

  void _submit() {
    if (_submitted) return;
    _submitted = true;
    ref
        .read(rideControllerProvider.notifier)
        .submitRating(stars: _stars, tip: _tip == 0 ? null : _tip);
    ref.read(rideControllerProvider.notifier).reset();
    if (mounted) context.go(Routes.pHome);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final ride = ref.watch(rideControllerProvider);
    final driver = ride?.driver;

    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Оцените поездку',
        subtitle: 'Сапарды бағалаңыз',
        onBack: () {
          if (mounted) context.go(Routes.pHome);
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          children: [
            const SizedBox(height: AppSpacing.lg),
            CircleAvatar(
              radius: 40,
              backgroundColor: scheme.surfaceContainerHigh,
              child:
                  Icon(Icons.person, size: 36, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              driver?.name ?? 'Водитель',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.headlineMd,
            ),
            const SizedBox(height: 2),
            Text(
              'Как прошла поездка? | Сапар қалай өтті?',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Stars.
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
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: 40,
                      color: filled
                          ? const Color(0xFFFFB300)
                          : scheme.outlineVariant,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Tip section.
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Чаевые | Шайпұл',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final tip in _tips) ...[
                  Expanded(
                    child: _TipChip(
                      label: tip == 0 ? 'Нет' : tip.tenge,
                      selected: _tip == tip,
                      onTap: () => setState(() => _tip = tip),
                    ),
                  ),
                  if (tip != _tips.last) const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
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

class _TipChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TipChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelMd.copyWith(
            color: selected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
