import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/enums.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/driver/dashboard/application/driver_controller.dart';
import '../features/driver/kyc/application/kyc_controller.dart';
import '../features/driver/vehicles/application/driver_vehicles_providers.dart';
import '../features/driver/wallet/application/driver_wallet_providers.dart';
import '../features/passenger/history/application/history_providers.dart';
import '../features/passenger/profile/application/favorites_controller.dart';
import '../features/ride/application/ride_controller.dart';
import '../features/ride/map/map_controller.dart';
import '../features/support/application/support_chat_controller.dart';
import '../services/accounts/account_session.dart';

/// Clears in-memory demo state when the auth session ends.
///
/// Persists the active account snapshot first so each phone keeps its own data.
class SessionReset {
  SessionReset._();

  static void _clearRuntimeState(WidgetRef ref) {
    ref.read(kycControllerProvider.notifier).reset();
    ref.read(rideControllerProvider.notifier).reset();
    ref.read(driverControllerProvider.notifier).goOffline();
    ref.read(mapControllerProvider.notifier).clearRoute();
    ref.read(supportChatControllerProvider.notifier).reset();
    ref.read(favoritesControllerProvider.notifier).reset();
    ref.read(tripHistoryControllerProvider.notifier).reset();
    ref.read(driverWalletBalanceProvider.notifier).reset();
    ref.read(activeDriverVehicleIdProvider.notifier).reset();
  }

  /// Clears cross-role state when the user picks a new role at the gate.
  static void onRoleSelected(WidgetRef ref, UserRole role) {
    ref.read(mapControllerProvider.notifier).clearRoute();
    if (role == UserRole.driver) {
      ref.read(rideControllerProvider.notifier).reset();
      // Fresh driver onboarding — avoid stale KYC from a prior session snapshot.
      ref.read(kycControllerProvider.notifier).reset();
      ref.read(driverControllerProvider.notifier).goOffline();
    } else {
      ref.read(driverControllerProvider.notifier).goOffline();
    }
    AccountSession.save(ref);
  }

  /// Call from [QaydaApp] when auth transitions authenticated → signed out.
  static void listen(WidgetRef ref) {
    ref.listen<AuthSession>(authControllerProvider, (prev, next) {
      if (prev?.authenticated == true && !next.authenticated) {
        if (prev?.phone != null) {
          AccountSession.save(
            ref,
            phone: prev!.phone,
            role: prev.role,
          );
        }
        _clearRuntimeState(ref);
      }
    });
  }
}
