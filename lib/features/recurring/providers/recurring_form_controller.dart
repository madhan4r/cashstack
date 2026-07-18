import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/recurrence_frequency.dart';
import '../models/recurring_status.dart';
import '../models/recurring_transaction.dart';
import '../models/recurring_form_data.dart';
import '../models/reminder_option.dart';
import '../repositories/recurring_repository.dart';
import 'recurring_list_controller.dart';
import 'recurring_form_state.dart';

/// Drives the Add/Edit Recurring Transaction form. Keyed by `recurringId`
/// (`null` for Add mode); `autoDispose` tears it down when the form screen
/// is popped.
class RecurringFormController extends Notifier<RecurringFormState> {
  final String? recurringId;

  RecurringFormController(this.recurringId);

  @override
  RecurringFormState build() {
    final id = recurringId;
    if (id != null) {
      unawaited(_loadExisting(id));
    }
    return RecurringFormState.initial(recurringId: id);
  }

  Future<void> _loadExisting(String id) async {
    final repository = ref.read(recurringRepositoryProvider);
    try {
      final recurring = await repository.getRecurringOne(id);
      state = RecurringFormState.fromRecurring(recurring);
    } catch (error) {
      state = state.copyWith(isLoadingInitial: false, loadError: mapExceptionToFailure(error));
    }
  }

  Future<void> retryLoad() async {
    final id = state.recurringId;
    if (id == null) return;
    state = state.copyWith(isLoadingInitial: true, clearLoadError: true);
    await _loadExisting(id);
  }

  void setName(String name) => state = state.copyWith(name: name);

  void setType(TransactionKind type) {
    if (type == state.type) return;
    state = state.copyWith(type: type, clearCategoryId: true, fieldErrors: const {});
  }

  void setAmount(double amount) => state = state.copyWith(amount: amount);

  void setCategory(String categoryId) => state = state.copyWith(categoryId: categoryId);

  void setAccount(String accountId) => state = state.copyWith(accountId: accountId);

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  void setFrequency(RecurrenceFrequency frequency) {
    state = state.copyWith(
      frequency: frequency,
      clearCustomIntervalDays: frequency != RecurrenceFrequency.custom,
    );
  }

  void setCustomIntervalDays(int days) => state = state.copyWith(customIntervalDays: days);

  void setStartDate(DateTime date) => state = state.copyWith(startDate: date);

  void setEndDate(DateTime? date) =>
      state = state.copyWith(endDate: date, clearEndDate: date == null);

  void setReminder(ReminderOption reminder) => state = state.copyWith(reminder: reminder);

  void setAutoGenerate(bool value) => state = state.copyWith(autoGenerate: value);

  Future<Result<RecurringTransaction>> submit() async {
    final errors = _validate(state);
    state = state.copyWith(fieldErrors: errors, showValidationErrors: true, clearSubmitError: true);

    if (errors.isNotEmpty) {
      return const Result.err(ValidationFailure(message: 'Please fix the highlighted fields'));
    }

    state = state.copyWith(isSubmitting: true);
    final repository = ref.read(recurringRepositoryProvider);
    final data = RecurringFormData(
      name: state.name,
      type: state.type,
      amount: state.amount!,
      categoryId: state.categoryId!,
      accountId: state.accountId!,
      notes: state.notes,
      frequency: state.frequency,
      customIntervalDays: state.customIntervalDays,
      startDate: state.startDate,
      endDate: state.endDate,
      reminder: state.reminder,
      autoGenerate: state.autoGenerate,
    );

    try {
      final saved = state.isEditMode
          ? await repository.updateRecurring(state.recurringId!, data)
          : await repository.createRecurring(data);

      ref.invalidate(recurringListControllerProvider);
      state = state.copyWith(isSubmitting: false);
      return Result.ok(saved);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isSubmitting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Future<Result<void>> delete() async {
    final id = state.recurringId;
    if (id == null) return const Result.ok(null);

    state = state.copyWith(isDeleting: true, clearSubmitError: true);
    final repository = ref.read(recurringRepositoryProvider);

    try {
      await repository.deleteRecurring(id);
      ref.invalidate(recurringListControllerProvider);
      state = state.copyWith(isDeleting: false);
      return const Result.ok(null);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isDeleting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Future<Result<RecurringTransaction>> toggleStatus() async {
    final id = state.recurringId;
    if (id == null) return const Result.err(UnknownFailure());

    state = state.copyWith(isTogglingStatus: true, clearSubmitError: true);
    final repository = ref.read(recurringRepositoryProvider);

    try {
      final updated = state.status == RecurringStatus.paused
          ? await repository.resumeRecurring(id)
          : await repository.pauseRecurring(id);

      ref.invalidate(recurringListControllerProvider);
      state = state.copyWith(isTogglingStatus: false, status: updated.status);
      return Result.ok(updated);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isTogglingStatus: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Map<String, String> _validate(RecurringFormState s) {
    final errors = <String, String>{};

    if (s.name.trim().isEmpty) {
      errors['name'] = 'Enter a name';
    }
    if (s.amount == null || s.amount! <= 0) {
      errors['amount'] = 'Enter an amount greater than 0';
    }
    if (s.categoryId == null) {
      errors['category'] = 'Select a category';
    }
    if (s.accountId == null) {
      errors['account'] = 'Select an account';
    }
    if (s.frequency == RecurrenceFrequency.custom &&
        (s.customIntervalDays == null || s.customIntervalDays! < 1)) {
      errors['customIntervalDays'] = 'Enter an interval of at least 1 day';
    }
    if (s.endDate != null && !s.endDate!.isAfter(s.startDate)) {
      errors['endDate'] = 'End date must be after the start date';
    }

    return errors;
  }
}

final recurringFormControllerProvider = NotifierProvider.autoDispose
    .family<RecurringFormController, RecurringFormState, String?>(
      RecurringFormController.new,
    );
