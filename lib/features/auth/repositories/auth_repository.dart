import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../dtos/dtos.dart';
import '../models/user.dart';
import '../services/auth_api_service.dart';

/// Presentation layer entry point for everything auth-related. Talks to
/// [AuthApiService], maps DTOs to domain [User]s, and persists tokens on
/// success — the UI/controller layer never touches [SecureStorageService],
/// [AuthApiService], or a DTO directly.
class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _storage;

  const AuthRepository(this._apiService, this._storage);

  Future<Result<User>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.register(
        RegisterRequestDto(fullName: fullName, email: email, password: password),
      );
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Result.ok(response.user.toDomain());
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<User>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final response = await _apiService.login(
        LoginRequestDto(email: email, password: password),
      );
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        remember: rememberMe,
      );
      return Result.ok(response.user.toDomain());
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<void>> forgotPassword({required String email}) async {
    try {
      await _apiService.forgotPassword(ForgotPasswordRequestDto(email: email));
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiService.resetPassword(
        ResetPasswordRequestDto(token: token, newPassword: newPassword),
      );
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  /// Fetches the current user using the persisted session, used on app
  /// startup to decide whether the stored token is still valid.
  Future<Result<User>> getCurrentUser() async {
    try {
      final user = await _apiService.getCurrentUser();
      return Result.ok(user.toDomain());
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<User>> updateProfile({
    String? fullName,
    String? preferredCurrency,
  }) async {
    try {
      final user = await _apiService.updateProfile(
        fullName: fullName,
        preferredCurrency: preferredCurrency,
      );
      return Result.ok(user.toDomain());
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<bool> hasStoredSession() => _storage.hasValidSession();

  /// Logs out locally (always) and best-effort notifies the backend so the
  /// refresh token is invalidated server-side too.
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {
      // Local logout must succeed even if the network call fails/we're
      // offline — the tokens are cleared below regardless.
    } finally {
      await _storage.clearTokens();
    }
  }

  /// Clears the local session without calling the backend. Used when the
  /// refresh token itself has already expired (see [AuthEventBus]).
  Future<void> clearLocalSession() => _storage.clearTokens();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authApiServiceProvider),
    ref.watch(secureStorageServiceProvider),
  );
});
