import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accounts_filter.dart';

/// The active search text + "show archived" toggle for the Accounts list.
class AccountsFilterController extends Notifier<AccountsFilter> {
  @override
  AccountsFilter build() => const AccountsFilter();

  void updateSearch(String search) {
    state = state.copyWith(search: search);
  }

  void setShowArchived(bool showArchived) {
    state = state.copyWith(showArchived: showArchived);
  }
}

final accountsFilterProvider =
    NotifierProvider<AccountsFilterController, AccountsFilter>(
      AccountsFilterController.new,
    );
