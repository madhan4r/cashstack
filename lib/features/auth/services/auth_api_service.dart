import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../core/network/request_flags.dart';
import '../../../shared/models/api_response.dart';
import '../dtos/dtos.dart';

/// Talks to the `/auth` and `/users/me` endpoints — the only place in the
/// app that touches [Dio] for authentication. Throws [AppException] (never
/// a raw [DioException]) so [AuthRepository] doesn't need to know about
/// Dio at all.
class AuthApiService {
  final Dio _dio;

  const AuthApiService(this._dio);

  Future<AuthResponseDto> register(RegisterRequestDto request) {
    return _postAuth('/auth/register', request.toJson());
  }

  Future<AuthResponseDto> login(LoginRequestDto request) {
    return _postAuth('/auth/login', request.toJson());
  }

  Future<void> forgotPassword(ForgotPasswordRequestDto request) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: request.toJson(),
        options: Options(extra: {RequestFlags.skipAuth: true}),
      );
    } on DioException catch (e) {
      throw e.appException;
    }
  }

  Future<void> resetPassword(ResetPasswordRequestDto request) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: request.toJson(),
        options: Options(extra: {RequestFlags.skipAuth: true}),
      );
    } on DioException catch (e) {
      throw e.appException;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw e.appException;
    }
  }

  Future<UserDto> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/users/me');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw e.appException;
    }
  }

  Future<AuthResponseDto> _postAuth(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(extra: {RequestFlags.skipAuth: true}),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => AuthResponseDto.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw e.appException;
    }
  }
}

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(dioProvider));
});
