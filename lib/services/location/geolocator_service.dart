import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../map/map_service.dart';

// Almaty city center — fallback for platforms without GPS support.
const _almatyCenter = (lat: 43.2389, lng: 76.8897);

class GeolocatorService {
  // geolocator does not support Windows or web.
  static bool get _supported =>
      !kIsWeb &&
      defaultTargetPlatform != TargetPlatform.windows &&
      defaultTargetPlatform != TargetPlatform.linux &&
      defaultTargetPlatform != TargetPlatform.macOS;

  Future<bool> requestPermission() async {
    if (!_supported) return true; // pretend granted on unsupported platforms
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return false;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<GeoPoint?> currentPosition() async {
    if (!_supported) return _almatyCenter; // use Almaty center on Windows/web
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
      return _almatyCenter;
    }
  }

  Stream<GeoPoint> positionStream() {
    if (!_supported) {
      // Return a static stream on unsupported platforms.
      return Stream.value(_almatyCenter);
    }
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    return Geolocator.getPositionStream(locationSettings: settings)
        .map((pos) => (lat: pos.latitude, lng: pos.longitude));
  }
}
