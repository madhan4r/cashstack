import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../models/account.dart';
import '../repositories/accounts_repository.dart';
import 'accounts_filter_provider.dart';
import 'accounts_list_state.dart';

/// Drives the Accounts list: initial load, pull-to-refresh, and local
/// mutation after archive/unarchive/delete so the list reflects those
/// actions immediately without a full refetch.
class AccountsListController extends Notifier<AccountsListState> {
  @override
  AccountsListState build() {
    unawaited(_load());
    return const AccountsListState();
  }

  Future<void> _load() async {
    final repository = ref.read(accountsRepositoryProvider);
    try {
      final accounts = await repository.getAccounts();
      state = state.copyWith(
        accounts: accounts,
        status: AccountsListStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AccountsListStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: AccountsListStatus.refreshing);
    await _load();
  }

  /// Replaces a single account in the cached list (e.g. after archiving or
  /// editing it elsewhere) without refetching the whole list.
  void upsertLocal(Account account) {
    final index = state.accounts.indexWhere((a) => a.id == account.id);
    final updated = [...state.accounts];
    if (index == -1) {
      updated.add(account);
    } else {
      updated[index] = account;
    }
    state = state.copyWith(accounts: updated);
  }

  void removeLocal(String accountId) {
    state = state.copyWith(
      accounts: state.accounts.where((a) => a.id != accountId).toList(),
    );
  }
}

final accountsListControllerProvider =
    NotifierProvider<AccountsListController, AccountsListState>(
      AccountsListController.new,
    );

/// The accounts list after applying [accountsFilterProvider]'s search text
/// and archived-visibility toggle.
final filteredAccountsProvider = Provider<List<Account>>((ref) {
  final state = ref.watch(accountsListControllerProvider);
  final filter = ref.watch(accountsFilterProvider);

  var accounts = state.accounts;
  if (!filter.showArchived) {
    accounts = accounts.where((a) => !a.isArchived).toList();
  }
  final query = filter.search.trim().toLowerCase();
  if (query.isNotEmpty) {
    accounts = accounts.where((a) => a.name.toLowerCase().contains(query)).toList();
  }
  return accounts;
});
