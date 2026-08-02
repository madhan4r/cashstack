import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Single reusable Add/Edit Account screen — `accountId == null` is Add
/// mode, otherwise Edit mode (pre-filled, with archive/delete actions).
class AccountFormScreen extends ConsumerStatefulWidget {
  final String? accountId;

  const AccountFormScreen({super.key, this.accountId});

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  late final _nameController = TextEditingController();
  late final _openingBalanceController = TextEditingController();
  late final _descriptionController = TextEditingController();
  bool _seededFromState = false;

  @override
  void dispose() {
    _nameController.dispose();
    _openingBalanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _seedControllers(AccountFormState state) {
    if (_seededFromState) return;
    _nameController.text = state.name;
    _openingBalanceController.text = state.openingBalance == null
        ? ''
        : state.openingBalance!.toStringAsFixed(
            state.openingBalance! % 1 == 0 ? 0 : 2,
          );
    _descriptionController.text = state.description;
    _seededFromState = true;
  }

  Future<void> _handleSave(bool isEditMode) async {
    final controller = ref.read(accountFormControllerProvider(widget.accountId).notifier);
    final result = await controller.submit();
    if (!mounted) return;

    result.when(
      ok: (account) {
        ref
            .read(snackbarServiceProvider)
            .showSuccess(isEditMode ? 'Account updated' : 'Account created');
        context.pop();
      },
      err: (failure) {
        if (failure is! ValidationFailure) {
          ref.read(snackbarServiceProvider).showError(failure.message);
        }
      },
    );
  }

  Future<void> _handleDelete(String accountName) async {
    final confirmed = await showDeleteAccountConfirmation(
      context: context,
      accountName: accountName,
    );
    if (confirmed != true || !mounted) return;

    final controller = ref.read(accountFormControllerProvider(widget.accountId).notifier);
    final result = await controller.delete();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Account deleted');
        context.pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _handleToggleArchive(String accountName, bool isArchived) async {
    final confirmed = await showArchiveAccountConfirmation(
      context: context,
      accountName: accountName,
      isCurrentlyArchived: isArchived,
    );
    if (confirmed != true || !mounted) return;

    final controller = ref.read(accountFormControllerProvider(widget.accountId).notifier);
    final result = await controller.toggleArchive();
    if (!mounted) return;

    result.when(
      ok: (account) => ref
          .read(snackbarServiceProvider)
          .showSuccess(account.isArchived ? 'Account archived' : 'Account unarchived'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountFormControllerProvider(widget.accountId));

    ref.listen(accountFormControllerProvider(widget.accountId), (previous, next) {
      // Only seed from state when the existing record's async load just
      // finished (Edit mode) — not on every field-level state change (e.g.
      // picking a type/currency), which would otherwise stomp on whatever
      // the user already typed into name/opening balance/description
      // (those aren't synced to state live; they're read directly on
      // save).
      final justFinishedLoading =
          (previous?.isLoadingInitial ?? false) && !next.isLoadingInitial;
      if (!_seededFromState && justFinishedLoading && next.loadError == null) {
        _seedControllers(next);
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: state.isEditMode ? 'Edit Account' : 'Add Account',
        actions: [
          if (state.isEditMode && !state.isLoadingInitial && state.loadError == null)
            IconButton(
              onPressed: () => _handleDelete(_nameController.text),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete account',
            ),
        ],
      ),
      body: state.isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : state.loadError != null
          ? ScrollableSingleChild(
              child: ErrorState.fromFailure(
                state.loadError!,
                onRetry: () =>
                    ref.read(accountFormControllerProvider(widget.accountId).notifier).retryLoad(),
              ),
            )
          : _FormContent(
              accountId: widget.accountId,
              state: state,
              nameController: _nameController,
              openingBalanceController: _openingBalanceController,
              descriptionController: _descriptionController,
              onSave: () => _handleSave(state.isEditMode),
              onToggleArchive: () =>
                  _handleToggleArchive(_nameController.text, state.isArchived),
            ),
    );
  }
}

class _FormContent extends ConsumerWidget {
  final String? accountId;
  final AccountFormState state;
  final TextEditingController nameController;
  final TextEditingController openingBalanceController;
  final TextEditingController descriptionController;
  final VoidCallback onSave;
  final VoidCallback onToggleArchive;

  const _FormContent({
    required this.accountId,
    required this.state,
    required this.nameController,
    required this.openingBalanceController,
    required this.descriptionController,
    required this.onSave,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(accountFormControllerProvider(accountId).notifier);

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
            AccountFormBody(
              nameController: nameController,
              openingBalanceController: openingBalanceController,
              descriptionController: descriptionController,
              type: state.type,
              onTypeChanged: controller.setType,
              currency: state.currency,
              onCurrencyChanged: controller.setCurrency,
              showValidationErrors: state.showValidationErrors,
              fieldErrors: state.fieldErrors,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: state.isEditMode ? 'Save Changes' : 'Add Account',
              isLoading: state.isSubmitting,
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      controller.setName(nameController.text);
                      controller.setOpeningBalance(
                        double.tryParse(
                              openingBalanceController.text.replaceAll(',', ''),
                            ) ??
                            0,
                      );
                      controller.setDescription(descriptionController.text);
                      onSave();
                    },
            ),
            if (state.isEditMode) ...[
              const SizedBox(height: AppSpacing.sm),
              AppOutlinedButton(
                label: state.isArchived ? 'Unarchive Account' : 'Archive Account',
                isLoading: state.isTogglingArchive,
                onPressed: state.isTogglingArchive ? null : onToggleArchive,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
