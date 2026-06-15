import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import 'application/kyc_controller.dart';

/// Driver KYC · verification pending
/// (Stitch `driver_onboarding_verification_pending`).
///
/// Shows the "documents under review" status. For the demo the fake back-office
/// auto-approves after a short delay (the real flow waits up to 24h); the
/// "Понятно / Түсінікті" button lets the driver skip straight to the result.
class KycPendingScreen extends ConsumerStatefulWidget {
  const KycPendingScreen({super.key});

  @override
  ConsumerState<KycPendingScreen> createState() => _KycPendingScreenState();
}

class _KycPendingScreenState extends ConsumerState<KycPendingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _autoApprove;
  bool _navigated = false;

  static const _reviewDelay = Duration(milliseconds: 3500);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    // Simulate the back-office finishing the review and surfacing the result.
    _autoApprove = Timer(_reviewDelay, _continue);
  }

  @override
  void dispose() {
    _autoApprove?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _continue() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _autoApprove?.cancel();
    ref.read(kycControllerProvider.notifier).approve();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(Routes.kycSuccess);
    });
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Поддержка скоро свяжется с вами / '
            'Қолдау қызметі жақын арада хабарласады'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Scaffold(
      appBar: QaydaAppBar(onBack: () => context.go(Routes.kycIdentity)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Pulsing illustration.
            SizedBox(
              width: 192,
              height: 192,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FadeTransition(
                    opacity:
                        Tween<double>(begin: 0.25, end: 0.55).animate(_pulse),
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.4, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color:
                                scheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 64, color: scheme.onSurface),
                          Positioned(
                            right: 24,
                            bottom: 24,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: scheme.surface, width: 4),
                              ),
                              child: Icon(Icons.search,
                                  size: 20, color: scheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Документы на проверке',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMobile,
            ),
            const SizedBox(height: 4),
            Text(
              'Құжаттар тексерілуде',
              textAlign: TextAlign.center,
              style:
                  AppTypography.bodyLg.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Обычно это занимает не более 24 часов. Мы отправим вам '
              'уведомление, когда всё будет готово.\n'
              'Әдетте бұл 24 сағаттан аспайды. Барлығы дайын болған кезде '
              'сізге хабарландыру жібереміз.',
              textAlign: TextAlign.center,
              style:
                  AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StatusGlassCard(),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: _contactSupport,
              child: Text(
                'Связаться с поддержкой / Қолдау қызметіне хабарласу',
                textAlign: TextAlign.center,
                style: AppTypography.labelMd.copyWith(color: scheme.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryActionButton(
              label: 'Понятно',
              labelSecondary: 'Түсінікті',
              onPressed: _continue,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

/// Glassmorphic status row: "Статус: В очереди / PENDING VERIFICATION".
class _StatusGlassCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.input),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadii.input),
            border:
                Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.verified_user, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Статус: В очереди / Кезекте',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PENDING VERIFICATION',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
