import 'dart:async';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/payment_method.dart';
import '../models/transaction.dart';
import '../models/transaction_form_data.dart';
import '../../categories/providers/category_preferences_provider.dart';
import '../repositories/transactions_repository.dart';
import 'transaction_form_state.dart';

/// Drives the Add/Edit Transaction form. Keyed by `transactionId` (`null`
/// for Add mode) so editing a different transaction — or opening a fresh
/// Add screen — always starts from clean state; `autoDispose` tears it
/// down when the form screen is popped.
///
/// Riverpod's non-codegen family notifiers receive the family argument via
/// the constructor (not a parameterized `build()`) — see
/// `NotifierProviderFamily`'s `NotifierT Function(ArgT arg)` factory.
class TransactionFormController extends Notifier<TransactionFormState> {
  final String? transactionId;

  TransactionFormController(this.transactionId);

  @override
  TransactionFormState build() {
    final id = transactionId;
    if (id != null) {
      unawaited(_loadExisting(id));
    }
    return TransactionFormState.initial(transactionId: id);
  }

  Future<void> _loadExisting(String id) async {
    final repository = ref.read(transactionsRepositoryProvider);
    try {
      final transaction = await repository.getTransaction(id);
      state = TransactionFormState.fromTransaction(transaction);
    } catch (error) {
      state = state.copyWith(
        isLoadingInitial: false,
        loadError: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> retryLoad() async {
    final id = state.transactionId;
    if (id == null) return;
    state = state.copyWith(isLoadingInitial: true, clearLoadError: true);
    await _loadExisting(id);
  }

  void setType(TransactionKind type) {
    if (type == state.type) return;
    final isTransfer = type == TransactionKind.transfer;
    state = state.copyWith(
      type: type,
      clearCategoryId: true,
      clearAccountId: isTransfer,
      clearFromAccountId: !isTransfer,
      clearToAccountId: !isTransfer,
      fieldErrors: const {},
    );
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setAccount(String accountId) {
    state = state.copyWith(accountId: accountId);
  }

  void setCategory(String categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setFromAccount(String accountId) {
    state = state.copyWith(fromAccountId: accountId);
  }

  void setToAccount(String accountId) {
    state = state.copyWith(toAccountId: accountId);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(time: time);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void setPaymentMethod(PaymentMethod? method) {
    state = state.copyWith(
      paymentMethod: method,
      clearPaymentMethod: method == null,
    );
  }

  Future<Result<Transaction>> submit() async {
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
    final repository = ref.read(transactionsRepositoryProvider);
    final data = TransactionFormData(
      type: state.type,
      amount: state.amount!,
      accountId: state.accountId,
      categoryId: state.categoryId,
      fromAccountId: state.fromAccountId,
      toAccountId: state.toAccountId,
      notes: state.notes,
      paymentMethod: state.paymentMethod,
      transactionDate: state.combinedDateTime,
      tags: state.tags,
    );

    try {
      final transaction = state.isEditMode
          ? await repository.updateTransaction(state.transactionId!, data)
          : await repository.createTransaction(data);

      if (state.categoryId != null) {
        await ref
            .read(categoryPreferencesProvider.notifier)
            .recordUsed(state.categoryId!);
      }

      state = state.copyWith(isSubmitting: false);
      return Result.ok(transaction);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isSubmitting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Future<Result<void>> delete() async {
    final id = state.transactionId;
    if (id == null) return const Result.ok(null);

    state = state.copyWith(isDeleting: true, clearSubmitError: true);
    final repository = ref.read(transactionsRepositoryProvider);

    try {
      await repository.deleteTransaction(id);
      state = state.copyWith(isDeleting: false);
      return const Result.ok(null);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isDeleting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Map<String, String> _validate(TransactionFormState s) {
    final errors = <String, String>{};

    if (s.amount == null || s.amount! <= 0) {
      errors['amount'] = 'Enter an amount greater than 0';
    }

    if (s.type == TransactionKind.transfer) {
      if (s.fromAccountId == null) {
        errors['fromAccount'] = 'Select a source account';
      }
      if (s.toAccountId == null) {
        errors['toAccount'] = 'Select a destination account';
      }
      if (s.fromAccountId != null &&
          s.toAccountId != null &&
          s.fromAccountId == s.toAccountId) {
        errors['toAccount'] = 'Source and destination accounts must be different';
      }
    } else {
      if (s.accountId == null) {
        errors['account'] = 'Select an account';
      }
      if (s.categoryId == null) {
        errors['category'] = 'Select a category';
      }
    }

    return errors;
  }
}

final transactionFormControllerProvider = NotifierProvider.autoDispose
    .family<TransactionFormController, TransactionFormState, String?>(
      TransactionFormController.new,
    );
