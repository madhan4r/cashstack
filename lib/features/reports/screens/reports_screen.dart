import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../../dashboard/widgets/staggered_entrance.dart';
import '../../transactions/models/category_ref.dart';
import '../../transactions/models/transaction_filter.dart';
import '../../transactions/providers/reference_data_provider.dart';
import '../../transactions/providers/transaction_filter_provider.dart';
import '../models/report_filter.dart';
import '../models/reports_data.dart';
import '../providers/providers.dart';
import '../services/report_export_service.dart';
import '../widgets/widgets.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref, ReportFilter filter) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: filter.fromDate, end: filter.toDate),
    );
    if (range == null) return;
    ref.read(reportsFilterProvider.notifier).setCustomRange(range.start, range.end);
  }

  Future<void> _openFilterSheet(BuildContext context, WidgetRef ref, ReportFilter filter) async {
    final result = await showReportsFilterSheet(context: context, currentFilter: filter);
    if (result == null) return;

    final notifier = ref.read(reportsFilterProvider.notifier)
      ..setAccountId(result.accountId)
      ..setCategoryId(result.categoryId)
      ..setType(result.type)
      ..setTags(result.tags);
    if (result.customFrom != null && result.customTo != null) {
      notifier.setCustomRange(result.customFrom!, result.customTo!);
    }
  }

  void _drillDownToCategory(BuildContext context, WidgetRef ref, ReportFilter filter, String categoryId) {
    ref.read(transactionFilterProvider.notifier).applyFilters(
      TransactionFilter(
        categoryId: categoryId,
        accountId: filter.accountId,
        type: filter.type,
        fromDate: filter.fromDate,
        toDate: filter.toDate,
      ),
    );
    context.push(AppRoutes.transactions);
  }

  void _drillDownToAccount(BuildContext context, WidgetRef ref, ReportFilter filter, String accountId) {
    ref.read(transactionFilterProvider.notifier).applyFilters(
      TransactionFilter(
        accountId: accountId,
        categoryId: filter.categoryId,
        type: filter.type,
        fromDate: filter.fromDate,
        toDate: filter.toDate,
      ),
    );
    context.push(AppRoutes.transactions);
  }

  Future<void> _handleExport(
    BuildContext context,
    WidgetRef ref,
    ReportsData data,
    ReportFilter filter,
    bool asPdf,
  ) async {
    try {
      final service = ref.read(reportExportServiceProvider);
      if (asPdf) {
        await service.exportPdf(data, filter);
      } else {
        await service.exportCsv(data, filter);
      }
    } catch (_) {
      if (context.mounted) {
        ref.read(snackbarServiceProvider).showError('Couldn\'t export the report');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportsFilterProvider);
    final reportsAsync = ref.watch(reportsControllerProvider);
    final referenceDataAsync = ref.watch(referenceDataProvider);

    return Scaffold(
      appBar: CashStackAppBar(
        title: 'Reports',
        actions: [
          reportsAsync.maybeWhen(
            data: (data) => ExportMenu(
              onExportPdf: () => _handleExport(context, ref, data, filter, true),
              onExportCsv: () => _handleExport(context, ref, data, filter, false),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            onPressed: () => _openFilterSheet(context, ref, filter),
            icon: Icon(
              filter.hasAdvancedFilters ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: DateFilterRow(
              selected: filter.preset,
              onSelected: (preset) => ref.read(reportsFilterProvider.notifier).setPreset(preset),
              onCustomTap: () => _pickCustomRange(context, ref, filter),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(reportsControllerProvider.notifier).refresh(),
              child: reportsAsync.when(
                data: (data) {
                  if (data.summary.transactionCount == 0) {
                    return ScrollableSingleChild(
                      child: ReportsEmptyState(
                        onClearFilters: filter.hasAdvancedFilters
                            ? () => ref.read(reportsFilterProvider.notifier).clearAdvancedFilters()
                            : null,
                      ),
                    );
                  }
                  return _ReportsContent(
                    data: data,
                    filter: filter,
                    categoriesById: switch (referenceDataAsync) {
                      AsyncData(:final value) => value.categoriesById,
                      _ => const {},
                    },
                    onTapCategorySegment: (categoryId) =>
                        _drillDownToCategory(context, ref, filter, categoryId),
                    onTapAccount: (accountId) => _drillDownToAccount(context, ref, filter, accountId),
                  );
                },
                loading: () => const ScrollableSingleChild(child: ReportsSkeleton()),
                error: (error, _) => ScrollableSingleChild(
                  child: ErrorState.fromFailure(
                    error is Failure ? error : const UnknownFailure(),
                    onRetry: () => ref.invalidate(reportsControllerProvider),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final ReportsData data;
  final ReportFilter filter;
  final Map<String, CategoryRef> categoriesById;
  final ValueChanged<String> onTapCategorySegment;
  final ValueChanged<String> onTapAccount;

  const _ReportsContent({
    required this.data,
    required this.filter,
    required this.categoriesById,
    required this.onTapCategorySegment,
    required this.onTapAccount,
  });

  String get _periodLabel {
    final from = filter.fromDate;
    final to = filter.toDate;
    return '${from.month}/${from.day}/${from.year} – ${to.month}/${to.day}/${to.year}';
  }

  String? _iconOf(String categoryId) => categoriesById[categoryId]?.icon;
  String? _colorOf(String categoryId) => categoriesById[categoryId]?.color;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        StaggeredEntrance(child: ReportSummaryGrid(summary: data.summary)),
        const SizedBox(height: AppSpacing.xl),
        StaggeredEntrance(
          delay: const Duration(milliseconds: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportSectionHeader(title: 'Category Spending', subtitle: _periodLabel),
              const SizedBox(height: AppSpacing.sm),
              PieChartCard(
                items: data.categoryBreakdown,
                onTapSegment: (item) => onTapCategorySegment(item.categoryId),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        StaggeredEntrance(
          delay: const Duration(milliseconds: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionHeader(title: 'Income vs Expense'),
              const SizedBox(height: AppSpacing.sm),
              BarChartCard(income: data.summary.totalIncome, expense: data.summary.totalExpense),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        StaggeredEntrance(
          delay: const Duration(milliseconds: 180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportSectionHeader(title: 'Monthly Trend', subtitle: '${filter.fromDate.year}'),
              const SizedBox(height: AppSpacing.sm),
              LineChartCard(points: data.monthlyTrend),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        StaggeredEntrance(
          delay: const Duration(milliseconds: 240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionHeader(title: 'Daily Spending'),
              const SizedBox(height: AppSpacing.sm),
              ColumnChartCard(days: data.dailySpending),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        StaggeredEntrance(
          delay: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionHeader(title: 'Category Breakdown'),
              const SizedBox(height: AppSpacing.sm),
              CategoryBreakdownList(
                items: data.categoryBreakdown,
                iconOf: _iconOf,
                colorOf: _colorOf,
                onTap: (item) => onTapCategorySegment(item.categoryId),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        StaggeredEntrance(
          delay: const Duration(milliseconds: 360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionHeader(title: 'Account Breakdown'),
              const SizedBox(height: AppSpacing.sm),
              AccountBreakdownList(
                items: data.accountBreakdown,
                onTap: (item) => onTapAccount(item.accountId),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        StaggeredEntrance(
          delay: const Duration(milliseconds: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionHeader(title: 'Top Insights'),
              const SizedBox(height: AppSpacing.sm),
              InsightsGrid(data: data),
            ],
          ),
        ),
      ],
    );
  }
}
