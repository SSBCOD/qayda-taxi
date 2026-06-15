import '../../core/constants/app_constants.dart';
import 'map_service.dart';

/// Mock map service centered on Almaty. Works without any API key.
class MockMapService implements MapService {
  @override
  Future<GeoPoint> currentCenter() async =>
      (lat: AppConstants.defaultLat, lng: AppConstants.defaultLng);

  @override
  Future<GeoPoint?> geocode(String query) async {
    if (query.trim().isEmpty) return null;
    return (lat: AppConstants.defaultLat, lng: AppConstants.defaultLng);
  }
}
