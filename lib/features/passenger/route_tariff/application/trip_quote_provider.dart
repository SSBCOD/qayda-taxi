import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/maps/route_service.dart';
import '../../../../data/models/address.dart';
import '../../address_search/application/address_providers.dart';
import '../tariff_providers.dart';

/// Distance/duration quote for the current origin → destination pair.
class TripQuote {
  final double distanceKm;
  final int durationMin;

  const TripQuote({
    required this.distanceKm,
    required this.durationMin,
  });

  static const fallback = TripQuote(
    distanceKm: kMockDistanceKm,
    durationMin: kMockDurationMin,
  );

  String get badgeText => '$durationMin мин ($distanceKm км)';
}

Address _origin(Ref ref) => ref.watch(selectedOriginProvider) ?? kMockOrigin;

/// Fetches OSRM distance/duration whenever origin or destination changes.
final tripQuoteProvider = FutureProvider<TripQuote>((ref) async {
  final origin = _origin(ref);
  final destination =
      ref.watch(selectedDestinationProvider) ?? kMockDestination;
  final originLatLng = LatLng(origin.lat, origin.lng);
  final destLatLng = LatLng(destination.lat, destination.lng);

  final route = await RouteService.fetchRouteResult(
    origin: originLatLng,
    destination: destLatLng,
  );

  return TripQuote(
    distanceKm: double.parse(route.distanceKm.toStringAsFixed(1)),
    durationMin: route.durationMin,
  );
});
