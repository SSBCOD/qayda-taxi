import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/widgets.dart';

/// Theme selection (Stitch `theme_selection_bilingual`).
///
/// Light / Dark / System radio cards wired to [themeControllerProvider]; the
/// choice applies immediately and "Сохранить" just confirms and pops.
class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final mode = ref.watch(themeControllerProvider);

    void select(ThemeMode m) {
      HapticFeedback.selectionClick();
      ref.read(themeControllerProvider.notifier).setMode(m);
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: QaydaAppBar(
        title: 'Тема / Тақырып',
        glass: false,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          _ThemeCard(
            icon: Icons.light_mode_outlined,
            title: 'Светлая / Жарық',
            subtitle: 'Standard high contrast',
            selected: mode == ThemeMode.light,
            onTap: () => select(ThemeMode.light),
          ),
          const SizedBox(height: AppSpacing.gutter),
          _ThemeCard(
            icon: Icons.dark_mode_outlined,
            title: 'Тёмная / Қараңғы',
            subtitle: 'Executive night mode',
            selected: mode == ThemeMode.dark,
            onTap: () => select(ThemeMode.dark),
          ),
          const SizedBox(height: AppSpacing.gutter),
          _ThemeCard(
            icon: Icons.brightness_auto_outlined,
            title: 'Системная / Жүйелік',
            subtitle: 'Sync with device settings',
            selected: mode == ThemeMode.system,
            onTap: () => select(ThemeMode.system),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.page,
        ),
        child: PrimaryActionButton(
          label: 'Сохранить',
          labelSecondary: 'Сақтау',
          onPressed: () => context.pop(),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: AppRadii.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.gutter),
          decoration: BoxDecoration(
            borderRadius: AppRadii.cardRadius,
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                child: Icon(icon, size: 30, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLg,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _RadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 7 : 2,
        ),
      ),
    );
  }
}
