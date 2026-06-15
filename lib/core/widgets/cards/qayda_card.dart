import 'package:flutter/material.dart';

import '../../theme/app_radii.dart';

/// Base container card: white surface, 24px radius, hairline border.
/// The neo-minimalist foundation for most content blocks.
class QaydaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool bordered;

  const QaydaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final decoration = BoxDecoration(
      color: color ?? scheme.surfaceContainerLowest,
      borderRadius: AppRadii.cardRadius,
      border: bordered
          ? Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5))
          : null,
    );

    final content = Padding(padding: padding, child: child);

    if (onTap == null) {
      return DecoratedBox(decoration: decoration, child: content);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Ink(decoration: decoration, child: content),
      ),
    );
  }
}
