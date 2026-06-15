import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/session_reset.dart';
import '../../services/accounts/account_session.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/enums.dart';
import '../driver/kyc/application/kyc_controller.dart';
import 'application/auth_controller.dart';

/// Role gate — shown once after first sign-in. Passenger goes straight to the
/// home map; driver enters the KYC onboarding (vehicle → identity → pending →
/// success) before reaching the dashboard.
class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});

  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  UserRole? _selected;

  void _confirm() {
    final role = _selected;
    if (role == null) return;
    ref.read(authControllerProvider.notifier).selectRole(role);
    SessionReset.onRoleSelected(ref, role);
    context.go(
      role == UserRole.driver
          ? AccountSession.driverKycEntryRoute(
              ref.read(kycControllerProvider).status,
            )
          : Routes.pHome,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const Text('Как будете пользоваться?',
                  style: AppTypography.headlineMobile),
              const SizedBox(height: 2),
              Text(
                'Qayda-ны қалай қолданасыз?',
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              _RoleCard(
                icon: Icons.person_outline,
                title: 'Пассажир',
                subtitle: 'Заказывать поездки • Жолаушы',
                selected: _selected == UserRole.passenger,
                onTap: () => setState(() => _selected = UserRole.passenger),
              ),
              const SizedBox(height: AppSpacing.gutter),
              _RoleCard(
                icon: Icons.directions_car_outlined,
                title: 'Водитель',
                subtitle: 'Зарабатывать на поездках • Жүргізуші',
                selected: _selected == UserRole.driver,
                onTap: () => setState(() => _selected = UserRole.driver),
              ),
            ],
          ),
        ),
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
            label: 'Продолжить',
            labelSecondary: 'Жалғастыру',
            onPressed: _selected == null ? null : _confirm,
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return QaydaCard(
      onTap: onTap,
      color: selected ? scheme.primary : scheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? scheme.onPrimary.withValues(alpha: 0.15)
                  : scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadii.button - 4),
            ),
            child: Icon(icon, color: fg),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.headlineMd.copyWith(color: fg)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyMd.copyWith(
                    color: selected
                        ? scheme.onPrimary.withValues(alpha: 0.8)
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (selected) Icon(Icons.check_circle, color: scheme.onPrimary),
        ],
      ),
    );
  }
}
