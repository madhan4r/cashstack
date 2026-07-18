import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_form_data.dart';

/// Talks to `/transactions` — listing (paginated, filtered) and the
/// single-transaction CRUD operations used by the Add/Edit form. Throws a
/// [Failure] (never a raw exception) so callers can surface it directly.
class TransactionsRepository {
  final Dio _dio;

  const TransactionsRepository(this._dio);

  Future<PaginatedResponse<Transaction>> getTransactions({
    required TransactionFilter filter,
    required int page,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/transactions',
        queryParameters: filter.toQueryParameters(page: page, limit: limit),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => Transaction.fromJson(item),
        ),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Transaction> getTransaction(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/transactions/$id');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Transaction.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Transaction> createTransaction(TransactionFormData data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/transactions',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Transaction.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Transaction> updateTransaction(String id, TransactionFormData data) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/transactions/$id',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Transaction.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _dio.delete('/transactions/$id');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.watch(dioProvider));
});
