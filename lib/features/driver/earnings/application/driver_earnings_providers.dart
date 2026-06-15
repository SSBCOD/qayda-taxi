import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pricing/kz_taxi_pricing.dart';
import '../../../../data/models/enums.dart';
import '../../dashboard/application/driver_controller.dart';

enum EarningsPeriod { day, week, month }

extension EarningsPeriodX on EarningsPeriod {
  String get labelRu => switch (this) {
        EarningsPeriod.day => 'День',
        EarningsPeriod.week => 'Неделя',
        EarningsPeriod.month => 'Месяц',
      };

  String get labelKk => switch (this) {
        EarningsPeriod.day => 'Күн',
        EarningsPeriod.week => 'Апта',
        EarningsPeriod.month => 'Ай',
      };
}

/// A single row in the «Последние» activity list.
class EarningsActivity {
  final String tierRu;
  final String tierKk;
  final String time;
  final String location;
  final num amountTenge;
  final IconData icon;

  const EarningsActivity({
    required this.tierRu,
    required this.tierKk,
    required this.time,
    required this.location,
    required this.amountTenge,
    required this.icon,
  });
}

/// Aggregated driver earnings for a time window (mock, ₸).
class DriverEarningsStats {
  final EarningsPeriod period;
  final num totalTenge;
  final double changePercent;
  final int trips;
  final String onlineTime;
  final double rating;
  final double ratingDelta;
  final int acceptancePercent;
  final List<double> chartPoints;
  final List<String> chartLabels;
  final List<EarningsActivity> recent;

  const DriverEarningsStats({
    required this.period,
    required this.totalTenge,
    required this.changePercent,
    required this.trips,
    required this.onlineTime,
    required this.rating,
    required this.ratingDelta,
    required this.acceptancePercent,
    required this.chartPoints,
    required this.chartLabels,
    required this.recent,
  });
}

const _recentSeed = [
  EarningsActivity(
    tierRu: 'Бизнес',
    tierKk: 'Бизнес',
    time: '14:20',
    location: 'Almaty Arena',
    amountTenge: 8400,
    icon: Icons.business_center_outlined,
  ),
  EarningsActivity(
    tierRu: 'Комфорт',
    tierKk: 'Комфорт',
    time: '13:05',
    location: 'Dostyk Plaza',
    amountTenge: 4200,
    icon: Icons.king_bed_outlined,
  ),
  EarningsActivity(
    tierRu: 'Бизнес',
    tierKk: 'Бизнес',
    time: '11:45',
    location: 'Аэропорт ALA',
    amountTenge: 12800,
    icon: Icons.flight_takeoff_outlined,
  ),
];

DriverEarningsStats _statsForPeriod(EarningsPeriod period, DriverState driver) {
  final comfortFare = KzTaxiPricing.fareTenge(
    RideTier.comfort,
    distanceKm: 4.2,
    durationMin: 12,
  );

  return switch (period) {
    EarningsPeriod.day => DriverEarningsStats(
        period: period,
        totalTenge: driver.earningsToday,
        changePercent: 12.5,
        trips: driver.tripsToday,
        onlineTime: '8ч 30м',
        rating: driver.rating,
        ratingDelta: 0.02,
        acceptancePercent: 98,
        chartPoints: const [0.8, 0.75, 0.85, 0.6, 0.4, 0.2, 0.1],
        chartLabels: const ['08:00', '12:00', '16:00', '20:00', '00:00'],
        recent: [
          EarningsActivity(
            tierRu: 'Комфорт',
            tierKk: 'Комфорт',
            time: '18:40',
            location: 'ТРЦ Mega',
            amountTenge: comfortFare,
            icon: Icons.directions_car_outlined,
          ),
          ..._recentSeed.take(2),
        ],
      ),
    EarningsPeriod.week => DriverEarningsStats(
        period: period,
        totalTenge: 87600,
        changePercent: 8.3,
        trips: 24,
        onlineTime: '42ч 15м',
        rating: driver.rating,
        ratingDelta: 0.05,
        acceptancePercent: 97,
        chartPoints: const [0.3, 0.45, 0.5, 0.7, 0.85, 0.6, 0.9],
        chartLabels: const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
        recent: _recentSeed,
      ),
    EarningsPeriod.month => DriverEarningsStats(
        period: period,
        totalTenge: 342000,
        changePercent: 15.2,
        trips: 96,
        onlineTime: '168ч',
        rating: driver.rating,
        ratingDelta: 0.08,
        acceptancePercent: 96,
        chartPoints: const [0.4, 0.55, 0.65, 0.75, 0.9],
        chartLabels: const ['1', '8', '15', '22', '30'],
        recent: _recentSeed,
      ),
  };
}

final driverEarningsPeriodProvider =
    StateProvider.autoDispose<EarningsPeriod>((_) => EarningsPeriod.day);

final driverEarningsStatsProvider =
    Provider.autoDispose<DriverEarningsStats>((ref) {
  final period = ref.watch(driverEarningsPeriodProvider);
  final driver = ref.watch(driverControllerProvider);
  return _statsForPeriod(period, driver);
});
