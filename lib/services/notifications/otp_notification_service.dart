import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows a local notification that mimics an SMS OTP on the Android emulator.
///
/// Real SMS is not available in the MVP (`useMock = true`); this gives a
/// convincing demo when the user submits their phone number.
class OtpNotificationService {
  OtpNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _ready = false;

  static const _channelId = 'qayda_otp';
  static const _channelName = 'Коды подтверждения';
  static const _channelDesc =
      'Уведомления с кодом подтверждения для входа в Qayda';

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Initialises the plugin and requests Android 13+ notification permission.
  static Future<void> init() async {
    if (_ready) return;

    if (_isAndroid) {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidInit);
      await _plugin.initialize(settings);

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();

      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ),
      );
    }

    _ready = true;
  }

  /// Posts a high-priority notification with the one-time code.
  /// On non-Android platforms prints to console (dev/desktop mode).
  static Future<void> showOtp({
    required String maskedPhone,
    required String code,
  }) async {
    if (!_ready) await init();

    if (!_isAndroid) {
      debugPrint('[OTP] Код для $maskedPhone: $code');
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Qayda OTP',
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Qayda — код подтверждения',
      'Код для $maskedPhone: $code',
      details,
    );
  }
}
