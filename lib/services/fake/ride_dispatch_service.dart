import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/pricing/kz_taxi_pricing.dart';
import '../../data/models/driver_order.dart';
import '../../data/models/enums.dart';
import '../../data/models/ride.dart';
import '../../features/driver/dashboard/application/driver_controller.dart';
import '../../features/ride/application/ride_controller.dart';
import 'driver_matching_service.dart';
import 'mock_driver_pool.dart';

/// Local dispatch bridge between the passenger [RideController] and the driver
/// [DriverController] — no Firebase, single-process MVP demo.
///
/// Flow:
///   passenger createOrder → searching
///   session driver online → assign + incoming offer on driver dashboard
///   driver accept → enRoute simulation (driver map) + passenger status sync
///   driver arrived / start / finish → mirrored ride status updates
class RideDispatchService {
  RideDispatchService(this._ref);

  final Ref _ref;

  static const Distance _distance = Distance();

  /// Builds a [DriverOrder] from the shared passenger ride + match result.
  DriverOrder buildDriverOrder({
    required Ride ride,
    required DriverMatch match,
  }) {
    final pickupM = _distance.as(
      LengthUnit.Meter,
      match.driverStart,
      ride.origin.latLng,
    );
    final bonus = KzTaxiPricing.driverBonusTenge(ride.priceTenge, ride.tier);

    return DriverOrder(
      id: ride.id,
      stage: DriverOrderStage.incoming,
      passengerName: 'Пассажир',
      passengerRating: 5.0,
      tier: ride.tier,
      fareTenge: ride.priceTenge,
      bonusTenge: bonus,
      paymentType: ride.paymentType,
      pickupTitle: ride.origin.titleRu,
      driverStart: match.driverStart,
      pickup: ride.origin.latLng,
      pickupDistanceKm: double.parse((pickupM / 1000).toStringAsFixed(1)),
      pickupEtaMin: match.etaMin,
      destTitleRu: ride.destination.titleRu,
      destSubtitleRu: ride.destination.fullText,
      destination: ride.destination.latLng,
      tripDistanceKm: ride.distanceKm,
      tripDurationMin: ride.durationMin,
    );
  }

  /// Assigns the ride to the session driver and surfaces an incoming offer.
  void deliverToSessionDriver({
    required Ride ride,
    required DriverMatch match,
  }) {
    final pool = _ref.read(mockDriverPoolProvider);
    if (!pool.sessionOnline) return;

    final driver = _ref.read(driverControllerProvider.notifier);
    final driverState = _ref.read(driverControllerProvider);
    if (!driverState.isOnline || driverState.order != null) return;

    driver.receiveDispatchedOrder(buildDriverOrder(ride: ride, match: match));
  }

  /// Called when the session driver goes online — picks up any pending search.
  void onSessionDriverOnline() {
    final ride = _ref.read(rideControllerProvider);
    if (ride == null || ride.status != RideStatus.searching) return;

    _ref.read(rideControllerProvider.notifier).retryMatching();
  }

  void onDriverAccepted(String rideId) {
    final ride = _ref.read(rideControllerProvider);
    if (ride == null || ride.id != rideId) return;
    _ref.read(rideControllerProvider.notifier).syncAccepted();
  }

  void onDriverEnRoute(String rideId) {
    final ride = _ref.read(rideControllerProvider);
    if (ride == null || ride.id != rideId) return;
    _ref.read(rideControllerProvider.notifier).syncEnRoute();
  }

  void onDriverArrived(String rideId) {
    final ride = _ref.read(rideControllerProvider);
    if (ride == null || ride.id != rideId) return;
    _ref.read(rideControllerProvider.notifier).syncArrived();
  }

  void onDriverStartTrip(String rideId) {
    final ride = _ref.read(rideControllerProvider);
    if (ride == null || ride.id != rideId) return;
    _ref.read(rideControllerProvider.notifier).syncInProgress();
  }

  void onDriverFinishTrip(String rideId) {
    final ride = _ref.read(rideControllerProvider);
    if (ride == null || ride.id != rideId) return;
    _ref.read(rideControllerProvider.notifier).syncCompleted();
  }

  void onDriverDeclined(String rideId) {
    final ride = _ref.read(rideControllerProvider);
    if (ride == null || ride.id != rideId) return;
    _ref.read(rideControllerProvider.notifier).returnToSearching();
  }

  void onRideCancelled() {
    final driver = _ref.read(driverControllerProvider.notifier);
    final order = _ref.read(driverControllerProvider).order;
    if (order != null) {
      driver.clearDispatchedOrder();
    }
  }
}

final rideDispatchServiceProvider = Provider<RideDispatchService>(
  (ref) => RideDispatchService(ref),
);
