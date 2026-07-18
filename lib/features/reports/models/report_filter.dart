import 'package:equatable/equatable.dart';

import '../../../shared/models/transaction_kind.dart';
import 'date_range_preset.dart';

/// Everything needed to query any `/reports/*` endpoint: the shared
/// `ReportFilterDto` fields (fromDate/toDate/accountId/categoryId/
/// transactionType/tags), plus the [preset] driving how the dates were
/// derived so the UI can highlight the active chip.
class ReportFilter extends Equatable {
  final DateRangePreset preset;
  final DateTime fromDate;
  final DateTime toDate;
  final String? accountId;
  final String? categoryId;
  final TransactionKind? type;
  final List<String> tags;

  const ReportFilter({
    required this.preset,
    required this.fromDate,
    required this.toDate,
    this.accountId,
    this.categoryId,
    this.type,
    this.tags = const [],
  });

  factory ReportFilter.initial() {
    const preset = DateRangePreset.thisMonth;
    final (from, to) = preset.dateRange()!;
    return ReportFilter(preset: preset, fromDate: from, toDate: to);
  }

  bool get hasAdvancedFilters =>
      accountId != null || categoryId != null || type != null || tags.isNotEmpty;

  ReportFilter copyWith({
    DateRangePreset? preset,
    DateTime? fromDate,
    DateTime? toDate,
    String? accountId,
    bool clearAccountId = false,
    String? categoryId,
    bool clearCategoryId = false,
    TransactionKind? type,
    bool clearType = false,
    List<String>? tags,
  }) {
    return ReportFilter(
      preset: preset ?? this.preset,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      type: clearType ? null : (type ?? this.type),
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'fromDate': _dateOnly(fromDate),
      'toDate': _dateOnly(toDate),
      if (accountId != null) 'accountId': accountId,
      if (categoryId != null) 'categoryId': categoryId,
      if (type != null) 'transactionType': type!.toJson(),
      if (tags.isNotEmpty) 'tags': tags,
    };
  }

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
    preset,
    fromDate,
    toDate,
    accountId,
    categoryId,
    type,
    tags,
  ];
}
