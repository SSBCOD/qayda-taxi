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
import '../../services/notifications/otp_notification_service.dart';
import 'application/auth_controller.dart';

/// STEP 2 of registration — phone number entry (after profile setup).
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _controller = TextEditingController();
  String _digits    = '';
  String? _error;
  bool _submitting  = false;

  bool get _canSubmit =>
      _digits.length == KzPhone.nationalLength &&
      KzPhone.validate(_digits) == null &&
      !_submitting;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _fmtLocal(String raw) {
    final b = StringBuffer();
    for (var i = 0; i < raw.length && i < 10; i++) {
      if (i == 3 || i == 6 || i == 8) b.write('-');
      b.write(raw[i]);
    }
    return b.toString();
  }

  void _onChanged(String value) {
    var raw = value.replaceAll(RegExp(r'\D'), '');
    if (raw.startsWith('7') && raw.length > 10) raw = raw.substring(1);
    if (raw.length > 10) raw = raw.substring(0, 10);

    final formatted = _fmtLocal(raw);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    final full = raw.isEmpty ? '' : '7$raw';
    setState(() {
      _digits = full;
      _error = full.length == KzPhone.nationalLength
          ? KzPhone.validate(full)
          : null;
    });
  }

  Future<void> _submit() async {
    final err = KzPhone.validate(_digits);
    if (err != null) { setState(() => _error = err); return; }
    if (!_canSubmit) return;

    setState(() => _submitting = true);
    try {
      final e164 = KzPhone.toE164(_digits);
      // requestOtp is now async — returns mock code or null (Firebase SMS).
      final mockCode = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(e164);
      if (mockCode != null && mockCode.isNotEmpty) {
        // Debug/Windows: show mock code in notification.
        await OtpNotificationService.showOtp(
          maskedPhone: KzPhone.mask(_digits),
          code: mockCode,
        );
      }
      if (mounted) context.go(Routes.otp);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme   = context.colors;
    final auth     = ref.watch(authControllerProvider);
    final firstName = auth.firstName;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ── Greeting ─────────────────────────────────────────────
              if (firstName.isNotEmpty) ...[
                Text(
                  'Привет, $firstName!',
                  style: AppTypography.headlineLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                'Поездка начнётся',
                style: AppTypography.headlineLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              Text(
                'с комфорта',
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.purpleLight,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Введите номер телефона для входа',
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Phone card ───────────────────────────────────────────
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
                    const Text(
                      'НОМЕР ТЕЛЕФОНА',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
                      Text(_error!,
                          style: AppTypography.bodyMd
                              .copyWith(color: scheme.error)),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Нажимая «Продолжить», вы принимаете условия '
                      'Пользовательского соглашения и Политики конфиденциальности',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
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
                child: TextButton(
                  onPressed: () => context.go(Routes.profileSetup),
                  child: const Text(
                    '← Изменить профиль',
                    style: TextStyle(color: AppColors.purpleLight),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              Center(
                child: const Text(
                  'БЫСТРЫЙ ВХОД ЧЕРЕЗ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(icon: Icons.g_mobiledata_rounded),
                  const SizedBox(width: AppSpacing.md),
                  _SocialButton(icon: Icons.apple),
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
              Text('+7',
                  style: AppTypography.headlineMd
                      .copyWith(color: Colors.white)),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
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
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\-]')),
                LengthLimitingTextInputFormatter(13),
              ],
              style: AppTypography.headlineMd.copyWith(color: Colors.white),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                hintText: '747-123-45-67',
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

class _SocialButton extends StatelessWidget {
  final IconData icon;
  const _SocialButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 24),
    );
  }
}
