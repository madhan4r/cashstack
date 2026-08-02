import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../models/household.dart';
import '../models/household_invite.dart';

/// Talks to `/households`. Throws a [Failure] (never a raw [DioException]) —
/// see other repositories for the same convention.
class HouseholdRepository {
  final Dio _dio;

  const HouseholdRepository(this._dio);

  /// `null` when the caller isn't in a household.
  Future<Household?> getMyHousehold() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/households/me');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => json == null
            ? null
            : Household.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<HouseholdInvite> inviteMember(String email) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/households/invites',
        data: {'email': email},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => HouseholdInvite.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<List<HouseholdInvite>> getPendingInvites() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/households/invites/me',
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((e) => HouseholdInvite.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> respondToInvite(String inviteId, {required bool accept}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/households/invites/$inviteId/respond',
        data: {'accept': accept},
      );
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> cancelInvite(String inviteId) async {
    try {
      await _dio.delete('/households/invites/$inviteId');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<void> leaveHousehold() async {
    try {
      await _dio.post('/households/leave');
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepository(ref.watch(dioProvider));
});
