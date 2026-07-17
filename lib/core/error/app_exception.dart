/// Exceptions thrown by data sources. Repositories catch these and translate
/// them into [Failure]s before returning a [Result] to the presentation
/// layer — the UI should never see a raw exception.
sealed class AppException implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  final int? statusCode;
  final List<String> errors;

  const ServerException({
    required super.message,
    this.statusCode,
    this.errors = const [],
  });
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection'});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Session expired'});
}

class ValidationException extends AppException {
  final List<String> errors;

  const ValidationException({required super.message, this.errors = const []});
}

/// Not a server/network failure — the request was intentionally cancelled
/// (e.g. the screen was disposed mid-request). Callers typically ignore it.
class CancelledException extends AppException {
  const CancelledException({super.message = 'Request cancelled'});
}
