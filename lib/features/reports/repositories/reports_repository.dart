import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../models/account_report.dart';
import '../models/account_report_item.dart';
import '../models/category_report.dart';
import '../models/category_breakdown_item.dart';
import '../models/monthly_report.dart';
import '../models/report_filter.dart';
import '../models/summary_report.dart';
import '../models/yearly_report.dart';

const _breakdownLimit = 10;

/// Talks to `/reports/*`. Throws a [Failure] (never a raw exception) so
/// [ReportsController] can let it surface straight into `AsyncValue.error`.
class ReportsRepository {
  final Dio _dio;

  const ReportsRepository(this._dio);

  Future<SummaryReport> getSummary(ReportFilter filter) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reports/summary',
        queryParameters: filter.toQueryParameters(),
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => SummaryReport.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<MonthlyReport> getMonthly(
    ReportFilter filter, {
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reports/monthly',
        queryParameters: {
          ...filter.toQueryParameters(),
          'year': year,
          'month': month,
        },
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => MonthlyReport.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<YearlyReport> getYearly(ReportFilter filter, {required int year}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reports/yearly',
        queryParameters: {...filter.toQueryParameters(), 'year': year},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => YearlyReport.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<CategoryReport> getCategoryReport(
    ReportFilter filter, {
    int page = 1,
    int limit = _breakdownLimit,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reports/category',
        queryParameters: {...filter.toQueryParameters(), 'page': page, 'limit': limit},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => CategoryReport.fromJson(
          json as Map<String, dynamic>,
          (item) => CategoryBreakdownItem.fromJson(item),
        ),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }

  Future<AccountReport> getAccountReport(
    ReportFilter filter, {
    int page = 1,
    int limit = _breakdownLimit,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reports/account',
        queryParameters: {...filter.toQueryParameters(), 'page': page, 'limit': limit},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => AccountReport.fromJson(
          json as Map<String, dynamic>,
          (item) => AccountReportItem.fromJson(item),
        ),
      );
      return apiResponse.data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e.appException);
    }
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(ref.watch(dioProvider));
});
