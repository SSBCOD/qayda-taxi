import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/enums.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/driver/dashboard/application/driver_controller.dart';
import '../../features/driver/kyc/application/kyc_controller.dart';
import '../../features/ride/application/ride_controller.dart';
import '../../services/accounts/account_session.dart';
import 'routes.dart';

/// Centralized navigation guard.
///
/// Resolution order (see docs/navigation.md):
///   auth → role → driver verification → role route isolation → flow guards.
class RedirectGuard {
  RedirectGuard._();

  /// Routes that make up the unauthenticated auth flow. While signed out the
  /// user may move freely between these; any other location bounces to splash.
  static const Set<String> _authFlow = {
    Routes.splash,
    Routes.language,
    Routes.welcome,
    Routes.phone,
    Routes.otp,
    Routes.profileSetup,
    Routes.role,
  };

  /// Driver onboarding flow — an unverified driver may move freely between
  /// these; any other location bounces to the first KYC step.
  static const Set<String> _kycFlow = {
    Routes.kycVehicle,
    Routes.kycIdentity,
    Routes.kycPending,
    Routes.kycSuccess,
  };

  /// Shared between passenger and driver (payment, settings, support).
  static const Set<String> _sharedRoutes = {
    Routes.payment,
    Routes.paymentAdd,
    Routes.paymentBinding,
    Routes.settings,
    Routes.settingsTheme,
    Routes.settingsNotifications,
    Routes.settingsPrivacy,
    Routes.settingsAbout,
    Routes.settingsLegal,
    Routes.support,
    Routes.supportChat,
  };

  static const Set<String> _passengerRideRoutes = {
    Routes.pRideWait,
    Routes.pRideActive,
    Routes.pRideCompleted,
    Routes.pRideRate,
  };

  static const Set<String> _driverOrderRoutes = {
    Routes.dOrderIncoming,
    Routes.dOrderEnroute,
    Routes.dOrderBoarding,
    Routes.dOrderActive,
    Routes.dOrderSummary,
    Routes.dOrderRate,
  };

  static bool _isPassengerArea(String loc) => loc.startsWith('/p/');

  static bool _isDriverArea(String loc) =>
      loc.startsWith('/d/') || _kycFlow.contains(loc);

  /// Canonical order-flow screen for the current [DriverOrderStage].
  static String _driverOrderRouteFor(DriverOrderStage stage) {
    return switch (stage) {
      DriverOrderStage.incoming => Routes.dOrderIncoming,
      DriverOrderStage.enRouteToPickup => Routes.dOrderEnroute,
      DriverOrderStage.arrived => Routes.dOrderBoarding,
      DriverOrderStage.inProgress => Routes.dOrderActive,
      DriverOrderStage.completed => Routes.dOrderSummary,
    };
  }

  static String? resolve(Ref ref, GoRouterState state) {
    final auth = ref.read(authControllerProvider);
    final loc = state.matchedLocation;
    final inAuthFlow = _authFlow.contains(loc);

    // 1. Not authenticated.
    if (!auth.authenticated) {
      // 1a. No profile yet → must fill profile first.
      if (!auth.hasProfile) {
        final profileOk = loc == Routes.profileSetup ||
            loc == Routes.splash ||
            loc == Routes.language;
        return profileOk ? null : Routes.profileSetup;
      }
      // 1b. Has profile → must stay inside auth flow (phone + OTP).
      return inAuthFlow ? null : Routes.welcome;
    }

    // 2. Authenticated but no role → apply selectedRole or show role screen.
    if (!auth.hasRole) {
      if (loc == Routes.role || loc == Routes.profileSetup) return null;
      return Routes.role;
    }

    final isDriver = auth.role == UserRole.driver;
    final isPassenger = auth.role == UserRole.passenger;
    final isShared = _sharedRoutes.contains(loc);

    // 3. Role isolation — each role stays in its own shell (shared routes OK).
    if (isPassenger && _isDriverArea(loc) && !isShared) {
      return Routes.pHome;
    }
    if (isDriver && _isPassengerArea(loc) && !isShared) {
      return Routes.dDashboard;
    }

    // 4. Driver not yet verified → gate everything behind the KYC flow.
    if (isDriver) {
      final kycStatus = ref.read(kycControllerProvider).status;
      if (kycStatus != VerificationStatus.verified) {
        if (_kycFlow.contains(loc)) return null;
        return AccountSession.driverKycEntryRoute(kycStatus);
      }
    }

    // 5. Passenger ride — require active ride + keep route aligned with status.
    if (isPassenger) {
      final ride = ref.read(rideControllerProvider);

      if (_passengerRideRoutes.contains(loc) && ride == null) {
        return Routes.pHome;
      }

      if (ride != null) {
        if (ride.status == RideStatus.completed &&
            (loc == Routes.pRideActive || loc == Routes.pRideWait)) {
          return Routes.paymentBinding;
        }
        if (ride.status == RideStatus.inProgress && loc == Routes.pRideWait) {
          return Routes.pRideActive;
        }
        if (ride.status == RideStatus.inProgress &&
            loc == Routes.pRideCompleted) {
          return Routes.pRideActive;
        }
      }
    }

    // 6. Driver order flow — require an order and keep the route in sync with
    // its stage (linear FSM: incoming → enroute → boarding → active → summary → rate).
    if (isDriver) {
      final order = ref.read(driverControllerProvider).order;

      if (_driverOrderRoutes.contains(loc)) {
        if (order == null) return Routes.dDashboard;
        if (order.stage == DriverOrderStage.completed) {
          if (loc == Routes.dOrderSummary || loc == Routes.dOrderRate) {
            return null;
          }
          return Routes.dOrderSummary;
        }
        final expected = _driverOrderRouteFor(order.stage);
        if (loc != expected) return expected;
      } else if (loc == Routes.dDashboard && order != null) {
        return _driverOrderRouteFor(order.stage);
      }
    }

    // 7. Verified driver still on auth/KYC screens → dashboard.
    if (inAuthFlow) {
      return isDriver ? Routes.dDashboard : Routes.pHome;
    }
    if (_kycFlow.contains(loc) && isDriver) {
      // Pending + success are part of the linear onboarding story.
      if (loc == Routes.kycPending || loc == Routes.kycSuccess) return null;
      return Routes.dDashboard;
    }

    return null;
  }
}
