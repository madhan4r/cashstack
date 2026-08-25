import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/misc/section_header.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../../transactions/models/account_ref.dart';
import '../../transactions/models/category_ref.dart';
import '../../transactions/providers/reference_data_provider.dart';
import '../../transactions/providers/transactions_list_state.dart';
import '../../transactions/widgets/transaction_list_tile.dart';
import '../models/category.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailsScreen({super.key, required this.categoryId});

  Future<void> _handleToggleArchive(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showArchiveCategoryConfirmation(
      context: context,
      categoryName: category.name,
      isCurrentlyArchived: category.isArchived,
      hasTransactions: category.transactionCount > 0,
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref
        .read(categoryDetailsControllerProvider(categoryId).notifier)
        .toggleArchive();
    if (!context.mounted) return;

    result.when(
      ok: (updated) => ref
          .read(snackbarServiceProvider)
          .showSuccess(updated.isArchived ? 'Category archived' : 'Category unarchived'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(categoryDetailsControllerProvider(categoryId));
    final transactionsState = ref.watch(
      categoryTransactionsControllerProvider(categoryId),
    );
    final referenceDataAsync = ref.watch(referenceDataProvider);
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);

    ref.listen(categoryTransactionsControllerProvider(categoryId), (previous, next) {
      final error = next.backgroundError;
      if (error != null && error != previous?.backgroundError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
        ref
            .read(categoryTransactionsControllerProvider(categoryId).notifier)
            .dismissBackgroundError();
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: detailsState.category?.name ?? 'Category',
        actions: [
          if (detailsState.category case final category?) ...[
            IconButton(
              onPressed: detailsState.isTogglingArchive
                  ? null
                  : () => _handleToggleArchive(context, ref, category),
              icon: detailsState.isTogglingArchive
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      category.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                    ),
              tooltip: category.isArchived ? 'Unarchive category' : 'Archive category',
            ),
            IconButton(
              onPressed: () => context.push(AppRoutes.editCategory(categoryId)),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit category',
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(categoryDetailsControllerProvider(categoryId).notifier).refresh();
          await ref
              .read(categoryTransactionsControllerProvider(categoryId).notifier)
              .refresh();
        },
        child: switch (detailsState.status) {
          CategoryDetailsStatus.loading => const ScrollableSingleChild(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: ShimmerCardPlaceholder(height: 220),
              ),
            ),
          CategoryDetailsStatus.error => ScrollableSingleChild(
              child: ErrorState.fromFailure(
                detailsState.error ?? const UnknownFailure(),
                onRetry: () =>
                    ref.read(categoryDetailsControllerProvider(categoryId).notifier).refresh(),
              ),
            ),
          CategoryDetailsStatus.loaded => _CategoryDetailsContent(
              category: detailsState.category!,
              transactionsState: transactionsState,
              referenceDataAsync: referenceDataAsync,
              currencySymbol: currencySymbol,
              onLoadMore: () => ref
                  .read(categoryTransactionsControllerProvider(categoryId).notifier)
                  .loadNextPage(),
            ),
        },
      ),
    );
  }
}

class _CategoryDetailsContent extends StatelessWidget {
  final Category category;
  final TransactionsListState transactionsState;
  final AsyncValue<ReferenceData> referenceDataAsync;
  final String currencySymbol;
  final VoidCallback onLoadMore;

  const _CategoryDetailsContent({
    required this.category,
    required this.transactionsState,
    required this.referenceDataAsync,
    required this.currencySymbol,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(category.color, fallback: context.colors.primary);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(categoryIconFor(category.icon), color: tint, size: 26),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: context.textStyles.titleLarge),
                  const SizedBox(height: 4),
                  CategoryTypeChip(type: category.type),
                ],
              ),
            ),
          ],
        ),
        if (category.description?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            category.description!,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Statistics'),
        const SizedBox(height: AppSpacing.sm),
        CategoryStatsGrid(category: category, currencySymbol: currencySymbol),
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
          'No transactions in this category yet.',
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
