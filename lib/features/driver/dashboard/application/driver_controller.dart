import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/driver_order.dart';
import '../../../../data/models/enums.dart';
import '../../../ride/map/map_controller.dart';
import '../../../../services/accounts/account_session.dart';
import '../../../../services/fake/mock_driver_pool.dart';
import '../../../../services/fake/ride_dispatch_service.dart';

/// Driver-side state: online status, today's metrics and the current order.
class DriverState {
  final DriverStatus status;
  final num earningsToday;
  final int tripsToday;
  final double rating;
  final DriverOrder? order;

  const DriverState({
    this.status = DriverStatus.offline,
    this.earningsToday = 12400,
    this.tripsToday = 8,
    this.rating = 4.98,
    this.order,
  });

  bool get isOnline => status != DriverStatus.offline;

  DriverState copyWith({
    DriverStatus? status,
    num? earningsToday,
    int? tripsToday,
    double? rating,
    DriverOrder? order,
    bool clearOrder = false,
  }) {
    return DriverState(
      status: status ?? this.status,
      earningsToday: earningsToday ?? this.earningsToday,
      tripsToday: tripsToday ?? this.tripsToday,
      rating: rating ?? this.rating,
      order: clearOrder ? null : (order ?? this.order),
    );
  }
}

/// Driver order FSM wired to [RideDispatchService] for the linked taxi demo.
///
/// Going online registers the session in [MockDriverPool] and picks up any
/// passenger ride that is currently `searching`. Incoming orders come from
/// dispatch — not from a random local timer.
class DriverController extends Notifier<DriverState> {
  @override
  DriverState build() => const DriverState();

  MapController get _map => ref.read(mapControllerProvider.notifier);
  RideDispatchService get _dispatch => ref.read(rideDispatchServiceProvider);

  void restoreProfile({
    required num earningsToday,
    required int tripsToday,
    required double rating,
  }) {
    state = state.copyWith(
      earningsToday: earningsToday,
      tripsToday: tripsToday,
      rating: rating,
      status: DriverStatus.offline,
      clearOrder: true,
    );
  }

  // ── Online / offline ──────────────────────────────────────────────

  void goOnline() {
    if (state.isOnline) return;
    ref.read(mockDriverPoolProvider.notifier).setSessionOnline(
          true,
          position: kSessionDriverStart,
        );
    state = state.copyWith(status: DriverStatus.online);
    _dispatch.onSessionDriverOnline();
  }

  void goOffline() {
    ref.read(mockDriverPoolProvider.notifier).setSessionOnline(false);
    _map.stopSimulation();
    _map.clearRoute();
    state = state.copyWith(status: DriverStatus.offline, clearOrder: true);
  }

  // ── Dispatch offer ────────────────────────────────────────────────

  void receiveDispatchedOrder(DriverOrder order) {
    if (!state.isOnline || state.order != null) return;
    state = state.copyWith(order: order);
  }

  void clearDispatchedOrder() {
    if (state.order == null) return;
    state = state.copyWith(clearOrder: true);
  }

  /// Decline / skip — passenger returns to searching.
  void declineOrder() {
    final order = state.order;
    if (order == null) return;
    _dispatch.onDriverDeclined(order.id);
    state = state.copyWith(clearOrder: true);
  }

  // ── Accept → drive to pickup ──────────────────────────────────────

  Future<void> acceptOrder() async {
    final order = state.order;
    if (order == null || order.stage != DriverOrderStage.incoming) return;

    state = state.copyWith(
      status: DriverStatus.onOrder,
      order: order.copyWith(stage: DriverOrderStage.enRouteToPickup),
    );
    _dispatch.onDriverAccepted(order.id);

    await _map.setRoute(origin: order.driverStart, destination: order.pickup);
    _dispatch.onDriverEnRoute(order.id);
    _map.startSimulation(
      duration: Duration(seconds: (order.pickupEtaMin * 5).clamp(6, 20)),
      onCompleted: _onApproachLegCompleted,
    );
  }

  void _onApproachLegCompleted() {
    final order = state.order;
    if (order == null || order.stage != DriverOrderStage.enRouteToPickup) {
      return;
    }
    arrivedAtPickup();
  }

  void arrivedAtPickup() {
    final order = state.order;
    if (order == null || order.stage != DriverOrderStage.enRouteToPickup) {
      return;
    }
    _map.stopSimulation();
    state =
        state.copyWith(order: order.copyWith(stage: DriverOrderStage.arrived));
    _dispatch.onDriverArrived(order.id);
  }

  void revertToEnRoute() {
    final order = state.order;
    if (order == null || order.stage != DriverOrderStage.arrived) return;
    state = state.copyWith(
      order: order.copyWith(stage: DriverOrderStage.enRouteToPickup),
    );
  }

  // ── Start trip → drive to destination ─────────────────────────────

  Future<void> startTrip() async {
    final order = state.order;
    if (order == null || order.stage != DriverOrderStage.arrived) return;
    state = state.copyWith(
      order: order.copyWith(stage: DriverOrderStage.inProgress),
    );
    _dispatch.onDriverStartTrip(order.id);

    await _map.setRoute(origin: order.pickup, destination: order.destination);
    _map.startSimulation(
      duration: Duration(seconds: (order.tripDurationMin * 5).clamp(10, 30)),
      onCompleted: _onTripLegCompleted,
    );
  }

  void _onTripLegCompleted() {
    final order = state.order;
    if (order == null || order.stage != DriverOrderStage.inProgress) return;
    finishTrip();
  }

  // ── Finish trip → earnings ────────────────────────────────────────

  void finishTrip() {
    final order = state.order;
    if (order == null || order.stage != DriverOrderStage.inProgress) return;
    _map.stopSimulation();
    state = state.copyWith(
      order: order.copyWith(stage: DriverOrderStage.completed),
      earningsToday: state.earningsToday + order.incomeTenge,
      tripsToday: state.tripsToday + 1,
    );
    _dispatch.onDriverFinishTrip(order.id);
    AccountSession.save(ref);
  }

  void completeOrder() {
    _map.stopSimulation();
    _map.clearRoute();
    state = state.copyWith(status: DriverStatus.online, clearOrder: true);
  }

  void submitPassengerRating({required int stars, String? comment}) {
    assert(stars >= 1 && stars <= 5);
    completeOrder();
  }
}

final driverControllerProvider =
    NotifierProvider<DriverController, DriverState>(DriverController.new);
