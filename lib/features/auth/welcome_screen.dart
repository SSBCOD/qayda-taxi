import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/phone/kz_phone.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../services/notifications/otp_notification_service.dart';
import 'application/auth_controller.dart';

/// Welcome + phone entry (Stitch `welcome_setup`).
///
/// Collects an 11-digit Kazakhstan mobile number (`7-707-123-45-67`), validates
/// the operator code, sends a mock OTP via a local Android notification and
/// continues to [OtpScreen].
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
      appBar: QaydaAppBar(
        title: 'Qayda',
        onBack: () => _back(context),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: Center(child: LanguageSwitcher()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Добро пожаловать в Qayda',
                style: AppTypography.displayLg.copyWith(color: scheme.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Qayda-ға қош келдіңіз',
                style: AppTypography.headlineMobile
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Ваш номер телефона',
                  style: AppTypography.headlineMobile),
              const SizedBox(height: 2),
              Text(
                'Телефон нөміріңіз',
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
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
              const SizedBox(height: AppSpacing.gutter),
              Text(
                'Мы отправим уведомление с кодом подтверждения\n'
                'Растау кодын хабарландыру арқылы жібереміз',
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
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
            label: 'Далее',
            labelSecondary: 'Жалғастыру',
            onPressed: _canSubmit ? _submit : null,
          ),
        ),
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.language);
    }
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(
          color: hasError
              ? scheme.error
              : scheme.outlineVariant.withValues(alpha: 0.4),
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\-]')),
          LengthLimitingTextInputFormatter(15),
        ],
        style: AppTypography.headlineMd,
        decoration: InputDecoration(
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          hintText: KzPhone.placeholder,
          hintStyle: AppTypography.headlineMd.copyWith(color: scheme.outline),
        ),
      ),
    );
  }
}
