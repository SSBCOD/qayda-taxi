import '../../core/phone/kz_phone.dart';
import '../../data/models/enums.dart';

/// Persisted snapshot for a single Qayda account (keyed by phone).
class UserAccountData {
  final String phone;
  final UserRole? role;
  final Map<String, dynamic> kyc;
  final List<Map<String, dynamic>> paymentMethods;
  final String selectedPaymentId;
  final Map<String, bool> notificationPrefs;
  final String themeMode;
  final List<Map<String, dynamic>> favorites;
  final List<Map<String, dynamic>> tripHistory;
  final num driverEarningsToday;
  final int driverTripsToday;
  final double driverRating;
  final num walletBalance;
  final String activeVehicleId;

  const UserAccountData({
    required this.phone,
    this.role,
    required this.kyc,
    required this.paymentMethods,
    required this.selectedPaymentId,
    required this.notificationPrefs,
    required this.themeMode,
    required this.favorites,
    required this.tripHistory,
    this.driverEarningsToday = 12400,
    this.driverTripsToday = 8,
    this.driverRating = 4.98,
    this.walletBalance = 45200,
    this.activeVehicleId = 'kyc_primary',
  });

  static String accountKey(String phoneE164) {
    final digits = phoneE164.replaceAll(RegExp(r'\D'), '');
    return 'qayda_account_$digits';
  }

  factory UserAccountData.defaults(String phoneE164) {
    return UserAccountData(
      phone: phoneE164,
      kyc: _defaultKycJson(),
      paymentMethods: _defaultPaymentMethodsJson(),
      selectedPaymentId: 'kaspi_1234',
      notificationPrefs: _defaultNotificationPrefs(),
      themeMode: 'system',
      favorites: _defaultFavoritesJson(),
      tripHistory: _defaultTripHistoryJson(),
    );
  }

