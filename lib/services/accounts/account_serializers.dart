import 'package:flutter/material.dart';

import '../../data/models/enums.dart';
import '../../data/models/payment_method.dart';
import '../../features/driver/kyc/application/kyc_controller.dart';
import '../../features/passenger/history/application/history_providers.dart';
import '../../features/passenger/profile/application/favorites_controller.dart';
import '../../features/settings/application/notification_prefs_controller.dart';

/// JSON ↔ domain conversions shared by [AccountSession].
class AccountSerializers {
  AccountSerializers._();

  static KycState kycFromJson(Map<String, dynamic> json) {
    return KycState(
      brandModel: json['brandModel'] as String? ?? 'Toyota Camry',
      year: (json['year'] as num?)?.toInt() ?? 2022,
      plate: json['plate'] as String? ?? '011 ABC 02',
      colorRu: json['colorRu'] as String? ?? 'Чёрный',
      colorKk: json['colorKk'] as String? ?? 'Қара',
      colorSwatch: Color((json['colorValue'] as num?)?.toInt() ?? 0xFF000000),
      tier: _tier(json['tier'] as String?),
      iin: json['iin'] as String? ?? '',
      idFrontUploaded: json['idFrontUploaded'] as bool? ?? false,
      idBackUploaded: json['idBackUploaded'] as bool? ?? false,
      licenseUploaded: json['licenseUploaded'] as bool? ?? false,
      status: _verification(json['status'] as String?),
    );
  }

  static Map<String, dynamic> kycToJson(KycState state) => {
        'brandModel': state.brandModel,
        'year': state.year,
        'plate': state.plate,
        'colorRu': state.colorRu,
        'colorKk': state.colorKk,
        'colorValue': state.colorSwatch.toARGB32(),
        'tier': state.tier.name,
        'iin': state.iin,
        'idFrontUploaded': state.idFrontUploaded,
        'idBackUploaded': state.idBackUploaded,
        'licenseUploaded': state.licenseUploaded,
        'status': state.status.name,
      };

  static List<PaymentMethod> paymentMethodsFromJson(
    List<Map<String, dynamic>> list,
  ) {
    return list.map((json) {
      return PaymentMethod(
        id: json['id'] as String,
        kind: _paymentKind(json['kind'] as String),
        labelRu: json['labelRu'] as String,
        labelKk: json['labelKk'] as String,
        lastFour: json['lastFour'] as String?,
        brandColor: Color((json['brandColor'] as num).toInt()),
        brandShort: json['brandShort'] as String,
      );
    }).toList();
  }

  static List<Map<String, dynamic>> paymentMethodsToJson(
    List<PaymentMethod> methods,
  ) {
    return methods
        .map(
          (m) => {
            'id': m.id,
            'kind': m.kind.name,
            'labelRu': m.labelRu,
            'labelKk': m.labelKk,
            if (m.lastFour != null) 'lastFour': m.lastFour,
            'brandColor': m.brandColor.toARGB32(),
            'brandShort': m.brandShort,
          },
        )
        .toList();
  }

  static NotificationPrefs notificationPrefsFromJson(Map<String, bool> json) {
    const d = NotificationPrefs();
    return NotificationPrefs(
      push: json['push'] ?? d.push,
      sms: json['sms'] ?? d.sms,
      email: json['email'] ?? d.email,
      rides: json['rides'] ?? d.rides,
      news: json['news'] ?? d.news,
      ratings: json['ratings'] ?? d.ratings,
    );
  }

  static Map<String, bool> notificationPrefsToJson(NotificationPrefs prefs) => {
        'push': prefs.push,
        'sms': prefs.sms,
        'email': prefs.email,
        'rides': prefs.rides,
        'news': prefs.news,
        'ratings': prefs.ratings,
      };

  static List<FavoritePlace> favoritesFromJson(
      List<Map<String, dynamic>> list) {
    return list
        .map(
          (json) => FavoritePlace(
            iconName: json['icon'] as String? ?? 'place',
            titleRu: json['titleRu'] as String,
            titleKk: json['titleKk'] as String,
            address: json['address'] as String,
          ),
        )
        .toList();
  }

  static List<Map<String, dynamic>> favoritesToJson(List<FavoritePlace> list) {
    return list
        .map(
          (f) => {
            'icon': f.iconName,
            'titleRu': f.titleRu,
            'titleKk': f.titleKk,
            'address': f.address,
          },
        )
        .toList();
  }

  static List<TripRecord> tripHistoryFromJson(List<Map<String, dynamic>> list) {
    return list
        .map(
          (json) => TripRecord(
            dateRu: json['dateRu'] as String,
            dateKk: json['dateKk'] as String,
            priceTenge: json['priceTenge'] as num,
            origin: json['origin'] as String,
            destination: json['destination'] as String,
            vehicle: json['vehicle'] as String,
            tier: _tier(json['tier'] as String?),
          ),
        )
        .toList();
  }

  static List<Map<String, dynamic>> tripHistoryToJson(List<TripRecord> list) {
    return list
        .map(
          (t) => {
            'dateRu': t.dateRu,
            'dateKk': t.dateKk,
            'priceTenge': t.priceTenge,
            'origin': t.origin,
            'destination': t.destination,
            'vehicle': t.vehicle,
            'tier': t.tier.name,
          },
        )
        .toList();
  }

  static RideTier _tier(String? raw) {
    return RideTier.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => RideTier.comfort,
    );
  }

  static VerificationStatus _verification(String? raw) {
    return VerificationStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => VerificationStatus.unverified,
    );
  }

  static PaymentMethodKind _paymentKind(String raw) {
    return PaymentMethodKind.values.firstWhere(
      (k) => k.name == raw,
      orElse: () => PaymentMethodKind.card,
    );
  }
}
