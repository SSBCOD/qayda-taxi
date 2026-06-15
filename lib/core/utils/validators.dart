/// Input validators for Kazakhstan-specific fields.
class Validators {
  Validators._();

  /// IIN / ЖСН is exactly 12 digits.
  static bool isValidIin(String value) =>
      RegExp(r'^\d{12}$').hasMatch(value.trim());

  /// Kazakhstan phone: 11 digits starting with 7 (e.g. 7XXXXXXXXXX).
  static bool isValidKzPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length == 11 && digits.startsWith('7');
  }

  /// OTP code: 4-6 digits.
  static bool isValidOtp(String value) =>
      RegExp(r'^\d{4,6}$').hasMatch(value.trim());
}
