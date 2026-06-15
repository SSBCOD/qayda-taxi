import 'package:flutter/material.dart';

/// Type scale from `qayda_executive/DESIGN.md` (Inter family).
/// Letter spacing is converted from em to logical pixels.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    height: 41 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.68,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.28,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22,
  );

  static const TextStyle headlineMobile = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.17,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.13,
  );

  /// Tenge (₸) prices — equal visual weight to digits.
  static const TextStyle priceDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLg,
    headlineLarge: headlineLg,
    headlineMedium: headlineMd,
    headlineSmall: headlineMobile,
    titleMedium: bodyLg,
    bodyLarge: bodyLg,
    bodyMedium: bodyMd,
    labelMedium: labelMd,
  );
}
