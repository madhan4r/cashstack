import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around [LocalAuthentication] scoped to this app's single
/// use case: an app-open unlock gate. Nothing outside this file should
/// touch the plugin directly.
class BiometricAuthService {
  final LocalAuthentication _auth;

  BiometricAuthService(this._auth);

  /// Whether the device can do biometric (or device-credential) auth at
  /// all — check before offering the Settings toggle.
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompts for biometric/device-credential auth. Returns `true` only on
  /// a genuine success — a failed attempt, cancellation, or plugin error
  /// (e.g. no biometrics enrolled) all return `false` rather than
  /// throwing, since callers treat "still locked" as the uniform result.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(LocalAuthentication());
});

/// Whether this device can do biometric/device-credential auth at all —
/// the Settings screen uses this to decide whether to offer the toggle.
final biometricAvailableProvider = FutureProvider<bool>((ref) {
  return ref.watch(biometricAuthServiceProvider).isAvailable();
});
