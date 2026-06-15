import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Glassmorphic top app bar: back button + centered (optional bilingual) title
/// + trailing actions. Height 64 to match the Stitch header.
class QaydaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool glass;

  const QaydaAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.onBack,
    this.actions = const [],
    this.glass = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final barHeight = preferredSize.height + topInset;

    final bar = Container(
      height: barHeight,
      padding: EdgeInsets.only(
        left: AppSpacing.page,
        top: topInset,
        right: AppSpacing.page,
      ),
      decoration: BoxDecoration(
        color: glass ? scheme.surface.withValues(alpha: 0.7) : scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title != null)
                  Text(title!,
                      textAlign: TextAlign.center,
                      maxLines: subtitle == null ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd),
                if (subtitle != null)
                  Text(subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd
                          .copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (actions.isEmpty)
            const SizedBox(width: 48)
          else
            Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ),
    );

    if (!glass) return bar;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppGlass.blur, sigmaY: AppGlass.blur),
        child: bar,
      ),
    );
  }
}
