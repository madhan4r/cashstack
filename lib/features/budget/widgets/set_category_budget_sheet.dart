import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../../../core/widgets/inputs/currency_text_field.dart';
import '../../../services/snackbar_service.dart';
import '../../categories/models/category_selector_item.dart';
import '../../categories/models/category_type.dart';
import '../../categories/providers/categories_list_controller.dart';
import '../../categories/widgets/category_selector_sheet.dart';
import '../models/category_budget.dart';
import '../providers/category_budgets_controller.dart';

/// Shows the Set/Change Category Budget flow: pick a category (skipped
/// when [existing] is passed, e.g. editing from the list), then an amount.
Future<void> showSetCategoryBudgetSheet({
  required BuildContext context,
  required String currencySymbol,
  CategoryBudget? existing,
}) {
  return showAppBottomSheet<void>(
    context: context,
    title: existing == null ? 'Add Category Budget' : 'Change Category Budget',
    builder: (context) => _SetCategoryBudgetForm(
      currencySymbol: currencySymbol,
      existing: existing,
    ),
  );
}

class _SetCategoryBudgetForm extends ConsumerStatefulWidget {
  final String currencySymbol;
  final CategoryBudget? existing;

  const _SetCategoryBudgetForm({required this.currencySymbol, this.existing});

  @override
  ConsumerState<_SetCategoryBudgetForm> createState() => _SetCategoryBudgetFormState();
}

class _SetCategoryBudgetFormState extends ConsumerState<_SetCategoryBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.existing == null ? '' : widget.existing!.amount.toStringAsFixed(0),
  );
  String? _categoryId;
  String? _categoryName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.existing?.categoryId;
    _categoryName = widget.existing?.categoryName;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final categories = ref.read(activeCategoriesByTypeProvider(CategoryType.expense));
    final items = categories
        .map((c) => CategorySelectorItem(id: c.id, name: c.name, icon: c.icon, color: c.color))
        .toList();
    final id = await showCategorySelectorSheet(
      context: context,
      categories: items,
      selectedCategoryId: _categoryId,
      title: 'Select category',
      categoryType: CategoryType.expense,
    );
    if (id == null) return;
    final match = items.where((c) => c.id == id);
    setState(() {
      _categoryId = id;
      _categoryName = match.isEmpty ? null : match.first.name;
    });
  }

  Future<void> _save() async {
    final categoryId = _categoryId;
    if (categoryId == null) {
      ref.read(snackbarServiceProvider).showError('Select a category');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(categoryBudgetsControllerProvider.notifier)
        .setBudget(categoryId, amount);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Category budget saved');
        Navigator.of(context).pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _remove() async {
    final categoryId = _categoryId;
    if (categoryId == null) return;

    setState(() => _isSubmitting = true);
    final result =
        await ref.read(categoryBudgetsControllerProvider.notifier).clearBudget(categoryId);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Category budget removed');
        Navigator.of(context).pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.existing == null)
            OutlinedButton(
              onPressed: _pickCategory,
              child: Text(_categoryName ?? 'Select category'),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                _categoryName ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          CurrencyTextField(
            label: 'Monthly Budget',
            symbol: widget.currencySymbol,
            controller: _amountController,
            validator: (value) {
              final amount = double.tryParse((value ?? '').replaceAll(',', ''));
              if (amount == null || amount <= 0) return 'Enter an amount greater than 0';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Save',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _save,
          ),
          if (widget.existing != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppOutlinedButton(
              label: 'Remove Budget',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _remove,
            ),
          ],
        ],
      ),
    );
  }
}
