import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/history_occurrence.dart';
import '../models/occurrence_status.dart';
import '../models/recurring_filter.dart';
import '../models/recurring_form_data.dart';
import '../models/recurring_transaction.dart';
import '../models/upcoming_occurrence.dart';

/// Talks to `/recurring-transactions`. Throws a [Failure] (never a raw
/// exception) so callers can surface it directly.
class RecurringRepository {
  final Dio _dio;

  const RecurringRepository(this._dio);

  Future<List<RecurringTransaction>> getRecurring(RecurringFilter filter) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/recurring-transactions',
        queryParameters: filter.toQueryParameters(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => RecurringTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<RecurringTransaction> getRecurringOne(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/recurring-transactions/$id');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => RecurringTransaction.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<RecurringTransaction> createRecurring(RecurringFormData data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/recurring-transactions',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => RecurringTransaction.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<RecurringTransaction> updateRecurring(String id, RecurringFormData data) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/recurring-transactions/$id',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => RecurringTransaction.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> deleteRecurring(String id) async {
    try {
      await _dio.delete('/recurring-transactions/$id');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<RecurringTransaction> pauseRecurring(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>('/recurring-transactions/$id/pause');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => RecurringTransaction.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<RecurringTransaction> resumeRecurring(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/recurring-transactions/$id/resume',
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => RecurringTransaction.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<List<UpcomingOccurrence>> getUpcoming({int days = 30}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/recurring-transactions/upcoming',
        queryParameters: {'days': days},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => UpcomingOccurrence.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<PaginatedResponse<HistoryOccurrence>> getHistory({
    OccurrenceStatus? status,
    String? recurringTransactionId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/recurring-transactions/history',
        queryParameters: {
          'page': page,
          'limit': limit,
          'status': ?status?.toJson(),
          'recurringTransactionId': ?recurringTransactionId,
        },
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => HistoryOccurrence.fromJson(item),
        ),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository(ref.watch(dioProvider));
});
