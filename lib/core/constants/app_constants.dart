/// Static, compile-time constants for the app. Runtime/environment-specific
/// values (like the API base URL) live in [AppConfig] instead.
class AppConstants {
  const AppConstants._();

  static const String appName = 'CashStack';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}

/// Keys used to persist values in secure storage. Centralized here so a typo
/// can't silently create a second, unrelated storage entry.
class StorageKeys {
  const StorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}
