import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/bilingual_text.dart';

/// Pure-black primary CTA with optional bilingual label and haptic feedback.
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final String? labelSecondary;
  final VoidCallback? onPressed;

  const PrimaryActionButton({
    super.key,
    required this.label,
    this.labelSecondary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onPressed!();
            },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: labelSecondary == null
            ? Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : BilingualText(
                primary: label,
                secondary: labelSecondary!,
                primaryMaxLines: 1,
                secondaryMaxLines: 1,
                primaryStyle: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: scheme.onPrimary),
                secondaryStyle:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.8),
                        ),
              ),
      ),
    );
  }
}
