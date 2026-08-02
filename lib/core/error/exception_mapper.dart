import 'app_exception.dart';
import 'failure.dart';

/// Translates a caught error (an [AppException] from a data source, or
/// anything unexpected) into a [Failure] for the presentation layer.
///
/// Idempotent: every repository already calls this once (wrapping
/// `e.appException`) before throwing, so the thing a controller's `catch`
/// block actually receives is a [Failure], not the original [AppException]
/// — passing it back through here a second time must return it unchanged,
/// not fall through to [UnknownFailure] and silently discard the real
/// message (e.g. "Current password is incorrect" becoming "Something went
/// wrong").
Failure mapExceptionToFailure(Object error) {
  if (error is Failure) return error;

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
