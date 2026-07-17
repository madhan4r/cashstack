import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/widgets/feedback/app_toast.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/app_fab.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../models/transaction.dart';
import '../models/transaction_sort_option.dart';
import '../providers/providers.dart';
import '../widgets/transaction_list.dart';
import '../widgets/transactions_empty_state.dart';
import '../widgets/transactions_filter_sheet.dart';
import '../widgets/transactions_search_bar.dart';
import '../widgets/transactions_skeleton.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  bool _isSearching = false;

  void _toggleSearch() {
    setState(() => _isSearching = !_isSearching);
    if (!_isSearching) {
      ref.read(transactionFilterProvider.notifier).updateSearch('');
    }
  }

  Future<void> _openFilterSheet() async {
    final currentFilter = ref.read(transactionFilterProvider);
    final applied = await showTransactionsFilterSheet(
      context: context,
      currentFilter: currentFilter,
    );
    if (applied != null) {
      ref.read(transactionFilterProvider.notifier).applyFilters(applied);
    }
  }

  void _onTapTransaction(Transaction transaction) {
    AppToast.show(context, 'Transaction details are coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(transactionsListControllerProvider);
    final filter = ref.watch(transactionFilterProvider);
    final referenceDataAsync = ref.watch(referenceDataProvider);

    ref.listen(transactionsListControllerProvider, (previous, next) {
      final error = next.backgroundError;
      if (error != null && error != previous?.backgroundError) {
        ref.read(snackbarServiceProvider).showError(error.message);
        ref.read(transactionsListControllerProvider.notifier).dismissBackgroundError();
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: _isSearching ? null : 'Transactions',
        titleWidget: _isSearching
            ? TransactionsSearchBar(
                onSearchChanged: (value) =>
                    ref.read(transactionFilterProvider.notifier).updateSearch(value),
              )
            : null,
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearching ? 'Close search' : 'Search',
          ),
          if (!_isSearching) ...[
            _SortButton(
              current: filter.sort,
              onSelected: (sort) =>
                  ref.read(transactionFilterProvider.notifier).updateSort(sort),
            ),
            _FilterButton(
              hasActiveFilters: filter.hasActiveFilters,
              onPressed: _openFilterSheet,
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionsListControllerProvider.notifier).refresh(),
        child: switch (listState.status) {
          TransactionsListStatus.loading => const ScrollableSingleChild(
              child: TransactionsSkeleton(),
            ),
          TransactionsListStatus.error => ScrollableSingleChild(
              child: ErrorState.fromFailure(
                listState.error ?? const UnknownFailure(),
                onRetry: () => ref.invalidate(transactionsListControllerProvider),
              ),
            ),
          _ when listState.isEmpty => ScrollableSingleChild(
              child: TransactionsEmptyState(
                hasActiveSearchOrFilters:
                    filter.hasActiveFilters || filter.search.isNotEmpty,
                onClearFilters: filter.hasActiveFilters || filter.search.isNotEmpty
                    ? () {
                        ref.read(transactionFilterProvider.notifier).clearFilters();
                        if (_isSearching) _toggleSearch();
                      }
                    : null,
                onAddTransaction: () =>
                    AppToast.show(context, 'Add Transaction is coming soon'),
              ),
            ),
          _ => referenceDataAsync.when(
              data: (referenceData) => TransactionList(
                transactions: listState.items,
                categoriesById: referenceData.categoriesById,
                accountsById: referenceData.accountsById,
                isLoadingMore: listState.status == TransactionsListStatus.loadingMore,
                hasMore: listState.hasMore,
                onLoadMore: () =>
                    ref.read(transactionsListControllerProvider.notifier).loadNextPage(),
                onTapTransaction: _onTapTransaction,
              ),
              loading: () => const ScrollableSingleChild(child: TransactionsSkeleton()),
              error: (error, _) => ScrollableSingleChild(
                child: ErrorState.fromFailure(
                  error is Failure ? error : const UnknownFailure(),
                  onRetry: () => ref.invalidate(referenceDataProvider),
                ),
              ),
            ),
        },
      ),
      floatingActionButton: AppFab(
        onPressed: () => AppToast.show(context, 'Add Transaction is coming soon'),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final TransactionSortOption current;
  final ValueChanged<TransactionSortOption> onSelected;

  const _SortButton({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TransactionSortOption>(
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'Sort',
      initialValue: current,
      onSelected: onSelected,
      itemBuilder: (context) => TransactionSortOption.values
          .map(
            (option) => PopupMenuItem(
              value: option,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(option.label),
                  if (option == current)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onPressed;

  const _FilterButton({required this.hasActiveFilters, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Filter',
        ),
        if (hasActiveFilters)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
