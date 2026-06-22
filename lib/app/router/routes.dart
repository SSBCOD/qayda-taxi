/// Centralized route paths and names. Mirrors NAVIGATION.md.
class Routes {
  Routes._();

  // Auth (shared)
  static const String splash = '/splash';
  static const String language = '/language';
  static const String theme = '/theme';
  static const String welcome = '/welcome';
  static const String phone = '/auth/phone';
  static const String otp = '/auth/otp';
  static const String profileSetup = '/auth/profile-setup';
  static const String role = '/auth/role';

  // Driver KYC / onboarding
  static const String kycVehicle = '/kyc/vehicle';
  static const String kycIdentity = '/kyc/identity';
  static const String kycPending = '/kyc/pending';
  static const String kycSuccess = '/kyc/success';

  // Passenger shell
  static const String pHome = '/p/home';
  static const String pSearch = '/p/search';
  static const String pSetDestination = '/p/set-destination';
  static const String pRoute = '/p/route';
  static const String pTariff = '/p/tariff';
  static const String pRideWait = '/p/ride/wait';
  static const String pRideActive = '/p/ride/active';
  static const String pRideCompleted = '/p/ride/completed';
  static const String pRideRate = '/p/ride/rate';
  static const String pHistory = '/p/history';
  static const String pProfile = '/p/profile';
  static const String pFavorites = '/p/profile/favorites';
  static const String pPromotions = '/p/profile/promotions';

  // Driver shell
  static const String dDashboard = '/d/dashboard';
  static const String dOrderIncoming = '/d/order/incoming';
  static const String dOrderEnroute = '/d/order/enroute';
  static const String dOrderBoarding = '/d/order/boarding';
  static const String dOrderActive = '/d/order/active';
  static const String dOrderSummary = '/d/order/summary';
  static const String dOrderRate = '/d/order/rate';
  static const String dEarnings = '/d/earnings';
  static const String dEarningsHistory = '/d/earnings/history';
  static const String dWallet = '/d/wallet';
  static const String dVehicles = '/d/vehicles';
  static const String dReferral = '/d/referral';
  static const String dProfile = '/d/profile';

  // Shared sections
  static const String payment = '/payment';
  static const String paymentAdd = '/payment/add';
  static const String paymentBinding = '/payment/binding';
  static const String settings = '/settings';
  static const String settingsTheme = '/settings/theme';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsAbout = '/settings/about';
  static const String settingsLegal = '/settings/legal';
  static const String support = '/support';
  static const String supportChat = '/support/chat';
}
