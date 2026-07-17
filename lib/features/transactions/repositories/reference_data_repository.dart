import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../models/account_ref.dart';
import '../models/category_ref.dart';

/// Fetches the user's accounts and categories — used to enrich transaction
/// rows with names/icons/colors (the transactions list endpoint only
/// returns raw IDs) and to populate the filter sheet's pickers.
///
/// There's no dedicated Accounts/Categories feature yet, so this lives
/// here, scoped to exactly what Transactions needs; it calls the existing
/// `GET /accounts` and `GET /categories` endpoints directly rather than
/// duplicating a second copy of account/category data on the backend.
class ReferenceDataRepository {
  final Dio _dio;

  const ReferenceDataRepository(this._dio);

  Future<List<AccountRef>> getAccounts() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/accounts');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => AccountRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<List<CategoryRef>> getCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/categories');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => CategoryRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final referenceDataRepositoryProvider = Provider<ReferenceDataRepository>((ref) {
  return ReferenceDataRepository(ref.watch(dioProvider));
});
