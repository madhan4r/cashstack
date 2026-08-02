import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/misc/section_header.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../transactions/models/account_ref.dart';
import '../../transactions/models/category_ref.dart';
import '../../transactions/providers/reference_data_provider.dart';
import '../../transactions/providers/transactions_list_state.dart';
import '../../transactions/widgets/transaction_list_tile.dart';
import '../models/account.dart';
import '../models/account_stats.dart';
import '../../../core/utils/currency.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class AccountDetailsScreen extends ConsumerWidget {
  final String accountId;

  const AccountDetailsScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(accountDetailsControllerProvider(accountId));
    final transactionsState = ref.watch(
      accountTransactionsControllerProvider(accountId),
    );
    final referenceDataAsync = ref.watch(referenceDataProvider);

    ref.listen(accountTransactionsControllerProvider(accountId), (previous, next) {
      final error = next.backgroundError;
      if (error != null && error != previous?.backgroundError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
        ref
            .read(accountTransactionsControllerProvider(accountId).notifier)
            .dismissBackgroundError();
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: detailsState.account?.name ?? 'Account',
        actions: [
          if (detailsState.account != null)
            IconButton(
              onPressed: () => context.push(AppRoutes.editAccount(accountId)),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit account',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(accountDetailsControllerProvider(accountId).notifier).refresh();
          await ref
              .read(accountTransactionsControllerProvider(accountId).notifier)
              .refresh();
        },
        child: switch (detailsState.status) {
          AccountDetailsStatus.loading => const ScrollableSingleChild(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: ShimmerCardPlaceholder(height: 220),
              ),
            ),
          AccountDetailsStatus.error => ScrollableSingleChild(
              child: ErrorState.fromFailure(
                detailsState.error ?? const UnknownFailure(),
                onRetry: () =>
                    ref.read(accountDetailsControllerProvider(accountId).notifier).refresh(),
              ),
            ),
          AccountDetailsStatus.loaded => _AccountDetailsContent(
              account: detailsState.account!,
              stats: detailsState.stats!,
              transactionsState: transactionsState,
              referenceDataAsync: referenceDataAsync,
              onLoadMore: () => ref
                  .read(accountTransactionsControllerProvider(accountId).notifier)
                  .loadNextPage(),
            ),
        },
      ),
    );
  }
}

class _AccountDetailsContent extends StatelessWidget {
  final Account account;
  final AccountStats stats;
  final TransactionsListState transactionsState;
  final AsyncValue<ReferenceData> referenceDataAsync;
  final VoidCallback onLoadMore;

  const _AccountDetailsContent({
    required this.account,
    required this.stats,
    required this.transactionsState,
    required this.referenceDataAsync,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol = currencySymbolFor(account.currency);
    final tint = colorFromHex(account.color, fallback: context.colors.primary);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(account.type.icon, color: tint, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            AccountTypeChip(type: account.type),
            const SizedBox(width: AppSpacing.sm),
            Text(
              account.currency,
              style: context.textStyles.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        BalanceWidget(balance: account.balance, currencySymbol: currencySymbol),
        if (account.description?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            account.description!,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Statistics'),
        const SizedBox(height: AppSpacing.sm),
        AccountStatsGrid(stats: stats, currencySymbol: currencySymbol),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Recent Transactions'),
        const SizedBox(height: AppSpacing.sm),
        referenceDataAsync.when(
          data: (referenceData) => _TransactionsSection(
            transactionsState: transactionsState,
            categoriesById: referenceData.categoriesById,
            accountsById: referenceData.accountsById,
            onLoadMore: onLoadMore,
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: ShimmerLoading(child: ShimmerBox(height: 80)),
          ),
          error: (error, _) => Text(
            'Couldn\'t load transaction history.',
            style: context.textStyles.bodySmall?.copyWith(color: context.colors.error),
          ),
        ),
      ],
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  final TransactionsListState transactionsState;
  final Map<String, CategoryRef> categoriesById;
  final Map<String, AccountRef> accountsById;
  final VoidCallback onLoadMore;

  const _TransactionsSection({
    required this.transactionsState,
    required this.categoriesById,
    required this.accountsById,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (transactionsState.status == TransactionsListStatus.loading) {
      return const ShimmerLoading(child: ShimmerListPlaceholder(itemCount: 3));
    }
    if (transactionsState.status == TransactionsListStatus.error) {
      return ErrorState.fromFailure(transactionsState.error ?? const UnknownFailure());
    }
    if (transactionsState.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          'No transactions on this account yet.',
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final transaction in transactionsState.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TransactionListTile(
              transaction: transaction,
              category: categoriesById[transaction.categoryId],
              account: accountsById[transaction.accountId],
              onTap: () => context.push(AppRoutes.editTransaction(transaction.id)),
            ),
          ),
        if (transactionsState.hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: transactionsState.status == TransactionsListStatus.loadingMore
                  ? const CircularProgressIndicator()
                  : TextButton(onPressed: onLoadMore, child: const Text('Load more')),
            ),
          ),
      ],
    );
  }
}
