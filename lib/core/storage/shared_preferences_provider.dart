import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's [SharedPreferences] instance, for small, non-sensitive local
/// preferences (e.g. favorite/recent categories) — never for tokens, which
/// belong in [SecureStorageService].
///
/// Must be overridden in `main.dart` with a resolved instance before
/// `runApp` (see there); reading it before that override is a bug.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});
