import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/confirmation_dialog.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/inputs/app_date_picker_field.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/currency_text_field.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../../categories/widgets/color_picker.dart';
import '../../categories/widgets/icon_picker.dart';
import '../providers/savings_goal_form_controller.dart';
import '../providers/savings_goal_form_state.dart';
import '../widgets/contribute_sheet.dart';

/// Single reusable Add/Edit/Detail Savings Goal screen —
/// `goalId == null` is Add mode, otherwise Edit/Detail mode (pre-filled,
/// with Add Money/Withdraw/Delete actions and a progress bar).
class SavingsGoalFormScreen extends ConsumerStatefulWidget {
  final String? goalId;

  const SavingsGoalFormScreen({super.key, this.goalId});

  @override
  ConsumerState<SavingsGoalFormScreen> createState() => _SavingsGoalFormScreenState();
}

class _SavingsGoalFormScreenState extends ConsumerState<SavingsGoalFormScreen> {
  late final _nameController = TextEditingController();
  late final _amountController = TextEditingController();
  bool _seededFromState = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _seedControllers(SavingsGoalFormState state) {
    if (_seededFromState) return;
    _nameController.text = state.name;
    _amountController.text =
        state.targetAmount == null ? '' : state.targetAmount!.toStringAsFixed(0);
    _seededFromState = true;
  }

  Future<void> _handleSave(bool isEditMode) async {
    final controller = ref.read(savingsGoalFormControllerProvider(widget.goalId).notifier);
    controller.setName(_nameController.text);
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount != null) controller.setTargetAmount(amount);

    final result = await controller.submit();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref
            .read(snackbarServiceProvider)
            .showSuccess(isEditMode ? 'Savings goal updated' : 'Savings goal created');
        context.pop();
      },
      err: (failure) {
        if (failure is! ValidationFailure) {
          ref.read(snackbarServiceProvider).showError(failure.message);
        }
      },
    );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Delete savings goal?',
      message: "This can't be undone.",
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    final controller = ref.read(savingsGoalFormControllerProvider(widget.goalId).notifier);
    final result = await controller.delete();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Savings goal deleted');
        context.pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _handleContribute(ContributeMode mode) async {
    final currencySymbol = ref.read(preferredCurrencySymbolProvider);
    final amount = await showContributeSheet(
      context: context,
      currencySymbol: currencySymbol,
      mode: mode,
    );
    if (amount == null || !mounted) return;

    final controller = ref.read(savingsGoalFormControllerProvider(widget.goalId).notifier);
    final result = await controller.contribute(amount);
    if (!mounted) return;

    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess(
        mode == ContributeMode.add ? 'Money added' : 'Money withdrawn',
      ),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsGoalFormControllerProvider(widget.goalId));
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);

    ref.listen(savingsGoalFormControllerProvider(widget.goalId), (previous, next) {
      final justFinishedLoading =
          (previous?.isLoadingInitial ?? false) && !next.isLoadingInitial;
      if (!_seededFromState && justFinishedLoading && next.loadError == null) {
        _seedControllers(next);
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: state.isEditMode ? 'Savings Goal' : 'New Savings Goal',
        actions: [
          if (state.isEditMode && !state.isLoadingInitial && state.loadError == null)
            IconButton(
              onPressed: _handleDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete goal',
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
                    .read(savingsGoalFormControllerProvider(widget.goalId).notifier)
                    .retryLoad(),
              ),
            )
          : _FormContent(
              goalId: widget.goalId,
              state: state,
              nameController: _nameController,
              amountController: _amountController,
              currencySymbol: currencySymbol,
              onSave: () => _handleSave(state.isEditMode),
              onAddMoney: () => _handleContribute(ContributeMode.add),
              onWithdraw: () => _handleContribute(ContributeMode.withdraw),
            ),
    );
  }
}

class _FormContent extends ConsumerWidget {
  final String? goalId;
  final SavingsGoalFormState state;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final String currencySymbol;
  final VoidCallback onSave;
  final VoidCallback onAddMoney;
  final VoidCallback onWithdraw;

  const _FormContent({
    required this.goalId,
    required this.state,
    required this.nameController,
    required this.amountController,
    required this.currencySymbol,
    required this.onSave,
    required this.onAddMoney,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(savingsGoalFormControllerProvider(goalId).notifier);
    final tint = colorFromHex(state.color, fallback: context.colors.primary);
    final progress = (state.targetAmount == null || state.targetAmount == 0)
        ? 0.0
        : (state.currentAmount / state.targetAmount!).clamp(0, 1).toDouble();

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
            if (state.isEditMode) ...[
              Center(
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(categoryIconFor(state.icon), color: tint, size: 30),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: progress, minHeight: 10),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$currencySymbol${state.currentAmount.toStringAsFixed(0)} of '
                '$currencySymbol${(state.targetAmount ?? 0).toStringAsFixed(0)} saved',
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(label: 'Withdraw', onPressed: onWithdraw),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppPrimaryButton(label: 'Add Money', onPressed: onAddMoney),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            AppTextField(
              label: 'Goal Name',
              hint: 'e.g. Trip to Japan',
              controller: nameController,
              textInputAction: TextInputAction.next,
            ),
            if (state.showValidationErrors && state.fieldErrors['name'] != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                state.fieldErrors['name']!,
                style: context.textStyles.bodySmall?.copyWith(color: context.colors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            CurrencyTextField(
              label: 'Target Amount',
              symbol: currencySymbol,
              controller: amountController,
            ),
            if (state.showValidationErrors && state.fieldErrors['targetAmount'] != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                state.fieldErrors['targetAmount']!,
                style: context.textStyles.bodySmall?.copyWith(color: context.colors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppDatePickerField(
                    label: 'Target Date (optional)',
                    value: state.targetDate,
                    firstDate: DateTime.now(),
                    onChanged: controller.setTargetDate,
                  ),
                ),
                if (state.targetDate != null)
                  IconButton(
                    onPressed: () => controller.setTargetDate(null),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Clear date',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Icon', style: context.textStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            IconPicker(selectedIcon: state.icon, accentColor: tint, onSelected: controller.setIcon),
            const SizedBox(height: AppSpacing.lg),
            Text('Color', style: context.textStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            ColorPicker(selectedColor: state.color, onSelected: controller.setColor),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: state.isEditMode ? 'Save Changes' : 'Create Savings Goal',
              isLoading: state.isSubmitting,
              onPressed: state.isSubmitting ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}
