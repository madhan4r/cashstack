import '../../../core/error/failure.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/recurrence_frequency.dart';
import '../models/recurring_status.dart';
import '../models/recurring_transaction.dart';
import '../models/reminder_option.dart';

/// State for [RecurringFormController]. `recurringId == null` means Add
/// mode; otherwise Edit mode, and [isLoadingInitial]/[loadError] reflect
/// fetching the existing schedule to populate the form.
class RecurringFormState {
  final String? recurringId;
  final bool isLoadingInitial;
  final Failure? loadError;

  final String name;
  final TransactionKind type;
  final double? amount;
  final String? categoryId;
  final String? accountId;
  final String notes;
  final RecurrenceFrequency frequency;
  final int? customIntervalDays;
  final DateTime startDate;
  final DateTime? endDate;
  final ReminderOption reminder;
  final bool autoGenerate;
  final RecurringStatus status;

  final bool showValidationErrors;
  final Map<String, String> fieldErrors;

  final bool isSubmitting;
  final bool isDeleting;
  final bool isTogglingStatus;
  final Failure? submitError;

  const RecurringFormState({
    this.recurringId,
    this.isLoadingInitial = false,
    this.loadError,
    this.name = '',
    this.type = TransactionKind.expense,
    this.amount,
    this.categoryId,
    this.accountId,
    this.notes = '',
    this.frequency = RecurrenceFrequency.monthly,
    this.customIntervalDays,
    required this.startDate,
    this.endDate,
    this.reminder = ReminderOption.oneDayBefore,
    this.autoGenerate = true,
    this.status = RecurringStatus.active,
    this.showValidationErrors = false,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.isDeleting = false,
    this.isTogglingStatus = false,
    this.submitError,
  });

  bool get isEditMode => recurringId != null;

  factory RecurringFormState.initial({String? recurringId}) {
    return RecurringFormState(
      recurringId: recurringId,
      isLoadingInitial: recurringId != null,
      startDate: DateTime.now(),
    );
  }

  factory RecurringFormState.fromRecurring(RecurringTransaction r) {
    return RecurringFormState(
      recurringId: r.id,
      isLoadingInitial: false,
      name: r.name,
      type: r.type,
      amount: r.amount,
      categoryId: r.categoryId,
      accountId: r.accountId,
      notes: r.notes ?? '',
      frequency: r.frequency,
      customIntervalDays: r.customIntervalDays,
      startDate: r.startDate,
      endDate: r.endDate,
      reminder: r.reminder,
      autoGenerate: r.autoGenerate,
      status: r.status,
    );
  }

  RecurringFormState copyWith({
    bool? isLoadingInitial,
    Failure? loadError,
    bool clearLoadError = false,
    String? name,
    TransactionKind? type,
    double? amount,
    String? categoryId,
    bool clearCategoryId = false,
    String? accountId,
    bool clearAccountId = false,
    String? notes,
    RecurrenceFrequency? frequency,
    int? customIntervalDays,
    bool clearCustomIntervalDays = false,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    ReminderOption? reminder,
    bool? autoGenerate,
    RecurringStatus? status,
    bool? showValidationErrors,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
    bool? isDeleting,
    bool? isTogglingStatus,
    Failure? submitError,
    bool clearSubmitError = false,
  }) {
    return RecurringFormState(
      recurringId: recurringId,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
      customIntervalDays: clearCustomIntervalDays
          ? null
          : (customIntervalDays ?? this.customIntervalDays),
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      reminder: reminder ?? this.reminder,
      autoGenerate: autoGenerate ?? this.autoGenerate,
      status: status ?? this.status,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      isTogglingStatus: isTogglingStatus ?? this.isTogglingStatus,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
