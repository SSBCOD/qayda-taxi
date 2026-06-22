import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth.dart';
import '../../features/driver/dashboard/application/driver_controller.dart';
import '../../features/driver/dashboard/driver_dashboard_screen.dart';
import '../../features/driver/earnings/driver_earnings_screen.dart';
import '../../features/driver/history/driver_daily_history_screen.dart';
import '../../features/driver/profile/driver_profile_screen.dart';
import '../../features/driver/referral/driver_referral_screen.dart';
import '../../features/driver/vehicles/driver_vehicles_screen.dart';
import '../../features/driver/wallet/driver_wallet_screen.dart';
import '../../features/driver/kyc/kyc.dart';
import '../../features/driver/order/driver_active_screen.dart';
import '../../features/driver/order/driver_boarding_screen.dart';
import '../../features/driver/order/driver_enroute_screen.dart';
import '../../features/driver/order/driver_order_rate_screen.dart';
import '../../features/driver/order/driver_incoming_screen.dart';
import '../../features/driver/order/driver_summary_screen.dart';
import '../../features/passenger/address_search/address_search_screen.dart';
import '../../features/passenger/address_search/set_destination_map_screen.dart';
import '../../features/passenger/history/history_screen.dart';
import '../../features/passenger/home_map/home_map_screen.dart';
import '../../features/passenger/profile/favorites_screen.dart';
import '../../features/passenger/profile/profile_screen.dart';
import '../../features/passenger/ride/ride_active_screen.dart';
import '../../features/passenger/ride/ride_completed_screen.dart';
import '../../features/passenger/ride/ride_rate_screen.dart';
import '../../features/passenger/ride/ride_wait_screen.dart';
import '../../features/ride/application/ride_controller.dart';
import '../../features/passenger/route_tariff/route_tariff_screen.dart';
import '../../features/payment/add_card_screen.dart';
import '../../features/payment/payment_binding_screen.dart';
import '../../features/payment/payment_methods_screen.dart';
import '../../features/settings/about_screen.dart';
import '../../features/support/faq_help_center_screen.dart';
import '../../features/support/support_chat_screen.dart';
import '../../features/settings/legal_support_screen.dart';
import '../../features/settings/notification_preferences_screen.dart';
import '../../features/settings/privacy_security_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/theme_selection_screen.dart';
import 'redirect_guard.dart';
import 'routes.dart';
import 'shells/passenger_shell.dart';

/// Root navigator key (used for full-screen routes pushed above the shells).
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _passengerShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'passengerShell');

