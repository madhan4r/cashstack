import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../models/account.dart';
import '../models/account_stats.dart';
import '../repositories/accounts_repository.dart';
import 'account_details_state.dart';

/// Drives the Account Details screen's header/stats — keyed by
/// `accountId`, `autoDispose` so it tears down when the screen is popped.
class AccountDetailsController extends Notifier<AccountDetailsState> {
  final String accountId;

  AccountDetailsController(this.accountId);

  @override
  AccountDetailsState build() {
    unawaited(_load());
    return const AccountDetailsState();
  }

  Future<void> _load() async {
    final repository = ref.read(accountsRepositoryProvider);
    try {
      final Account account;
      final AccountStats stats;
      (account, stats) = await (
        repository.getAccount(accountId),
        repository.getAccountStats(accountId),
      ).wait;
      state = state.copyWith(
        account: account,
        stats: stats,
        status: AccountDetailsStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AccountDetailsStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() => _load();
}

final accountDetailsControllerProvider = NotifierProvider.autoDispose
    .family<AccountDetailsController, AccountDetailsState, String>(
      AccountDetailsController.new,
    );
