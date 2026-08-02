import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import '../../../core/storage/shared_preferences_provider.dart';

const _prefsKey = 'transaction_detection.enabled';

/// Whether the user has opted into Smart Transaction Detection (reading
/// bank notifications to suggest transactions), persisted on-device.
/// `false` until they explicitly enable it *and* grant the OS's
/// notification-access permission — this is opt-in, not opt-out, same as
/// the app-lock and reminder-notification toggles.
class SmartDetectionEnabledController extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_prefsKey) ?? false;
  }

  /// Opens the OS's "Notification access" settings page and waits for the
  /// user to grant it there (Android has no in-app permission dialog for
  /// this). Only persists `true` if it ends up granted.
  Future<bool> enable() async {
    final granted = await NotificationListenerService.requestPermission();
    if (!granted) return false;

    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_prefsKey, true);
    return true;
  }

  Future<void> disable() async {
    state = false;
    await ref.read(sharedPreferencesProvider).setBool(_prefsKey, false);
  }
}

final smartDetectionEnabledProvider =
    NotifierProvider<SmartDetectionEnabledController, bool>(
      SmartDetectionEnabledController.new,
    );
