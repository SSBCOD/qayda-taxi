/// Kazakhstan mobile phone validation and display formatting.
///
/// National format: 11 digits starting with `7` (e.g. `77071234567`),
/// displayed as `7-707-123-45-67`. Operator code is the 3 digits after the
/// leading country digit (`707`, `747`, `777`, …).
class KzPhone {
  KzPhone._();

  /// Valid KZ mobile operator codes (ITU + local allocations).
  static const Set<String> operatorCodes = {
    '700',
    '701',
    '702',
    '703',
    '704',
    '705',
    '706',
    '707',
    '708',
    '709',
    '747',
    '750',
    '751',
    '760',
    '761',
    '762',
    '763',
    '764',
    '765',
    '766',
    '767',
    '768',
    '771',
    '775',
    '776',
    '777',
    '778',
  };

  static const int nationalLength = 11;

  /// Strips non-digits and normalises to a leading `7`.
  static String normalizeDigits(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (!digits.startsWith('7')) digits = '7$digits';
    if (digits.length > nationalLength) {
      digits = digits.substring(0, nationalLength);
    }
    return digits;
  }

  /// Formats digits as `7-707-123-45-67` (hyphens after 1st, 4th, 7th, 9th).
  static String format(String digits) {
    final d = normalizeDigits(digits);
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 1 || i == 4 || i == 7 || i == 9) b.write('-');
      b.write(d[i]);
    }
    return b.toString();
  }

  /// E.164-style storage value: `+77071234567`.
  static String toE164(String digits) => '+${normalizeDigits(digits)}';

  /// Returns `null` when valid; otherwise a bilingual error message.
  static String? validate(String digits) {
    final d = normalizeDigits(digits);
    if (d.isEmpty) return null;
    if (d.length < nationalLength) return null;

    if (d.length != nationalLength) {
      return 'Номер должен содержать 11 цифр / Нөмір 11 саннан тұруы керек';
    }
    if (!d.startsWith('7')) {
      return 'Номер должен начинаться с 7 / Нөмір 7-ден басталуы керек';
    }
    if (d[1] != '7') {
      return 'Неверный формат мобильного номера / Жарамсыз ұялы нөмір пішімі';
    }
    final code = d.substring(1, 4);
    if (!operatorCodes.contains(code)) {
      return 'Неверный код оператора / Оператор коды қате';
    }
    return null;
  }

  /// Masked display for OTP subtitle: `+7 (707) ••• •• 67`.
  static String mask(String digits) {
    final d = normalizeDigits(digits);
    if (d.length < nationalLength) return '+7 ••• ••• •• ••';
    final code = d.substring(1, 4);
    final last = d.substring(d.length - 2);
    return '+7 ($code) ••• •• $last';
  }

  /// Placeholder hint matching the hyphen mask.
  static const String placeholder = '7-707-123-45-67';
}
