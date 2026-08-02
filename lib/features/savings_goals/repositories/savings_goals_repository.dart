import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../models/savings_goal.dart';
import '../models/savings_goal_form_data.dart';

/// Talks to `/savings-goals`. Throws a [Failure] (never a raw
/// [DioException]) — see other repositories for the same convention.
class SavingsGoalsRepository {
  final Dio _dio;

  const SavingsGoalsRepository(this._dio);

  Future<List<SavingsGoal>> getGoals() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/savings-goals');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => SavingsGoal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<SavingsGoal> getGoal(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/savings-goals/$id');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => SavingsGoal.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<SavingsGoal> createGoal(SavingsGoalFormData data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/savings-goals',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => SavingsGoal.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<SavingsGoal> updateGoal(String id, SavingsGoalFormData data) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/savings-goals/$id',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => SavingsGoal.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  /// [amount] positive to contribute, negative to withdraw.
  Future<SavingsGoal> contribute(String id, double amount) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/savings-goals/$id/contribute',
        data: {'amount': amount},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => SavingsGoal.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _dio.delete('/savings-goals/$id');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final savingsGoalsRepositoryProvider = Provider<SavingsGoalsRepository>((ref) {
  return SavingsGoalsRepository(ref.watch(dioProvider));
});
