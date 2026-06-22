import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/accounts/account_session.dart';

/// Holds the active [ThemeMode] (light / dark / system) per account.
///
/// Persisted via [AccountSession]; falls back to system before login restore.
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setMode(ThemeMode mode) {
    state = mode;
    AccountSession.save(ref, themeMode: mode);
  }

  void restore(String raw) {
    switch (raw) {
      case 'light':
        state = ThemeMode.light;
      case 'dark':
        state = ThemeMode.dark;
      default:
        state = ThemeMode.system;
    }
  }

  /// Convenience toggle between light and dark used by the profile switch.
  void toggleDark({required bool dark}) =>
      setMode(dark ? ThemeMode.dark : ThemeMode.light);
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
