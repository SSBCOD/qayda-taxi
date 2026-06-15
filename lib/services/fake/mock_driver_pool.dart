import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'fake_drivers.dart';

/// Demo persona linked to the logged-in driver session (see [sessionDriverId]).
const String sessionDriverId = 'drv_arman';

/// Default start position for the session driver around Almaty.
const LatLng kSessionDriverStart = LatLng(43.2380, 76.9450);

/// Tracks online mock drivers for the local dispatch demo.
///
/// The logged-in driver session maps to [sessionDriverId]; [goOnline] marks
/// that driver online with [sessionPosition]. Pool drivers use [MockDriver.isOnline].
class MockDriverPoolState {
  final bool sessionOnline;
  final LatLng? sessionPosition;

  const MockDriverPoolState({
    this.sessionOnline = false,
    this.sessionPosition,
  });

  MockDriverPoolState copyWith({
    bool? sessionOnline,
    LatLng? sessionPosition,
    bool clearSessionPosition = false,
  }) {
    return MockDriverPoolState(
      sessionOnline: sessionOnline ?? this.sessionOnline,
      sessionPosition: clearSessionPosition
          ? null
          : (sessionPosition ?? this.sessionPosition),
    );
  }

  bool isDriverOnline(String driverId) {
    if (driverId == sessionDriverId) return sessionOnline;
    return kMockDrivers
        .firstWhere((d) => d.id == driverId, orElse: () => kMockDrivers.first)
        .isOnline;
  }

  /// All mock drivers currently online (session uses live [sessionPosition]).
  List<MockDriver> get onlineDrivers {
    final result = <MockDriver>[];
    for (final d in kMockDrivers) {
      if (!isDriverOnline(d.id)) continue;
      if (d.id == sessionDriverId && sessionPosition != null) {
        result.add(MockDriver(
          id: d.id,
          name: d.name,
          phone: d.phone,
          rating: d.rating,
          carModel: d.carModel,
          carNumber: d.carNumber,
          carColor: d.carColor,
          lat: sessionPosition!.latitude,
          lng: sessionPosition!.longitude,
          isOnline: true,
        ));
      } else {
        result.add(d);
      }
    }
    return result;
  }
}

class MockDriverPool extends Notifier<MockDriverPoolState> {
  @override
  MockDriverPoolState build() => const MockDriverPoolState();

  void setSessionOnline(bool online, {LatLng? position}) {
    state = state.copyWith(
      sessionOnline: online,
      sessionPosition: online ? (position ?? kSessionDriverStart) : null,
      clearSessionPosition: !online,
    );
  }
}

final mockDriverPoolProvider =
    NotifierProvider<MockDriverPool, MockDriverPoolState>(MockDriverPool.new);
