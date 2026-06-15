import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map/map_service.dart';
import 'map/mock_map_service.dart';

/// Infrastructure service providers (DI roots).
/// Swap the mock implementations for real ones when wiring backend/maps.
final mapServiceProvider = Provider<MapService>((ref) => MockMapService());
