import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/gen/app_localizations.dart';

/// Convenience accessors on [BuildContext].
extension BuildContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppLocalizations get l10n => AppLocalizations.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Pops when possible; otherwise replaces with [fallbackRoute] (avoids GoError).
  void popOrGo(String fallbackRoute) {
    if (canPop()) {
      pop();
    } else {
      go(fallbackRoute);
    }
  }
}
