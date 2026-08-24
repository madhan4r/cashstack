import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/feedback/circular_loader.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../models/app_notification.dart';
import '../providers/notifications_controller.dart';
import '../providers/notifications_list_state.dart';

const _loadMoreThreshold = 400.0;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _handleTap(BuildContext context, WidgetRef ref, AppNotification n) {
    if (!n.read) {
      ref.read(notificationsControllerProvider.notifier).markRead(n.id);
    }

    final route = switch (n.type) {
      'household_invite' => AppRoutes.pendingInvites,
      'recurring_due_today' => AppRoutes.recurring,
      'budget_threshold' => AppRoutes.categoryBudgets,
      'savings_goal_milestone' ||
      'savings_goal_deadline' => n.data['savingsGoalId'] != null
          ? AppRoutes.savingsGoalDetails(n.data['savingsGoalId']!)
          : AppRoutes.savingsGoals,
      'low_balance' => n.data['accountId'] != null
          ? AppRoutes.accountDetails(n.data['accountId']!)
          : AppRoutes.accounts,
      _ => null,
    };
    if (route != null) context.push(route);
  }

  IconData _iconFor(String type) => switch (type) {
    'household_invite' => Icons.group_outlined,
    'recurring_due_today' => Icons.repeat_rounded,
    'budget_threshold' => Icons.pie_chart_outline_rounded,
    'savings_goal_milestone' || 'savings_goal_deadline' => Icons.savings_outlined,
    'low_balance' => Icons.account_balance_wallet_outlined,
    _ => Icons.notifications_none_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);

    ref.listen(notificationsControllerProvider, (previous, next) {
      if (next.backgroundError != null &&
          previous?.backgroundError != next.backgroundError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.backgroundError!.message)),
        );
        ref.read(notificationsControllerProvider.notifier).dismissBackgroundError();
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: 'Notifications',
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsControllerProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsControllerProvider.notifier).refresh(),
        child: state.isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : state.status == NotificationsListStatus.error
            ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      state.error is Failure
                          ? (state.error as Failure).message
                          : state.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : state.isEmpty
            ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'No notifications yet',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  final metrics = notification.metrics;
                  final remaining = metrics.maxScrollExtent - metrics.pixels;
                  if (remaining < _loadMoreThreshold &&
                      state.hasMore &&
                      state.status != NotificationsListStatus.loadingMore) {
                    ref.read(notificationsControllerProvider.notifier).loadNextPage();
                  }
                  return false;
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.items.length + 1,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      return _TrailingIndicator(
                        isLoadingMore:
                            state.status == NotificationsListStatus.loadingMore,
                      );
                    }

                    final n = state.items[index];
                    return ListTile(
                      onTap: () => _handleTap(context, ref, n),
                      leading: CircleAvatar(
                        backgroundColor: context.colors.primaryContainer,
                        child: Icon(
                          _iconFor(n.type),
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        n.title,
                        style: n.read
                            ? null
                            : const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(n.body),
                      trailing: !n.read
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Text(
                              DateFormat.MMMd().add_jm().format(n.createdAt.toLocal()),
                              style: context.textStyles.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _TrailingIndicator extends StatelessWidget {
  final bool isLoadingMore;

  const _TrailingIndicator({required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    if (!isLoadingMore) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(child: CircularLoader(size: 20)),
    );
  }
}
