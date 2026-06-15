import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

/// Compact A→B route used on trip-history and order cards: an origin circle and
/// destination square joined by a connector, with the two address lines.
///
/// Unlike [RouteTimeline] (which shows uppercase labels), this is the dense,
/// value-only variant for list cards.
class CompactRoute extends StatelessWidget {
  final String origin;
  final String destination;
  const CompactRoute({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = AppTypography.bodyMd.copyWith(color: scheme.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface,
                  border: Border.all(color: scheme.primary, width: 2),
                ),
              ),
              Container(width: 2, height: 24, color: scheme.outlineVariant),
              Container(width: 11, height: 11, color: scheme.primary),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(origin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle),
              const SizedBox(height: 20),
              Text(destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle),
            ],
          ),
        ),
      ],
    );
  }
}
