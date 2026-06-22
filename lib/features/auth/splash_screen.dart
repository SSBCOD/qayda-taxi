import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

/// Splash / start screen — the unauthenticated landing (Stitch
/// `splash_start_2gis_update`). 3D-style logo, bilingual welcome and the
/// "Начать / Бастау" CTA leading into language selection.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final isKk = ref.watch(localeControllerProvider).languageCode == 'kk';
    String pri(String ru, String kk) => isKk ? kk : ru;
    String sec(String ru, String kk) => isKk ? ru : kk;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Language switcher (top-right).
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.page),
                child: LanguageSwitcher(),
              ),
            ),

            // Centered logo + welcome copy.
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Logo(),
                    const SizedBox(height: 40),
                    Text(
                      pri('Добро пожаловать в Qayda', 'Qayda-ға қош келдіңіз'),
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLg.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      sec('Добро пожаловать в Qayda', 'Qayda-ға қош келдіңіз'),
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineMobile.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      pri('Такси по всему Казахстану',
                          'Бүкіл Қазақстан бойынша такси'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLg.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      sec('Такси по всему Казахстану',
                          'Бүкіл Қазақстан бойынша такси'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA.
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.lg,
                ),
                child: PrimaryActionButton(
                  label: pri('Начать', 'Бастау'),
                  labelSecondary: sec('Начать', 'Бастау'),
                  onPressed: () => context.go(Routes.language),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A35),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E2E55), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_taxi_rounded,
            size: 56,
            color: Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'QAYDA',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ПРЕМИАЛЬНЫЙ СЕРВИС • КАЗАХСТАН',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}
