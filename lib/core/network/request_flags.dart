/// Keys for [RequestOptions.extra], used to flag requests that need special
/// interceptor behavior.
class RequestFlags {
  const RequestFlags._();

  /// Skip attaching the access token / attempting a refresh on 401 for this
  /// request (login, register, refresh, forgot-password, etc).
  static const String skipAuth = 'skipAuth';

  /// Internal flag set by [RefreshTokenInterceptor] to mark a request that
  /// has already been retried once after a token refresh, preventing an
  /// infinite retry loop if the refreshed token is rejected too.
  static const String isRetry = 'isRetry';
}
