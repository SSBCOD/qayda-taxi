import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// OSRM route payload used for map polylines and fare distance/duration.
class OsrmRoute {
  final List<LatLng> points;
  final double distanceM;
  final double durationSec;

  const OsrmRoute({
    required this.points,
    required this.distanceM,
    required this.durationSec,
  });

  double get distanceKm => distanceM / 1000;

  int get durationMin => (durationSec / 60).ceil().clamp(1, 999);
}

/// Builds the A→B driving route used to draw the map polyline.
///
/// Uses the free, key-less public **OSRM** demo server. No billing, no API
/// key. Falls back to a straight line if the network call fails so the demo
/// never breaks (stability first — see docs/backend.md maps section).
class RouteService {
  RouteService._();

  static const _base = 'https://router.project-osrm.org/route/v1/driving';
  static const _timeout = Duration(seconds: 8);
  static final _cache = <String, OsrmRoute>{};

  static String _cacheKey(LatLng origin, LatLng destination) =>
      '${origin.latitude.toStringAsFixed(5)},${origin.longitude.toStringAsFixed(5)};'
      '${destination.latitude.toStringAsFixed(5)},${destination.longitude.toStringAsFixed(5)}';

  /// Returns road geometry + distance/duration. Straight-line fallback on error.
  static Future<OsrmRoute> fetchRouteResult({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final key = _cacheKey(origin, destination);
    final cached = _cache[key];
    if (cached != null) return cached;

    final url = Uri.parse(
      '$_base/${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final resp = await http.get(url).timeout(_timeout);
      if (resp.statusCode != 200) {
        return _cacheAndReturn(key, _straightLine(origin, destination));
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final routes = body['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return _cacheAndReturn(key, _straightLine(origin, destination));
      }

      final route = routes.first as Map<String, dynamic>;
      final coords = (route['geometry']['coordinates'] as List)
          .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      final result = OsrmRoute(
        points: coords.isEmpty ? [origin, destination] : coords,
        distanceM: (route['distance'] as num?)?.toDouble() ??
            const Distance().as(LengthUnit.Meter, origin, destination),
        durationSec: (route['duration'] as num?)?.toDouble() ?? 600,
      );
      return _cacheAndReturn(key, result);
    } catch (_) {
      return _cacheAndReturn(key, _straightLine(origin, destination));
    }
  }

  static OsrmRoute _cacheAndReturn(String key, OsrmRoute route) {
    _cache[key] = route;
    return route;
  }

  static OsrmRoute _straightLine(LatLng origin, LatLng destination) {
    const dist = Distance();
    final meters = dist.as(LengthUnit.Meter, origin, destination);
    return OsrmRoute(
      points: [origin, destination],
      distanceM: meters,
      durationSec: (meters / 1000 / 30 * 3600).clamp(120, 7200),
    );
  }

  /// Returns the ordered list of points forming the road route between
  /// [origin] and [destination]. Straight line on any failure.
  static Future<List<LatLng>> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final result = await fetchRouteResult(
      origin: origin,
      destination: destination,
    );
    return result.points;
  }
}
