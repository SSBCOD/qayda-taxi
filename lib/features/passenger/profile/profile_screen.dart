import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/auth.dart';

/// Passenger profile + settings tab (Stitch `passenger_profile_settings_bilingual`).
///
/// Avatar header, grouped account/settings/support menus, dark-mode switch and
/// sign-out. Lives inside [PassengerShell] (BottomNav from the shell).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isDark = ref.watch(themeControllerProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: const QaydaAppBar(
        title: 'Профиль и Настройки',
        subtitle: 'Профиль мен Баптаулар',
        glass: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          // ── Avatar header ─────────────────────────────────────────────
          Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: scheme.surfaceContainerHigh,
                    child: Icon(Icons.person,
                        size: 48, color: scheme.onSurfaceVariant),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: scheme.surfaceContainerLowest, width: 2),
                      ),
                      child:
                          Icon(Icons.edit, size: 14, color: scheme.onPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Арман Муратов',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMobile,
              ),
              const SizedBox(height: 2),
              Text(
                '+7 707 ••• •• 77',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Account ───────────────────────────────────────────────────
          _MenuGroup(
            title: 'Аккаунт / Аккаунт',
            children: [
              _MenuRow(
                icon: Icons.person_outline,
                label: 'Личные данные / Жеке деректер',
                onTap: () {},
              ),
              _MenuRow(
                icon: Icons.payments_outlined,
                label: 'Способы оплаты / Төлем әдістері',
                onTap: () => context.push(Routes.payment),
              ),
              _MenuRow(
                icon: Icons.bookmark_outline,
                label: 'Мои адреса / Менің мекенжайларым',
                onTap: () => context.push(Routes.pFavorites),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Settings ──────────────────────────────────────────────────
          _MenuGroup(
            title: 'Настройки / Баптаулар',
            children: [
              _MenuRow(
                icon: Icons.language,
                label: 'Язык приложения / Қосымша тілі',
                subtitle: 'Русский / Қазақ',
                onTap: () => context.push(Routes.settings),
              ),
              _MenuRow(
                icon: Icons.notifications_outlined,
                label: 'Уведомления / Хабарландырулар',
                onTap: () => context.push(Routes.settingsNotifications),
              ),
              _MenuRow(
                icon: Icons.dark_mode_outlined,
                label: 'Тёмная тема / Күңгірт режим',
                showDivider: false,
                trailing: Switch(
                  value: isDark,
                  onChanged: (v) => ref
                      .read(themeControllerProvider.notifier)
                      .toggleDark(dark: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Support & legal ───────────────────────────────────────────
          _MenuGroup(
            children: [
              _MenuRow(
                icon: Icons.support_agent,
                label: 'Служба поддержки / Қолдау көрсету',
                onTap: () => context.push(Routes.support),
              ),
              _MenuRow(
                icon: Icons.info_outline,
                label: 'О приложении / Қосымша туралы',
                onTap: () => context.push(Routes.settingsAbout),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Sign out ──────────────────────────────────────────────────
          Material(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => ref.read(authControllerProvider.notifier).signOut(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: scheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Выйти / Шығу',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMd
                            .copyWith(color: scheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grouped settings card with optional section header.
// ─────────────────────────────────────────────────────────────────────────────
class _MenuGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _MenuGroup({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title!.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMd.copyWith(color: scheme.secondary),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLg,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd
                              .copyWith(color: scheme.outline),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.38,
                  ),
                  child: trailing ??
                      (onTap != null
                          ? Icon(Icons.chevron_right, color: scheme.outline)
                          : const SizedBox.shrink()),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
                height: 1, color: scheme.outlineVariant.withValues(alpha: 0.2)),
          ),
      ],
    );
  }
}
