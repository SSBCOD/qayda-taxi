import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/enums.dart';
import 'application/auth_controller.dart';
import 'application/user_profile_controller.dart';

/// STEP 1 of registration — shown BEFORE phone entry.
/// Collects name, surname, email and role (passenger / driver).
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  UserRole _role   = UserRole.passenger;
  bool _saving     = false;

  bool get _canContinue => _firstCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Pre-fill if user already saved profile earlier.
    final auth = ref.read(authControllerProvider);
    if (auth.hasProfile) {
      _firstCtrl.text = auth.firstName;
      _lastCtrl.text  = auth.lastName;
      _emailCtrl.text = auth.email;
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_canContinue || _saving) return;
    setState(() => _saving = true);
    try {
      // Save to AuthController (persists to SharedPreferences).
      await ref.read(authControllerProvider.notifier).saveProfile(
            firstName: _firstCtrl.text,
            lastName:  _lastCtrl.text,
            email:     _emailCtrl.text,
          );
      // Store pre-selected role for OTP completion.
      ref.read(selectedRoleProvider.notifier).state = _role;
      if (!mounted) return;
      // Navigate to phone entry (Welcome).
      context.go(Routes.welcome);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ── Header ──────────────────────────────────────────────
              const Text(
                'Создайте аккаунт',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Заполните данные для регистрации',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Avatar ──────────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        border: Border.all(color: AppColors.outlineLight, width: 2),
                      ),
                      child: const Icon(Icons.person_outline_rounded,
                          size: 40, color: AppColors.textSecondary),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgMain, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Name fields ─────────────────────────────────────────
              _Field(
                controller: _firstCtrl,
                label: 'ИМЯ *',
                hint: 'Арман',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _lastCtrl,
                label: 'ФАМИЛИЯ',
                hint: 'Муратов',
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _emailCtrl,
                label: 'EMAIL',
                hint: 'example@mail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Role selection ──────────────────────────────────────
              const Text(
                'КТО ВЫ?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.bgMain,
                  borderRadius: BorderRadius.circular(AppRadii.button),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Row(
                  children: [
                    _RoleTab(
                      icon: Icons.person_outline,
                      label: 'Пассажир',
                      selected: _role == UserRole.passenger,
                      onTap: () => setState(() => _role = UserRole.passenger),
                    ),
                    _RoleTab(
                      icon: Icons.directions_car_outlined,
                      label: 'Водитель',
                      selected: _role == UserRole.driver,
                      onTap: () => setState(() => _role = UserRole.driver),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              PrimaryActionButton(
                label: 'Продолжить →',
                onPressed: _canContinue ? _continue : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  '* Имя обязательно',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.button - 4),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.name,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTypography.headlineMd.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.headlineMd
                .copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.bgCard,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide: const BorderSide(color: AppColors.outlineLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide: const BorderSide(color: AppColors.outlineLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide:
                  const BorderSide(color: AppColors.purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
