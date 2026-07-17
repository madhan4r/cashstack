import 'package:equatable/equatable.dart';

/// Domain-level representation of "something went wrong", returned by
/// repositories instead of throwing. Keeping this in the domain layer (not
/// Dio-specific) means the presentation layer never has to know about HTTP.
sealed class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// The request reached the server but it responded with an error status.
class ServerFailure extends Failure {
  final int? statusCode;
  final List<String> errors;

  const ServerFailure({
    required super.message,
    this.statusCode,
    this.errors = const [],
  });

  @override
  List<Object?> get props => [message, statusCode, errors];
}

/// No usable connection (offline, DNS failure, timeout before a response).
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// The access token was rejected/expired and the refresh attempt also
/// failed. The caller should treat this as "log the user out".
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Session expired'});
}

/// Request payload failed validation (surfaces field-level errors).
class ValidationFailure extends Failure {
  final List<String> errors;

  const ValidationFailure({required super.message, this.errors = const []});

  @override
  List<Object?> get props => [message, errors];
}

/// Anything that doesn't fit the categories above.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Something went wrong'});
}

/// The request was intentionally cancelled. Callers generally ignore this
/// rather than showing it as an error to the user.
class CancelledFailure extends Failure {
  const CancelledFailure({super.message = 'Request cancelled'});
}
