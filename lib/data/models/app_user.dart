import 'enums.dart';

/// Authenticated Qayda account (see `docs/models.md` § User).
///
/// Maps to Firestore `/users/{uid}` in production; the MVP may hydrate this
/// from local session data after phone OTP sign-in.
class AppUser {
  final String id;
  final String phone;
  final String? fullName;
  final String? iin;
  final bool iinVerified;
  final String? photoUrl;
  final UserRole role;
  final String locale;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.phone,
    this.fullName,
    this.iin,
    this.iinVerified = false,
    this.photoUrl,
    required this.role,
    this.locale = 'ru',
    required this.createdAt,
  });

  /// Preferred name for UI headers; falls back to phone when unset.
  String get displayName =>
      fullName?.trim().isNotEmpty == true ? fullName! : phone;

  bool get isPassenger => role == UserRole.passenger;

  bool get isDriver => role == UserRole.driver;

  AppUser copyWith({
    String? id,
    String? phone,
    String? fullName,
    bool clearFullName = false,
    String? iin,
    bool clearIin = false,
    bool? iinVerified,
    String? photoUrl,
    bool clearPhotoUrl = false,
    UserRole? role,
    String? locale,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: clearFullName ? null : (fullName ?? this.fullName),
      iin: clearIin ? null : (iin ?? this.iin),
      iinVerified: iinVerified ?? this.iinVerified,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      role: role ?? this.role,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'fullName': fullName,
        'iin': iin,
        'iinVerified': iinVerified,
        'photoUrl': photoUrl,
        'role': role.name,
        'locale': locale,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      fullName: json['fullName'] as String?,
      iin: json['iin'] as String?,
      iinVerified: json['iinVerified'] as bool? ?? false,
      photoUrl: json['photoUrl'] as String?,
      role: _parseRole(json['role'] as String?),
      locale: json['locale'] as String? ?? 'ru',
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static UserRole _parseRole(String? raw) {
    if (raw != null) {
      for (final role in UserRole.values) {
        if (role.name == raw) return role;
      }
    }
    return UserRole.passenger;
  }

  static DateTime _parseDateTime(Object? raw) {
    if (raw is String) return DateTime.parse(raw);
    if (raw is DateTime) return raw;
    return DateTime.now();
  }
}
