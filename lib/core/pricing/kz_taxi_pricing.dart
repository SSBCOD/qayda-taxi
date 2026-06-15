import '../../data/models/enums.dart';
import '../../data/models/tariff.dart';

/// Almaty taxi fare rates (₸) — calibrated to local market levels
/// (Yandex Go / inDriver ballpark, 2024–2025).
///
/// Formula: `max(minimum, base + km×perKm + min×perMin)`, rounded to 10 ₸.
class KzTaxiPricing {
  KzTaxiPricing._();

  static const _rates = <RideTier, _TierRates>{
    RideTier.economy: _TierRates(
      baseTenge: 450,
      perKmTenge: 95,
      perMinTenge: 15,
      minimumTenge: 600,
      etaPickupMin: 4,
    ),
    RideTier.comfort: _TierRates(
      baseTenge: 650,
      perKmTenge: 125,
      perMinTenge: 20,
      minimumTenge: 900,
      etaPickupMin: 4,
    ),
    RideTier.business: _TierRates(
      baseTenge: 1100,
      perKmTenge: 210,
      perMinTenge: 35,
      minimumTenge: 1800,
      etaPickupMin: 6,
    ),
  };

  /// Raw fare before rounding.
  static num rawFare(
    RideTier tier, {
    required double distanceKm,
    required int durationMin,
  }) {
    final r = _rates[tier]!;
    final total =
        r.baseTenge + distanceKm * r.perKmTenge + durationMin * r.perMinTenge;
    return total < r.minimumTenge ? r.minimumTenge : total;
  }

  /// Fare rounded to the nearest 10 ₸ (common in KZ ride-hailing apps).
  static int fareTenge(
    RideTier tier, {
    required double distanceKm,
    required int durationMin,
  }) {
    final raw = rawFare(tier, distanceKm: distanceKm, durationMin: durationMin);
    return ((raw / 10).round() * 10).toInt();
  }

  /// Platform bonus for drivers (~15–20 % of base fare on comfort trips).
  static int driverBonusTenge(num fareTenge, RideTier tier) => switch (tier) {
        RideTier.economy => (fareTenge * 0.12).round(),
        RideTier.comfort => (fareTenge * 0.18).round(),
        RideTier.business => (fareTenge * 0.15).round(),
      };

  /// Build [Tariff] list for a given trip distance/duration.
  static List<Tariff> tariffsForTrip({
    required double distanceKm,
    required int durationMin,
  }) {
    return RideTier.values.map((tier) {
      final r = _rates[tier]!;
      return Tariff(
        tier: tier,
        titleRu: tier.titleRu,
        titleKk: tier.titleKk,
        priceTenge:
            fareTenge(tier, distanceKm: distanceKm, durationMin: durationMin),
        etaPickupMin: r.etaPickupMin,
      );
    }).toList();
  }
}

class _TierRates {
  final num baseTenge;
  final num perKmTenge;
  final num perMinTenge;
  final num minimumTenge;
  final int etaPickupMin;

  const _TierRates({
    required this.baseTenge,
    required this.perKmTenge,
    required this.perMinTenge,
    required this.minimumTenge,
    required this.etaPickupMin,
  });
}
