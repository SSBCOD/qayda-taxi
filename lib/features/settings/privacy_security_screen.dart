import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import 'widgets/settings_tiles.dart';

/// Privacy & data security (Stitch `privacy_data_security_bilingual`).
class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() =>
      _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  bool _locationTracking = true;
  bool _contactAccess = false;

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: QaydaAppBar(
        title: 'Конфиденциальность / Құпиялылық',
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
          // ── Account data ──────────────────────────────────────────────
          const SettingsSectionLabel('Данные аккаунта / Аккаунт деректері'),
          SettingsTile(
            title: 'Экспорт моих данных / Деректерді экспорттау',
            onTap: () => _toast('Экспорт начат / Экспорт басталды'),
          ),
          SettingsTile(
            title: 'Политика конфиденциальности / Құпиялылық саясаты',
            onTap: () => context.push(Routes.settingsLegal),
          ),
          SettingsTile(
            title: 'Условия использования / Пайдалану шарттары',
            onTap: () => context.push(Routes.settingsLegal),
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Permissions ───────────────────────────────────────────────
          const SettingsSectionLabel('Разрешения / Рұқсаттар'),
          SettingsSwitchTile(
            title: 'Отслеживание геолокации / Геолокацияны бақылау',
            value: _locationTracking,
            onChanged: (v) => setState(() => _locationTracking = v),
          ),
          SettingsSwitchTile(
            title: 'Доступ к контактам / Контактілерге рұқсат',
            value: _contactAccess,
            onChanged: (v) => setState(() => _contactAccess = v),
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Security ──────────────────────────────────────────────────
          const SettingsSectionLabel('Безопасность / Қауіпсіздік'),
          SettingsTile(
            title: 'Активные сеансы / Белсенді сеанстар',
            onTap: () => _toast('1 активный сеанс / 1 белсенді сеанс'),
          ),
          SettingsTile(
            title: 'Двухфакторная аутентификация',
            subtitle: 'Екі факторлы аутентификация • Откл. / Өшірулі',
            trailing: _OffBadge(),
            showChevron: false,
            showDivider: false,
            onTap: () => _toast('Скоро / Жақында'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Footer note ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Qayda использует надёжное шифрование для защиты ваших данных. '
              'Мы никогда не передаём ваши данные третьим лицам.\n\n'
              'Qayda деректеріңізді қорғау үшін сенімді шифрлауды пайдаланады.',
              textAlign: TextAlign.center,
              style: AppTypography.labelMd.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OffBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'OFF',
        style: AppTypography.labelMd.copyWith(
          color: scheme.error,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
