import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs_service.dart';
import 'user_account_data.dart';

/// Local persistence for per-phone account snapshots (SharedPreferences JSON).
class AccountRepository {
  final PrefsService _prefs;

  AccountRepository(this._prefs);

  static const _registryKey = 'qayda_account_registry';

  UserAccountData loadOrCreate(String phoneE164) {
    final key = UserAccountData.accountKey(phoneE164);
    final raw = _prefs.getString(key);
    if (raw == null) {
      final created = UserAccountData.defaults(phoneE164);
      save(created);
      return created;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserAccountData.fromJson(map);
    } catch (_) {
      final created = UserAccountData.defaults(phoneE164);
      save(created);
      return created;
    }
  }

  void save(UserAccountData data) {
    final key = UserAccountData.accountKey(data.phone);
    _prefs.setString(key, jsonEncode(data.toJson()));
    _registerPhone(data.phone);
  }

  List<String> knownPhones() {
    final raw = _prefs.getString(_registryKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  void _registerPhone(String phoneE164) {
    final phones = knownPhones().toSet()..add(phoneE164);
    _prefs.setString(_registryKey, jsonEncode(phones.toList()..sort()));
  }
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.read(prefsServiceProvider));
});
