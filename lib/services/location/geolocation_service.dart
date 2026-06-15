/// Abstraction over device geolocation (permissions + position stream).
/// Implement with `geolocator` when wiring real maps.
abstract interface class GeolocationService {
  Future<bool> requestPermission();
  Future<({double lat, double lng})?> currentPosition();
}
