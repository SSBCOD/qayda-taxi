/// A simple coordinate pair independent of any map SDK.
/// Named GeoPoint to avoid conflict with google_maps_flutter.LatLng.
typedef GeoPoint = ({double lat, double lng});

/// Abstraction over the map provider so the rest of the app never touches
/// a third-party Map SDK directly.
abstract interface class MapService {
  Future<GeoPoint> currentCenter();
  Future<GeoPoint?> geocode(String query);
}
