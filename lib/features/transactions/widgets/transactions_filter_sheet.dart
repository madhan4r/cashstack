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
import '../models/account_ref.dart';
import '../models/category_ref.dart';
import '../models/transaction_filter.dart';
import '../providers/reference_data_provider.dart';

/// Shows the transactions filter sheet and returns the filter the user
/// applied, or `null` if they dismissed it without applying.
Future<TransactionFilter?> showTransactionsFilterSheet({
  required BuildContext context,
  required TransactionFilter currentFilter,
}) {
  return showAppBottomSheet<TransactionFilter>(
    context: context,
    title: 'Filter Transactions',
    builder: (context) => TransactionsFilterSheet(initialFilter: currentFilter),
  );
}

class TransactionsFilterSheet extends ConsumerStatefulWidget {
  final TransactionFilter initialFilter;

  const TransactionsFilterSheet({super.key, required this.initialFilter});

  @override
  ConsumerState<TransactionsFilterSheet> createState() =>
      _TransactionsFilterSheetState();
}

class _TransactionsFilterSheetState
    extends ConsumerState<TransactionsFilterSheet> {
  late TransactionKind? _type = widget.initialFilter.type;
  late String? _categoryId = widget.initialFilter.categoryId;
  late String? _accountId = widget.initialFilter.accountId;
  late DateTime? _fromDate = widget.initialFilter.fromDate;
  late DateTime? _toDate = widget.initialFilter.toDate;
  late final _minAmountController = TextEditingController(
    text: widget.initialFilter.minAmount?.toStringAsFixed(0) ?? '',
  );
  late final _maxAmountController = TextEditingController(
    text: widget.initialFilter.maxAmount?.toStringAsFixed(0) ?? '',
  );

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _type = null;
      _categoryId = null;
      _accountId = null;
      _fromDate = null;
      _toDate = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _apply() {
    final result = widget.initialFilter.copyWith(
      type: _type,
      clearType: _type == null,
      categoryId: _categoryId,
      clearCategoryId: _categoryId == null,
      accountId: _accountId,
      clearAccountId: _accountId == null,
      fromDate: _fromDate,
      clearFromDate: _fromDate == null,
      toDate: _toDate,
      clearToDate: _toDate == null,
      minAmount: double.tryParse(_minAmountController.text),
      clearMinAmount: double.tryParse(_minAmountController.text) == null,
      maxAmount: double.tryParse(_maxAmountController.text),
      clearMaxAmount: double.tryParse(_maxAmountController.text) == null,
    );
    Navigator.of(context).pop(result);
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
          Text('Date range', style: context.textStyles.titleSmall),
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
          const SizedBox(height: AppSpacing.lg),
          Text('Amount range', style: context.textStyles.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Min',
                  controller: _minAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: 'Max',
                  controller: _maxAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(label: 'Reset', onPressed: _reset),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppPrimaryButton(label: 'Apply', onPressed: _apply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
