import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../models/category.dart';
import '../models/category_form_data.dart';

/// Talks to `/categories` — listing, single-category CRUD, and
/// archive/unarchive. Throws a [Failure] (never a raw exception) so
/// callers can surface it directly.
class CategoriesRepository {
  final Dio _dio;

  const CategoriesRepository(this._dio);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/categories');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Category> getCategory(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/categories/$id');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Category> createCategory(CategoryFormData data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/categories',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Category> updateCategory(String id, CategoryFormData data) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/categories/$id',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('/categories/$id');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Category> archiveCategory(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>('/categories/$id/archive');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Category> unarchiveCategory(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/categories/$id/unarchive',
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(dioProvider));
});
