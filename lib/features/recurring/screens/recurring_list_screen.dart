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
import '../../../core/utils/currency.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../../transactions/providers/reference_data_provider.dart';
import '../models/occurrence_status.dart';
import '../models/recurrence_frequency.dart';
import '../models/recurring_filter.dart';
import '../models/recurring_sort_option.dart';
import '../models/recurring_status.dart';
import '../models/recurring_transaction.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class RecurringListScreen extends StatelessWidget {
  const RecurringListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const CashStackAppBar(
          title: 'Recurring Transactions',
          bottom: TabBar(
            tabs: [
              Tab(text: 'Schedules'),
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_SchedulesTab(), _UpcomingTab(), _HistoryTab()],
        ),
        floatingActionButton: AppFab(
          onPressed: () => context.push(AppRoutes.addRecurring),
        ),
      ),
    );
  }
}

class _SchedulesTab extends ConsumerWidget {
  const _SchedulesTab();

  Future<void> _handlePause(BuildContext context, WidgetRef ref, RecurringTransaction r) async {
    final controller = ref.read(recurringFormControllerProvider(r.id).notifier);
    final result = await controller.toggleStatus();
    if (!context.mounted) return;
    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess('Paused "${r.name}"'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _handleResume(BuildContext context, WidgetRef ref, RecurringTransaction r) async {
    final controller = ref.read(recurringFormControllerProvider(r.id).notifier);
    final result = await controller.toggleStatus();
    if (!context.mounted) return;
    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess('Resumed "${r.name}"'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, RecurringTransaction r) async {
    final confirmed = await showDeleteRecurringConfirmation(context: context, name: r.name);
    if (confirmed != true || !context.mounted) return;

    final controller = ref.read(recurringFormControllerProvider(r.id).notifier);
    final result = await controller.delete();
    if (!context.mounted) return;
    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess('Deleted "${r.name}"'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(recurringListControllerProvider);
    final filter = ref.watch(recurringFilterProvider);
    final referenceDataAsync = ref.watch(referenceDataProvider);
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);
    final hasActiveFilters = filter.status != null || filter.frequency != null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: _FilterRow(filter: filter),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(recurringListControllerProvider.notifier).refresh(),
            child: switch (listState.status) {
              RecurringListStatus.loading => const ScrollableSingleChild(
                  child: RecurringSkeleton(),
                ),
              RecurringListStatus.error => ScrollableSingleChild(
                  child: ErrorState.fromFailure(
                    listState.error ?? const UnknownFailure(),
                    onRetry: () => ref.read(recurringListControllerProvider.notifier).refresh(),
                  ),
                ),
              _ when listState.items.isEmpty => ScrollableSingleChild(
                  child: RecurringEmptyState(
                    hasActiveFilters: hasActiveFilters,
                    onClearFilters: hasActiveFilters
                        ? () {
                            ref.read(recurringFilterProvider.notifier)
                              ..setStatus(null)
                              ..setFrequency(null);
                          }
                        : null,
                    onAdd: () => context.push(AppRoutes.addRecurring),
                  ),
                ),
              _ => referenceDataAsync.when(
                  data: (referenceData) => ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: listState.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final r = listState.items[index];
                      final category = referenceData.categoriesById[r.categoryId];
                      final account = referenceData.accountsById[r.accountId];
                      return RecurringCard(
                        recurring: r,
                        categoryName: category?.name,
                        categoryIcon: category?.icon,
                        categoryColor: category?.color,
                        accountName: account?.name,
                        currencySymbol: account != null
                            ? currencySymbolFor(account.currency)
                            : currencySymbol,
                        onTap: () => context.push(AppRoutes.editRecurring(r.id)),
                        onPause: () => _handlePause(context, ref, r),
                        onResume: () => _handleResume(context, ref, r),
                        onDelete: () => _handleDelete(context, ref, r),
                      );
                    },
                  ),
                  loading: () => const ScrollableSingleChild(child: RecurringSkeleton()),
                  error: (error, _) => ScrollableSingleChild(
                    child: ErrorState.fromFailure(
                      error is Failure ? error : const UnknownFailure(),
                      onRetry: () => ref.invalidate(referenceDataProvider),
                    ),
                  ),
                ),
            },
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends ConsumerWidget {
  final RecurringFilter filter;

  const _FilterRow({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final status in RecurringStatus.values) ...[
            FilterChip(
              label: Text(status.label),
              selected: filter.status == status,
              onSelected: (selected) =>
                  ref.read(recurringFilterProvider.notifier).setStatus(selected ? status : null),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          PopupMenuButton<RecurrenceFrequency?>(
            initialValue: filter.frequency,
            onSelected: (value) => ref.read(recurringFilterProvider.notifier).setFrequency(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All frequencies')),
              for (final f in RecurrenceFrequency.values)
                PopupMenuItem(value: f, child: Text(f.label)),
            ],
            child: Chip(
              avatar: const Icon(Icons.repeat_rounded, size: 16),
              label: Text(filter.frequency?.label ?? 'Frequency'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PopupMenuButton<RecurringSortOption>(
            initialValue: filter.sort,
            onSelected: (value) => ref.read(recurringFilterProvider.notifier).setSort(value),
            itemBuilder: (context) => [
              for (final s in RecurringSortOption.values)
                PopupMenuItem(value: s, child: Text(s.label)),
            ],
            child: Chip(
              avatar: const Icon(Icons.sort_rounded, size: 16),
              label: Text(filter.sort.label),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTab extends ConsumerWidget {
  const _UpcomingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingOccurrencesProvider(30));
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);
    final referenceDataAsync = ref.watch(referenceDataProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(upcomingOccurrencesProvider(30)),
      child: upcomingAsync.when(
        data: (entries) => ScrollableSingleChild(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SchedulePreview(
              entries: entries,
              currencySymbol: currencySymbol,
              symbolFor: (entry) {
                final account =
                    referenceDataAsync.value?.accountsById[entry.accountId];
                return account != null
                    ? currencySymbolFor(account.currency)
                    : currencySymbol;
              },
            ),
          ),
        ),
        loading: () => const ScrollableSingleChild(child: RecurringSkeleton()),
        error: (error, _) => ScrollableSingleChild(
          child: ErrorState.fromFailure(
            error is Failure ? error : const UnknownFailure(),
            onRetry: () => ref.invalidate(upcomingOccurrencesProvider(30)),
          ),
        ),
      ),
    );
  }
}

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  OccurrenceStatus _status = OccurrenceStatus.generated;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Generated'),
                selected: _status == OccurrenceStatus.generated,
                onSelected: (_) => setState(() => _status = OccurrenceStatus.generated),
              ),
              const SizedBox(width: AppSpacing.sm),
              ChoiceChip(
                label: const Text('Missed'),
                selected: _status == OccurrenceStatus.missed,
                onSelected: (_) => setState(() => _status = OccurrenceStatus.missed),
              ),
            ],
          ),
        ),
        Expanded(child: _HistoryList(status: _status)),
      ],
    );
  }
}

