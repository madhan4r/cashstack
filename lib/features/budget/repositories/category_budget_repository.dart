import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../models/category_budget.dart';

class CategoryBudgetRepository {
  final Dio _dio;

  const CategoryBudgetRepository(this._dio);

  Future<List<CategoryBudget>> getAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/budget/categories');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> set(String categoryId, double amount) async {
    try {
      await _dio.put<Map<String, dynamic>>(
        '/budget/categories/$categoryId',
        data: {'amount': amount},
      );
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> clear(String categoryId) async {
    try {
      await _dio.delete('/budget/categories/$categoryId');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final categoryBudgetRepositoryProvider = Provider<CategoryBudgetRepository>((ref) {
  return CategoryBudgetRepository(ref.watch(dioProvider));
});
