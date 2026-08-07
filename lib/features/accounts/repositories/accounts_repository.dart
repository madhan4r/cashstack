import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../models/account.dart';
import '../models/account_form_data.dart';
import '../models/account_stats.dart';

/// Talks to `/accounts` — listing, single-account CRUD, archive/unarchive,
/// and the per-account stats aggregate. Throws a [Failure] (never a raw
/// exception) so callers can surface it directly.
class AccountsRepository {
  final Dio _dio;

  const AccountsRepository(this._dio);

  Future<List<Account>> getAccounts() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/accounts');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => Account.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  /// A household member's accounts — read-only, works regardless of your
  /// own combine/separate household view mode. 403s if you don't currently
  /// share a household with them.
  Future<List<Account>> getAccountsForMember(String memberId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/accounts/member/$memberId',
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => Account.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Account> getAccount(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/accounts/$id');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Account.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<AccountStats> getAccountStats(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/accounts/$id/stats');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => AccountStats.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Account> createAccount(AccountFormData data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/accounts',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Account.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Account> updateAccount(String id, AccountFormData data) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/accounts/$id',
        data: data.toJson(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Account.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _dio.delete('/accounts/$id');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Account> archiveAccount(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>('/accounts/$id/archive');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Account.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<Account> unarchiveAccount(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/accounts/$id/unarchive',
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => Account.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(ref.watch(dioProvider));
});
