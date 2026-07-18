import '../../../core/error/failure.dart';
import '../models/account.dart';

enum AccountsListStatus { loading, refreshing, loaded, error }

/// State for [AccountsListController]. The backend returns the full,
/// unpaginated account list in one call, so unlike Transactions there's no
/// infinite-scroll status — just loading/refreshing/loaded/error.
class AccountsListState {
  final List<Account> accounts;
  final AccountsListStatus status;
  final Failure? error;

  const AccountsListState({
    this.accounts = const [],
    this.status = AccountsListStatus.loading,
    this.error,
  });

  bool get isInitialLoading =>
      status == AccountsListStatus.loading && accounts.isEmpty;

  AccountsListState copyWith({
    List<Account>? accounts,
    AccountsListStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return AccountsListState(
      accounts: accounts ?? this.accounts,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
