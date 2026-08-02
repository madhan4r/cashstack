import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';

/// Talks to `/budget`. Throws a [Failure] (never a raw [DioException]) —
/// see other repositories for the same convention.
class BudgetRepository {
  final Dio _dio;

  const BudgetRepository(this._dio);

  Future<double?> getBudget() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/budget');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as Map<String, dynamic>)['amount'] as num?,
      );
      return apiResponse.data?.toDouble();
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<double> setBudget(double amount) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/budget',
        data: {'amount': amount},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => ((json as Map<String, dynamic>)['amount'] as num).toDouble(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> clearBudget() async {
    try {
      await _dio.delete('/budget');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(dioProvider));
});
