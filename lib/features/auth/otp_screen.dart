import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/constants/app_constants.dart';
import 'application/user_profile_controller.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../services/accounts/account_session.dart';
import '../../services/notifications/otp_notification_service.dart';
import 'application/auth_controller.dart';

/// OTP verification (Stitch `verification_code`). 6-digit boxed input, a resend
/// countdown and a local notification that delivers the mock SMS code.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendSeconds = 59;
  Timer? _timer;
  int _remaining = _resendSeconds;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remaining = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  Future<void> _resend() async {
    final auth = ref.read(authControllerProvider.notifier);
    final otp = auth.resendOtp();
    if (otp.isEmpty) return;

    await OtpNotificationService.showOtp(
      maskedPhone: auth.maskedPhone,
      code: otp,
    );
    _startCountdown();
  }

  void _onCompleted(String code) {
    final auth = ref.read(authControllerProvider.notifier);
    final ok = auth.verifyOtp(code);
    if (!ok) {
      setState(() => _error = true);
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    final phone = auth.pendingPhone;
    AccountSession.restore(ref, phone);

    if (!mounted) return;
    final session = ref.read(authControllerProvider);
    if (session.hasRole) {
      // Returning user — go straight to their home screen.
      context.go(AccountSession.homeRouteFor(ref));
    } else {
      // New user — check if they already entered their name.
      final profile = ref.read(userProfileProvider).valueOrNull;
      if (profile != null && profile.hasName) {
        context.go(Routes.role);
      } else {
        context.go(Routes.profileSetup);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final masked = ref.read(authControllerProvider.notifier).maskedPhone;

    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Qayda',
        onBack: () => _back(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const Text('Введите код', style: AppTypography.headlineMobile),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Отправлен на $masked',
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 56),
              OtpInput(
                length: AppConstants.otpLength,
                onChanged: (_) {
                  if (_error) setState(() => _error = false);
                },
                onCompleted: _onCompleted,
              ),
              const SizedBox(height: AppSpacing.md),
              if (_error)
                Center(
                  child: Text(
                    'Неверный код. Попробуйте ещё раз / Код қате',
                    style: AppTypography.bodyMd.copyWith(color: scheme.error),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: _ResendControl(
                  remaining: _remaining,
                  onResend: _resend,
                ),
              ),
              const Spacer(),
              // ── OTP code display card ───────────────────────────────────
              _OtpCodeCard(
                getCode: () =>
                    ref.read(authControllerProvider.notifier).debugOtp,
                onCopy: (otp) {
                  Clipboard.setData(ClipboardData(text: otp));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Код скопирован: $otp'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.welcome);
    }
  }
}

/// Big visible OTP code card — replaces the hidden DEV badge.
class _OtpCodeCard extends StatelessWidget {
  final String Function() getCode;
  final void Function(String) onCopy;

  const _OtpCodeCard({required this.getCode, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final code = getCode();
    return GestureDetector(
      onTap: () => onCopy(code),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.sms_outlined, size: 18, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Text(
                  'Qayda — код подтверждения',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _spaced(code),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.touch_app_outlined, size: 14, color: Color(0xFF8B5CF6)),
                SizedBox(width: 4),
                Text(
                  'Нажмите чтобы скопировать',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _spaced(String s) => s.split('').join(' ');
}

class _ResendControl extends StatelessWidget {
  final int remaining;
  final Future<void> Function() onResend;

  const _ResendControl({required this.remaining, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    if (remaining > 0) {
      final m = remaining ~/ 60;
      final s = (remaining % 60).toString().padLeft(2, '0');
      return Text(
        'Отправить снова через $m:$s',
        style: AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
      );
    }
    return TextButton(
      onPressed: () => onResend(),
      child: const Text('Отправить снова / Қайта жіберу'),
    );
  }
}
