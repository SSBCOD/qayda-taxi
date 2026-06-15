import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/phone/kz_phone.dart';
import '../../../data/models/enums.dart';

/// In-memory authentication session for the MVP demo.
///
/// Mirrors the production `AuthRepository` contract (phone OTP → session →
/// role) but keeps everything local so the Auth flow plays end-to-end without
/// Firebase. The [RedirectGuard] reads this to gate the app:
///
///   not authenticated → /splash · authenticated & no role → /auth/role ·
///   otherwise → role-based home.
class AuthSession {
  final bool authenticated;
  final String? phone;
  final UserRole? role;

  const AuthSession({
    this.authenticated = false,
    this.phone,
    this.role,
  });

  bool get hasRole => role != null;

  AuthSession copyWith({bool? authenticated, String? phone, UserRole? role}) {
    return AuthSession(
      authenticated: authenticated ?? this.authenticated,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }
}

class AuthController extends Notifier<AuthSession> {
  /// Phone captured on the welcome screen, confirmed on OTP verification.
  String _pendingPhone = '';

  /// One-time code generated on [requestOtp] / [resendOtp].
  String _pendingOtp = '';

  final _random = Random();

  @override
  AuthSession build() => const AuthSession();

  /// Stores the phone, generates a fresh OTP and returns it so the UI can
  /// surface it in a local notification (mock SMS).
  String requestOtp(String phoneE164) {
    _pendingPhone = phoneE164;
    _pendingOtp = _generateOtp();
    state = state.copyWith(phone: phoneE164);
    return _pendingOtp;
  }

  /// Regenerates the OTP for the current pending phone (resend flow).
  String resendOtp() {
    if (_pendingPhone.isEmpty) return '';
    _pendingOtp = _generateOtp();
    return _pendingOtp;
  }

  /// Masked phone for the OTP screen subtitle.
  String get maskedPhone {
    final digits = _pendingPhone.replaceAll(RegExp(r'\D'), '');
    return KzPhone.mask(digits);
  }

  String get pendingPhone => _pendingPhone;

  String get debugOtp => _pendingOtp;

  /// Verifies the entered code. Returns `true` on success.
  bool verifyOtp(String code) {
    final ok = code == _pendingOtp;
    if (ok) {
      state = state.copyWith(authenticated: true, phone: _pendingPhone);
    }
    return ok;
  }

  /// Sets the role after sign-in (passenger / driver gate).
  void selectRole(UserRole role) => state = state.copyWith(role: role);

  /// Restores a saved role when the account snapshot is loaded.
  void restoreRole(UserRole role) => state = state.copyWith(role: role);

  void signOut() {
    _pendingPhone = '';
    _pendingOtp = '';
    state = const AuthSession();
  }

  String _generateOtp() {
    return List.generate(6, (_) => _random.nextInt(10)).join();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthSession>(AuthController.new);
