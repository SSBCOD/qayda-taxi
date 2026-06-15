import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/storage/prefs_service.dart';

/// Holds the active UI locale (RU/KK) and persists the choice.
///
/// The bilingual product always shows both languages on screen; this controls
/// which one is the "primary" line and Material localizations.
class LocaleController extends Notifier<Locale> {
  static const _key = 'app_locale';
  static const ru = Locale('ru');
  static const kk = Locale('kk');

  @override
  Locale build() {
    final saved = ref.read(prefsServiceProvider).getString(_key);
    return saved == 'kk' ? kk : ru;
  }

  void setLocale(Locale locale) {
    state = locale;
    ref.read(prefsServiceProvider).setString(_key, locale.languageCode);
  }

  void toggle() => setLocale(state.languageCode == 'ru' ? kk : ru);
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
