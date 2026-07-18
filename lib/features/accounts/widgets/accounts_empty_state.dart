import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/empty_state.dart';

/// Shown when the Accounts list has nothing to display. Copy adapts to
/// whether search/the archived filter is narrowing an otherwise non-empty
/// list, vs. a brand-new user with no accounts at all.
class AccountsEmptyState extends StatelessWidget {
  final bool hasActiveSearch;
  final VoidCallback? onClearSearch;
  final VoidCallback? onAddAccount;

  const AccountsEmptyState({
    super.key,
    required this.hasActiveSearch,
    this.onClearSearch,
    this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    if (hasActiveSearch) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching accounts',
        description: 'Try a different search term.',
        actionLabel: onClearSearch == null ? null : 'Clear search',
        onAction: onClearSearch,
      );
    }

    return EmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'No accounts yet',
      description: 'Add your first account to start tracking your money.',
      actionLabel: onAddAccount == null ? null : 'Add Account',
      onAction: onAddAccount,
    );
  }
}
