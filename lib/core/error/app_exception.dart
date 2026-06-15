/// Base exception type for the app's domain/data layers.
class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error', super.cause]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error', super.cause]);
}
