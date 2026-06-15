import 'dart:developer' as developer;

/// Lightweight logger wrapper (avoids `print` in production code).
class Log {
  Log._();

  static void d(Object? message) => developer.log('$message', name: 'qayda');

  static void e(Object? message, [Object? error, StackTrace? stackTrace]) =>
      developer.log('$message',
          name: 'qayda', error: error, stackTrace: stackTrace);
}
