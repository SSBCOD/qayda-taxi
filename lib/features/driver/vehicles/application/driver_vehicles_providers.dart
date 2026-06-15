import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/enums.dart';
import '../../../../services/accounts/account_session.dart';
import '../../kyc/application/kyc_controller.dart';

/// A driver-owned vehicle shown on the fleet screen.
class DriverVehicle {
  final String id;
  final String brandModel;
  final int year;
  final String plate;
  final RideTier tier;
  final String tierSubtitleRu;
  final String tierSubtitleKk;
  final List<String> tariffTagsRu;
  final List<String> tariffTagsKk;

  const DriverVehicle({
    required this.id,
    required this.brandModel,
    required this.year,
    required this.plate,
    required this.tier,
    required this.tierSubtitleRu,
    required this.tierSubtitleKk,
    required this.tariffTagsRu,
    required this.tariffTagsKk,
  });
}

List<String> _tariffTagsRu(RideTier tier) => switch (tier) {
      RideTier.economy => ['Эконом'],
      RideTier.comfort => ['Комфорт', 'Комфорт+'],
      RideTier.business => ['Комфорт+', 'Business'],
    };

List<String> _tariffTagsKk(RideTier tier) => switch (tier) {
      RideTier.economy => ['Эконом'],
      RideTier.comfort => ['Комфорт', 'Комфорт+'],
      RideTier.business => ['Комфорт+', 'Business'],
    };

const _extraVehicles = [
  DriverVehicle(
    id: 'mercedes_s',
    brandModel: 'Mercedes-Benz S-Class',
    year: 2022,
    plate: '777 VIP 01',
    tier: RideTier.business,
    tierSubtitleRu: 'VIP / Luxury',
    tierSubtitleKk: 'VIP / Luxury',
    tariffTagsRu: ['Business', 'VIP'],
    tariffTagsKk: ['Business', 'VIP'],
  ),
  DriverVehicle(
    id: 'mercedes_e',
    brandModel: 'Mercedes-Benz E-Class',
    year: 2021,
    plate: '544 KZA 02',
    tier: RideTier.business,
    tierSubtitleRu: 'Бизнес / Business',
    tierSubtitleKk: 'Бизнес / Business',
    tariffTagsRu: ['Комфорт+', 'Business'],
    tariffTagsKk: ['Комфорт+', 'Business'],
  ),
];

class ActiveDriverVehicleController extends Notifier<String> {
  @override
  String build() => 'kyc_primary';

  void select(String id) {
    state = id;
    AccountSession.save(ref);
  }

  void restore(String id) => state = id;

  void reset() => state = 'kyc_primary';
}

/// Id of the vehicle currently active on the line (per account).
final activeDriverVehicleIdProvider =
    NotifierProvider<ActiveDriverVehicleController, String>(
  ActiveDriverVehicleController.new,
);

/// Fleet list: KYC-verified primary car + demo secondary vehicles.
final driverVehiclesProvider = Provider<List<DriverVehicle>>((ref) {
  final kyc = ref.watch(kycControllerProvider);
  final primary = DriverVehicle(
    id: 'kyc_primary',
    brandModel: kyc.brandModel,
    year: kyc.year,
    plate: kyc.plate,
    tier: kyc.tier,
    tierSubtitleRu: '${kyc.tierLabelRu} / Business',
    tierSubtitleKk: '${kyc.tierLabelKk} / Business',
    tariffTagsRu: _tariffTagsRu(kyc.tier),
    tariffTagsKk: _tariffTagsKk(kyc.tier),
  );
  return [primary, ..._extraVehicles];
});

final activeDriverVehicleProvider = Provider<DriverVehicle>((ref) {
  final id = ref.watch(activeDriverVehicleIdProvider);
  final list = ref.watch(driverVehiclesProvider);
  return list.firstWhere((v) => v.id == id, orElse: () => list.first);
});

final inactiveDriverVehiclesProvider = Provider<List<DriverVehicle>>((ref) {
  final id = ref.watch(activeDriverVehicleIdProvider);
  return ref.watch(driverVehiclesProvider).where((v) => v.id != id).toList();
});
