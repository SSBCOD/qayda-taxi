import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/phone/kz_phone.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/enums.dart';
import '../../services/notifications/otp_notification_service.dart';
import 'application/auth_controller.dart';
import 'application/user_profile_controller.dart';

/// Welcome screen — role tabs (Passenger / Driver) + phone entry.
/// Pre-selects the role so it's already set when the user finishes OTP.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _controller = TextEditingController();
  String _digits = '';
  String? _error;
  bool _submitting = false;
  UserRole _role = UserRole.passenger;

  bool get _canSubmit =>
      _digits.length == KzPhone.nationalLength &&
      KzPhone.validate(_digits) == null &&
      !_submitting;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final digits = KzPhone.normalizeDigits(value);
    final formatted = KzPhone.format(digits);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {
      _digits = digits;
      _error = digits.length == KzPhone.nationalLength
          ? KzPhone.validate(digits)
          : null;
    });
  }

  Future<void> _submit() async {
    final validationError = KzPhone.validate(_digits);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    if (!_canSubmit) return;

    setState(() => _submitting = true);
    try {
      final e164 = KzPhone.toE164(_digits);
      final otp = ref.read(authControllerProvider.notifier).requestOtp(e164);
      // Save chosen role so OTP screen can use it
      ref.read(selectedRoleProvider.notifier).state = _role;
      await OtpNotificationService.showOtp(
        maskedPhone: KzPhone.mask(_digits),
        code: otp,
      );
      if (mounted) context.go(Routes.otp);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ── Header ──────────────────────────────────────────────────
              Text(
                'Поездка начнётся',
                style: AppTypography.headlineLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
              Text(
                'с комфорта',
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.purpleLight,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Введите номер телефона, чтобы авторизоваться',
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Card with role tabs + phone ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Role tabs ──────────────────────────────────────────
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.bgMain,
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                      child: Row(
                        children: [
                          _RoleTab(
                            label: 'Пассажир',
                            selected: _role == UserRole.passenger,
                            onTap: () => setState(() => _role = UserRole.passenger),
                          ),
                          _RoleTab(
                            label: 'Водитель',
                            selected: _role == UserRole.driver,
                            onTap: () => setState(() => _role = UserRole.driver),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Phone field ────────────────────────────────────────
                    Text(
                      'НОМЕР ТЕЛЕФОНА',
                      style: AppTypography.labelMd.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _PhoneField(
                      controller: _controller,
                      hasError: _error != null,
                      onChanged: _onChanged,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _error!,
                        style: AppTypography.bodyMd.copyWith(color: scheme.error),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Нажимая «Продолжить», вы принимаете условия '
                      'Пользовательского соглашения и Политики конфиденциальности',
                      style: AppTypography.labelMd.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryActionButton(
                      label: 'Продолжить →',
                      onPressed: _canSubmit ? _submit : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  'БЫСТРЫЙ ВХОД ЧЕРЕЗ',
                  style: AppTypography.labelMd.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(
                    label: 'Google',
                    icon: Icons.g_mobiledata_rounded,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _SocialButton(
                    label: 'Apple',
                    icon: Icons.apple,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Role tab widget ────────────────────────────────────────────────────────────

class _RoleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTab({
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
                      color: AppColors.purple.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Phone field ────────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hasError;

  const _PhoneField({
    required this.controller,
    required this.onChanged,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Row(
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCardMid,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(color: AppColors.outlineLight),
          ),
          child: Row(
            children: [
              Text('+7', style: AppTypography.headlineMd.copyWith(color: Colors.white)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bgCardMid,
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(
                color: hasError ? scheme.error : AppColors.outlineLight,
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: false,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\-]')),
                LengthLimitingTextInputFormatter(15),
              ],
              style: AppTypography.headlineMd.copyWith(color: Colors.white),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: KzPhone.placeholder,
                hintStyle: AppTypography.headlineMd
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Social login button ────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SocialButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 26),
    );
  }
}

