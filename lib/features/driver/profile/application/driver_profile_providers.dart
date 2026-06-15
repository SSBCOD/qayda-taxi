import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/enums.dart';
import '../../dashboard/application/driver_controller.dart';
import '../../kyc/application/kyc_controller.dart';
import '../../vehicles/application/driver_vehicles_providers.dart';

/// Driver profile header + career stats for the profile screen.
class DriverProfileView {
  final String nameRu;
  final String nameKk;
  final String tierBadgeRu;
  final String tierBadgeKk;
  final double rating;
  final int totalTrips;
  final String experienceRu;
  final String experienceKk;
  final String vehicleLine;
  final bool documentsVerified;

  const DriverProfileView({
    required this.nameRu,
    required this.nameKk,
    required this.tierBadgeRu,
    required this.tierBadgeKk,
    required this.rating,
    required this.totalTrips,
    required this.experienceRu,
    required this.experienceKk,
    required this.vehicleLine,
    required this.documentsVerified,
  });
}

/// Aggregates auth/KYC/vehicle/driver stats for `/d/profile`.
final driverProfileProvider = Provider<DriverProfileView>((ref) {
  final driver = ref.watch(driverControllerProvider);
  final kyc = ref.watch(kycControllerProvider);
  final vehicle = ref.watch(activeDriverVehicleProvider);

  final tierBadge = switch (vehicle.tier) {
    RideTier.business => ('Premium', 'Premium'),
    RideTier.comfort => ('Комфорт', 'Комфорт'),
    RideTier.economy => ('Эконом', 'Эконом'),
  };

  return DriverProfileView(
    nameRu: 'Арман Ибрагимов',
    nameKk: 'Арман Ибрагимов',
    tierBadgeRu: tierBadge.$1,
    tierBadgeKk: tierBadge.$2,
    rating: driver.rating,
    totalTrips: 1240,
    experienceRu: '2 года',
    experienceKk: '2 жыл',
    vehicleLine: '${vehicle.brandModel}, ${vehicle.plate}',
    documentsVerified: kyc.status == VerificationStatus.verified,
  );
});
