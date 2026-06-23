import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Phone Auth for both mobile and web.
///
/// On web: uses invisible reCAPTCHA (no UI needed).
/// On Android/iOS: Firebase auto-reads the SMS.
class FirebaseAuthService {
  FirebaseAuthService._();
  static final _auth = FirebaseAuth.instance;

  // Web: holds the ConfirmationResult after sendOtp.
  static ConfirmationResult? _webConfirmation;

  /// Sends an OTP to [phoneE164] (e.g. "+77471234567").
  /// Returns null on success, or an error message string.
  static Future<String?> sendOtp({
    required String phoneE164,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    try {
      if (kIsWeb) {
        // Web: signInWithPhoneNumber uses invisible reCAPTCHA automatically.
        _webConfirmation = await _auth.signInWithPhoneNumber(phoneE164);
        onCodeSent(_webConfirmation!.verificationId);
        return null;
      }

      // Mobile (Android / iOS).
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneE164,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          // Android auto-completes — sign in immediately.
          _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) => onError(e),
        codeSent: (String verificationId, int? resendToken) =>
            onCodeSent(verificationId),
        codeAutoRetrievalTimeout: (_) {},
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Ошибка отправки кода';
    }
  }

  /// Verifies the [smsCode] against [verificationId] (mobile)
  /// or the stored ConfirmationResult (web).
  /// Returns the Firebase UID on success, null on failure.
  static Future<String?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      UserCredential cred;
      if (kIsWeb && _webConfirmation != null) {
        cred = await _webConfirmation!.confirm(smsCode);
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        cred = await _auth.signInWithCredential(credential);
      }
      return cred.user?.uid;
    } on FirebaseAuthException {
      return null;
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;
}
