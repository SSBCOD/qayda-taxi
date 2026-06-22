import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/enums.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;

  const UserProfile({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
  });

  bool get hasName => firstName.trim().isNotEmpty;

  String get displayName {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty) return '';
    return l.isEmpty ? f : '$f $l';
  }

  UserProfile copyWith({String? firstName, String? lastName, String? email}) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
    );
  }
}

class UserProfileController extends AsyncNotifier<UserProfile> {
  static const _kFirst = 'profile_first_name';
  static const _kLast = 'profile_last_name';
  static const _kEmail = 'profile_email';

  @override
  Future<UserProfile> build() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      firstName: prefs.getString(_kFirst) ?? '',
      lastName: prefs.getString(_kLast) ?? '',
      email: prefs.getString(_kEmail) ?? '',
    );
  }

  Future<void> save({
    required String firstName,
    required String lastName,
    String email = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFirst, firstName.trim());
    await prefs.setString(_kLast, lastName.trim());
    await prefs.setString(_kEmail, email.trim());
    state = AsyncData(UserProfile(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
    ));
  }

  Future<void> updateEmail(String email) async {
    final current = state.valueOrNull ?? const UserProfile();
    await save(
      firstName: current.firstName,
      lastName: current.lastName,
      email: email,
    );
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileController, UserProfile>(
  UserProfileController.new,
);

/// Role pre-selected on the welcome screen — passed to OtpScreen.
final selectedRoleProvider =
    StateProvider<UserRole>((ref) => UserRole.passenger);
