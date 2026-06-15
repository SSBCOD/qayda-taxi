import 'package:flutter/widgets.dart';

/// Corner radii — "Large-Radius Minimalism" (DESIGN.md).
class AppRadii {
  AppRadii._();

  static const double button = 16; // interactive elements
  static const double input = 16;
  static const double card = 24; // containers / cards
  static const double sheet = 24; // bottom sheets

  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetRadius =
      BorderRadius.vertical(top: Radius.circular(sheet));
}
