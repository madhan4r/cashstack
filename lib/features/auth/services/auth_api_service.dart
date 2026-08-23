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

  Future<UserDto> updateProfile({String? fullName, String? preferredCurrency}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/users/me',
        data: {'fullName': ?fullName, 'preferredCurrency': ?preferredCurrency},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw e.appException;
    }
  }

  Future<UserDto> uploadAvatar(String filePath) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/users/me/avatar',
        data: FormData.fromMap({
          // Explicit contentType rather than letting Dio guess one from the
          // file extension — the picker (see ProfileScreen) always
          // re-encodes to JPEG when resizing/compressing, but the cached
          // file path it hands back doesn't necessarily get a matching
          // ".jpg" extension, so extension-based sniffing can send the
          // wrong Content-Type and get rejected by the backend's mimetype
          // check even though the bytes are a perfectly valid JPEG.
          'avatar': await MultipartFile.fromFile(
            filePath,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        }),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw e.appException;
    }
  }

  Future<UserDto> removeAvatar() async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/users/me/avatar',
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw e.appException;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
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
