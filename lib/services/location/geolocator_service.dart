import 'package:geolocator/geolocator.dart';

import '../map/map_service.dart';

/// Concrete geolocation service using the [geolocator] package.
class GeolocatorService {
  /// Requests location permission and returns whether it was granted.
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return false;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Returns the device's current position, or null if unavailable.
  Future<GeoPoint?> currentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Continuous position stream (use during active ride tracking).
  Stream<GeoPoint> positionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // metres before an event fires
    );
    return Geolocator.getPositionStream(locationSettings: settings)
        .map((pos) => (lat: pos.latitude, lng: pos.longitude));
  }
}
