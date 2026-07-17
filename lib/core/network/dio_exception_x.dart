import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import 'dio_error_mapper.dart';

/// Data sources should use this instead of re-deriving an [AppException]
/// from status codes themselves — [ErrorInterceptor] already did that work.
extension DioExceptionX on DioException {
  AppException get appException {
    final mapped = error;
    return mapped is AppException ? mapped : mapDioExceptionToAppException(this);
  }
}
