import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../features/ride/map/map_controller.dart';
import '../../../features/ride/map/map_state.dart';
import '../../theme/app_colors.dart';
import 'pulse_marker.dart';
import '../feedback/app_loader.dart';

/// Shared map widget used across all map screens (home, route/tariff, wait,
/// active ride, completed). Renders OpenStreetMap tiles via flutter_map — no
/// API key or billing required.
///
/// Marker/polyline layers use [select] so driver simulation ticks do not
/// rebuild the tile layer.
class QaydaMap extends ConsumerWidget {
  const QaydaMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routePoints =
        ref.watch(mapControllerProvider.select((s) => s.routePoints));
    final flags = ref.watch(mapControllerProvider.select((s) => (
          s.isLocating,
          s.isLoading,
          s.error,
        )));
    final controller = ref.read(mapControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: MapState.initial.center,
            initialZoom: MapState.initial.zoom,
            minZoom: 3,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: Theme.of(context).brightness == Brightness.dark
                  ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                  : 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.qayda',
              tileProvider: NetworkTileProvider(),
            ),
            if (routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5,
                    color: AppColors.routeBlue,
                  ),
                ],
              ),
            const _MapMarkerLayer(),
          ],
        ),
        if (flags.$1) const Center(child: AppLoader(size: 32)),
        if (flags.$2)
          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(child: AppLoader(size: 24)),
          ),
        if (flags.$3 != null)
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Material(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  flags.$3!,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Rebuilds only when marker positions change (not on every map flag tick).
class _MapMarkerLayer extends ConsumerWidget {
  const _MapMarkerLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = ref.watch(mapControllerProvider.select((s) => s.origin));
    final destination =
        ref.watch(mapControllerProvider.select((s) => s.destination));
    final userPosition =
        ref.watch(mapControllerProvider.select((s) => s.userPosition));
    final driverPosition =
        ref.watch(mapControllerProvider.select((s) => s.driverPosition));
    final driverBearing =
        ref.watch(mapControllerProvider.select((s) => s.driverBearing));
    final scheme = Theme.of(context).colorScheme;

    return MarkerLayer(
      markers: _markers(
        scheme: scheme,
        origin: origin,
        destination: destination,
        userPosition: userPosition,
        driverPosition: driverPosition,
        driverBearing: driverBearing,
      ),
    );
  }

  List<Marker> _markers({
    required ColorScheme scheme,
    required LatLng? origin,
    required LatLng? destination,
    required LatLng? userPosition,
    required LatLng? driverPosition,
    required double driverBearing,
  }) {
    final markers = <Marker>[];

    if (origin != null) {
      markers.add(_pin(origin, AppColors.online, Icons.trip_origin));
    }
    if (destination != null) {
      markers.add(_pin(destination, scheme.primary, Icons.place));
    }
    if (userPosition != null) {
      markers.add(
        Marker(
          point: userPosition,
          width: 28,
          height: 28,
          child: const RepaintBoundary(child: PulseMarker(size: 16)),
        ),
      );
    }
    if (driverPosition != null) {
      markers.add(
        Marker(
          point: driverPosition,
          width: 44,
          height: 44,
          child: RepaintBoundary(
            child: Transform.rotate(
              angle: driverBearing * math.pi / 180,
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.onPrimary, width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child:
                    Icon(Icons.navigation, size: 20, color: scheme.onPrimary),
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  Marker _pin(LatLng point, Color color, IconData icon) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      alignment: Alignment.topCenter,
      child: Icon(icon, color: color, size: 32),
    );
  }
}
