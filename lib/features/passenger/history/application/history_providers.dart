import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pricing/kz_taxi_pricing.dart';
import '../../../../data/models/enums.dart';

/// A completed trip shown in the ride-history list.
class TripRecord {
  final String dateRu;
  final String dateKk;
  final num priceTenge;
  final String origin;
  final String destination;
  final String vehicle;
  final RideTier tier;
  const TripRecord({
    required this.dateRu,
    required this.dateKk,
    required this.priceTenge,
    required this.origin,
    required this.destination,
    required this.vehicle,
    required this.tier,
  });
}

class TripHistoryController extends Notifier<List<TripRecord>> {
  @override
  List<TripRecord> build() => _defaultTrips();

  void restore(List<TripRecord> trips) => state = List.of(trips);

  void reset() => state = const [];

  static List<TripRecord> _defaultTrips() => [
        TripRecord(
          dateRu: '14 октября, 18:30',
          dateKk: '14 қазан, 18:30',
          priceTenge: KzTaxiPricing.fareTenge(
            RideTier.comfort,
            distanceKm: 2.8,
            durationMin: 8,
          ),
          origin: 'пр. Абая, 150',
          destination: 'ТРЦ Esentai Mall',
          vehicle: 'Toyota Camry',
          tier: RideTier.comfort,
        ),
        TripRecord(
          dateRu: '12 октября, 09:15',
          dateKk: '12 қазан, 09:15',
          priceTenge: KzTaxiPricing.fareTenge(
            RideTier.business,
            distanceKm: 8.4,
            durationMin: 15,
          ),
          origin: 'Аэропорт Алматы',
          destination: 'Отель Ritz-Carlton',
          vehicle: 'Mercedes E-Class',
          tier: RideTier.business,
        ),
        TripRecord(
          dateRu: '10 октября, 21:45',
          dateKk: '10 қазан, 21:45',
          priceTenge: KzTaxiPricing.fareTenge(
            RideTier.economy,
            distanceKm: 1.8,
            durationMin: 5,
          ),
          origin: 'ул. Фурманова, 103',
          destination: 'ул. Гоголя, 22',
          vehicle: 'Hyundai Elantra',
          tier: RideTier.economy,
        ),
      ];
}

final tripHistoryControllerProvider =
    NotifierProvider<TripHistoryController, List<TripRecord>>(
  TripHistoryController.new,
);

/// Read-only alias used by the history screen.
final tripHistoryProvider = Provider<List<TripRecord>>(
  (ref) => ref.watch(tripHistoryControllerProvider),
);
