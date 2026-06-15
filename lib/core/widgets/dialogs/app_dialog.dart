import 'package:flutter/material.dart';

import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

/// Styled modal matching the neo-minimalist look (24px radius, black CTA).
class QaydaDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmLabel;
  final String? cancelLabel;
  final bool destructive;

  const QaydaDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = 'OK',
    this.cancelLabel,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final confirmColor = destructive ? scheme.error : scheme.primary;

    return Dialog(
      backgroundColor: scheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineMd,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!,
                  textAlign: TextAlign.center,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd
                      .copyWith(color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: confirmColor),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
            if (cancelLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows a [QaydaDialog]. Returns `true` on confirm, `false`/`null` otherwise.
Future<bool?> showQaydaDialog({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = 'OK',
  String? cancelLabel,
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => QaydaDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
}
