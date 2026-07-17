import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_event_bus.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';

/// Builds the single [Dio] instance used by every repository.
///
/// Interceptor order matters: auth (attach token) → refresh (retry on 401,
/// runs before the error interceptor so it can resolve the request instead
/// of surfacing an error) → error mapping (always runs last so it maps
/// whatever error, if any, remains) → logging (observes everything).
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final authEventBus = ref.watch(authEventBusProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      contentType: 'application/json',
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage),
    RefreshTokenInterceptor(
      dio: dio,
      storage: storage,
      authEventBus: authEventBus,
    ),
    ErrorInterceptor(),
    if (AppConfig.enableNetworkLogging) LoggingInterceptor(),
  ]);

  return dio;
});
