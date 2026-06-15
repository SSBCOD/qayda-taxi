import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/widgets.dart';
import '../auth/auth.dart';
import 'widgets/settings_tiles.dart';

/// Shared settings hub (Stitch `app_settings_notifications_bilingual`).
///
/// Navigation entry into the detailed settings screens (theme, notifications,
/// privacy, legal/support, about). Reachable from both passenger and driver
/// menus via [Routes.settings].
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final isKk = locale.languageCode == 'kk';

    final themeValue = switch (themeMode) {
      ThemeMode.light => 'Светлая / Жарық',
      ThemeMode.dark => 'Тёмная / Қараңғы',
      ThemeMode.system => 'Системная / Жүйелік',
    };

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: QaydaAppBar(
        title: 'Настройки / Баптаулар',
        glass: false,
        onBack: () => context.pop(),
        actions: const [LanguageSwitcher()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          // ── Application ───────────────────────────────────────────────
          const SettingsSectionLabel('Приложение / Қосымша'),
          SettingsTile(
            title: 'Язык / Тіл',
            value: isKk ? 'Қазақша' : 'Русский',
            onTap: () => ref.read(localeControllerProvider.notifier).toggle(),
          ),
          SettingsTile(
            title: 'Тема / Тақырып',
            value: themeValue,
            onTap: () => context.push(Routes.settingsTheme),
          ),
          SettingsTile(
            title: 'Уведомления / Хабарламалар',
            subtitle: 'Push, SMS, Email',
            onTap: () => context.push(Routes.settingsNotifications),
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Privacy & legal ───────────────────────────────────────────
          const SettingsSectionLabel('Конфиденциальность / Құпиялылық'),
          SettingsTile(
            title: 'Безопасность данных / Деректер қауіпсіздігі',
            onTap: () => context.push(Routes.settingsPrivacy),
          ),
          SettingsTile(
            title: 'Поддержка и право / Қолдау және құқық',
            onTap: () => context.push(Routes.settingsLegal),
          ),
          SettingsTile(
            title: 'О приложении / Қосымша туралы',
            onTap: () => context.push(Routes.settingsAbout),
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Account ───────────────────────────────────────────────────
          const SettingsSectionLabel('Аккаунт / Аккаунт'),
          SettingsTile(
            title: 'Очистить кэш / Кэшті тазалау',
            leadingIcon: Icons.delete_sweep_outlined,
            showChevron: false,
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Кэш очищен / Кэш тазаланды'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
          ),
          SettingsTile(
            title: 'Удалить аккаунт / Аккаунтты жою',
            leadingIcon: Icons.person_remove_outlined,
            titleColor: scheme.error,
            iconColor: scheme.error,
            showChevron: false,
            showDivider: false,
            onTap: () => _confirmDelete(context, ref),
          ),

          // ── Decorative footer ─────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          Opacity(
            opacity: 0.3,
            child: Column(
              children: [
                Divider(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'QAYDA EXECUTIVE',
                  style: AppTypography.labelMd.copyWith(letterSpacing: 3),
                ),
                const SizedBox(height: 4),
                const Text('v2.4.0 (2024)', style: AppTypography.labelMd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final scheme = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить аккаунт?\nАккаунтты жою?'),
        content: const Text(
          'Это действие необратимо.\nБұл әрекетті болдырмау мүмкін емес.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена / Болдырмау'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: const Text('Удалить / Жою'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(authControllerProvider.notifier).signOut();
    }
  }
}
