import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notifications/otp_notification_service.dart';
import '../services/storage/prefs_service.dart';

/// One-time async initialization before [runApp].
///
/// Returns the list of provider overrides that depend on async resources
/// (e.g. [SharedPreferences]). Keep this lean for the MVP.
Future<List<Override>> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await OtpNotificationService.init();

  return [
    prefsServiceProvider.overrideWithValue(PrefsService(prefs)),
  ];
}
