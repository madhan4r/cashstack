import 'package:dio/dio.dart';

import '../dio_error_mapper.dart';

/// Normalizes every [DioException] into a domain [AppException], attached
/// via [DioException.error]. Runs last so [RefreshTokenInterceptor] gets a
/// chance to resolve 401s before this maps the (now-final) error.
///
/// Data sources should read the mapped exception via the
/// `DioExceptionX.appException` extension instead of re-deriving it from
/// the status code themselves.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = mapDioExceptionToAppException(err);
    handler.next(err.copyWith(error: mapped));
  }
}
