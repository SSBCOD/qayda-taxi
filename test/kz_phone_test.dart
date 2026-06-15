import 'package:flutter_test/flutter_test.dart';
import 'package:qayda/core/phone/kz_phone.dart';

void main() {
  group('KzPhone', () {
    test('formats 11 digits with hyphens', () {
      expect(KzPhone.format('77071234567'), '7-707-123-45-67');
    });

    test('accepts valid Beeline number', () {
      expect(KzPhone.validate('77071234567'), isNull);
    });

    test('rejects unknown operator code', () {
      expect(KzPhone.validate('71231234567'), isNotNull);
    });

    test('rejects invalid operator on full number', () {
      expect(KzPhone.validate('79991234567'), isNotNull);
    });

    test('incomplete number has no error', () {
      expect(KzPhone.validate('7707123456'), isNull);
    });

    test('toE164 adds plus prefix', () {
      expect(KzPhone.toE164('77071234567'), '+77071234567');
    });
  });
}
