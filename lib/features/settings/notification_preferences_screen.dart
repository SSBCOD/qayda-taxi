import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import 'application/notification_prefs_controller.dart';
import 'widgets/settings_tiles.dart';

/// Notification preferences (Stitch `notification_preferences_bilingual`).
///
/// Boxed toggle rows grouped into "types" and "categories", backed by
/// [notificationPrefsControllerProvider] so the hub quick-toggles stay in sync.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final prefs = ref.watch(notificationPrefsControllerProvider);
    final ctrl = ref.read(notificationPrefsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: QaydaAppBar(
        title: 'Уведомления / Хабарламалар',
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
          const SettingsSectionLabel('Типы уведомлений / Хабарлама түрлері'),
          SettingsSwitchTile(
            boxed: true,
            title: 'Push-уведомления',
            subtitle: 'Push-хабарламалар',
            value: prefs.push,
            onChanged: ctrl.setPush,
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsSwitchTile(
            boxed: true,
            title: 'SMS-уведомления',
            subtitle: 'SMS-хабарламалар',
            value: prefs.sms,
            onChanged: ctrl.setSms,
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsSwitchTile(
            boxed: true,
            title: 'Email-уведомления',
            subtitle: 'Email-хабарламалар',
            value: prefs.email,
            onChanged: ctrl.setEmail,
          ),
          const SizedBox(height: AppSpacing.lg),
          const SettingsSectionLabel('Категории / Категориялар'),
          SettingsSwitchTile(
            boxed: true,
            title: 'Поездки и заказы',
            subtitle: 'Сапарлар мен тапсырыстар',
            value: prefs.rides,
            onChanged: ctrl.setRides,
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsSwitchTile(
            boxed: true,
            title: 'Новости и акции',
            subtitle: 'Жаңалықтар мен акциялар',
            value: prefs.news,
            onChanged: ctrl.setNews,
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsSwitchTile(
            boxed: true,
            title: 'Оценки и отзывы',
            subtitle: 'Бағалау мен пікірлер',
            value: prefs.ratings,
            onChanged: ctrl.setRatings,
          ),
        ],
      ),
    );
  }
}
