import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/accounts/account_session.dart';

/// User notification preferences (faked, persisted per account).
///
/// Shared between the settings hub quick toggles and the detailed screen.
class NotificationPrefs {
  final bool push;
  final bool sms;
  final bool email;
  final bool rides;
  final bool news;
  final bool ratings;

  const NotificationPrefs({
    this.push = true,
    this.sms = false,
    this.email = false,
    this.rides = true,
    this.news = true,
    this.ratings = true,
  });

  NotificationPrefs copyWith({
    bool? push,
    bool? sms,
    bool? email,
    bool? rides,
    bool? news,
    bool? ratings,
  }) {
    return NotificationPrefs(
      push: push ?? this.push,
      sms: sms ?? this.sms,
      email: email ?? this.email,
      rides: rides ?? this.rides,
      news: news ?? this.news,
      ratings: ratings ?? this.ratings,
    );
  }
}

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() => const NotificationPrefs();

  void restore(NotificationPrefs prefs) => state = prefs;

  void setPush(bool v) => _set(state.copyWith(push: v));
  void setSms(bool v) => _set(state.copyWith(sms: v));
  void setEmail(bool v) => _set(state.copyWith(email: v));
  void setRides(bool v) => _set(state.copyWith(rides: v));
  void setNews(bool v) => _set(state.copyWith(news: v));
  void setRatings(bool v) => _set(state.copyWith(ratings: v));

  void _set(NotificationPrefs next) {
    state = next;
    AccountSession.save(ref);
  }
}

final notificationPrefsControllerProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
  NotificationPrefsController.new,
);
