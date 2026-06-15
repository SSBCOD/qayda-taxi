import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

/// Driver/vehicle summary used on wait, boarding and ride-summary screens:
/// avatar + rating badge, name, vehicle line and the mono plate chip.
class DriverCard extends StatelessWidget {
  final String name;
  final double rating;
  final String vehicle; // e.g. "Toyota Camry • Black"
  final String plate; // e.g. "011 ABC 02"
  final ImageProvider? photo;
  final Widget? trailing;

  const DriverCard({
    super.key,
    required this.name,
    required this.rating,
    required this.vehicle,
    required this.plate,
    this.photo,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: scheme.surfaceContainerHigh,
              backgroundImage: photo,
              child: photo == null
                  ? Icon(Icons.person, color: scheme.onSurfaceVariant)
                  : null,
            ),
            Positioned(
              bottom: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rating.toStringAsFixed(1),
                        style: AppTypography.labelMd
                            .copyWith(color: scheme.onPrimary)),
                    Icon(Icons.star, size: 12, color: scheme.onPrimary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
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
              const SizedBox(height: 2),
              Text(
                vehicle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxWidth: 132),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    plate,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
