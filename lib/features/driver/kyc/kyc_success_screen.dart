import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../dashboard/application/driver_controller.dart';
import 'application/kyc_controller.dart';

/// Driver KYC · verification successful
/// (Stitch `vehicle_verification_successful`).
///
/// Confirms the vehicle is approved and lets the driver go online — which lands
/// on the driver dashboard. The KYC application is already
/// [VerificationStatus.verified] at this point, so the [RedirectGuard] now lets
/// `/d/*` through.
class KycSuccessScreen extends ConsumerWidget {
  const KycSuccessScreen({super.key});

  void _goOnline(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    // Ensure verified even if the user arrived here without the pending step.
    ref.read(kycControllerProvider.notifier).approve();
    ref.read(driverControllerProvider.notifier).goOnline();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.go(Routes.dDashboard);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final kyc = ref.watch(kycControllerProvider);

    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Верификация',
        subtitle: 'Тексеру',
        onBack: () => context.go(Routes.dDashboard),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.help_outline, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          children: [
            // Success icon.
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surfaceContainer),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_circle,
                      size: 60, color: Color(0xFF16A34A)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Автомобиль проверен',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineMobile,
            ),
            const SizedBox(height: 4),
            Text(
              'Көлік тексерілді',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTypography.bodyLg.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ваш ${kyc.brandModel} готов к работе. Теперь вы можете принимать '
              'заказы.\nСіздің ${kyc.brandModel} жұмысқа дайын. Енді '
              'тапсырыстарды қабылдай аласыз.',
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            _VerifiedVehicleCard(
              brandModel: kyc.brandModel,
              year: kyc.year,
              plate: kyc.plate,
              tierRu: kyc.tierLabelRu,
            ),
            const SizedBox(height: AppSpacing.gutter),
            _ReadyToWorkCard(),
          ],
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
            label: 'Выйти на линию',
            labelSecondary: 'Желіге шығу',
            onPressed: () => _goOnline(context, ref),
          ),
        ),
      ),
    );
  }
}

/// Verified vehicle summary card: tier badge + model + plate + VERIFIED pill.
class _VerifiedVehicleCard extends StatelessWidget {
  final String brandModel;
  final int year;
  final String plate;
  final String tierRu;

  const _VerifiedVehicleCard({
    required this.brandModel,
    required this.year,
    required this.plate,
    required this.tierRu,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return QaydaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tierRu.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      brandModel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$year • $plate',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 16, color: Color(0xFF15803D)),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'VERIFIED',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AspectRatio(
            aspectRatio: 1.49,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Icon(Icons.directions_car,
                  size: 72, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Готовы к работе?" prompt card.
class _ReadyToWorkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: scheme.surfaceContainerHigh),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.rocket_launch, size: 20, color: scheme.onPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Готовы к работе? / Дайынсыз ба?',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLg
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Нажмите кнопку ниже, чтобы выйти на линию. Система начнёт '
                  'поиск заказов в вашем районе.\nЖеліге шығу үшін төмендегі '
                  'түймені басыңыз.',
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
