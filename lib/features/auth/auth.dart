/// Auth feature: splash, language selection, phone + OTP, role gate.
///
/// Layers:
///   application/  -> auth_controller (Riverpod session state)
///   *_screen.dart -> the flow screens (splash → language → phone → otp → role)
library;

export 'application/auth_controller.dart';
export 'application/user_profile_controller.dart';
export 'language_screen.dart';
export 'otp_screen.dart';
export 'phone_screen.dart';
export 'profile_setup_screen.dart';
export 'role_screen.dart';
export 'splash_screen.dart';
export 'welcome_screen.dart';
