import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for simple key/value persistence
/// (locale, theme, onboarding flags).
class PrefsService {
  final SharedPreferences _prefs;
  PrefsService(this._prefs);

  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;
  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);
}

/// Overridden in [bootstrap] with a real instance.
final prefsServiceProvider = Provider<PrefsService>(
  (ref) => throw UnimplementedError('prefsServiceProvider must be overridden'),
);
