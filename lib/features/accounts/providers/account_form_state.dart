import '../../../core/error/failure.dart';
import '../models/account.dart';
import '../models/account_type.dart';
import '../../../core/utils/currency.dart';

/// State for [AccountFormController]. `accountId == null` means Add mode;
/// otherwise Edit mode, and [isLoadingInitial]/[loadError] reflect fetching
/// the existing account to populate the form.
class AccountFormState {
  final String? accountId;
  final bool isLoadingInitial;
  final Failure? loadError;

  final String name;
  final AccountType type;
  final String currency;
  final double? openingBalance;
  final String description;

  /// The account's current computed balance, captured when an existing
  /// account is loaded. Create/update responses don't include a fresh
  /// `balance` (only `GET /accounts` and `GET /accounts/:id` do), so this
  /// is what the caller should display after a successful edit rather than
  /// trusting the submit response's balance (which — for an account with
  /// existing transactions — would incorrectly fall back to its opening
  /// balance).
  final double? knownBalance;
  final bool isArchived;

  /// Only shown once the user has attempted to submit.
  final bool showValidationErrors;
  final Map<String, String> fieldErrors;

  final bool isSubmitting;
  final bool isDeleting;
  final bool isTogglingArchive;
  final Failure? submitError;

  const AccountFormState({
    this.accountId,
    this.isLoadingInitial = false,
    this.loadError,
    this.name = '',
    this.type = AccountType.bank,
    this.currency = 'INR',
    this.openingBalance,
    this.description = '',
    this.knownBalance,
    this.isArchived = false,
    this.showValidationErrors = false,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.isDeleting = false,
    this.isTogglingArchive = false,
    this.submitError,
  });

  bool get isEditMode => accountId != null;

  factory AccountFormState.initial({String? accountId}) {
    return AccountFormState(
      accountId: accountId,
      isLoadingInitial: accountId != null,
      openingBalance: accountId == null ? 0 : null,
      currency: supportedCurrencies.first.code,
    );
  }

  factory AccountFormState.fromAccount(Account account) {
    return AccountFormState(
      accountId: account.id,
      isLoadingInitial: false,
      name: account.name,
      type: account.type,
      currency: account.currency,
      openingBalance: account.openingBalance,
      description: account.description ?? '',
      knownBalance: account.balance,
      isArchived: account.isArchived,
    );
  }

  AccountFormState copyWith({
    bool? isLoadingInitial,
    Failure? loadError,
    bool clearLoadError = false,
    String? name,
    AccountType? type,
    String? currency,
    double? openingBalance,
    String? description,
    double? knownBalance,
    bool? isArchived,
    bool? showValidationErrors,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
    bool? isDeleting,
    bool? isTogglingArchive,
    Failure? submitError,
    bool clearSubmitError = false,
  }) {
    return AccountFormState(
      accountId: accountId,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      openingBalance: openingBalance ?? this.openingBalance,
      description: description ?? this.description,
      knownBalance: knownBalance ?? this.knownBalance,
      isArchived: isArchived ?? this.isArchived,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      isTogglingArchive: isTogglingArchive ?? this.isTogglingArchive,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
