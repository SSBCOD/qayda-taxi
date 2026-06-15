import 'package:flutter/material.dart';

/// The core bilingual pattern: a primary line (RU or KK) with a smaller
/// secondary line beneath it. Used everywhere across Qayda screens.
class BilingualText extends StatelessWidget {
  final String primary;
  final String secondary;
  final TextStyle? primaryStyle;
  final TextStyle? secondaryStyle;
  final TextAlign textAlign;
  final int primaryMaxLines;
  final int secondaryMaxLines;

  const BilingualText({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryStyle,
    this.secondaryStyle,
    this.textAlign = TextAlign.center,
    this.primaryMaxLines = 2,
    this.secondaryMaxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCenter = textAlign == TextAlign.center;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(primary,
            textAlign: textAlign,
            maxLines: primaryMaxLines,
            overflow: TextOverflow.ellipsis,
            style: primaryStyle ?? theme.textTheme.headlineMedium),
        const SizedBox(height: 2),
        Text(
          secondary,
          textAlign: textAlign,
          maxLines: secondaryMaxLines,
          overflow: TextOverflow.ellipsis,
          style: secondaryStyle ??
              theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
