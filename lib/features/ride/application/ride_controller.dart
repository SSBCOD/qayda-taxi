import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/address.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/ride.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../services/fake/driver_matching_service.dart';
import '../../../services/fake/fake_payment_service.dart';
import '../../../services/fake/ride_dispatch_service.dart';
import '../../auth/application/auth_controller.dart';
import '../map/map_controller.dart';

/// Fake taxi order system — passenger ride lifecycle + dispatch to the local
/// driver session (see [RideDispatchService]).
///
/// Lifecycle:
///   createOrder → searching
///        └─ nearest online session driver → driverAssigned + incoming
///        └─ driver accepts → accepted (passenger sees driver info)
///        └─ later legs → enRoute / arrived / inProgress / completed
class RideController extends Notifier<Ride?> {
  Timer? _timer;
  int _seq = 0;

  @override
  Ride? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  MapController get _map => ref.read(mapControllerProvider.notifier);
  FakeDriverMatcher get _matcher => ref.read(driverMatcherProvider);
  FakePaymentService get _payments => ref.read(paymentServiceProvider);
  RideDispatchService get _dispatch => ref.read(rideDispatchServiceProvider);
  RideRepository get _rides => ref.read(rideRepositoryProvider);

  bool _valid(int token) => token == _seq && state != null;

  void _schedule(int token, Duration delay, void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (_valid(token)) action();
    });
  }

  // ── 1. Create order ───────────────────────────────────────────────

  Future<void> createOrder({
    required Address origin,
    required Address destination,
    required RideTier tier,
    required num priceTenge,
    required double distanceKm,
    required int durationMin,
    String paymentLabel = 'Kaspi Gold •• 7777',
    PaymentType paymentType = PaymentType.kaspi,
  }) async {
    final token = ++_seq;
    final auth = ref.read(authControllerProvider);
    final passengerId = auth.phone ?? 'demo_passenger';
    final ride = Ride(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      passengerId: passengerId,
      status: RideStatus.searching,
      tier: tier,
      origin: origin,
      destination: destination,
      distanceKm: distanceKm,
      durationMin: durationMin,
      priceTenge: priceTenge,
      paymentLabel: paymentLabel,
      paymentType: paymentType,
    );
    state = ride;

    await _map.setRoute(origin: origin.latLng, destination: destination.latLng);
    if (!_valid(token)) return;
    await _persistRide(token, passengerPhone: auth.phone);
    if (!_valid(token)) return;
    unawaited(_tryMatch(token));
  }

  Future<void> _persistRide(int token, {String? passengerPhone}) async {
    final ride = state;
    if (ride == null || !_valid(token)) return;

    try {
      await _rides.createRide(
        ride: ride,
        routePoints: ref.read(mapControllerProvider).routePoints,
        passengerPhone: passengerPhone,
      );
    } catch (error) {
      debugPrint('Firestore createRide failed; continuing local demo: $error');
    }
  }

  // ── 2. Match session driver ───────────────────────────────────────

  /// Re-attempt matching while `searching` (called when driver goes online).
  void retryMatching() {
    if (state?.status != RideStatus.searching) return;
    _tryMatch(_seq);
  }

  Future<void> _tryMatch(int token) async {
    final currentRide = state;
    if (currentRide == null || token != _seq) return;
    final match = await _matcher.findDispatchableDriver(
      pickup: currentRide.origin.latLng,
    );
    if (!_valid(token)) return;

    if (match == null) {
      _schedule(token, const Duration(seconds: 2), () => _tryMatch(token));
      return;
    }

    _assignAndDeliver(token, match);
  }

  void _assignAndDeliver(int token, DriverMatch match) {
    if (!_valid(token)) return;
    state = state!.copyWith(
      status: RideStatus.driverAssigned,
      driver: match.driver,
      driverEtaMin: match.etaMin,
    );
    _map.updateDriverPosition(match.driverStart);
    _dispatch.deliverToSessionDriver(ride: state!, match: match);
  }

  // ── 3. Status sync from driver app (via dispatch) ─────────────────

  void syncAccepted() {
    if (state?.status != RideStatus.driverAssigned) return;
    state = state!.copyWith(status: RideStatus.accepted);
  }

  void syncEnRoute() {
    if (state?.status != RideStatus.accepted &&
        state?.status != RideStatus.driverAssigned) {
      return;
    }
    state = state!.copyWith(status: RideStatus.enRoute);
  }

  void syncArrived() {
    if (state?.status != RideStatus.enRoute &&
        state?.status != RideStatus.accepted) {
      return;
    }
    state = state!.copyWith(status: RideStatus.arrived, driverEtaMin: 0);
  }

  void syncInProgress() {
    if (state?.status != RideStatus.arrived) return;
    state = state!.copyWith(status: RideStatus.inProgress);
  }

  void syncCompleted() {
    if (state?.status != RideStatus.inProgress) return;
    _map.stopSimulation();
    state = state!.copyWith(status: RideStatus.completed);
  }

  /// Called from the post-ride payment screen after the user confirms payment.
  Future<void> processPayment() async {
    if (state?.status != RideStatus.completed) return;
    final token = ++_seq;
    await _processPayment(token);
  }

  void returnToSearching() {
    if (state == null) return;
    state = state!.copyWith(status: RideStatus.searching, clearDriver: true);
    _schedule(_seq, const Duration(seconds: 2), () => _tryMatch(_seq));
  }

  Future<void> _processPayment(int token) async {
    final result = await _payments.charge(
      amount: state!.priceTenge + (state!.tipTenge ?? 0),
      method: state!.paymentType,
    );
    if (!_valid(token)) return;
    state = state!.copyWith(
      status: RideStatus.paid,
      paymentStatus: result.success ? 'paid' : 'failed',
      receiptId: result.receiptId,
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────

  void cancelTrip() {
    _seq++;
    _timer?.cancel();
    _map.stopSimulation();
    _map.clearRoute();
    _dispatch.onRideCancelled();
    if (state != null) {
      state = state!.copyWith(status: RideStatus.cancelled);
    }
  }

  // ── Rating + reset ────────────────────────────────────────────────

  void submitRating({required int stars, num? tip}) {
    if (state == null) return;
    state = state!.copyWith(
      status: RideStatus.rated,
      ratingStars: stars,
      tipTenge: tip,
    );
  }

  void reset() {
    _seq++;
    _timer?.cancel();
    _map.stopSimulation();
    _map.clearRoute();
    state = null;
  }
}

final rideControllerProvider =
    NotifierProvider<RideController, Ride?>(RideController.new);
