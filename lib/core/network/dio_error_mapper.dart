import 'package:dio/dio.dart';

import '../error/app_exception.dart';

/// Maps a raw [DioException] to a domain [AppException] with a
/// user-friendly message. Centralized so the HTTP-status-code /
/// connection-failure interpretation lives in exactly one place — screens
/// only ever see `failure.message`.
AppException mapDioExceptionToAppException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkException(
        message: 'The request timed out. Please try again.',
      );
    case DioExceptionType.connectionError:
      return const NetworkException(
        message: 'No internet connection. Please check your network and try again.',
      );
    case DioExceptionType.cancel:
      return const CancelledException();
    case DioExceptionType.badCertificate:
      return const NetworkException(
        message: 'Secure connection could not be verified.',
      );
    case DioExceptionType.badResponse:
      return _mapBadResponse(error);
    case DioExceptionType.unknown:
      return const NetworkException(
        message: 'No internet connection. Please check your network and try again.',
      );
  }
}

AppException _mapBadResponse(DioException error) {
  final statusCode = error.response?.statusCode;
  final data = error.response?.data;

  final (message, errors) = _extractMessageAndErrors(data);

  switch (statusCode) {
    case 400:
    case 422:
      return ValidationException(
        message: message ?? 'Please check your input and try again.',
        errors: errors,
      );
    case 401:
      return UnauthorizedException(message: message ?? 'Session expired. Please log in again.');
    case 403:
      return ServerException(
        message: message ?? "You don't have permission to do that.",
        statusCode: statusCode,
        errors: errors,
      );
    case 404:
      return ServerException(
        message: message ?? 'The requested resource could not be found.',
        statusCode: statusCode,
        errors: errors,
      );
    default:
      if (statusCode != null && statusCode >= 500) {
        return ServerException(
          message: message ?? 'Something went wrong on our end. Please try again shortly.',
          statusCode: statusCode,
          errors: errors,
        );
      }
      return ServerException(
        message: message ?? 'Something went wrong. Please try again.',
        statusCode: statusCode,
        errors: errors,
      );
  }
}

(String?, List<String>) _extractMessageAndErrors(Object? data) {
  if (data is! Map) {
    return (null, const []);
  }

  final message = data['message'];
  final rawErrors = data['errors'];

  final errors = switch (rawErrors) {
    List<dynamic> list => list.map((e) => e.toString()).toList(),
    String single => [single],
    _ => const <String>[],
  };

  return (message is String ? message : null, errors);
}
