import 'package:latlong2/latlong.dart';

import 'enums.dart';
import 'tariff.dart';

/// A single order as seen by the **driver** app (incoming offer → trip →
/// earnings). For the MVP this is generated locally by `DriverController`; in
/// production it would be the same Firestore ride document the passenger sees,
/// projected for the driver.
class DriverOrder {
  final String id;
  final DriverOrderStage stage;

  // Passenger.
  final String passengerName;
  final double passengerRating;

  // Commercials.
  final RideTier tier;
  final num fareTenge; // base fare
  final num bonusTenge; // platform bonus
  final PaymentType paymentType;

  // Pickup leg (driver → passenger).
  final String pickupTitle; // "пр. Аль-Фараби, 77/7"
  final LatLng driverStart;
  final LatLng pickup;
  final double pickupDistanceKm;
  final int pickupEtaMin;

  // Trip leg (pickup → destination).
  final String destTitleRu; // "ТРЦ Mega Center"
  final String destSubtitleRu; // "ул. Розыбакиева, 247"
  final LatLng destination;
  final double tripDistanceKm;
  final int tripDurationMin;

  const DriverOrder({
    required this.id,
    this.stage = DriverOrderStage.incoming,
    required this.passengerName,
    required this.passengerRating,
    required this.tier,
    required this.fareTenge,
    this.bonusTenge = 0,
    this.paymentType = PaymentType.card,
    required this.pickupTitle,
    required this.driverStart,
    required this.pickup,
    required this.pickupDistanceKm,
    required this.pickupEtaMin,
    required this.destTitleRu,
    required this.destSubtitleRu,
    required this.destination,
    required this.tripDistanceKm,
    required this.tripDurationMin,
  });

  /// Driver income = base fare + bonus.
  num get incomeTenge => fareTenge + bonusTenge;

  String get tierLabelRu => tier.titleRu;

  String get tierLabelKk => tier.titleKk;

  String get paymentLabelRu => switch (paymentType) {
        PaymentType.cash => 'Наличные',
        PaymentType.kaspi => 'Kaspi Gold',
        _ => 'Безналичный',
      };

  String get paymentLabelKk => switch (paymentType) {
        PaymentType.cash => 'Қолма-қол',
        PaymentType.kaspi => 'Kaspi Gold',
        _ => 'Қолма-қолсыз',
      };

  DriverOrder copyWith({DriverOrderStage? stage}) {
    return DriverOrder(
      id: id,
      stage: stage ?? this.stage,
      passengerName: passengerName,
      passengerRating: passengerRating,
      tier: tier,
      fareTenge: fareTenge,
      bonusTenge: bonusTenge,
      paymentType: paymentType,
      pickupTitle: pickupTitle,
      driverStart: driverStart,
      pickup: pickup,
      pickupDistanceKm: pickupDistanceKm,
      pickupEtaMin: pickupEtaMin,
      destTitleRu: destTitleRu,
      destSubtitleRu: destSubtitleRu,
      destination: destination,
      tripDistanceKm: tripDistanceKm,
      tripDurationMin: tripDurationMin,
    );
  }
}
