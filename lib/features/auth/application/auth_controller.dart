import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/phone/kz_phone.dart';
import '../../../data/models/enums.dart';
import '../../../services/auth/firebase_auth_service.dart';
import '../../../services/storage/prefs_service.dart';

class AuthSession {
  final bool authenticated;
  final String? phone;
  final UserRole? role;
  final String firstName;
  final String lastName;
  final String email;
  final String? firebaseUid;

  const AuthSession({
    this.authenticated = false,
    this.phone,
    this.role,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.firebaseUid,
  });

  bool get hasRole    => role != null;
  bool get hasProfile => firstName.trim().isNotEmpty;

  String get displayName {
    final l = lastName.trim();
    return l.isEmpty ? firstName.trim() : '${firstName.trim()} $l';
  }

  AuthSession copyWith({
    bool?     authenticated,
    String?   phone,
    UserRole? role,
    String?   firstName,
    String?   lastName,
    String?   email,
    String?   firebaseUid,
  }) => AuthSession(
    authenticated: authenticated ?? this.authenticated,
    phone:         phone         ?? this.phone,
    role:          role          ?? this.role,
    firstName:     firstName     ?? this.firstName,
    lastName:      lastName      ?? this.lastName,
    email:         email         ?? this.email,
    firebaseUid:   firebaseUid   ?? this.firebaseUid,
  );
}

class AuthController extends Notifier<AuthSession> {
  static const _kFirst = 'profile_first_name';
  static const _kLast  = 'profile_last_name';
  static const _kEmail = 'profile_email';

  String _pendingPhone = '';
  String _pendingOtp   = '';          // used only in mock/debug mode
  String _verificationId = '';        // Firebase web/mobile
  final _random = Random();

  // Use Firebase on web/mobile; fall back to mock on Windows & pure debug.
  static bool get _useFirebase =>
      !(!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.windows);

  @override
  AuthSession build() {
    final prefs = ref.read(prefsServiceProvider);
    return AuthSession(
      firstName: prefs.getString(_kFirst) ?? '',
      lastName:  prefs.getString(_kLast)  ?? '',
      email:     prefs.getString(_kEmail) ?? '',
    );
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    String email = '',
    UserRole? role,
  }) async {
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setString(_kFirst, firstName.trim());
    await prefs.setString(_kLast,  lastName.trim());
    await prefs.setString(_kEmail, email.trim());
    state = state.copyWith(
      firstName: firstName.trim(),
      lastName:  lastName.trim(),
      email:     email.trim(),
      role:      role ?? state.role,
    );
  }

  // ── OTP ───────────────────────────────────────────────────────────────────

  /// Sends an OTP. Returns the mock code on debug/Windows (show to user),
  /// or null on Firebase (real SMS sent).
  Future<String?> requestOtp(String phoneE164) async {
    _pendingPhone = phoneE164;
    state = state.copyWith(phone: phoneE164);

    if (!_useFirebase) {
      // Mock mode (Windows desktop / debug).
      _pendingOtp = _generateOtp();
      debugPrint('[OTP-MOCK] Code for $phoneE164: $_pendingOtp');
      return _pendingOtp;
    }

    // Firebase mode.
    _pendingOtp = '';
    final error = await FirebaseAuthService.sendOtp(
      phoneE164: phoneE164,
      onCodeSent: (vid) => _verificationId = vid,
      onError: (e) => debugPrint('[Firebase Auth Error] ${e.message}'),
    );
    if (error != null) debugPrint('[OTP Error] $error');
    return null; // real SMS sent — no code to show
  }

  String resendOtp() {
    if (_pendingPhone.isEmpty) return '';
    if (!_useFirebase) {
      _pendingOtp = _generateOtp();
      return _pendingOtp;
    }
    // Re-trigger Firebase (fire-and-forget).
    requestOtp(_pendingPhone);
    return '';
  }

  /// Verifies the entered [code]. Returns true on success.
  Future<bool> verifyOtp(String code) async {
    if (!_useFirebase) {
      // Mock verification.
      final ok = code == _pendingOtp;
      if (ok) state = state.copyWith(authenticated: true, phone: _pendingPhone);
      return ok;
    }

    // Firebase verification.
    final uid = await FirebaseAuthService.verifyOtp(
      verificationId: _verificationId,
      smsCode: code,
    );
    if (uid == null) return false;
    state = state.copyWith(
      authenticated: true,
      phone: _pendingPhone,
      firebaseUid: uid,
    );
    return true;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get maskedPhone {
    final digits = _pendingPhone.replaceAll(RegExp(r'\D'), '');
    return KzPhone.mask(digits);
  }

  String get pendingPhone => _pendingPhone;

  /// Debug-only: returns the mock OTP (empty when Firebase is active).
  String get debugOtp => _pendingOtp;

  void selectRole(UserRole role)  => state = state.copyWith(role: role);
  void restoreRole(UserRole role) => state = state.copyWith(role: role);

  void signOut() {
    _pendingPhone    = '';
    _pendingOtp      = '';
    _verificationId  = '';
    if (_useFirebase) FirebaseAuthService.signOut();
    state = AuthSession(
      firstName: state.firstName,
      lastName:  state.lastName,
      email:     state.email,
    );
  }

  String _generateOtp() =>
      List.generate(6, (_) => _random.nextInt(10)).join();
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthSession>(AuthController.new);
