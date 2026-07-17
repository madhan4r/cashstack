import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../models/dashboard_data.dart';

/// Fetches the dashboard summary from `GET /dashboard`. A single-endpoint,
/// read-only feature doesn't need a separate API-service layer on top of
/// this — [DashboardRepository] owns the Dio call directly, same as any
/// other repository in the app.
///
/// Throws a [Failure] (never a raw exception) so [DashboardController] can
/// let it surface straight into `AsyncValue.error` and screens can render
/// it with `ErrorState.fromFailure`.
class DashboardRepository {
  final Dio _dio;

  const DashboardRepository(this._dio);

  Future<DashboardData> getDashboard() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/dashboard');
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => DashboardData.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});
