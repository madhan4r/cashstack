import '../../../core/error/failure.dart';
import '../models/account.dart';
import '../models/account_stats.dart';

enum AccountDetailsStatus { loading, loaded, error }

/// State for [AccountDetailsController] — the account itself plus its
/// ledger stats, fetched together.
class AccountDetailsState {
  final Account? account;
  final AccountStats? stats;
  final AccountDetailsStatus status;
  final Failure? error;

  const AccountDetailsState({
    this.account,
    this.stats,
    this.status = AccountDetailsStatus.loading,
    this.error,
  });

  AccountDetailsState copyWith({
    Account? account,
    AccountStats? stats,
    AccountDetailsStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return AccountDetailsState(
      account: account ?? this.account,
      stats: stats ?? this.stats,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
