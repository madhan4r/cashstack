import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/app_fab.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../models/account.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class AccountsListScreen extends ConsumerStatefulWidget {
  const AccountsListScreen({super.key});

  @override
  ConsumerState<AccountsListScreen> createState() => _AccountsListScreenState();
}

class _AccountsListScreenState extends ConsumerState<AccountsListScreen> {
  bool _isSearching = false;

  void _toggleSearch() {
    setState(() => _isSearching = !_isSearching);
    if (!_isSearching) {
      ref.read(accountsFilterProvider.notifier).updateSearch('');
    }
  }

  void _onTapAccount(Account account) {
    context.push(AppRoutes.accountDetails(account.id));
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(accountsListControllerProvider);
    final filter = ref.watch(accountsFilterProvider);
    final accounts = ref.watch(filteredAccountsProvider);

    return Scaffold(
      appBar: CashStackAppBar(
        title: _isSearching ? null : 'Accounts',
        titleWidget: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search accounts',
                  border: InputBorder.none,
                ),
                onChanged: (value) =>
                    ref.read(accountsFilterProvider.notifier).updateSearch(value),
              )
            : null,
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearching ? 'Close search' : 'Search',
          ),
          if (!_isSearching)
            IconButton(
              onPressed: () => ref
                  .read(accountsFilterProvider.notifier)
                  .setShowArchived(!filter.showArchived),
              icon: Icon(
                filter.showArchived
                    ? Icons.archive_rounded
                    : Icons.archive_outlined,
              ),
              tooltip: filter.showArchived ? 'Hide archived' : 'Show archived',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(accountsListControllerProvider.notifier).refresh(),
        child: switch (listState.status) {
          AccountsListStatus.loading => const ScrollableSingleChild(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AccountsSkeleton(),
              ),
            ),
          AccountsListStatus.error => ScrollableSingleChild(
              child: ErrorState.fromFailure(
                listState.error ?? const UnknownFailure(),
                onRetry: () => ref.read(accountsListControllerProvider.notifier).refresh(),
              ),
            ),
          _ when accounts.isEmpty => ScrollableSingleChild(
              child: AccountsEmptyState(
                hasActiveSearch: filter.search.isNotEmpty,
                onClearSearch: filter.search.isNotEmpty
                    ? () {
                        ref.read(accountsFilterProvider.notifier).updateSearch('');
                        if (_isSearching) _toggleSearch();
                      }
                    : null,
                onAddAccount: () => context.push(AppRoutes.addAccount),
              ),
            ),
          _ => ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final account = accounts[index];
                return AccountListItem(
                  account: account,
                  onTap: () => _onTapAccount(account),
                );
              },
            ),
        },
      ),
      floatingActionButton: AppFab(
        onPressed: () => context.push(AppRoutes.addAccount),
      ),
    );
  }
}
