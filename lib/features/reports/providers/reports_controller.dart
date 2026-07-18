import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/models/transaction_filter.dart';
import '../../transactions/models/transaction_sort_option.dart';
import '../../transactions/repositories/transactions_repository.dart';
import '../models/report_filter.dart';
import '../models/reports_data.dart';
import '../repositories/reports_repository.dart';
import 'reports_filter_provider.dart';

/// Loads every report the Reports Dashboard needs for the active
/// [reportsFilterProvider], in parallel, as one bundle — same
/// `AsyncNotifier` shape as `DashboardController`, so loading/error/
/// pull-to-refresh all come from `AsyncValue` for free.
class ReportsController extends AsyncNotifier<ReportsData> {
  @override
  Future<ReportsData> build() {
    final filter = ref.watch(reportsFilterProvider);
    return _fetch(filter);
  }

  Future<void> refresh() async {
    final filter = ref.read(reportsFilterProvider);
    final result = await AsyncValue.guard(() => _fetch(filter));
    state = result;
  }

  Future<ReportsData> _fetch(ReportFilter filter) async {
    final repository = ref.read(reportsRepositoryProvider);

    // The daily/monthly breakdown endpoints are scoped to a single
    // calendar month/year (not an arbitrary range) — derive them from the
    // filter's start date so "This Month"/"Today"/"This Week"/"Last Month"
    // all resolve to their containing month, and "This Year"/custom ranges
    // fall back to the month or year containing the range's start.
    final monthAnchor = filter.fromDate;

    final transactionsRepository = ref.read(transactionsRepositoryProvider);

    final results = await (
      repository.getSummary(filter),
      repository.getMonthly(filter, year: monthAnchor.year, month: monthAnchor.month),
      repository.getYearly(filter, year: monthAnchor.year),
      repository.getCategoryReport(filter),
      repository.getAccountReport(filter),
      transactionsRepository.getTransactions(
        filter: TransactionFilter(
          type: filter.type,
          categoryId: filter.categoryId,
          accountId: filter.accountId,
          fromDate: filter.fromDate,
          toDate: filter.toDate,
          sort: TransactionSortOption.amountHigh,
        ),
        page: 1,
        limit: 1,
      ),
    ).wait;

    final summary = results.$1;
    final monthly = results.$2;
    final yearly = results.$3;
    final categoryReport = results.$4;
    final accountReport = results.$5;
    final largestTransactionPage = results.$6;

    // Daily spending should reflect only the days actually inside the
    // active filter window, even though the monthly report always returns
    // the whole calendar month.
    final dailySpending = monthly.dailyBreakdown
        .where((d) => !d.date.isBefore(filter.fromDate) && !d.date.isAfter(filter.toDate))
        .toList();

    return ReportsData(
      summary: summary,
      categoryBreakdown: categoryReport.items,
      accountBreakdown: accountReport.items,
      monthlyTrend: yearly.monthlyBreakdown,
      dailySpending: dailySpending.isEmpty ? monthly.dailyBreakdown : dailySpending,
      largestTransaction:
          largestTransactionPage.items.isEmpty ? null : largestTransactionPage.items.first,
    );
  }
}

final reportsControllerProvider = AsyncNotifierProvider<ReportsController, ReportsData>(
  ReportsController.new,
);
