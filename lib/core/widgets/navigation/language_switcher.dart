import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/locale_controller.dart';
import '../../theme/app_typography.dart';

/// The "ҚАЗ | РУС" pill toggle present on most Stitch screens.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final locale = ref.watch(localeControllerProvider);
    final isKk = locale.languageCode == 'kk';

    TextStyle styleFor(bool active) => AppTypography.labelMd.copyWith(
          color: active ? scheme.onSurface : scheme.onSurfaceVariant,
        );

    return GestureDetector(
      onTap: () => ref.read(localeControllerProvider.notifier).toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ҚАЗ', style: styleFor(isKk)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('|', style: styleFor(false)),
            ),
            Text('РУС', style: styleFor(!isKk)),
          ],
        ),
      ),
    );
  }
}
