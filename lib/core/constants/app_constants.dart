/// App-wide constants and feature flags.
class AppConstants {
  AppConstants._();

  static const String appName = 'Qayda';
  static const List<String> supportedLanguageCodes = ['ru', 'kk'];

  /// Demo OTP accepted by the mock auth flow (see docs/app_flows.md §1 and
  /// docs/backend.md "test phone numbers"). No real SMS is sent.
  static const String demoOtp = '123456';
  static const int otpLength = 6;

  /// Backend switch: when true, repositories use local mock data sources.
  /// Set to false once Firebase is wired (see ARCHITECTURE.md backend section).
  static const bool useMock = true;

  /// Default map center (Almaty). Maps use OpenStreetMap (flutter_map) +
  /// OSRM — no API key or billing required.
  static const double defaultLat = 43.2389;
  static const double defaultLng = 76.8897;
}
