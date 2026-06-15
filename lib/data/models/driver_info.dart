/// Lightweight driver/vehicle summary shown to the passenger during a ride
/// (wait · active · completed screens). The full DriverProfile/Vehicle schema
/// lives in `docs/models.md`; this is the display projection the passenger app
/// receives on the Ride document.
class DriverInfo {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final String carModel; // "Toyota Camry"
  final String carColorRu; // "Чёрный"
  final String carColorKk; // "Қара"
  final String plate; // "011 ABC 02"
  final String? photoUrl;

  const DriverInfo({
    required this.id,
    required this.name,
    this.phone = '',
    required this.rating,
    required this.carModel,
    required this.carColorRu,
    required this.carColorKk,
    required this.plate,
    this.photoUrl,
  });

  /// e.g. "Toyota Camry • Чёрный"
  String get vehicleLineRu => '$carModel • $carColorRu';
  String get vehicleLineKk => '$carModel • $carColorKk';
}