/// GoRouter configuration.
///
/// Structure mirrors `docs/navigation.md`:
///   - Shared / auth routes live on the root navigator (no shell).
///   - Passenger hub screens (home · history · profile) live inside a
///     [StatefulShellRoute.indexedStack] so each tab keeps its own stack and
///     the BottomNav stays visible.
///   - The passenger order flow (search → route → tariff → ride/*) is pushed
///     full-screen on the root navigator so the BottomNav is hidden, matching
///     the Stitch "BottomNavBar suppressed in active driving state" rule.
///
/// The app opens on [Routes.splash]; [RedirectGuard] then gates everything
/// behind auth → role → role-based home. A [_RouterRefresh] listenable
/// re-evaluates the guard whenever the auth session changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) => RedirectGuard.resolve(ref, state),
    routes: [
      // ── Shared / auth flow (no shell) ───────────────────────────────
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.language,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.phone,
        redirect: (context, state) => Routes.welcome,
      ),
      GoRoute(
        path: Routes.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: Routes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: Routes.role,
        builder: (context, state) => const RoleScreen(),
      ),

      // ── Passenger order flow (full-screen, BottomNav hidden) ────────
      GoRoute(
        path: Routes.pSearch,
        builder: (context, state) => const AddressSearchScreen(),
      ),
      GoRoute(
        path: Routes.pSetDestination,
        builder: (context, state) => const SetDestinationMapScreen(),
      ),
      GoRoute(
        path: Routes.pRoute,
        redirect: (context, state) => Routes.pTariff,
      ),
      GoRoute(
        path: Routes.pTariff,
        builder: (context, state) => const RouteTariffScreen(),
      ),
      GoRoute(
        path: Routes.pRideWait,
        builder: (context, state) => const RideWaitScreen(),
      ),
      GoRoute(
        path: Routes.pRideActive,
        builder: (context, state) => const RideActiveScreen(),
      ),
      GoRoute(
        path: Routes.pRideCompleted,
        builder: (context, state) => const RideCompletedScreen(),
      ),
      GoRoute(
        path: Routes.pRideRate,
        builder: (context, state) => const RideRateScreen(),
      ),
      GoRoute(
        path: Routes.pFavorites,
        builder: (context, state) => const FavoritesScreen(),
      ),

      // ── Driver KYC / onboarding (no shell, BottomNav suppressed) ────
      GoRoute(
        path: Routes.kycVehicle,
        builder: (context, state) => const KycVehicleScreen(),
      ),
      GoRoute(
        path: Routes.kycIdentity,
        builder: (context, state) => const KycIdentityScreen(),
      ),
      GoRoute(
        path: Routes.kycPending,
        builder: (context, state) => const KycPendingScreen(),
      ),
      GoRoute(
        path: Routes.kycSuccess,
        builder: (context, state) => const KycSuccessScreen(),
      ),

      // ── Driver dashboard + order flow (no shell, Drawer-based) ──────
      GoRoute(
        path: Routes.dDashboard,
        builder: (context, state) => const DriverDashboardScreen(),
      ),
      GoRoute(
        path: Routes.dOrderIncoming,
        builder: (context, state) => const DriverIncomingScreen(),
      ),
      GoRoute(
        path: Routes.dOrderEnroute,
        builder: (context, state) => const DriverEnrouteScreen(),
      ),
      GoRoute(
        path: Routes.dOrderBoarding,
        builder: (context, state) => const DriverBoardingScreen(),
      ),
      GoRoute(
        path: Routes.dOrderActive,
        builder: (context, state) => const DriverActiveScreen(),
      ),
      GoRoute(
        path: Routes.dOrderSummary,
        builder: (context, state) => const DriverSummaryScreen(),
      ),
      GoRoute(
        path: Routes.dOrderRate,
        builder: (context, state) => const DriverOrderRateScreen(),
      ),
      GoRoute(
        path: Routes.dEarnings,
        builder: (context, state) => const DriverEarningsScreen(),
      ),
      GoRoute(
        path: Routes.dEarningsHistory,
        builder: (context, state) => const DriverDailyHistoryScreen(),
      ),
      GoRoute(
        path: Routes.dWallet,
        builder: (context, state) => const DriverWalletScreen(),
      ),
      GoRoute(
        path: Routes.dVehicles,
        builder: (context, state) => const DriverVehiclesScreen(),
      ),
      GoRoute(
        path: Routes.dReferral,
        builder: (context, state) => const DriverReferralScreen(),
      ),
      GoRoute(
        path: Routes.dProfile,
        builder: (context, state) => const DriverProfileScreen(),
      ),

      // ── Shared sections (reachable from the menu drawer) ────────────
      GoRoute(
        path: Routes.payment,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: Routes.paymentAdd,
        builder: (context, state) => const AddCardScreen(),
      ),
      GoRoute(
        path: Routes.paymentBinding,
        builder: (context, state) => const PaymentBindingScreen(),
      ),
      GoRoute(
        path: Routes.support,
        builder: (context, state) => const FaqHelpCenterScreen(),
      ),
      GoRoute(
        path: Routes.supportChat,
        builder: (context, state) => const SupportChatScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.settingsTheme,
        builder: (context, state) => const ThemeSelectionScreen(),
      ),
      GoRoute(
        path: Routes.settingsNotifications,
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: Routes.settingsPrivacy,
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: Routes.settingsAbout,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: Routes.settingsLegal,
        builder: (context, state) => const LegalSupportScreen(),
      ),

      // ── Passenger shell (BottomNav: Такси · История · Профиль) ──────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            PassengerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _passengerShellKey,
            routes: [
              GoRoute(
                path: Routes.pHome,
                builder: (context, state) => const HomeMapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.pHistory,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.pProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Bridges app flow providers to GoRouter's `refreshListenable`.
///
/// KYC is navigated explicitly by its screens; listening to the whole KYC state
/// here would refresh GoRouter on every IIN/document form edit.
class _RouterRefresh extends ChangeNotifier {
  final List<ProviderSubscription<dynamic>> _subs = [];

  _RouterRefresh(Ref ref) {
    _subs.add(ref.listen(authControllerProvider, (_, __) => notifyListeners()));
    _subs.add(ref.listen(rideControllerProvider, (_, __) => notifyListeners()));
    _subs.add(ref.listen(driverControllerProvider, (_, __) => notifyListeners()));
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.close();
    }
    super.dispose();
  }
}
