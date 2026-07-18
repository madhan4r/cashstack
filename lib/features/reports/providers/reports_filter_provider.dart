import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/transaction_kind.dart';
import '../models/date_range_preset.dart';
import '../models/report_filter.dart';

/// The active date range + account/category/type/tags filters for the
/// Reports Dashboard. [ReportsController] watches this and refetches
/// every report whenever it changes.
class ReportsFilterController extends Notifier<ReportFilter> {
  @override
  ReportFilter build() => ReportFilter.initial();

  void setPreset(DateRangePreset preset) {
    final range = preset.dateRange();
    if (range == null) return;
    final (from, to) = range;
    state = state.copyWith(preset: preset, fromDate: from, toDate: to);
  }

  void setCustomRange(DateTime from, DateTime to) {
    state = state.copyWith(preset: DateRangePreset.custom, fromDate: from, toDate: to);
  }

  void setAccountId(String? accountId) {
    state = state.copyWith(accountId: accountId, clearAccountId: accountId == null);
  }

  void setCategoryId(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearCategoryId: categoryId == null);
  }

  void setType(TransactionKind? type) {
    state = state.copyWith(type: type, clearType: type == null);
  }

  void setTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  void clearAdvancedFilters() {
    state = state.copyWith(
      clearAccountId: true,
      clearCategoryId: true,
      clearType: true,
      tags: const [],
    );
  }
}

final reportsFilterProvider = NotifierProvider<ReportsFilterController, ReportFilter>(
  ReportsFilterController.new,
);
