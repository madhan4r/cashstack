import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/widgets/feedback/confirmation_dialog.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/inputs/app_date_picker_field.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/app_time_picker_field.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/misc/section_header.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../../../shared/models/transaction_kind.dart';
import '../../categories/models/category_selector_item.dart';
import '../../categories/widgets/category_selector_sheet.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../providers/transaction_form_controller.dart';
import '../providers/transaction_form_state.dart';
import '../widgets/account_picker_sheet.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/transaction_amount_input.dart';
import '../widgets/transaction_form_skeleton.dart';
import '../widgets/transaction_save_button.dart';
import '../widgets/transaction_type_selector.dart';

/// Add/Edit Transaction — the same screen handles both modes;
/// [transactionId] being non-null means Edit.
class TransactionFormScreen extends ConsumerStatefulWidget {
  final String? transactionId;

  /// Preselects the type in Add mode (e.g. Dashboard's "Add Income" quick
  /// action). Ignored in Edit mode, where the loaded transaction's type
  /// always wins.
  final TransactionKind? initialType;

  const TransactionFormScreen({super.key, this.transactionId, this.initialType});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  late final _amountController = TextEditingController();
  late final _notesController = TextEditingController();
  bool _hydratedControllers = false;
  bool _appliedInitialType = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = transactionFormControllerProvider(widget.transactionId);
    final formState = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    final initialType = widget.initialType;
    if (!_appliedInitialType &&
        initialType != null &&
        widget.transactionId == null) {
      _appliedInitialType = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.setType(initialType);
      });
    }
    final referenceDataAsync = ref.watch(referenceDataProvider);
    final referenceData = switch (referenceDataAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };

    ref.listen(provider, (previous, next) {
      if (!_hydratedControllers && !next.isLoadingInitial && next.loadError == null) {
        _hydratedControllers = true;
        _amountController.text = next.amount == null
            ? ''
            : NumberFormat.decimalPattern().format(next.amount);
        _notesController.text = next.notes;
      }

      final error = next.submitError;
      if (error != null && error != previous?.submitError) {
        ref.read(snackbarServiceProvider).showError(error.message);
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: formState.isEditMode ? 'Edit Transaction' : 'Add Transaction',
        actions: [
          if (formState.isEditMode)
            IconButton(
              onPressed: formState.isDeleting
                  ? null
                  : () => _handleDelete(controller),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SafeArea(
        child: switch (true) {
          _ when formState.isLoadingInitial => const TransactionFormSkeleton(),
          _ when formState.loadError != null => ScrollableSingleChild(
              child: ErrorState.fromFailure(
                formState.loadError!,
                onRetry: controller.retryLoad,
              ),
            ),
          _ => _FormBody(
              formState: formState,
              controller: controller,
              amountController: _amountController,
              notesController: _notesController,
              categories: referenceData?.categories ?? const [],
              accounts: referenceData?.accounts ?? const [],
              onSave: () => _handleSave(controller, formState.isEditMode),
            ),
        },
      ),
    );
  }

  Future<void> _handleSave(TransactionFormController controller, bool isEditMode) async {
    FocusScope.of(context).unfocus();
    final result = await controller.submit();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref
            .read(snackbarServiceProvider)
            .showSuccess(isEditMode ? 'Transaction updated' : 'Transaction added');
        ref.invalidate(transactionsListControllerProvider);
        context.pop();
      },
      // API failures are surfaced via ref.listen(submitError); local
      // validation failures are already visible as inline field errors.
      err: (_) {},
    );
  }

  Future<void> _handleDelete(TransactionFormController controller) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Delete transaction?',
      message: "This can't be undone.",
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    final result = await controller.delete();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Transaction deleted');
        ref.invalidate(transactionsListControllerProvider);
        context.pop();
      },
      err: (_) {},
    );
  }
}

class _FormBody extends StatelessWidget {
  final TransactionFormState formState;
  final TransactionFormController controller;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final List<CategoryRef> categories;
  final List<AccountRef> accounts;
  final VoidCallback onSave;

  const _FormBody({
    required this.formState,
    required this.controller,
    required this.amountController,
    required this.notesController,
    required this.categories,
    required this.accounts,
    required this.onSave,
  });