class _HistoryList extends ConsumerWidget {
  final OccurrenceStatus status;

  const _HistoryList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider(status));
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);
    final referenceDataAsync = ref.watch(referenceDataProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(historyControllerProvider(status).notifier).refresh(),
      child: switch (state.status) {
        HistoryStatus.loading => const ScrollableSingleChild(child: RecurringSkeleton()),
        HistoryStatus.error => ScrollableSingleChild(
            child: ErrorState.fromFailure(
              state.error ?? const UnknownFailure(),
              onRetry: () => ref.read(historyControllerProvider(status).notifier).refresh(),
            ),
          ),
        _ when state.items.isEmpty => ScrollableSingleChild(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  status == OccurrenceStatus.generated
                      ? 'No generated transactions yet'
                      : 'No missed schedules',
                ),
              ),
            ),
          ),
        _ => NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (metrics.maxScrollExtent - metrics.pixels < 300 && state.hasMore) {
                ref.read(historyControllerProvider(status).notifier).loadNextPage();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final occurrence = state.items[index];
                final account =
                    referenceDataAsync.value?.accountsById[occurrence.accountId];
                return HistoryTile(
                  occurrence: occurrence,
                  currencySymbol: account != null
                      ? currencySymbolFor(account.currency)
                      : currencySymbol,
                );
              },
            ),
          ),
      },
    );
  }
}
