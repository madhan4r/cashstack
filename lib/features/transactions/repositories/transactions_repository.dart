import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';

/// Fetches paginated transactions from `GET /transactions`, applying
/// [TransactionFilter] as query parameters. Throws a [Failure] (never a
/// raw exception) so [TransactionsListController] can surface it directly.
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
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.watch(dioProvider));
});
