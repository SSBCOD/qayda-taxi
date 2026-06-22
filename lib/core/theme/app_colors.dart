import 'package:flutter/material.dart';

/// Dark-purple "Midnight" palette — matches the Ether/Obsidian reference design.
class AppColors {
  AppColors._();

  // ── Brand purple ────────────────────────────────────────────────────────────
  static const Color purple        = Color(0xFF8B5CF6);
  static const Color purpleLight   = Color(0xFFA78BFA);
  static const Color purpleDark    = Color(0xFF7C3AED);
  static const Color purpleDeep    = Color(0xFF5B21B6);

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color bgMain        = Color(0xFF090912); // scaffold
  static const Color bgCard        = Color(0xFF12122A); // card / sheet
  static const Color bgCardMid     = Color(0xFF1A1A35); // elevated card
  static const Color bgCardHigh    = Color(0xFF1F1F3C); // highest card

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F0FA);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textDisabled  = Color(0xFF4B5563);

  // ── Outlines ────────────────────────────────────────────────────────────────
  static const Color outline       = Color(0xFF2E2E55);
  static const Color outlineLight  = Color(0xFF3D3D6A);

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const Color error         = Color(0xFFFF6B6B);
  static const Color errorContainer = Color(0xFF2A1010);
  static const Color online        = Color(0xFF22C55E);
  static const Color locationBlue  = Color(0xFF60A5FA);
  static const Color routeBlue     = Color(0xFFA78BFA); // purple route line

  // ── Dark ColorScheme ────────────────────────────────────────────────────────
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,

    primary:            purple,
    onPrimary:          Color(0xFFFFFFFF),
    primaryContainer:   Color(0xFF1E1235),
    onPrimaryContainer: purpleLight,

    secondary:            purpleLight,
    onSecondary:          Color(0xFF0A0A1A),
    secondaryContainer:   Color(0xFF1E1235),
    onSecondaryContainer: purpleLight,

    tertiary:    Color(0xFF60A5FA),
    onTertiary:  Color(0xFF0A0A1A),

    error:            error,
    onError:          Color(0xFFFFFFFF),
    errorContainer:   errorContainer,
    onErrorContainer: error,

    surface:              bgMain,
    onSurface:            textPrimary,
    onSurfaceVariant:     textSecondary,

    outline:        outlineLight,
    outlineVariant: outline,

    inverseSurface:   textPrimary,
    onInverseSurface: bgMain,
    inversePrimary:   purpleDark,

    surfaceTint: purple,

    surfaceContainerLowest:  Color(0xFF0D0D20),
    surfaceContainerLow:     bgCard,
    surfaceContainer:        bgCardMid,
    surfaceContainerHigh:    bgCardHigh,
    surfaceContainerHighest: Color(0xFF252550),
  );

  // ── Light ColorScheme (fallback — same dark look) ───────────────────────────
  static const ColorScheme light = dark;
}
