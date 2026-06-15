import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pricing/kz_taxi_pricing.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/tariff.dart';
import '../../dashboard/application/driver_controller.dart';

/// One completed trip on the driver's daily history screen.
class DriverDailyTrip {
  final String id;
  final String passengerRu;
  final String passengerKk;
  final RideTier tier;
  final String time;
  final num incomeTenge;
  final double distanceKm;

  const DriverDailyTrip({
    required this.id,
    required this.passengerRu,
    required this.passengerKk,
    required this.tier,
    required this.time,
    required this.incomeTenge,
    required this.distanceKm,
  });

  String get tierRu => tier.titleRu;
  String get tierKk => tier.titleKk;
}

class DriverDailyHistoryState {
  final num earningsTenge;
  final int tripCount;
  final String onlineTimeRu;
  final String onlineTimeKk;
  final List<double> hourlyBars;
  final List<String> hourLabels;
  final List<DriverDailyTrip> trips;

  const DriverDailyHistoryState({
    required this.earningsTenge,
    required this.tripCount,
    required this.onlineTimeRu,
    required this.onlineTimeKk,
    required this.hourlyBars,
    required this.hourLabels,
    required this.trips,
  });
}

int _driverIncome(RideTier tier, double km, int min) {
  final fare = KzTaxiPricing.fareTenge(tier, distanceKm: km, durationMin: min);
  return fare + KzTaxiPricing.driverBonusTenge(fare, tier);
}

const _tripSeed = [
  (
    id: 't1',
    passenger: 'Александр',
    tier: RideTier.comfort,
    km: 4.2,
    min: 12,
    time: '14:20',
  ),
  (
    id: 't2',
    passenger: 'Айгерим',
    tier: RideTier.business,
    km: 8.7,
    min: 18,
    time: '13:45',
  ),
  (
    id: 't3',
    passenger: 'Даурен',
    tier: RideTier.comfort,
    km: 5.1,
    min: 14,
    time: '12:10',
  ),
  (
    id: 't4',
    passenger: 'Михаил',
    tier: RideTier.comfort,
    km: 3.9,
    min: 10,
    time: '11:05',
  ),
  (
    id: 't5',
    passenger: 'Сауле',
    tier: RideTier.comfort,
    km: 6.0,
    min: 15,
    time: '10:30',
  ),
  (
    id: 't6',
    passenger: 'Ерлан',
    tier: RideTier.economy,
    km: 2.8,
    min: 8,
    time: '09:50',
  ),
  (
    id: 't7',
    passenger: 'Гульнара',
    tier: RideTier.business,
    km: 7.2,
    min: 16,
    time: '09:10',
  ),
  (
    id: 't8',
    passenger: 'Нурлан',
    tier: RideTier.comfort,
    km: 4.5,
    min: 11,
    time: '08:40',
  ),
];

List<DriverDailyTrip> _buildTrips() {
  return _tripSeed
      .map(
        (t) => DriverDailyTrip(
          id: t.id,
          passengerRu: t.passenger,
          passengerKk: t.passenger,
          tier: t.tier,
          time: t.time,
          incomeTenge: _driverIncome(t.tier, t.km, t.min),
          distanceKm: t.km,
        ),
      )
      .toList();
}

/// Today's driver trip history — synced with [driverControllerProvider] totals.
final driverDailyHistoryProvider = Provider<DriverDailyHistoryState>((ref) {
  final driver = ref.watch(driverControllerProvider);

  return DriverDailyHistoryState(
    earningsTenge: driver.earningsToday,
    tripCount: driver.tripsToday,
    onlineTimeRu: '6ч 30м',
    onlineTimeKk: '6 сағ 30 мин',
    hourlyBars: const [0.2, 0.35, 0.8, 0.45, 0.6, 0.25, 0.9, 0.15],
    hourLabels: const ['08:00', '12:00', '16:00', '20:00'],
    trips: _buildTrips().take(driver.tripsToday).toList(),
  );
});
