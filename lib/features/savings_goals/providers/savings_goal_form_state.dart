import '../../../core/error/failure.dart';
import '../models/savings_goal.dart';

/// State for [SavingsGoalFormController]. `goalId == null` means Add mode;
/// otherwise Edit/Detail mode, and [isLoadingInitial]/[loadError] reflect
/// fetching the existing goal.
class SavingsGoalFormState {
  final String? goalId;
  final bool isLoadingInitial;
  final Failure? loadError;

  final String name;
  final double? targetAmount;
  final DateTime? targetDate;
  final String? icon;
  final String? color;
  final double currentAmount;

  final bool showValidationErrors;
  final Map<String, String> fieldErrors;

  final bool isSubmitting;
  final bool isDeleting;
  final bool isContributing;
  final Failure? submitError;

  const SavingsGoalFormState({
    this.goalId,
    this.isLoadingInitial = false,
    this.loadError,
    this.name = '',
    this.targetAmount,
    this.targetDate,
    this.icon,
    this.color,
    this.currentAmount = 0,
    this.showValidationErrors = false,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.isDeleting = false,
    this.isContributing = false,
    this.submitError,
  });

  bool get isEditMode => goalId != null;

  factory SavingsGoalFormState.initial({String? goalId}) {
    return SavingsGoalFormState(goalId: goalId, isLoadingInitial: goalId != null);
  }

  factory SavingsGoalFormState.fromGoal(SavingsGoal goal) {
    return SavingsGoalFormState(
      goalId: goal.id,
      isLoadingInitial: false,
      name: goal.name,
      targetAmount: goal.targetAmount,
      targetDate: goal.targetDate,
      icon: goal.icon,
      color: goal.color,
      currentAmount: goal.currentAmount,
    );
  }

  SavingsGoalFormState copyWith({
    bool? isLoadingInitial,
    Failure? loadError,
    bool clearLoadError = false,
    String? name,
    double? targetAmount,
    DateTime? targetDate,
    bool clearTargetDate = false,
    String? icon,
    String? color,
    double? currentAmount,
    bool? showValidationErrors,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
    bool? isDeleting,
    bool? isContributing,
    Failure? submitError,
    bool clearSubmitError = false,
  }) {
    return SavingsGoalFormState(
      goalId: goalId,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      icon: icon ?? this.icon,
      color: color ?? this.color,
      currentAmount: currentAmount ?? this.currentAmount,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      isContributing: isContributing ?? this.isContributing,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
