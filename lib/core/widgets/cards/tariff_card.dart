import 'package:flutter/material.dart';

import '../../extensions/num_ext.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

/// Ride category card (Эконом / Комфорт / Бизнес).
/// Selected state inverts to the primary (black) background, per Stitch.
class TariffCard extends StatelessWidget {
  final String title;
  final num priceTenge;
  final int? etaMinutes;
  final String? carAsset; // optional 3D car render
  final bool selected;
  final VoidCallback? onTap;

  const TariffCard({
    super.key,
    required this.title,
    required this.priceTenge,
    this.etaMinutes,
    this.carAsset,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.primary : scheme.surfaceContainerLowest;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    final subFg = selected
        ? scheme.onPrimary.withValues(alpha: 0.7)
        : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: selected ? 128 : 112,
        constraints: const BoxConstraints(minWidth: 96),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.cardRadius,
          border: selected
              ? null
              : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMd.copyWith(color: subFg),
            ),
            const SizedBox(height: 8),
            if (carAsset != null)
              Image.asset(carAsset!, height: 44, fit: BoxFit.contain)
            else
              Icon(Icons.directions_car, size: 40, color: fg),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                priceTenge.tenge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.priceDisplay.copyWith(color: fg),
              ),
            ),
            if (etaMinutes != null) ...[
              const SizedBox(height: 2),
              Text(
                '~$etaMinutes мин',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMd.copyWith(color: subFg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
