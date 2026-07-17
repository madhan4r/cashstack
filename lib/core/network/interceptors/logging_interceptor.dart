import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Logs requests/responses/errors via `dart:developer` (visible in
/// DevTools/IDE logs, stripped from release console noise) rather than
/// `print`. Only registered when [AppConfig.enableNetworkLogging] is true.
class LoggingInterceptor extends Interceptor {
  static const _name = 'CashStack.Network';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '--> ${options.method} ${options.uri}',
      name: _name,
    );
    if (options.data != null) {
      developer.log('Body: ${options.data}', name: _name);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.uri}',
      name: _name,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}',
      name: _name,
      level: 1000,
    );
    handler.next(err);
  }
}
