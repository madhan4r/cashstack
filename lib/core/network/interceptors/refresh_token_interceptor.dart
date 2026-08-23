import 'dart:async';

import 'package:dio/dio.dart';

import '../../storage/secure_storage_service.dart';
import '../auth_event_bus.dart';
import '../request_flags.dart';

/// On a 401 response, attempts to refresh the access token exactly once and
/// retries the original request. If a refresh is already in flight, other
/// failed requests wait for it instead of triggering their own (a "single
/// flight" refresh) — otherwise N concurrent 401s would fire N refresh
/// calls, and only the first would actually succeed (refresh tokens are
/// rotated and single-use).
///
/// If the refresh itself fails, tokens are cleared and [AuthEventBus] is
/// notified so the app can navigate back to the login screen.
class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  final AuthEventBus _authEventBus;
  final String _refreshPath;

  Completer<bool>? _refreshCompleter;

  RefreshTokenInterceptor({
    required this._dio,
    required this._storage,
    required this._authEventBus,
    this._refreshPath = '/auth/refresh',
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final skipAuth = requestOptions.extra[RequestFlags.skipAuth] == true;
    final alreadyRetried = requestOptions.extra[RequestFlags.isRetry] == true;

    if (!isUnauthorized || skipAuth || alreadyRetried) {
      return handler.next(err);
    }

    final refreshed = await _refreshTokenSingleFlight();

    if (!refreshed) {
      await _storage.clearTokens();
      _authEventBus.emitSessionExpired();
      return handler.next(err);
    }

    try {
      final accessToken = await _storage.getAccessToken();
      final retryOptions = requestOptions.copyWith(
        extra: {...requestOptions.extra, RequestFlags.isRetry: true},
      );
      retryOptions.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _dio.fetch(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  Future<bool> _refreshTokenSingleFlight() {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;
    _performRefresh().then(completer.complete).whenComplete(() {
      _refreshCompleter = null;
    });

    return completer.future;
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _refreshPath,
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
          extra: {RequestFlags.skipAuth: true},
        ),
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (newAccessToken == null || newRefreshToken == null) {
        return false;
      }

      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