  bool get _referenceDataReady => categories.isNotEmpty || accounts.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isTransfer = formState.type == TransactionKind.transfer;
    final bottomInset = context.viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TransactionTypeSelector(value: formState.type, onChanged: controller.setType),
          const SizedBox(height: AppSpacing.xl),
          TransactionAmountInput(
            controller: amountController,
            onChanged: controller.setAmount,
            errorText: formState.showValidationErrors ? formState.fieldErrors['amount'] : null,
            autofocus: !formState.isEditMode,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (isTransfer) ...[
            _SelectionField(
              label: 'From Account',
              value: _accountLabel(formState.fromAccountId),
              icon: Icons.account_balance_wallet_outlined,
              errorText: formState.showValidationErrors ? formState.fieldErrors['fromAccount'] : null,
              enabled: _referenceDataReady,
              onTap: () async {
                final id = await showAccountPickerSheet(
                  context: context,
                  accounts: accounts,
                  title: 'From account',
                  selectedAccountId: formState.fromAccountId,
                  excludeAccountId: formState.toAccountId,
                );
                if (id != null) controller.setFromAccount(id);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _SelectionField(
              label: 'To Account',
              value: _accountLabel(formState.toAccountId),
              icon: Icons.account_balance_wallet_outlined,
              errorText: formState.showValidationErrors ? formState.fieldErrors['toAccount'] : null,
              enabled: _referenceDataReady,
              onTap: () async {
                final id = await showAccountPickerSheet(
                  context: context,
                  accounts: accounts,
                  title: 'To account',
                  selectedAccountId: formState.toAccountId,
                  excludeAccountId: formState.fromAccountId,
                );
                if (id != null) controller.setToAccount(id);
              },
            ),
          ] else ...[
            _SelectionField(
              label: 'Category',
              value: _categoryLabel(formState.categoryId),
              icon: _categoryIcon(formState.categoryId),
              errorText: formState.showValidationErrors ? formState.fieldErrors['category'] : null,
              enabled: _referenceDataReady,
              onTap: () async {
                final categoriesForType = categories
                    .where((c) => c.type == formState.type)
                    .map(
                      (c) => CategorySelectorItem(
                        id: c.id,
                        name: c.name,
                        icon: c.icon,
                        color: c.color,
                      ),
                    )
                    .toList();
                final id = await showCategorySelectorSheet(
                  context: context,
                  categories: categoriesForType,
                  selectedCategoryId: formState.categoryId,
                );
                if (id != null) controller.setCategory(id);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _SelectionField(
              label: 'Account',
              value: _accountLabel(formState.accountId),
              icon: Icons.account_balance_wallet_outlined,
              errorText: formState.showValidationErrors ? formState.fieldErrors['account'] : null,
              enabled: _referenceDataReady,
              onTap: () async {
                final id = await showAccountPickerSheet(
                  context: context,
                  accounts: accounts,
                  title: 'Account',
                  selectedAccountId: formState.accountId,
                );
                if (id != null) controller.setAccount(id);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppDatePickerField(
                  label: 'Date',
                  value: formState.date,
                  lastDate: DateTime.now(),
                  onChanged: controller.setDate,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTimePickerField(
                  label: 'Time',
                  value: formState.time,
                  onChanged: controller.setTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Payment method'),
          const SizedBox(height: AppSpacing.sm),
          PaymentMethodSelector(
            value: formState.paymentMethod,
            onChanged: controller.setPaymentMethod,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Notes',
            controller: notesController,
            maxLines: 3,
            maxLength: 250,
            onChanged: controller.setNotes,
          ),
          const SizedBox(height: AppSpacing.xl),
          TransactionSaveButton(
            isEditMode: formState.isEditMode,
            isLoading: formState.isSubmitting,
            onPressed: formState.isSubmitting ? null : onSave,
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String? id) {
    if (id == null) return 'Select category';
    final match = categories.where((c) => c.id == id);
    return match.isEmpty ? 'Select category' : match.first.name;
  }

  IconData _categoryIcon(String? id) {
    if (id == null) return Icons.category_outlined;
    final match = categories.where((c) => c.id == id);
    return match.isEmpty ? Icons.category_outlined : categoryIconFor(match.first.icon);
  }

  String _accountLabel(String? id) {
    if (id == null) return 'Select account';
    final match = accounts.where((a) => a.id == id);
    return match.isEmpty ? 'Select account' : match.first.name;
  }
}

/// A compact, tappable row summarizing the current selection (category or
/// account) that opens the relevant picker sheet — reuses [AppTextField]'s
/// read-only + tap-to-open pattern (see [AppDatePickerField]) rather than
/// introducing a new field type. [errorText] is surfaced through the same
/// validator-driven red error text `TextFormField` renders natively.
class _SelectionField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? errorText;
  final bool enabled;
  final VoidCallback onTap;

  const _SelectionField({
    required this.label,
    required this.value,
    required this.icon,
    required this.errorText,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      key: ValueKey('$label-$value'),
      label: label,
      controller: TextEditingController(text: value),
      readOnly: true,
      enabled: enabled,
      prefixIcon: Icon(icon),
      suffixIcon: const Icon(Icons.chevron_right_rounded),
      validator: errorText == null ? null : (_) => errorText,
      autovalidateMode: errorText == null ? null : AutovalidateMode.always,
      onTap: enabled ? onTap : null,
    );
  }
}
