import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../services/accounts/account_session.dart';
import 'application/auth_controller.dart';
import 'application/user_profile_controller.dart';

/// Profile setup shown once after OTP — user enters name & surname.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _saving = false;

  bool get _canContinue => _firstCtrl.text.trim().isNotEmpty;

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
      await ref.read(userProfileProvider.notifier).save(
            firstName: _firstCtrl.text,
            lastName:  _lastCtrl.text,
            email:     _emailCtrl.text,
          );
      // Apply pre-selected role and navigate
      final role = ref.read(selectedRoleProvider);
      ref.read(authControllerProvider.notifier).selectRole(role);
      AccountSession.save(ref, role: role);
      if (!mounted) return;
      context.go(
        role.name == 'driver' ? Routes.kycVehicle : Routes.pHome,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Ваш профиль',
        subtitle: 'Сіздің профиліңіз',
        onBack: () => context.go(Routes.otp),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ── Avatar placeholder ───────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        border: Border.all(color: AppColors.outlineLight, width: 2),
                      ),
                      child: const Icon(Icons.person_outline_rounded,
                          size: 48, color: AppColors.textSecondary),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgMain, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              const Text('Как вас зовут?', style: AppTypography.headlineMobile),
              const SizedBox(height: 4),
              Text('Эти данные будут видны водителю',
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),

              // ── Name fields ─────────────────────────────────────────
              _Field(
                controller: _firstCtrl,
                label: 'Имя *',
                hint: 'Арман',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _lastCtrl,
                label: 'Фамилия',
                hint: 'Муратов',
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _emailCtrl,
                label: 'Email (необязательно)',
                hint: 'example@mail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                '* Обязательное поле',
                style: AppTypography.labelMd
                    .copyWith(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
          child: _saving
              ? const Center(child: CircularProgressIndicator())
              : PrimaryActionButton(
                  label: 'Продолжить →',
                  onPressed: _canContinue ? _continue : null,
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
          label.toUpperCase(),
          style: AppTypography.labelMd.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
            fontSize: 11,
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
