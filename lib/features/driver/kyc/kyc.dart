/// Driver KYC / onboarding feature.
///
/// Flow: vehicle details → identity verification → pending → success
/// (routes `/kyc/*`). State lives in `application/kyc_controller.dart`.
library;

export 'application/kyc_controller.dart';
export 'kyc_identity_screen.dart';
export 'kyc_pending_screen.dart';
export 'kyc_success_screen.dart';
export 'kyc_vehicle_screen.dart';
