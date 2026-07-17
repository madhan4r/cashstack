import 'app_exception.dart';
import 'failure.dart';

/// Translates a caught error (an [AppException] from a data source, or
/// anything unexpected) into a [Failure] for the presentation layer.
Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    ServerException(:final message, :final statusCode, :final errors) =>
      ServerFailure(message: message, statusCode: statusCode, errors: errors),
    NetworkException(:final message) => NetworkFailure(message: message),
    UnauthorizedException(:final message) => UnauthorizedFailure(
      message: message,
    ),
    ValidationException(:final message, :final errors) => ValidationFailure(
      message: message,
      errors: errors,
    ),
    CancelledException(:final message) => CancelledFailure(message: message),
    _ => const UnknownFailure(),
  };
}
