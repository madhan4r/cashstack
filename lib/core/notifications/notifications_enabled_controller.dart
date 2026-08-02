import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/shared_preferences_provider.dart';
import 'notification_service.dart';

const _prefsKey = 'notifications_enabled';

/// Whether the user has opted into recurring-transaction reminders,
/// persisted on-device. `false` until they explicitly turn it on (and OS
/// permission is granted) — this is opt-in, not opt-out.
class NotificationsEnabledController extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_prefsKey) ?? false;
  }

  /// Turns reminders on: requests OS permission first, and only persists
  /// `true` if it's granted. Returns whether it ended up enabled.
  Future<bool> enable() async {
    final granted = await ref.read(notificationServiceProvider).requestPermission();
    if (!granted) return false;

    state = true;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_prefsKey, true);
    return true;
  }

  Future<void> disable() async {
    state = false;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_prefsKey, false);
    await ref.read(notificationServiceProvider).cancelAll();
  }
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledController, bool>(
      NotificationsEnabledController.new,
    );
