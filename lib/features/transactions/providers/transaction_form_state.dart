import 'package:flutter/material.dart' show TimeOfDay;

import '../../../core/error/failure.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/payment_method.dart';
import '../models/transaction.dart';

/// State for [TransactionFormController]. `transactionId == null` means
/// Add mode; otherwise Edit mode, and [isLoadingInitial]/[loadError]
/// reflect fetching the existing transaction to populate the form.
class TransactionFormState {
  final String? transactionId;
  final bool isLoadingInitial;
  final Failure? loadError;

  final TransactionKind type;
  final double? amount;
  final String? accountId;
  final String? categoryId;
  final String? fromAccountId;
  final String? toAccountId;
  final DateTime date;
  final TimeOfDay time;
  final String notes;
  final PaymentMethod? paymentMethod;
  final List<String> tags;

  /// Only shown once the user has attempted to submit — avoids greeting a
  /// blank form with a wall of red errors.
  final bool showValidationErrors;
  final Map<String, String> fieldErrors;

  final bool isSubmitting;
  final bool isDeleting;
  final Failure? submitError;

  const TransactionFormState({
    this.transactionId,
    this.isLoadingInitial = false,
    this.loadError,
    this.type = TransactionKind.expense,
    this.amount,
    this.accountId,
    this.categoryId,
    this.fromAccountId,
    this.toAccountId,
    required this.date,
    required this.time,
    this.notes = '',
    this.paymentMethod,
    this.tags = const [],
    this.showValidationErrors = false,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.isDeleting = false,
    this.submitError,
  });

  bool get isEditMode => transactionId != null;

  DateTime get combinedDateTime =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  factory TransactionFormState.initial({String? transactionId}) {
    final now = DateTime.now();
    return TransactionFormState(
      transactionId: transactionId,
      isLoadingInitial: transactionId != null,
      date: DateTime(now.year, now.month, now.day),
      time: TimeOfDay(hour: now.hour, minute: now.minute),
    );
  }

  factory TransactionFormState.fromTransaction(Transaction transaction) {
    final local = transaction.transactionDate.toLocal();
    return TransactionFormState(
      transactionId: transaction.id,
      isLoadingInitial: false,
      type: transaction.kind,
      amount: transaction.amount,
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      fromAccountId: transaction.fromAccountId,
      toAccountId: transaction.toAccountId,
      date: DateTime(local.year, local.month, local.day),
      time: TimeOfDay(hour: local.hour, minute: local.minute),
      notes: transaction.notes ?? '',
      paymentMethod: transaction.paymentMethod,
      tags: transaction.tags,
    );
  }

  TransactionFormState copyWith({
    bool? isLoadingInitial,
    Failure? loadError,
    bool clearLoadError = false,
    TransactionKind? type,
    double? amount,
    String? accountId,
    bool clearAccountId = false,
    String? categoryId,
    bool clearCategoryId = false,
    String? fromAccountId,
    bool clearFromAccountId = false,
    String? toAccountId,
    bool clearToAccountId = false,
    DateTime? date,
    TimeOfDay? time,
    String? notes,
    PaymentMethod? paymentMethod,
    bool clearPaymentMethod = false,
    List<String>? tags,
    bool? showValidationErrors,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
    bool? isDeleting,
    Failure? submitError,
    bool clearSubmitError = false,
  }) {
    return TransactionFormState(
      transactionId: transactionId,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      fromAccountId:
          clearFromAccountId ? null : (fromAccountId ?? this.fromAccountId),
      toAccountId: clearToAccountId ? null : (toAccountId ?? this.toAccountId),
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      paymentMethod:
          clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
      tags: tags ?? this.tags,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
