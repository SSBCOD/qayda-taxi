import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/phone/kz_phone.dart';
import '../../../data/models/enums.dart';
import '../../../services/storage/prefs_service.dart';

class AuthSession {
  final bool authenticated;
  final String? phone;
  final UserRole? role;
  final String firstName;
  final String lastName;
  final String email;

  const AuthSession({
    this.authenticated = false,
    this.phone,
    this.role,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
  });

  bool get hasRole => role != null;
  bool get hasProfile => firstName.trim().isNotEmpty;
  String get displayName {
    final l = lastName.trim();
    return l.isEmpty ? firstName.trim() : '${firstName.trim()} $l';
  }

  AuthSession copyWith({
    bool? authenticated,
    String? phone,
    UserRole? role,
    String? firstName,
    String? lastName,
    String? email,
  }) {
    return AuthSession(
      authenticated: authenticated ?? this.authenticated,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
    );
  }
}

class AuthController extends Notifier<AuthSession> {
  static const _kFirst = 'profile_first_name';
  static const _kLast  = 'profile_last_name';
  static const _kEmail = 'profile_email';

  String _pendingPhone = '';
  String _pendingOtp   = '';
  final _random = Random();

  @override
  AuthSession build() {
    // Restore profile from SharedPreferences synchronously on every build.
    final prefs = ref.read(prefsServiceProvider);
    return AuthSession(
      firstName: prefs.getString(_kFirst) ?? '',
      lastName:  prefs.getString(_kLast)  ?? '',
      email:     prefs.getString(_kEmail) ?? '',
    );
  }

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

  String requestOtp(String phoneE164) {
    _pendingPhone = phoneE164;
    _pendingOtp   = _generateOtp();
    state = state.copyWith(phone: phoneE164);
    return _pendingOtp;
  }

  String resendOtp() {
    if (_pendingPhone.isEmpty) return '';
    _pendingOtp = _generateOtp();
    return _pendingOtp;
  }

  String get maskedPhone {
    final digits = _pendingPhone.replaceAll(RegExp(r'\D'), '');
    return KzPhone.mask(digits);
  }

  String get pendingPhone  => _pendingPhone;
  String get debugOtp      => _pendingOtp;

  bool verifyOtp(String code) {
    final ok = code == _pendingOtp;
    if (ok) state = state.copyWith(authenticated: true, phone: _pendingPhone);
    return ok;
  }

  void selectRole(UserRole role) => state = state.copyWith(role: role);
  void restoreRole(UserRole role) => state = state.copyWith(role: role);

  void signOut() {
    _pendingPhone = '';
    _pendingOtp   = '';
    // Keep firstName/lastName/email — user shouldn't re-enter profile on next login.
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
