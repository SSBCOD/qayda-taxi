import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/enums.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/application/user_profile_controller.dart';
import 'application/driver_profile_providers.dart';

/// Driver profile & settings (Stitch `driver_profile_settings`).
///
/// Avatar with tier badge, career stats, grouped account/settings menus and
/// sign-out. Reachable from the dashboard drawer header.
class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final profile = ref.watch(driverProfileProvider);
    final auth    = ref.watch(authControllerProvider);
    final phone   = auth.phone != null
        ? auth.phone!.replaceRange(5, auth.phone!.length - 2, ' ••• ••')
        : ref.read(authControllerProvider.notifier).maskedPhone;
    final tripsFormatted =
        NumberFormat.decimalPattern('ru').format(profile.totalTrips);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: QaydaAppBar(
        title: 'Профиль / Профиль',
        glass: false,
        onBack: () => context.popOrGo(Routes.dDashboard),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          // ── Header ────────────────────────────────────────────────────
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.surfaceContainer,
                        width: 4,
                      ),
                      color: scheme.surfaceContainerHigh,
                    ),
                    child: Icon(Icons.person,
                        size: 56, color: scheme.onSurfaceVariant),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: scheme.surface, width: 2),
                      ),
                      child: Text(
                        '${profile.tierBadgeRu} / ${profile.tierBadgeKk}',
                        style: AppTypography.labelMd.copyWith(
                          color: scheme.onPrimary,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                auth.displayName.isNotEmpty
                    ? auth.displayName
                    : profile.nameRu,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMobile,
              ),
              const SizedBox(height: 4),
              Text(
                phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd.copyWith(color: scheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Stats row ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.star,
                  value: profile.rating.toStringAsFixed(2),
                  label: 'Рейтинг / Рейтинг',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  icon: Icons.local_taxi,
                  value: tripsFormatted,
                  label: 'Поездки / Сапарлар',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  icon: Icons.calendar_month,
                  value: '${profile.experienceRu} / ${profile.experienceKk}',
                  label: 'Стаж / Тәжірибе',
                  compactValue: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Account & documents ───────────────────────────────────────
          const _SectionTitle(
            text: 'Аккаунт и документы / Аккаунт және құжаттар',
          ),
          _MenuCard(
            children: [
              _MenuRow(
                icon: Icons.person_outline,
                label: 'Личные данные / Жеке деректер',
                onTap: () => context.push(Routes.editProfile),
              ),
              _MenuRow(
                icon: Icons.local_taxi_outlined,
                label: 'Транспорт / Көлік',
                subtitle: profile.vehicleLine,
                onTap: () => context.push(Routes.dVehicles),
              ),
              _MenuRow(
                icon: Icons.description_outlined,
                label: 'Документы / Құжаттар',
                trailing: profile.documentsVerified
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Проверено / Тексерілді',
                          style: AppTypography.labelMd.copyWith(
                            color: scheme.secondary,
                            fontSize: 11,
                          ),
                        ),
                      )
                    : null,
                onTap: () => _toast(
                  context,
                  profile.documentsVerified
                      ? 'Документы проверены / Құжаттар тексерілді'
                      : 'Загрузите документы в KYC / KYC-де құжаттарды жүктеңіз',
                ),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── App settings ──────────────────────────────────────────────
          const _SectionTitle(
            text: 'Настройки приложения / Қолданба параметрлері',
          ),
          _MenuCard(
            children: [
              _MenuRow(
                icon: Icons.map_outlined,
                label: 'Навигатор / Навигатор',
                subtitle: '2GIS',
                onTap: () => _toast(
                  context,
                  '2GIS — навигация по умолчанию / 2GIS — әдепкі навигация',
                ),
              ),
              _MenuRow(
                icon: Icons.notifications_outlined,
                label: 'Уведомления / Хабарламалар',
                onTap: () => context.push(Routes.settingsNotifications),
              ),
              _MenuRow(
                icon: Icons.language,
                label: 'Язык / Тіл',
                subtitle: 'Русский / Қазақ',
                onTap: () => context.push(Routes.settings),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Other ─────────────────────────────────────────────────────
          const _SectionTitle(text: 'Прочее / Басқалары'),
          _MenuCard(
            children: [
              _MenuRow(
                icon: Icons.support_agent,
                label: 'Поддержка / Қолдау',
                onTap: () => context.push(Routes.support),
              ),
              _MenuRow(
                icon: Icons.info_outline,
                label: 'О приложении / Қолданба туралы',
                onTap: () => context.push(Routes.settingsAbout),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Switch to passenger ───────────────────────────────────────
          _SwitchToPassengerButton(),
          const SizedBox(height: 40),

          // ── Sign out ──────────────────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(authControllerProvider.notifier).signOut();
              },
              borderRadius: BorderRadius.circular(AppRadii.button),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.button),
                  border: Border.all(
                    color: scheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: scheme.error),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Выйти из аккаунта / Аккаунттан шығу',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLg.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'QAYDA DRIVER V4.2.0-STABLE',
            textAlign: TextAlign.center,
            style: AppTypography.labelMd.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.md),
      child: Text(
        text.toUpperCase(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelMd.copyWith(
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool compactValue;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.compactValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: compactValue
                  ? AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)
                  : AppTypography.priceDisplay,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchToPassengerButton extends ConsumerWidget {
  const _SwitchToPassengerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _switchRole(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.person_outline, color: scheme.secondary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Стать пассажиром',
                      style: AppTypography.bodyLg.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Жолаушы болу',
                      style: AppTypography.labelMd.copyWith(
                        color: scheme.onSecondaryContainer
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: scheme.onSecondaryContainer),
            ],
          ),
        ),
      ),
    );
  }

  void _switchRole(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Стать пассажиром?'),
        content: const Text(
          'Вы перейдёте в режим пассажира. Все данные водителя сохранятся — вы сможете вернуться в любой момент.\n\n'
          'Жолаушы режиміне өтесіз. Жүргізуші деректері сақталады.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Продолжить'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true || !context.mounted) return;
      ref.read(selectedRoleProvider.notifier).state = UserRole.passenger;
      ref.read(authControllerProvider.notifier).signOut();
    });
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
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
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: scheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.md),
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
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd.copyWith(
                            color: scheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.34,
                    ),
                    child: trailing!,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (onTap != null)
                  Icon(Icons.chevron_right, color: scheme.outlineVariant),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            color: scheme.outlineVariant.withValues(alpha: 0.15),
          ),
      ],
    );
  }
}
