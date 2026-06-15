/// Animation / business timers used across the app.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  /// Driver has 15s to accept an incoming order.
  static const Duration incomingOrder = Duration(seconds: 15);

  /// Free waiting time at pickup (02:45).
  static const Duration freeWaiting = Duration(seconds: 165);
}
