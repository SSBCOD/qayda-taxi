import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

/// Language selection (Stitch `language_selection_bilingual`).
///
/// Only the two supported locales are offered (RU / KK). Tapping a row updates
/// [localeControllerProvider] immediately so the whole UI re-renders; "Сохранить"
/// continues into the phone step.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final isKk = locale.languageCode == 'kk';

    void select(Locale value) =>
        ref.read(localeControllerProvider.notifier).setLocale(value);

    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Выбор языка',
        subtitle: 'Тілді таңдау',
        onBack: () => _back(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          _LanguageOption(
            title: 'Русский',
            subtitle: 'Орыс тілі',
            selected: !isKk,
            onTap: () => select(LocaleController.ru),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LanguageOption(
            title: 'Қазақша',
            subtitle: 'Казахский',
            selected: isKk,
            onTap: () => select(LocaleController.kk),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _InfoCard(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: PrimaryActionButton(
            label: 'Сохранить',
            labelSecondary: 'Сақтау',
            onPressed: () => context.go(Routes.welcome),
          ),
        ),
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.splash);
    }
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return QaydaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLg),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: selected ? scheme.primary : Colors.transparent,
              shape: BoxShape.circle,
              border:
                  selected ? null : Border.all(color: scheme.outline, width: 2),
            ),
            child: selected
                ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
                : null,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: scheme.primary),
          const SizedBox(height: AppSpacing.gutter),
          Text(
            'Язык применяется ко всему приложению Qayda, включая заказы и '
            'уведомления.',
            style:
                AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Тіл бүкіл Qayda қолданбасына қолданылады.',
            style:
                AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
