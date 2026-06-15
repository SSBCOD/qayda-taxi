import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/enums.dart';
import '../../../../data/models/tariff.dart';
import '../../../../services/accounts/account_session.dart';

/// In-memory driver KYC / onboarding state for the MVP demo.
///
/// Mirrors a future `DriverProfile`/`Vehicle` verification flow but keeps
/// everything local: the driver fills vehicle + identity details, submits for
/// review (→ [VerificationStatus.pending]) and the fake back-office "approves"
/// the application (→ [VerificationStatus.verified]). The [RedirectGuard] reads
/// [status] to gate `/d/*` behind a completed verification.
class KycState {
  // Vehicle (Stitch `driver_onboarding_vehicle_details`).
  final String brandModel;
  final int year;
  final String plate;
  final String colorRu;
  final String colorKk;
  final Color colorSwatch;
  final RideTier tier;

  // Identity (Stitch `driver_onboarding_identity_verification`).
  final String iin; // 12 digits (raw)
  final bool idFrontUploaded;
  final bool idBackUploaded;
  final bool licenseUploaded;

  final VerificationStatus status;

  const KycState({
    this.brandModel = 'Toyota Camry',
    this.year = 2022,
    this.plate = '011 ABC 02',
    this.colorRu = 'Чёрный',
    this.colorKk = 'Қара',
    this.colorSwatch = const Color(0xFF000000),
    this.tier = RideTier.comfort,
    this.iin = '',
    this.idFrontUploaded = false,
    this.idBackUploaded = false,
    this.licenseUploaded = false,
    this.status = VerificationStatus.unverified,
  });

  /// All identity documents collected → ready to submit for review.
  bool get hasValidIin => iin.replaceAll(RegExp(r'\D'), '').length == 12;

  bool get identityComplete =>
      hasValidIin && idFrontUploaded && idBackUploaded && licenseUploaded;

  /// Masked IIN for display, e.g. "000000******".
  String get maskedIin {
    if (iin.isEmpty) return '000000******';
    if (iin.length <= 6) return iin.padRight(6, '0') + '*' * 6;
    return iin.substring(0, 6) + '*' * (iin.length - 6);
  }

  String get tierLabelRu => tier.titleRu;

  String get tierLabelKk => tier.titleKk;

  KycState copyWith({
    String? brandModel,
    int? year,
    String? plate,
    String? colorRu,
    String? colorKk,
    Color? colorSwatch,
    RideTier? tier,
    String? iin,
    bool? idFrontUploaded,
    bool? idBackUploaded,
    bool? licenseUploaded,
    VerificationStatus? status,
  }) {
    return KycState(
      brandModel: brandModel ?? this.brandModel,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      colorRu: colorRu ?? this.colorRu,
      colorKk: colorKk ?? this.colorKk,
      colorSwatch: colorSwatch ?? this.colorSwatch,
      tier: tier ?? this.tier,
      iin: iin ?? this.iin,
      idFrontUploaded: idFrontUploaded ?? this.idFrontUploaded,
      idBackUploaded: idBackUploaded ?? this.idBackUploaded,
      licenseUploaded: licenseUploaded ?? this.licenseUploaded,
      status: status ?? this.status,
    );
  }
}

/// A selectable vehicle paint option (swatch + bilingual name).
class VehicleColor {
  final String ru;
  final String kk;
  final Color value;
  const VehicleColor(this.ru, this.kk, this.value);
}

const List<VehicleColor> kVehicleColors = [
  VehicleColor('Чёрный', 'Қара', Color(0xFF000000)),
  VehicleColor('Белый', 'Ақ', Color(0xFFF2F2F2)),
  VehicleColor('Серебристый', 'Күміс', Color(0xFFC0C0C0)),
  VehicleColor('Серый', 'Сұр', Color(0xFF6B7280)),
  VehicleColor('Синий', 'Көк', Color(0xFF1E3A8A)),
  VehicleColor('Красный', 'Қызыл', Color(0xFFB91C1C)),
];

class KycController extends Notifier<KycState> {
  @override
  KycState build() => const KycState();

  void setBrandModel(String value) => _mutate(
        state.copyWith(brandModel: value.trim()),
      );

  void setYear(int value) => _mutate(state.copyWith(year: value));

  void setPlate(String value) => _mutate(
        state.copyWith(plate: value.trim().toUpperCase()),
      );

  void setColor(VehicleColor color) => _mutate(
        state.copyWith(
          colorRu: color.ru,
          colorKk: color.kk,
          colorSwatch: color.value,
        ),
      );

  void setIin(String value) => _mutate(
        state.copyWith(iin: value.replaceAll(RegExp(r'\D'), '')),
      );

  void setIdFront(bool uploaded) =>
      _mutate(state.copyWith(idFrontUploaded: uploaded));

  void setIdBack(bool uploaded) =>
      _mutate(state.copyWith(idBackUploaded: uploaded));

  void setLicense(bool uploaded) =>
      _mutate(state.copyWith(licenseUploaded: uploaded));

  void _mutate(KycState next) {
    state = next;
    AccountSession.save(ref, kycState: next);
  }

  /// Submit the application — moves to [VerificationStatus.pending].
  void submitForReview() {
    final next = state.copyWith(status: VerificationStatus.pending);
    state = next;
    AccountSession.save(ref, kycState: next);
  }

  /// Fake back-office approval — moves to [VerificationStatus.verified].
  void approve() {
    final next = state.copyWith(status: VerificationStatus.verified);
    state = next;
    AccountSession.save(ref, kycState: next);
  }

  void restore(KycState value) => state = value;

  void reset() => state = const KycState();
}

final kycControllerProvider =
    NotifierProvider<KycController, KycState>(KycController.new);
