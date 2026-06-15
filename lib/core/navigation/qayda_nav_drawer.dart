import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../extensions/context_ext.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/lists/boutique_list_tile.dart';
import 'app_menu_config.dart';

/// Reusable navigation drawer driven by [AppMenuEntry] rows.
class QaydaNavDrawer extends StatelessWidget {
  final List<AppMenuEntry> entries;
  final Widget? header;
  final Widget? footer;
  final bool closeBeforeNavigate;
  final bool usePush;

  const QaydaNavDrawer({
    super.key,
    required this.entries,
    this.header,
    this.footer,
    this.closeBeforeNavigate = true,
    this.usePush = false,
  });

  void _go(BuildContext context, String route) {
    if (closeBeforeNavigate) {
      Navigator.of(context).pop();
    }
    if (usePush) {
      context.push(route);
    } else {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ...[
                header!,
                const SizedBox(height: AppSpacing.lg),
              ],
              ...entries.asMap().entries.map((e) {
                final entry = e.value;
                final isLast = e.key == entries.length - 1;
                return BoutiqueListTile(
                  leadingIcon: entry.icon,
                  title: entry.bilingualLabel,
                  showDivider: !isLast,
                  onTap: () => _go(context, entry.route),
                );
              }),
              if (footer != null) ...[
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: footer!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Passenger drawer header wordmark.
class QaydaDrawerHeader extends StatelessWidget {
  const QaydaDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Text(
        'Qayda',
        style: AppTypography.displayLg.copyWith(color: context.colors.primary),
      ),
    );
  }
}
