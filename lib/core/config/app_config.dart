/// Environment-specific configuration, resolved at compile time via
/// `--dart-define`. Defaults to the hosted backend.
///
/// Example override (e.g. for local development):
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://cashstack.madhan.dev/api/v1',
  );

  /// [apiBaseUrl] without its `/api/v1` (or similar) suffix — the backend
  /// serves uploaded files (avatars, ...) as plain static assets at its
  /// origin (e.g. `/uploads/avatars/...`), not under the versioned API path.
  static String get apiOrigin {
    final uri = Uri.parse(apiBaseUrl);
    // `query: ''` (as opposed to omitting it) sets an explicit-but-empty
    // query component, so `Uri.toString()` renders a trailing "?" even
    // though there's nothing after it — e.g. "https://host?". Concatenating
    // "/uploads/avatars/x.jpg" onto that turns the whole path into part of
    // the query string, and the backend 404s on `GET /?/uploads/...`. Since
    // apiBaseUrl never has a query component to begin with, just clearing
    // path is enough.
    return uri.replace(path: '').toString();
  }

  static const bool enableNetworkLogging = bool.fromEnvironment(
    'ENABLE_NETWORK_LOGGING',
    defaultValue: true,
  );
}
