import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/network/auth_event_bus.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

/// Single source of truth for "is the user logged in". [routes] reads this
/// (via [authControllerProvider]) to decide whether to redirect to login.
///
/// Also listens to [AuthEventBus] so a refresh-token failure deep inside the
/// network layer (see [RefreshTokenInterceptor]) automatically flips the app
/// back to the unauthenticated state without every screen needing to know
/// about it.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final bus = ref.watch(authEventBusProvider);
    final subscription = bus.onSessionExpired.listen((_) => _forceLogout());
    ref.onDispose(subscription.cancel);

    _restoreSession();
    return const AuthState.unknown();
  }

  Future<void> _restoreSession() async {
    final repository = ref.read(authRepositoryProvider);

    final hasSession = await repository.hasStoredSession();
    if (!hasSession) {
      state = const AuthState.unauthenticated();
      return;
    }

    final result = await repository.getCurrentUser();
    state = result.when(
      ok: AuthState.authenticated,
      err: (failure) {
        // A network hiccup shouldn't sign the user out — offer a retry
        // instead. An actual invalid/expired session (401, or any other
        // definitive rejection) does sign them out.
        if (failure is NetworkFailure) {
          return AuthState.restoreFailed(failure.message);
        }
        return const AuthState.unauthenticated();
      },
    );
  }

  /// Re-runs the session-restore check after a [AuthState.restoreFailed].
  Future<void> retryRestoreSession() => _restoreSession();

  Future<Result<void>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    return result.when(
      ok: (user) {
        state = AuthState.authenticated(user);
        return const Result.ok(null);
      },
      err: (failure) => Result.err(failure),
    );
  }

  Future<Result<void>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
    return result.when(
      ok: (user) {
        state = AuthState.authenticated(user);
        return const Result.ok(null);
      },
      err: (failure) => Result.err(failure),
    );
  }

  Future<Result<void>> forgotPassword({required String email}) {
    final repository = ref.read(authRepositoryProvider);
    return repository.forgotPassword(email: email);
  }

  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) {
    final repository = ref.read(authRepositoryProvider);
    return repository.resetPassword(token: token, newPassword: newPassword);
  }

  Future<Result<void>> updatePreferredCurrency(String currencyCode) =>
      updateProfile(preferredCurrency: currencyCode);

  Future<Result<void>> updateProfile({
    String? fullName,
    String? preferredCurrency,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.updateProfile(
      fullName: fullName,
      preferredCurrency: preferredCurrency,
    );
    return result.when(
      ok: (user) {
        state = AuthState.authenticated(user);
        return const Result.ok(null);
      },
      err: (failure) => Result.err(failure),
    );
  }

  Future<Result<void>> uploadAvatar(String filePath) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.uploadAvatar(filePath);
    return result.when(
      ok: (user) {
        state = AuthState.authenticated(user);
        return const Result.ok(null);
      },
      err: (failure) => Result.err(failure),
    );
  }

  Future<Result<void>> removeAvatar() async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.removeAvatar();
    return result.when(
      ok: (user) {
        state = AuthState.authenticated(user);
        return const Result.ok(null);
      },
      err: (failure) => Result.err(failure),
    );
  }

  /// Changes the password, then signs the user out locally — the backend
  /// invalidates the refresh token on a successful change, so every
  /// session (including this one) needs to sign in again regardless.
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (result.isOk) {
      await repository.clearLocalSession();
      state = const AuthState.unauthenticated();
    }
    return result;
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AuthState.unauthenticated();
  }

  Future<void> _forceLogout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.clearLocalSession();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
