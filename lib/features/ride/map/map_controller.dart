import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/maps/route_service.dart';
import '../../../core/maps/trip_simulator.dart';
import '../../../services/location/geolocator_service.dart';
import 'map_state.dart';

/// Drives everything on the map (user location, driver position, route,
/// simulation). Screens call the public commands; they never build map state
/// themselves, keeping [QaydaMap] fully dumb.
///
/// Rendering uses flutter_map + OpenStreetMap tiles (no API key / billing) and
/// OSRM for road routing.
class MapController extends Notifier<MapState> {

  /// flutter_map controller used for camera moves (created here, attached by
  /// the [QaydaMap] widget).
  final fm.MapController mapController = fm.MapController();

  TripSimulator? _simulator;
  StreamSubscription<SimulatorFrame>? _simSub;

  GeolocatorService get _geo => ref.read(geolocatorServiceProvider);

  @override
  MapState build() {
    ref.onDispose(() {
      stopSimulation();
      mapController.dispose();
    });
    return MapState.initial;
  }

  // ── User location ─────────────────────────────────────────────────

  Future<void> locateUser() async {
    state = state.copyWith(isLocating: true, error: null);
    final pos = await _geo.currentPosition();
    if (pos == null) {
      state = state.copyWith(isLocating: false, error: 'GPS недоступен');
      return;
    }
    final latlng = LatLng(pos.lat, pos.lng);
    state = state.copyWith(
      userPosition: latlng,
      center: latlng,
      isLocating: false,
    );
    _move(latlng, 15);
  }

  // ── Route ─────────────────────────────────────────────────────────

  Future<void> setRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      origin: origin,
      destination: destination,
    );

    var points = await RouteService.fetchRoute(
      origin: origin,
      destination: destination,
    );
    if (points.length < 2) {
      points = [origin, destination];
    }

    state = state.copyWith(routePoints: points, isLoading: false);
    _fitBounds(points);
  }

  void clearRoute() {
    stopSimulation();
    state = state.copyWith(
      origin: null,
      destination: null,
      routePoints: [],
      clearSimulation: true,
    );
  }

  // ── Driver position (live or simulated) ───────────────────────────

  void updateDriverPosition(LatLng pos, {double bearing = 0}) {
    state = state.copyWith(driverPosition: pos, driverBearing: bearing);
  }

  // ── Trip simulation ───────────────────────────────────────────────

  /// Animates the driver marker along [waypoints] (or the current route) so the
  /// leg finishes in roughly [duration] — the simulated speed is derived from
  /// the path length, keeping the demo brisk regardless of real distance.
  void startSimulation({
    List<LatLng>? waypoints,
    Duration duration = const Duration(seconds: 10),
    void Function()? onCompleted,
  }) {
    stopSimulation();
    final route = waypoints ??
        (state.routePoints.length >= 2
            ? state.routePoints
            : almatyCityToAirport);
    if (route.length < 2) {
      onCompleted?.call();
      return;
    }
    final totalKm = _routeLengthKm(route);
    final totalMin = duration.inSeconds <= 0
        ? 1
        : (duration.inSeconds / 60).ceil().clamp(1, 999);
    state = state.copyWith(
      isSimulating: true,
      simulationProgress: 0,
      remainingDistanceKm: totalKm,
      remainingEtaMin: totalMin,
    );
    _simulator =
        TripSimulator(waypoints: route, speedKmh: _speedFor(route, duration));
    _simSub = _simulator!.stream.listen((frame) {
      final progress = frame.progress.clamp(0.0, 1.0);
      final remainingKm =
          double.parse((totalKm * (1 - progress)).toStringAsFixed(1));
      final remainingMin =
          ((totalMin * (1 - progress)).ceil()).clamp(0, totalMin);
      state = state.copyWith(
        driverPosition: frame.position,
        driverBearing: frame.bearing,
        simulationProgress: progress,
        remainingDistanceKm: remainingKm,
        remainingEtaMin: remainingMin,
        isSimulating: !frame.isCompleted,
        clearSimulation: frame.isCompleted,
      );
      if (frame.isCompleted) onCompleted?.call();
    });
    _simulator!.start();
  }

  double _routeLengthKm(List<LatLng> route) {
    var meters = 0.0;
    for (var i = 0; i < route.length - 1; i++) {
      meters += _distance.as(LengthUnit.Meter, route[i], route[i + 1]);
    }
    return double.parse((meters / 1000).toStringAsFixed(1));
  }

  static const Distance _distance = Distance();

  double _speedFor(List<LatLng> route, Duration duration) {
    var meters = 0.0;
    for (var i = 0; i < route.length - 1; i++) {
      meters += _distance.as(LengthUnit.Meter, route[i], route[i + 1]);
    }
    final seconds = duration.inMilliseconds / 1000;
    if (meters <= 0 || seconds <= 0) return 40;
    return ((meters / 1000) / (seconds / 3600)).clamp(5, 100000);
  }

  void stopSimulation() {
    _simSub?.cancel();
    _simSub = null;
    _simulator?.dispose();
    _simulator = null;
    state = state.copyWith(clearSimulation: true);
  }

  // ── Camera helpers ────────────────────────────────────────────────

  void _move(LatLng target, double zoom) {
    try {
      mapController.move(target, zoom);
    } catch (_) {
      // Controller not attached to a map yet — ignore.
    }
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    try {
      mapController.fitCamera(
        fm.CameraFit.bounds(
          bounds: fm.LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(60),
        ),
      );
    } catch (_) {
      // Controller not attached yet.
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final geolocatorServiceProvider =
    Provider<GeolocatorService>((ref) => GeolocatorService());

final mapControllerProvider =
    NotifierProvider<MapController, MapState>(MapController.new);
