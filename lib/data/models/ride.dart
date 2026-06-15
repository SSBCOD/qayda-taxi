import 'address.dart';
import 'driver_info.dart';
import 'enums.dart';

/// The central ride entity (see `docs/models.md`). Both passenger and driver
/// apps render from this object; in production it is a Firestore document
/// streamed in realtime so a status change updates both UIs instantly.
class Ride {
  final String id;
  final String passengerId;
  final RideStatus status;
  final RideTier tier;

  final Address origin;
  final Address destination;
  final double distanceKm;
  final int durationMin;

  final num priceTenge;
  final String paymentLabel; // "Kaspi Gold •• 7777"
  final PaymentType paymentType;
  final String paymentStatus; // 'pending' | 'paid' | 'failed'
  final String? receiptId; // fake payment receipt, set on success

  final DriverInfo? driver;
  final int driverEtaMin; // minutes until driver reaches pickup

  final int? ratingStars;
  final num? tipTenge;

  const Ride({
    required this.id,
    required this.passengerId,
    required this.status,
    required this.tier,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationMin,
    required this.priceTenge,
    this.paymentLabel = 'Kaspi Gold •• 7777',
    this.paymentType = PaymentType.kaspi,
    this.paymentStatus = 'pending',
    this.receiptId,
    this.driver,
    this.driverEtaMin = 4,
    this.ratingStars,
    this.tipTenge,
  });

  Ride copyWith({
    RideStatus? status,
    RideTier? tier,
    num? priceTenge,
    String? paymentLabel,
    PaymentType? paymentType,
    String? paymentStatus,
    String? receiptId,
    DriverInfo? driver,
    bool clearDriver = false,
    int? driverEtaMin,
    int? ratingStars,
    num? tipTenge,
  }) {
    return Ride(
      id: id,
      passengerId: passengerId,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      origin: origin,
      destination: destination,
      distanceKm: distanceKm,
      durationMin: durationMin,
      priceTenge: priceTenge ?? this.priceTenge,
      paymentLabel: paymentLabel ?? this.paymentLabel,
      paymentType: paymentType ?? this.paymentType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      receiptId: receiptId ?? this.receiptId,
      driver: clearDriver ? null : (driver ?? this.driver),
      driverEtaMin: driverEtaMin ?? this.driverEtaMin,
      ratingStars: ratingStars ?? this.ratingStars,
      tipTenge: tipTenge ?? this.tipTenge,
    );
  }
}
