import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../models/account.dart';
import '../models/account_form_data.dart';
import '../models/account_type.dart';
import '../repositories/accounts_repository.dart';
import 'accounts_list_controller.dart';
import 'account_form_state.dart';

/// Drives the Add/Edit Account form. Keyed by `accountId` (`null` for Add
/// mode) so editing a different account — or opening a fresh Add screen —
/// always starts from clean state; `autoDispose` tears it down when the
/// form screen is popped.
class AccountFormController extends Notifier<AccountFormState> {
  final String? accountId;

  AccountFormController(this.accountId);

  @override
  AccountFormState build() {
    final id = accountId;
    if (id != null) {
      unawaited(_loadExisting(id));
    }
    return AccountFormState.initial(accountId: id);
  }

  Future<void> _loadExisting(String id) async {
    final repository = ref.read(accountsRepositoryProvider);
    try {
      final account = await repository.getAccount(id);
      state = AccountFormState.fromAccount(account);
    } catch (error) {
      state = state.copyWith(
        isLoadingInitial: false,
        loadError: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> retryLoad() async {
    final id = state.accountId;
    if (id == null) return;
    state = state.copyWith(isLoadingInitial: true, clearLoadError: true);
    await _loadExisting(id);
  }

  void setName(String name) => state = state.copyWith(name: name);

  void setType(AccountType type) => state = state.copyWith(type: type);

  void setCurrency(String currency) => state = state.copyWith(currency: currency);

  void setOpeningBalance(double openingBalance) =>
      state = state.copyWith(openingBalance: openingBalance);

  void setDescription(String description) =>
      state = state.copyWith(description: description);

  Future<Result<Account>> submit() async {
    final errors = _validate(state);
    state = state.copyWith(
      fieldErrors: errors,
      showValidationErrors: true,
      clearSubmitError: true,
    );

    if (errors.isNotEmpty) {
      return const Result.err(
        ValidationFailure(message: 'Please fix the highlighted fields'),
      );
    }

    state = state.copyWith(isSubmitting: true);
    final repository = ref.read(accountsRepositoryProvider);
    final data = AccountFormData(
      name: state.name,
      type: state.type,
      currency: state.currency,
      openingBalance: state.openingBalance!,
      description: state.description,
    );

    try {
      final saved = state.isEditMode
          ? await repository.updateAccount(state.accountId!, data)
          : await repository.createAccount(data);

      // Create/update responses don't include a fresh `balance` — for an
      // edit, keep displaying the account's actual known balance instead
      // of the response's opening-balance fallback.
      final result = state.isEditMode && state.knownBalance != null
          ? saved.copyWith(balance: state.knownBalance)
          : saved;

      ref.read(accountsListControllerProvider.notifier).upsertLocal(result);
      state = state.copyWith(isSubmitting: false, knownBalance: result.balance);
      return Result.ok(result);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isSubmitting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Future<Result<void>> delete() async {
    final id = state.accountId;
    if (id == null) return const Result.ok(null);

    state = state.copyWith(isDeleting: true, clearSubmitError: true);
    final repository = ref.read(accountsRepositoryProvider);

    try {
      await repository.deleteAccount(id);
      ref.read(accountsListControllerProvider.notifier).removeLocal(id);
      state = state.copyWith(isDeleting: false);
      return const Result.ok(null);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isDeleting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Future<Result<Account>> toggleArchive() async {
    final id = state.accountId;
    if (id == null) return const Result.err(UnknownFailure());

    state = state.copyWith(isTogglingArchive: true, clearSubmitError: true);
    final repository = ref.read(accountsRepositoryProvider);

    try {
      final updated = state.isArchived
          ? await repository.unarchiveAccount(id)
          : await repository.archiveAccount(id);
      final result = state.knownBalance != null
          ? updated.copyWith(balance: state.knownBalance)
          : updated;

      ref.read(accountsListControllerProvider.notifier).upsertLocal(result);
      state = state.copyWith(
        isTogglingArchive: false,
        isArchived: result.isArchived,
      );
      return Result.ok(result);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isTogglingArchive: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Map<String, String> _validate(AccountFormState s) {
    final errors = <String, String>{};

    if (s.name.trim().isEmpty) {
      errors['name'] = 'Enter an account name';
    }
    if (s.currency.trim().length != 3) {
      errors['currency'] = 'Select a currency';
    }
    if (s.openingBalance == null) {
      errors['openingBalance'] = 'Enter an opening balance';
    } else if (s.openingBalance! < 0) {
      errors['openingBalance'] = 'Opening balance cannot be negative';
    }

    return errors;
  }
}

final accountFormControllerProvider = NotifierProvider.autoDispose
    .family<AccountFormController, AccountFormState, String?>(
      AccountFormController.new,
    );
