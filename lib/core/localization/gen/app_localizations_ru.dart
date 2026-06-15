// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Qayda';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonStart => 'Начать';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonAccept => 'Принять';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get navTaxi => 'Такси';

  @override
  String get navHistory => 'История';

  @override
  String get navProfile => 'Профиль';

  @override
  String get tariffEconomy => 'Эконом';

  @override
  String get tariffComfort => 'Комфорт';

  @override
  String get tariffBusiness => 'Бизнес';

  @override
  String get homeSearchHint => 'Қайда барамыз? / Куда поедем?';

  @override
  String homeEtaPickup(int minutes) {
    return 'Подача: $minutes мин';
  }

  @override
  String get homeChipHome => 'Дом';

  @override
  String get homeChipWork => 'Работа';

  @override
  String get homePromoTitle => 'Быстрая подача';

  @override
  String get homePromoSubtitle => 'Машины рядом с вами';

  @override
  String get menuPayments => 'Платежи';

  @override
  String get menuSupport => 'Поддержка';

  @override
  String get menuSettings => 'Настройки';
}
