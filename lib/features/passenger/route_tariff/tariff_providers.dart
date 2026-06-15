import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pricing/kz_taxi_pricing.dart';
import '../../../data/models/address.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/tariff.dart';
import 'application/trip_quote_provider.dart';

/// Mock trip endpoints used while the address-search feature is not wired.
/// Coordinates: Almaty centre → Almaty International Airport.
const Address kMockOrigin = Address(
  label: 'custom',
  titleRu: 'пр-т Аль-Фараби, 77/7',
  titleKk: 'Әл-Фараби даңғ., 77/7',
  fullText: 'пр-т Аль-Фараби, 77/7, Алматы',
  lat: 43.2389,
  lng: 76.8897,
  type: 'history',
);

const Address kMockDestination = Address(
  label: 'custom',
  titleRu: 'Международный аэропорт Алматы',
  titleKk: 'Халықаралық Алматы әуежайы',
  fullText: 'Международный аэропорт Алматы',
  lat: 43.3521,
  lng: 77.0405,
  type: 'search',
);

const double kMockDistanceKm = 8.4;
const int kMockDurationMin = 15;

/// Tariffs for the route/tariff screen — computed from [tripQuoteProvider]
/// distance/duration via [KzTaxiPricing] (₸).
final tariffsProvider = Provider<List<Tariff>>((ref) {
  final quote = ref.watch(tripQuoteProvider).valueOrNull ?? TripQuote.fallback;
  return KzTaxiPricing.tariffsForTrip(
    distanceKm: quote.distanceKm,
    durationMin: quote.durationMin,
  );
});

/// Currently selected tariff on the route/tariff screen (defaults to Комфорт,
/// matching the highlighted card in the Stitch design).
final selectedTierProvider =
    StateProvider.autoDispose<RideTier>((ref) => RideTier.comfort);
