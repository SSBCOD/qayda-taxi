import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/enums.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/driver/dashboard/application/driver_controller.dart';
import '../../features/driver/kyc/application/kyc_controller.dart';
import '../../features/driver/vehicles/application/driver_vehicles_providers.dart';
import '../../features/driver/wallet/application/driver_wallet_providers.dart';
import '../../features/passenger/history/application/history_providers.dart';
import '../../features/passenger/profile/application/favorites_controller.dart';
import '../../features/payment/application/payment_controller.dart';
import '../../features/settings/application/notification_prefs_controller.dart';
import '../../data/models/payment_method.dart';
import '../../app/router/routes.dart';
import '../../core/theme/theme_controller.dart';
import 'account_repository.dart';
import 'account_serializers.dart';

/// Loads and saves per-account snapshots across Riverpod controllers.
class AccountSession {
  AccountSession._();

  /// Restores all account-bound state after OTP verification.
  static void restore(WidgetRef ref, String phoneE164) {
    _restore(ref, phoneE164);
  }

  static void _restore(dynamic ref, String phoneE164) {
    final data = ref.read(accountRepositoryProvider).loadOrCreate(phoneE164);

    if (data.role != null) {
      ref.read(authControllerProvider.notifier).restoreRole(data.role!);
    }

    ref.read(kycControllerProvider.notifier).restore(
          AccountSerializers.kycFromJson(data.kyc),
        );
    ref.read(paymentControllerProvider.notifier).restore(
          methods:
              AccountSerializers.paymentMethodsFromJson(data.paymentMethods),
          selectedId: data.selectedPaymentId,
        );
    ref.read(notificationPrefsControllerProvider.notifier).restore(
          AccountSerializers.notificationPrefsFromJson(data.notificationPrefs),
        );
    ref.read(themeControllerProvider.notifier).restore(data.themeMode);
    ref.read(favoritesControllerProvider.notifier).restore(
          AccountSerializers.favoritesFromJson(data.favorites),
        );
    ref.read(tripHistoryControllerProvider.notifier).restore(
          AccountSerializers.tripHistoryFromJson(data.tripHistory),
        );
    ref.read(driverControllerProvider.notifier).restoreProfile(
          earningsToday: data.driverEarningsToday,
          tripsToday: data.driverTripsToday,
          rating: data.driverRating,
        );
    ref.read(driverWalletBalanceProvider.notifier).restore(data.walletBalance);
    ref
        .read(activeDriverVehicleIdProvider.notifier)
        .restore(data.activeVehicleId);
  }

  /// Persists the active account snapshot (call before sign-out / on changes).
  ///
  /// [phone] and [role] overrides are used when saving during sign-out (the
  /// auth session is already cleared but controller state is still intact).
  static void save(
    dynamic ref, {
    String? phone,
    UserRole? role,
    KycState? kycState,
    ThemeMode? themeMode,
    List<PaymentMethod>? paymentMethods,
    String? selectedPaymentId,
  }) {
    final auth = ref.read(authControllerProvider);
    final effectivePhone = phone ?? auth.phone;
    if (effectivePhone == null) return;

    final effectiveRole = role ?? auth.role;
    final existing =
        ref.read(accountRepositoryProvider).loadOrCreate(effectivePhone);

    final PaymentState? payment = (paymentMethods == null || selectedPaymentId == null)
        ? ref.read(paymentControllerProvider)
        : null;
    final data = existing.copyWith(
      role: effectiveRole,
      clearRole: effectiveRole == null,
      kyc: AccountSerializers.kycToJson(
        kycState ?? ref.read(kycControllerProvider),
      ),
      paymentMethods: AccountSerializers.paymentMethodsToJson(
        paymentMethods ?? payment!.methods,
      ),
      selectedPaymentId: selectedPaymentId ?? payment!.selectedId,
      notificationPrefs: AccountSerializers.notificationPrefsToJson(
        ref.read(notificationPrefsControllerProvider),
      ),
      themeMode: _themeModeToJson(themeMode ?? ref.read(themeControllerProvider)),
      favorites: AccountSerializers.favoritesToJson(
        ref.read(favoritesControllerProvider),
      ),
      tripHistory: AccountSerializers.tripHistoryToJson(
        ref.read(tripHistoryControllerProvider),
      ),
      driverEarningsToday: ref.read(driverControllerProvider).earningsToday,
      driverTripsToday: ref.read(driverControllerProvider).tripsToday,
      driverRating: ref.read(driverControllerProvider).rating,
      walletBalance: ref.read(driverWalletBalanceProvider),
      activeVehicleId: ref.read(activeDriverVehicleIdProvider),
    );

    ref.read(accountRepositoryProvider).save(data);
  }

  /// First KYC screen for a driver who is not yet verified.
  static String driverKycEntryRoute(VerificationStatus status) {
    return switch (status) {
      VerificationStatus.verified => Routes.dDashboard,
      VerificationStatus.pending => Routes.kycPending,
      _ => Routes.kycVehicle,
    };
  }

  /// Home route for a restored session (role + KYC aware).
  static String homeRouteFor(WidgetRef ref) {
    final auth = ref.read(authControllerProvider);
    if (auth.role == UserRole.driver) {
      return driverKycEntryRoute(ref.read(kycControllerProvider).status);
    }
    return Routes.pHome;
  }

  static String _themeModeToJson(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
