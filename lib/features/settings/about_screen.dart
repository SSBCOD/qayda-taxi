import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import 'widgets/settings_tiles.dart';

/// About / app version (Stitch `app_version_about_bilingual`).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _toast(BuildContext context, String msg) {
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
        title: 'О приложении / Қосымша туралы',
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
          const SizedBox(height: AppSpacing.lg),
          // ── Logo block ────────────────────────────────────────────────
          Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child:
                    Icon(Icons.local_taxi, size: 48, color: scheme.onPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Qayda Executive',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.displayLg,
              ),
              const SizedBox(height: 4),
              Text(
                'v2.4.0 (2024)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // ── Action list ───────────────────────────────────────────────
          SettingsTile(
            title: 'Что нового / Жаңалықтар',
            onTap: () => _toast(context, 'Скоро / Жақында'),
          ),
          SettingsTile(
            title: 'Оценить приложение / Қосымшаны бағалау',
            onTap: () => _toast(context, 'Спасибо! / Рахмет!'),
          ),
          SettingsTile(
            title: 'Поделиться с друзьями / Достармен бөлісу',
            onTap: () => _toast(context, 'Скоро / Жақында'),
            showDivider: false,
          ),
          const SizedBox(height: 40),

          // ── Footer ────────────────────────────────────────────────────
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.sizeOf(context).width - (AppSpacing.page * 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Flexible(
                    child: Text(
                      'Сделано в Казахстане / Қазақстанда жасалған',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.favorite, size: 14, color: scheme.error),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '© 2024 Qayda Tech. Все права защищены.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