  UserAccountData copyWith({
    UserRole? role,
    bool clearRole = false,
    Map<String, dynamic>? kyc,
    List<Map<String, dynamic>>? paymentMethods,
    String? selectedPaymentId,
    Map<String, bool>? notificationPrefs,
    String? themeMode,
    List<Map<String, dynamic>>? favorites,
    List<Map<String, dynamic>>? tripHistory,
    num? driverEarningsToday,
    int? driverTripsToday,
    double? driverRating,
    num? walletBalance,
    String? activeVehicleId,
  }) {
    return UserAccountData(
      phone: phone,
      role: clearRole ? null : (role ?? this.role),
      kyc: kyc ?? this.kyc,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentId: selectedPaymentId ?? this.selectedPaymentId,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
      themeMode: themeMode ?? this.themeMode,
      favorites: favorites ?? this.favorites,
      tripHistory: tripHistory ?? this.tripHistory,
      driverEarningsToday: driverEarningsToday ?? this.driverEarningsToday,
      driverTripsToday: driverTripsToday ?? this.driverTripsToday,
      driverRating: driverRating ?? this.driverRating,
      walletBalance: walletBalance ?? this.walletBalance,
      activeVehicleId: activeVehicleId ?? this.activeVehicleId,
    );
  }

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'role': role?.name,
        'kyc': kyc,
        'paymentMethods': paymentMethods,
        'selectedPaymentId': selectedPaymentId,
        'notificationPrefs': notificationPrefs,
        'themeMode': themeMode,
        'favorites': favorites,
        'tripHistory': tripHistory,
        'driverEarningsToday': driverEarningsToday,
        'driverTripsToday': driverTripsToday,
        'driverRating': driverRating,
        'walletBalance': walletBalance,
        'activeVehicleId': activeVehicleId,
      };

  factory UserAccountData.fromJson(Map<String, dynamic> json) {
    final phone = json['phone'] as String? ?? '';
    return UserAccountData(
      phone: phone.startsWith('+') ? phone : KzPhone.toE164(phone),
      role: _parseRole(json['role'] as String?),
      kyc: Map<String, dynamic>.from(
        json['kyc'] as Map? ?? _defaultKycJson(),
      ),
      paymentMethods: (json['paymentMethods'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          _defaultPaymentMethodsJson(),
      selectedPaymentId: json['selectedPaymentId'] as String? ?? 'kaspi_1234',
      notificationPrefs: (json['notificationPrefs'] as Map?)?.map(
            (k, v) => MapEntry(k as String, v as bool),
          ) ??
          _defaultNotificationPrefs(),
      themeMode: json['themeMode'] as String? ?? 'system',
      favorites: (json['favorites'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          _defaultFavoritesJson(),
      tripHistory: (json['tripHistory'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          _defaultTripHistoryJson(),
      driverEarningsToday: (json['driverEarningsToday'] as num?) ?? 12400,
      driverTripsToday: (json['driverTripsToday'] as num?)?.toInt() ?? 8,
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 4.98,
      walletBalance: (json['walletBalance'] as num?) ?? 45200,
      activeVehicleId: json['activeVehicleId'] as String? ?? 'kyc_primary',
    );
  }

  static UserRole? _parseRole(String? raw) {
    if (raw == null) return null;
    for (final role in UserRole.values) {
      if (role.name == raw) return role;
    }
    return null;
  }

  static Map<String, dynamic> _defaultKycJson() => {
        'brandModel': 'Toyota Camry',
        'year': 2022,
        'plate': '011 ABC 02',
        'colorRu': 'Чёрный',
        'colorKk': 'Қара',
        'colorValue': 0xFF000000,
        'tier': RideTier.comfort.name,
        'iin': '',
        'idFrontUploaded': false,
        'idBackUploaded': false,
        'licenseUploaded': false,
        'status': VerificationStatus.unverified.name,
      };

  static Map<String, bool> _defaultNotificationPrefs() => {
        'push': true,
        'sms': false,
        'email': false,
        'rides': true,
        'news': true,
        'ratings': true,
      };

  static List<Map<String, dynamic>> _defaultFavoritesJson() => [
        {
          'icon': 'home',
          'titleRu': 'Дом',
          'titleKk': 'Үй',
          'address': 'пр-т Абая, 150',
        },
        {
          'icon': 'work',
          'titleRu': 'Работа',
          'titleKk': 'Жұмыс',
          'address': 'БЦ «Нурлы Тау», блок 5А',
        },
        {
          'icon': 'fitness_center',
          'titleRu': 'Спортзал',
          'titleKk': 'Спортзал',
          'address': 'ул. Розыбакиева, 247',
        },
      ];

  static List<Map<String, dynamic>> _defaultPaymentMethodsJson() => [
        {
          'id': 'cash',
          'kind': 'cash',
          'labelRu': 'Наличные',
          'labelKk': 'Қолма-қол ақша',
          'brandColor': 0xFF5D5F5F,
          'brandShort': '₸',
        },
        {
          'id': 'kaspi_1234',
          'kind': 'kaspiGold',
          'labelRu': 'Kaspi Gold',
          'labelKk': 'Kaspi Gold',
          'lastFour': '1234',
          'brandColor': 0xFFF14635,
          'brandShort': 'Kaspi',
        },
        {
          'id': 'freedom_5678',
          'kind': 'freedom',
          'labelRu': 'Freedom',
          'labelKk': 'Freedom',
          'lastFour': '5678',
          'brandColor': 0xFF00A15D,
          'brandShort': 'Freedom',
        },
        {
          'id': 'halyk_9012',
          'kind': 'halyk',
          'labelRu': 'Halyk',
          'labelKk': 'Halyk',
          'lastFour': '9012',
          'brandColor': 0xFF007054,
          'brandShort': 'Halyk',
        },
      ];

  static List<Map<String, dynamic>> _defaultTripHistoryJson() => [
        {
          'dateRu': '14 октября, 18:30',
          'dateKk': '14 қазан, 18:30',
          'priceTenge': 1680,
          'origin': 'пр. Абая, 150',
          'destination': 'ТРЦ Esentai Mall',
          'vehicle': 'Toyota Camry',
          'tier': RideTier.comfort.name,
        },
        {
          'dateRu': '12 октября, 09:15',
          'dateKk': '12 қазан, 09:15',
          'priceTenge': 3240,
          'origin': 'Аэропорт Алматы',
          'destination': 'Отель Ritz-Carlton',
          'vehicle': 'Mercedes E-Class',
          'tier': RideTier.business.name,
        },
        {
          'dateRu': '10 октября, 21:45',
          'dateKk': '10 қазан, 21:45',
          'priceTenge': 890,
          'origin': 'ул. Фурманова, 103',
          'destination': 'ул. Гоголя, 22',
          'vehicle': 'Hyundai Elantra',
          'tier': RideTier.economy.name,
        },
      ];
}
