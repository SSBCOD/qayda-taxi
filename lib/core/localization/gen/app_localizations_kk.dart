// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'Qayda';

  @override
  String get commonNext => 'Келесі';

  @override
  String get commonStart => 'Бастау';

  @override
  String get commonCancel => 'Болдырмау';

  @override
  String get commonAccept => 'Қабылдау';

  @override
  String get commonContinue => 'Жалғастыру';

  @override
  String get navTaxi => 'Такси';

  @override
  String get navHistory => 'Тарих';

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
    return 'Жеткізу: $minutes мин';
  }

  @override
  String get homeChipHome => 'Үй';

  @override
  String get homeChipWork => 'Жұмыс';

  @override
  String get homePromoTitle => 'Жылдам жеткізу';

  @override
  String get homePromoSubtitle => 'Жақын маңдағы көліктер';

  @override
  String get menuPayments => 'Төлемдер';

  @override
  String get menuSupport => 'Қолдау';

  @override
  String get menuSettings => 'Баптаулар';
}
