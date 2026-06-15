import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/driver_info.dart';
import 'mock_driver_pool.dart';

/// Result of a successful match: which driver, where they start, and the ETA
/// to the pickup point.
class DriverMatch {
  final DriverInfo driver;
  final LatLng driverStart;
  final int etaMin;
  const DriverMatch({
    required this.driver,
    required this.driverStart,
    required this.etaMin,
  });
}

/// Fake driver matching for the MVP demo.
///
/// Finds **online** mock drivers near the pickup, sorted by distance.
/// Dispatch to the driver app only works for [sessionDriverId] when the
/// session is online — see [RideDispatchService].
class FakeDriverMatcher {
  const FakeDriverMatcher(this._ref);

  final Ref _ref;

  static const Distance _distance = Distance();
  static const double _approachSpeedKmh = 28;

  /// All online drivers near [pickup], nearest first.
  Future<List<DriverMatch>> findNearbyOnline({
    required LatLng pickup,
    Duration delay = const Duration(milliseconds: 1500),
  }) async {
    await Future.delayed(delay);

    final online = _ref.read(mockDriverPoolProvider).onlineDrivers;
    if (online.isEmpty) return [];

    final sorted = [...online]..sort((a, b) => _distance
        .as(LengthUnit.Meter, a.position, pickup)
        .compareTo(_distance.as(LengthUnit.Meter, b.position, pickup)));

    return sorted.map((d) {
      final meters = _distance.as(LengthUnit.Meter, d.position, pickup);
      final etaMin =
          ((meters / 1000) / _approachSpeedKmh * 60).clamp(2, 12).round();
      return DriverMatch(
        driver: d.toDriverInfo(),
        driverStart: d.position,
        etaMin: etaMin,
      );
    }).toList();
  }

  /// Nearest online driver to [pickup], or null if none online.
  Future<DriverMatch?> findNearestOnline({
    required LatLng pickup,
    Duration delay = const Duration(milliseconds: 1500),
  }) async {
    final nearby = await findNearbyOnline(pickup: pickup, delay: delay);
    return nearby.isEmpty ? null : nearby.first;
  }

  /// Nearest online driver that can receive dispatch on this device.
  Future<DriverMatch?> findDispatchableDriver({
    required LatLng pickup,
    Duration delay = const Duration(milliseconds: 1500),
  }) async {
    final nearby = await findNearbyOnline(pickup: pickup, delay: delay);
    if (nearby.isEmpty) return null;

    final pool = _ref.read(mockDriverPoolProvider);
    if (!pool.sessionOnline) return null;

    for (final match in nearby) {
      if (match.driver.id == sessionDriverId) return match;
    }
    return null;
  }
}

final driverMatcherProvider = Provider<FakeDriverMatcher>(
  (ref) => FakeDriverMatcher(ref),
);
