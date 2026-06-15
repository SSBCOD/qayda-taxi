import 'package:flutter/material.dart';

/// Color tokens sourced from `qayda_executive/DESIGN.md`.
/// Neo-minimalist: binary black/white with a restrained surface ladder.
class AppColors {
  AppColors._();

  // Core
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1B1B1B);
  static const Color onPrimaryContainer = Color(0xFF848484);
  static const Color secondary = Color(0xFF5D5F5F);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDFE0E0);
  static const Color onSecondaryContainer = Color(0xFF616363);
  static const Color tertiary = Color(0xFF000000);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFF9F9FE);
  static const Color onSurface = Color(0xFF1A1C1F);
  static const Color onSurfaceVariant = Color(0xFF4C4546);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F8);
  static const Color surfaceContainer = Color(0xFFEDEDF2);
  static const Color surfaceContainerHigh = Color(0xFFE8E8ED);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E7);

  static const Color outline = Color(0xFF7E7576);
  static const Color outlineVariant = Color(0xFFCFC4C5);
  static const Color surfaceTint = Color(0xFF5E5E5E);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color inverseSurface = Color(0xFF2F3034);
  static const Color inverseOnSurface = Color(0xFFF0F0F5);
  static const Color inversePrimary = Color(0xFFC6C6C6);

  // Semantic accents (used on maps / live states only)
  static const Color locationBlue = Color(0xFF007AFF);
  static const Color routeBlue = Color(0xFF409CFF);
  static const Color online = Color(0xFF22C55E);

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    surfaceTint: surfaceTint,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFFFFF),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFFE2E2E2),
    onPrimaryContainer: Color(0xFF1B1B1B),
    secondary: Color(0xFFC6C6C7),
    onSecondary: Color(0xFF1A1C1C),
    secondaryContainer: Color(0xFF2A2A2A),
    onSecondaryContainer: Color(0xFFDFE0E0),
    tertiary: Color(0xFFFFFFFF),
    onTertiary: Color(0xFF000000),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF111316),
    onSurface: Color(0xFFE2E2E7),
    onSurfaceVariant: Color(0xFFCFC4C5),
    outline: Color(0xFF989091),
    outlineVariant: Color(0xFF4C4546),
    inverseSurface: Color(0xFFE2E2E7),
    onInverseSurface: Color(0xFF2F3034),
    inversePrimary: Color(0xFF000000),
  );
}
