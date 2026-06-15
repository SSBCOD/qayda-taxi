/// Contract for authentication (phone OTP) and the current user/session.
/// Implemented by a Firebase source and a mock source (see ARCHITECTURE.md).
abstract interface class AuthRepository {
  // Future<void> sendOtp(String phone);
  // Future<bool> verifyOtp(String code);
  // Stream<bool> authState();
  // Future<void> signOut();
}
