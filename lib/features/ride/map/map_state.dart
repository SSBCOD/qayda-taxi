import 'package:latlong2/latlong.dart';

/// Immutable snapshot of everything the map widget needs to render.
///
/// Holds plain domain data (positions + route points) rather than SDK marker
/// objects, so the rendering layer (flutter_map / OpenStreetMap) stays a dumb
/// view that builds its own markers from this state.
class MapState {
  final LatLng center;
  final double zoom;

  // Live ride data
  final LatLng? userPosition; // passenger location
  final LatLng? driverPosition; // driver car position
  final double driverBearing; // car heading in degrees
  final LatLng? origin; // pickup (A)
  final LatLng? destination; // drop-off (B)
  final List<LatLng> routePoints; // polyline A→B

  // Active leg simulation (updated by TripSimulator, not recomputed from OSRM).
  final bool isSimulating;
  final double simulationProgress; // 0–1 along current leg
  final double remainingDistanceKm;
  final int remainingEtaMin;

  // UI flags
  final bool isLocating; // fetching GPS
  final bool isLoading; // fetching route
  final String? error;

  const MapState({
    required this.center,
    this.zoom = 14.5,
    this.userPosition,
    this.driverPosition,
    this.driverBearing = 0,
    this.origin,
    this.destination,
    this.routePoints = const [],
    this.isSimulating = false,
    this.simulationProgress = 0,
    this.remainingDistanceKm = 0,
    this.remainingEtaMin = 0,
    this.isLocating = false,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    LatLng? center,
    double? zoom,
    LatLng? userPosition,
    LatLng? driverPosition,
    double? driverBearing,
    LatLng? origin,
    LatLng? destination,
    List<LatLng>? routePoints,
    bool? isSimulating,
    double? simulationProgress,
    double? remainingDistanceKm,
    int? remainingEtaMin,
    bool? isLocating,
    bool? isLoading,
    String? error,
    bool clearSimulation = false,
  }) {
    return MapState(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      userPosition: userPosition ?? this.userPosition,
      driverPosition: driverPosition ?? this.driverPosition,
      driverBearing: driverBearing ?? this.driverBearing,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      routePoints: routePoints ?? this.routePoints,
      isSimulating:
          clearSimulation ? false : (isSimulating ?? this.isSimulating),
      simulationProgress:
          clearSimulation ? 0 : (simulationProgress ?? this.simulationProgress),
      remainingDistanceKm: clearSimulation
          ? 0
          : (remainingDistanceKm ?? this.remainingDistanceKm),
      remainingEtaMin:
          clearSimulation ? 0 : (remainingEtaMin ?? this.remainingEtaMin),
      isLocating: isLocating ?? this.isLocating,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = MapState(
    center: LatLng(43.2389, 76.8897), // Almaty default
  );
}
