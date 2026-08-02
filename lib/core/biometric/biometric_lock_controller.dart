import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/shared_preferences_provider.dart';
import 'biometric_auth_service.dart';

const _prefsKey = 'biometric_lock_enabled';
const _unlockReason = 'Unlock CashStack';

/// Whether the user has opted into a biometric app lock, persisted
/// on-device. `false` until they explicitly turn it on (and an actual
/// biometric check succeeds) — opt-in, not opt-out.
class BiometricLockEnabledController extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_prefsKey) ?? false;
  }

  /// Turns the lock on: runs a real biometric check first so the user
  /// can't lock themselves out with something that doesn't actually work
  /// on their device. Only persists `true` if that check succeeds.
  Future<bool> enable() async {
    final verified = await ref
        .read(biometricAuthServiceProvider)
        .authenticate(reason: _unlockReason);
    if (!verified) return false;

    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_prefsKey, true);
    return true;
  }

  Future<void> disable() async {
    state = false;
    await ref.read(sharedPreferencesProvider).setBool(_prefsKey, false);
  }
}

final biometricLockEnabledProvider =
    NotifierProvider<BiometricLockEnabledController, bool>(
      BiometricLockEnabledController.new,
    );

/// Whether the app is currently unlocked for this run. Starts `false`
/// (locked) — [AppLockGate] flips it to `true` after a successful
/// biometric check, and re-locks whenever the app is backgrounded (see
/// its `didChangeAppLifecycleState`). Irrelevant while
/// [biometricLockEnabledProvider] is off — [AppLockGate] doesn't render
/// the lock screen at all in that case.
class AppUnlockedController extends Notifier<bool> {
  @override
  bool build() => false;

  void setUnlocked(bool value) => state = value;
}

final appUnlockedProvider = NotifierProvider<AppUnlockedController, bool>(
  AppUnlockedController.new,
);
