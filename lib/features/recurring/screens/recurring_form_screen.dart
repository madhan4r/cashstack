import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../core/utils/category_icons.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../../categories/models/category_selector_item.dart';
import '../../categories/models/category_type.dart';
import '../../categories/providers/categories_list_controller.dart';
import '../../categories/widgets/category_selector_sheet.dart';
import '../../transactions/models/account_ref.dart';
import '../../transactions/providers/reference_data_provider.dart';
import '../../transactions/widgets/account_picker_sheet.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/recurring_status.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Single reusable Add/Edit Recurring Transaction screen —
/// `recurringId == null` is Add mode, otherwise Edit mode (pre-filled,
/// with pause/resume + delete actions).
class RecurringFormScreen extends ConsumerStatefulWidget {
  final String? recurringId;

  const RecurringFormScreen({super.key, this.recurringId});

  @override
  ConsumerState<RecurringFormScreen> createState() => _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  late final _nameController = TextEditingController();
  late final _amountController = TextEditingController();
  late final _notesController = TextEditingController();
  late final _customIntervalController = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _customIntervalController.dispose();
    super.dispose();
  }

  void _seedControllers(RecurringFormState state) {
    if (_seeded) return;
    _nameController.text = state.name;
    _amountController.text =
        state.amount == null ? '' : NumberFormat.decimalPattern().format(state.amount);
    _notesController.text = state.notes;
    _customIntervalController.text = state.customIntervalDays?.toString() ?? '';
    _seeded = true;
  }

  Future<void> _handleSave(bool isEditMode) async {
    final controller = ref.read(recurringFormControllerProvider(widget.recurringId).notifier);
    controller
      ..setName(_nameController.text)
      ..setAmount(double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0)
      ..setNotes(_notesController.text);

    final intervalDays = int.tryParse(_customIntervalController.text);
    if (intervalDays != null) controller.setCustomIntervalDays(intervalDays);

    final result = await controller.submit();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref
            .read(snackbarServiceProvider)
            .showSuccess(isEditMode ? 'Recurring transaction updated' : 'Recurring transaction created');
        context.pop();
      },
      err: (failure) {
        if (failure is! ValidationFailure) {
          ref.read(snackbarServiceProvider).showError(failure.message);
        }
      },
    );
  }

  Future<void> _handleDelete(String name) async {
    final confirmed = await showDeleteRecurringConfirmation(context: context, name: name);
    if (confirmed != true || !mounted) return;

    final controller = ref.read(recurringFormControllerProvider(widget.recurringId).notifier);
    final result = await controller.delete();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Recurring transaction deleted');
        context.pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _handleToggleStatus() async {
    final controller = ref.read(recurringFormControllerProvider(widget.recurringId).notifier);
    final result = await controller.toggleStatus();
    if (!mounted) return;

    result.when(
      ok: (r) => ref
          .read(snackbarServiceProvider)
          .showSuccess(r.status == RecurringStatus.paused ? 'Paused' : 'Resumed'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recurringFormControllerProvider(widget.recurringId));

    ref.listen(recurringFormControllerProvider(widget.recurringId), (previous, next) {
      // Only seed from state when the existing record's async load just
      // finished (Edit mode) — not on every field-level state change (e.g.
      // picking a category), which would otherwise stomp on whatever the
      // user already typed into the name/amount fields (those aren't
      // synced to state live; they're read directly on save).
      final justFinishedLoading =
          (previous?.isLoadingInitial ?? false) && !next.isLoadingInitial;
      if (!_seeded && justFinishedLoading && next.loadError == null) {
        _seedControllers(next);
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: state.isEditMode ? 'Edit Recurring Transaction' : 'Create Recurring Transaction',
        actions: [
          if (state.isEditMode && !state.isLoadingInitial && state.loadError == null)
            IconButton(
              onPressed: () => _handleDelete(_nameController.text),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: state.isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : state.loadError != null
          ? ScrollableSingleChild(
              child: ErrorState.fromFailure(
                state.loadError!,
                onRetry: () => ref
                    .read(recurringFormControllerProvider(widget.recurringId).notifier)
                    .retryLoad(),
              ),
            )
          : _FormContent(
              recurringId: widget.recurringId,
              state: state,
              nameController: _nameController,
              amountController: _amountController,
              notesController: _notesController,
              customIntervalController: _customIntervalController,
              onSave: () => _handleSave(state.isEditMode),
              onToggleStatus: _handleToggleStatus,
            ),
    );
  }
}

class _FormContent extends ConsumerWidget {
  final String? recurringId;
  final RecurringFormState state;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final TextEditingController customIntervalController;
  final VoidCallback onSave;
  final VoidCallback onToggleStatus;

  const _FormContent({
    required this.recurringId,
    required this.state,
    required this.nameController,
    required this.amountController,
    required this.notesController,
    required this.customIntervalController,
    required this.onSave,
    required this.onToggleStatus,
  });

  CategoryType get _categoryType =>
      state.type == TransactionKind.income ? CategoryType.income : CategoryType.expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(recurringFormControllerProvider(recurringId).notifier);
    final categories = ref.watch(activeCategoriesByTypeProvider(_categoryType));
    final referenceDataAsync = ref.watch(referenceDataProvider);
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);
    final accounts = switch (referenceDataAsync) {
      AsyncData(:final value) => value.accounts,
      _ => const <AccountRef>[],
    };

    final categoryMatches = categories.where((c) => c.id == state.categoryId);
    final selectedCategory = categoryMatches.isEmpty ? null : categoryMatches.first;
    final accountMatches = accounts.where((a) => a.id == state.accountId);
    final selectedAccount = accountMatches.isEmpty ? null : accountMatches.first;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RecurringFormBody(
              nameController: nameController,
              amountController: amountController,
              currencySymbol: currencySymbol,
              notesController: notesController,
              customIntervalController: customIntervalController,
              type: state.type,
              onTypeChanged: controller.setType,
              categoryLabel: selectedCategory?.name ?? 'Select category',
              categoryIcon: categoryIconFor(selectedCategory?.icon),
              onTapCategory: () async {
                final items = categories
                    .map(
                      (c) => CategorySelectorItem(id: c.id, name: c.name, icon: c.icon, color: c.color),
                    )
                    .toList();
                final id = await showCategorySelectorSheet(
                  context: context,
                  categories: items,
                  selectedCategoryId: state.categoryId,
                );
                if (id != null) controller.setCategory(id);
              },
              accountLabel: selectedAccount?.name ?? 'Select account',
              onTapAccount: () async {
                final id = await showAccountPickerSheet(
                  context: context,
                  accounts: accounts,
                  title: 'Account',
                  selectedAccountId: state.accountId,
                );
                if (id != null) controller.setAccount(id);
              },
              frequency: state.frequency,
              onFrequencyChanged: controller.setFrequency,
              startDate: state.startDate,
              onStartDateChanged: controller.setStartDate,
              endDate: state.endDate,
              onEndDateChanged: controller.setEndDate,
              reminder: state.reminder,
              onReminderChanged: controller.setReminder,
              autoGenerate: state.autoGenerate,
              onAutoGenerateChanged: controller.setAutoGenerate,
              showValidationErrors: state.showValidationErrors,
              fieldErrors: state.fieldErrors,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: state.isEditMode ? 'Save Changes' : 'Create Recurring Transaction',
              isLoading: state.isSubmitting,
              onPressed: state.isSubmitting ? null : onSave,
            ),
            if (state.isEditMode) ...[
              const SizedBox(height: AppSpacing.sm),
              AppOutlinedButton(
                label: state.status == RecurringStatus.paused ? 'Resume' : 'Pause',
                isLoading: state.isTogglingStatus,
                onPressed: state.isTogglingStatus ? null : onToggleStatus,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
