import 'package:flutter/material.dart';

import 'enums.dart';

/// A selectable payment option for the KZ market (Kaspi, local banks, cash).
class PaymentMethod {
  final String id;
  final PaymentMethodKind kind;
  final String labelRu;
  final String labelKk;
  final String? lastFour;
  final Color brandColor;
  final String brandShort;

  const PaymentMethod({
    required this.id,
    required this.kind,
    required this.labelRu,
    required this.labelKk,
    this.lastFour,
    required this.brandColor,
    required this.brandShort,
  });

  /// Bilingual display label, e.g. `Kaspi Gold (•••• 1234)`.
  String get displayLabelRu =>
      lastFour == null ? labelRu : '$labelRu (•••• $lastFour)';

  String get displayLabelKk =>
      lastFour == null ? labelKk : '$labelKk (•••• $lastFour)';

  /// Combined RU/KK label used across ride + payment screens.
  String get displayLabel => displayLabelRu;

  PaymentType get paymentType => switch (kind) {
        PaymentMethodKind.cash => PaymentType.cash,
        PaymentMethodKind.kaspiGold => PaymentType.kaspi,
        PaymentMethodKind.freedom ||
        PaymentMethodKind.halyk ||
        PaymentMethodKind.card =>
          PaymentType.card,
      };

  /// Detect issuer from a KZ card BIN for the "add card" flow.
  static PaymentMethod fromCardNumber(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    final last4 =
        clean.length >= 4 ? clean.substring(clean.length - 4) : '0000';
    final id = 'card_$last4';

    if (clean.startsWith('440043') || clean.startsWith('4400')) {
      return PaymentMethod(
        id: id,
        kind: PaymentMethodKind.kaspiGold,
        labelRu: 'Kaspi Gold',
        labelKk: 'Kaspi Gold',
        lastFour: last4,
        brandColor: const Color(0xFFF14635),
        brandShort: 'Kaspi',
      );
    }
    if (clean.startsWith('5489') || clean.startsWith('4003')) {
      return PaymentMethod(
        id: id,
        kind: PaymentMethodKind.freedom,
        labelRu: 'Freedom',
        labelKk: 'Freedom',
        lastFour: last4,
        brandColor: const Color(0xFF00A15D),
        brandShort: 'Freedom',
      );
    }
    if (clean.startsWith('4405') || clean.startsWith('5269')) {
      return PaymentMethod(
        id: id,
        kind: PaymentMethodKind.halyk,
        labelRu: 'Halyk',
        labelKk: 'Halyk',
        lastFour: last4,
        brandColor: const Color(0xFF007054),
        brandShort: 'Halyk',
      );
    }
    return PaymentMethod(
      id: id,
      kind: PaymentMethodKind.card,
      labelRu: 'Банковская карта',
      labelKk: 'Банк картасы',
      lastFour: last4,
      brandColor: const Color(0xFF1B1B1B),
      brandShort: 'Card',
    );
  }
}

enum PaymentMethodKind { cash, kaspiGold, freedom, halyk, card }

/// Seed payment methods for the KZ MVP demo.
const kDefaultPaymentMethods = [
  PaymentMethod(
    id: 'cash',
    kind: PaymentMethodKind.cash,
    labelRu: 'Наличные',
    labelKk: 'Қолма-қол ақша',
    brandColor: Color(0xFF5D5F5F),
    brandShort: '₸',
  ),
  PaymentMethod(
    id: 'kaspi_1234',
    kind: PaymentMethodKind.kaspiGold,
    labelRu: 'Kaspi Gold',
    labelKk: 'Kaspi Gold',
    lastFour: '1234',
    brandColor: Color(0xFFF14635),
    brandShort: 'Kaspi',
  ),
  PaymentMethod(
    id: 'freedom_5678',
    kind: PaymentMethodKind.freedom,
    labelRu: 'Freedom',
    labelKk: 'Freedom',
    lastFour: '5678',
    brandColor: Color(0xFF00A15D),
    brandShort: 'Freedom',
  ),
  PaymentMethod(
    id: 'halyk_9012',
    kind: PaymentMethodKind.halyk,
    labelRu: 'Halyk',
    labelKk: 'Halyk',
    lastFour: '9012',
    brandColor: Color(0xFF007054),
    brandShort: 'Halyk',
  ),
];
