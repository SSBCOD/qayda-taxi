import 'dart:async';
import 'dart:math';

import 'package:latlong2/latlong.dart';

/// Simulates a driver moving along a list of waypoints.
///
/// Progress is measured by arc-length along the full polyline so ETA and
/// remaining distance stay accurate on dense OSRM routes.
class TripSimulator {
  factory TripSimulator({
    required List<LatLng> waypoints,
    double speedKmh = 40,
    int tickMs = 100,
  }) {
    final segments = _computeSegmentLengths(waypoints);
    return TripSimulator._(
      waypoints: waypoints,
      segmentLengths: segments,
      totalMeters: _totalLength(segments),
      speedKmh: speedKmh,
      tickMs: tickMs,
    );
  }

  TripSimulator._({
    required List<LatLng> waypoints,
    required List<double> segmentLengths,
    required double totalMeters,
    required this.speedKmh,
    required this.tickMs,
  })  : _waypoints = List.unmodifiable(waypoints),
        _segmentLengths = segmentLengths,
        _totalMeters = totalMeters;

  final List<LatLng> _waypoints;
  final List<double> _segmentLengths;
  final double _totalMeters;
  final double speedKmh;
  final int tickMs;

  final _controller = StreamController<SimulatorFrame>.broadcast();
  Stream<SimulatorFrame> get stream => _controller.stream;

  Timer? _timer;
  double _distanceTraveled = 0;

  bool get isRunning => _timer?.isActive ?? false;

  void start() {
    if (_waypoints.length < 2 || _totalMeters <= 0) return;
    _distanceTraveled = 0;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: tickMs), _tick);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  void _tick(Timer timer) {
    final metersPerTick = (speedKmh * 1000 / 3600) * (tickMs / 1000);
    _distanceTraveled += metersPerTick;

    if (_distanceTraveled >= _totalMeters) {
      stop();
      final last = _waypoints.last;
      final prev = _waypoints[_waypoints.length - 2];
      _controller.add(SimulatorFrame(
        position: last,
        bearing: _bearing(prev, last),
        progress: 1,
        isCompleted: true,
      ));
      return;
    }

    final progress = (_distanceTraveled / _totalMeters).clamp(0.0, 1.0);
    final (position, bearing) = _positionAt(progress);
    _controller.add(SimulatorFrame(
      position: position,
      bearing: bearing,
      progress: progress,
      isCompleted: false,
    ));
  }

  (LatLng, double) _positionAt(double progress) {
    final targetM = _totalMeters * progress;
    var walked = 0.0;
    for (var i = 0; i < _segmentLengths.length; i++) {
      final segM = _segmentLengths[i];
      if (walked + segM >= targetM) {
        final t = segM > 0 ? (targetM - walked) / segM : 0.0;
        final tt = t.clamp(0.0, 1.0).toDouble();
        final from = _waypoints[i];
        final to = _waypoints[i + 1];
        return (_interpolate(from, to, tt), _bearing(from, to));
      }
      walked += segM;
    }
    final last = _waypoints.last;
    final prev = _waypoints[_waypoints.length - 2];
    return (last, _bearing(prev, last));
  }

  static List<double> _computeSegmentLengths(List<LatLng> waypoints) {
    if (waypoints.length < 2) return const [];
    final lengths = <double>[];
    for (var i = 0; i < waypoints.length - 1; i++) {
      lengths.add(_haversineM(waypoints[i], waypoints[i + 1]));
    }
    return lengths;
  }

  static double _totalLength(List<double> lengths) =>
      lengths.fold(0.0, (a, b) => a + b);

  static LatLng _interpolate(LatLng a, LatLng b, double t) => LatLng(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      );

  static double _bearing(LatLng from, LatLng to) {
    final dLng = _toRad(to.longitude - from.longitude);
    final lat1 = _toRad(from.latitude);
    final lat2 = _toRad(to.latitude);
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    return ((_toDeg(atan2(y, x)) + 360) % 360).toDouble();
  }

  static double _haversineM(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(a.latitude)) *
            cos(_toRad(b.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * r * asin(sqrt(h));
  }

  static double _toRad(double deg) => deg * pi / 180;
  static double _toDeg(double rad) => rad * 180 / pi;
}

/// A single position update emitted by [TripSimulator].
class SimulatorFrame {
  final LatLng position;
  final double bearing;
  final double progress;
  final bool isCompleted;

  const SimulatorFrame({
    required this.position,
    required this.bearing,
    required this.progress,
    required this.isCompleted,
  });
}

/// Hardcoded demo route through central Almaty (pickup → airport).
/// Used when OSRM is unavailable or returns too few points.
const List<LatLng> almatyCityToAirport = [
  LatLng(43.2389, 76.8897),
  LatLng(43.2320, 76.8870),
  LatLng(43.2260, 76.8830),
  LatLng(43.2200, 76.8800),
  LatLng(43.2140, 76.8920),
  LatLng(43.2080, 76.9050),
  LatLng(43.3430, 77.0397),
];
