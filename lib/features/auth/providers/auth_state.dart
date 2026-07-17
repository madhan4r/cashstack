import 'package:equatable/equatable.dart';

import '../models/user.dart';

/// The app's authentication status. [routes] redirects purely off this.
enum AuthStatus {
  /// Startup, before we've checked whether a stored session is valid.
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  /// Set when [AuthStatus.unknown] and the session-restore check failed for
  /// a retryable reason (network error) rather than an invalid session.
  /// [SplashScreen] shows this with a retry action instead of silently
  /// falling through to Login.
  final String? restoreError;

  const AuthState._({required this.status, this.user, this.restoreError});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.restoreFailed(String message)
    : this._(status: AuthStatus.unknown, restoreError: message);

  const AuthState.authenticated(User user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user, restoreError];
}
