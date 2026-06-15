import 'package:flutter/material.dart';

/// Elevation tokens extracted from the Stitch markup.
///
/// Neo-minimalism prefers hairline borders over heavy shadows, so these are
/// intentionally soft. Use [hairline] for the default container separation.
class AppShadows {
  AppShadows._();

  /// shadow-sm — subtle card lift.
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Floating map controls / FABs: 0 4px 12px rgba(0,0,0,0.15).
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x26000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Elevated primary button: 0 8px 30px rgba(0,0,0,0.12).
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 30, offset: Offset(0, 8)),
  ];

  /// Bottom sheet (upward): 0 -8px 30px rgba(0,0,0,0.08).
  static const List<BoxShadow> sheet = [
    BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, -8)),
  ];
}

/// Glassmorphism constants (DESIGN.md: rgba(255,255,255,0.7) + 10px blur).
class AppGlass {
  AppGlass._();

  static const double blur = 10;
  static const Color lightFill = Color(0xB3FFFFFF); // white @ 70%
  static const Color darkFill = Color(0xB3111316);

  /// Theme-aware glass fill so frosted surfaces adapt to dark mode.
  static Color fillOf(Brightness brightness) =>
      brightness == Brightness.dark ? darkFill : lightFill;
}
