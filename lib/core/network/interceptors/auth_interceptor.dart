import 'package:dio/dio.dart';

import '../../storage/secure_storage_service.dart';
import '../request_flags.dart';

/// Attaches the current access token to every outgoing request, unless the
/// request was explicitly marked as public via [RequestFlags.skipAuth].
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[RequestFlags.skipAuth] == true) {
      return handler.next(options);
    }

    final accessToken = await _storage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}
