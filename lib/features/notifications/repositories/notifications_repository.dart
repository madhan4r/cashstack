import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/app_notification.dart';

/// Talks to `/notifications`. Throws a [Failure] (never a raw exception) so
/// callers can surface it directly.
class NotificationsRepository {
  final Dio _dio;

  const NotificationsRepository(this._dio);

  Future<PaginatedResponse<AppNotification>> getNotifications({
    int page = 1,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications',
        queryParameters: {'page': page},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => AppNotification.fromJson(item),
        ),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications/unread-count',
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as Map<String, dynamic>)['count'] as int,
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.post('/notifications/read-all');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  /// A category absent from the returned map is enabled by default.
  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/notification-preferences',
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as bool),
        ),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  /// Merges [updates] into the stored preferences — only the categories
  /// present are changed.
  Future<Map<String, bool>> updateNotificationPreferences(
    Map<String, bool> updates,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/users/me/notification-preferences',
        data: {'preferences': updates},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as bool),
        ),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(dioProvider));
});
