import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

/// Origin → destination timeline (point A circle, connector, point B square)
/// used on order, boarding and ride-summary screens.
class RouteTimeline extends StatelessWidget {
  final String originLabel;
  final String originValue;
  final String destinationLabel;
  final String destinationValue;

  const RouteTimeline({
    super.key,
    required this.originLabel,
    required this.originValue,
    required this.destinationLabel,
    required this.destinationValue,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.primary, width: 2),
                ),
              ),
              Container(width: 2, height: 32, color: scheme.outlineVariant),
              Container(
                width: 10,
                height: 10,
                color: scheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Entry(label: originLabel, value: originValue, scheme: scheme),
              const SizedBox(height: 16),
              _Entry(
                  label: destinationLabel,
                  value: destinationValue,
                  scheme: scheme),
            ],
          ),
        ),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme scheme;
  const _Entry({
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelMd.copyWith(color: scheme.secondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyLg,
        ),
      ],
    );
  }
}
