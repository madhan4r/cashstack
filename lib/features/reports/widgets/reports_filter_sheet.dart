import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/cards/category_chip.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../../../core/widgets/inputs/app_date_picker_field.dart';
import '../../../core/widgets/inputs/app_dropdown.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../shared/models/transaction_kind.dart';
import '../../transactions/models/account_ref.dart';
import '../../transactions/models/category_ref.dart';
import '../../transactions/providers/reference_data_provider.dart';
import '../models/date_range_preset.dart';
import '../models/report_filter.dart';

class ReportsFilterResult {
  final String? accountId;
  final String? categoryId;
  final TransactionKind? type;
  final List<String> tags;
  final DateTime? customFrom;
  final DateTime? customTo;

  const ReportsFilterResult({
    this.accountId,
    this.categoryId,
    this.type,
    this.tags = const [],
    this.customFrom,
    this.customTo,
  });
}

/// Shows the Reports advanced-filter sheet (Account/Category/Type/Tags/
/// Date Range) and returns the applied selections, or `null` if dismissed.
Future<ReportsFilterResult?> showReportsFilterSheet({
  required BuildContext context,
  required ReportFilter currentFilter,
}) {
  return showAppBottomSheet<ReportsFilterResult>(
    context: context,
    title: 'Filter Reports',
    builder: (context) => ReportsFilterSheet(initialFilter: currentFilter),
  );
}

class ReportsFilterSheet extends ConsumerStatefulWidget {
  final ReportFilter initialFilter;

  const ReportsFilterSheet({super.key, required this.initialFilter});

  @override
  ConsumerState<ReportsFilterSheet> createState() => _ReportsFilterSheetState();
}

class _ReportsFilterSheetState extends ConsumerState<ReportsFilterSheet> {
  late TransactionKind? _type = widget.initialFilter.type;
  late String? _categoryId = widget.initialFilter.categoryId;
  late String? _accountId = widget.initialFilter.accountId;
  late DateTime? _fromDate =
      widget.initialFilter.preset == DateRangePreset.custom ? widget.initialFilter.fromDate : null;
  late DateTime? _toDate =
      widget.initialFilter.preset == DateRangePreset.custom ? widget.initialFilter.toDate : null;
  late final _tagsController = TextEditingController(
    text: widget.initialFilter.tags.join(', '),
  );

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _type = null;
      _categoryId = null;
      _accountId = null;
      _fromDate = null;
      _toDate = null;
      _tagsController.clear();
    });
  }

  void _apply() {
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    Navigator.of(context).pop(
      ReportsFilterResult(
        accountId: _accountId,
        categoryId: _categoryId,
        type: _type,
        tags: tags,
        customFrom: _fromDate,
        customTo: _toDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final referenceDataAsync = ref.watch(referenceDataProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type', style: context.textStyles.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              CategoryChip(
                label: 'All',
                selected: _type == null,
                onTap: () => setState(() => _type = null),
              ),
              CategoryChip(
                label: 'Income',
                color: context.semanticColors.income,
                selected: _type == TransactionKind.income,
                onTap: () => setState(() => _type = TransactionKind.income),
              ),
              CategoryChip(
                label: 'Expense',
                color: context.semanticColors.expense,
                selected: _type == TransactionKind.expense,
                onTap: () => setState(() => _type = TransactionKind.expense),
              ),
              CategoryChip(
                label: 'Transfer',
                selected: _type == TransactionKind.transfer,
                onTap: () => setState(() => _type = TransactionKind.transfer),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          referenceDataAsync.when(
            data: (referenceData) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDropdown<CategoryRef?>(
                  label: 'Category',
                  value: referenceData.categoriesById[_categoryId],
                  items: [null, ...referenceData.categories],
                  labelBuilder: (c) => c?.name ?? 'All categories',
                  onChanged: (c) => setState(() => _categoryId = c?.id),
                ),
                const SizedBox(height: AppSpacing.md),
                AppDropdown<AccountRef?>(
                  label: 'Account',
                  value: referenceData.accountsById[_accountId],
                  items: [null, ...referenceData.accounts],
                  labelBuilder: (a) => a?.name ?? 'All accounts',
                  onChanged: (a) => setState(() => _accountId = a?.id),
                ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Tags', style: context.textStyles.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(hint: 'Comma-separated, e.g. work, travel', controller: _tagsController),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Custom date range (leave blank to keep the selected quick range)',
            style: context.textStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppDatePickerField(
                  label: 'From',
                  value: _fromDate,
                  lastDate: _toDate,
                  onChanged: (date) => setState(() => _fromDate = date),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppDatePickerField(
                  label: 'To',
                  value: _toDate,
                  firstDate: _fromDate,
                  onChanged: (date) => setState(() => _toDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: AppOutlinedButton(label: 'Reset', onPressed: _reset)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: AppPrimaryButton(label: 'Apply', onPressed: _apply)),
            ],
          ),
        ],
      ),
    );
  }
}
