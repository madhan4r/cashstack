import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../repositories/notifications_repository.dart';
import 'notifications_list_state.dart';

const _pageSize = 30;

/// Drives the notification center: initial load, infinite scroll
/// (`loadNextPage`), and pull-to-refresh (`refresh`) — mirrors
/// `TransactionsListController`'s shape.
class NotificationsController extends Notifier<NotificationsListState> {
  @override
  NotificationsListState build() {
    unawaited(_loadFirstPage());
    return const NotificationsListState();
  }

  Future<void> _loadFirstPage() async {
    final repository = ref.read(notificationsRepositoryProvider);
    try {
      final result = await repository.getNotifications(page: 1);
      state = state.copyWith(
        items: result.items,
        meta: result.meta,
        status: NotificationsListStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: NotificationsListStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.status != NotificationsListStatus.loaded || !state.hasMore) {
      return;
    }

    state = state.copyWith(status: NotificationsListStatus.loadingMore);
    final repository = ref.read(notificationsRepositoryProvider);
    final nextPage = (state.meta?.page ?? 0) + 1;

    try {
      final result = await repository.getNotifications(page: nextPage);
      state = state.copyWith(
        items: [...state.items, ...result.items],
        meta: result.meta,
        status: NotificationsListStatus.loaded,
      );
    } catch (error) {
      // Keep the existing items visible; surface the failure separately.
      state = state.copyWith(
        status: NotificationsListStatus.loaded,
        backgroundError: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: NotificationsListStatus.refreshing);
    final repository = ref.read(notificationsRepositoryProvider);

    try {
      final result = await repository.getNotifications(page: 1);
      state = state.copyWith(
        items: result.items,
        meta: result.meta,
        status: NotificationsListStatus.loaded,
        clearError: true,
        clearBackgroundError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: NotificationsListStatus.loaded,
        backgroundError: mapExceptionToFailure(error),
      );
    }
  }

  void dismissBackgroundError() {
    state = state.copyWith(clearBackgroundError: true);
  }

  Future<void> markRead(String id) async {
    final items = state.items;
    final index = items.indexWhere((n) => n.id == id);
    if (index == -1 || items[index].read) return;

    // Optimistic — the notification center should feel instant, and a
    // failed mark-read just means the item reverts on next refresh.
    state = state.copyWith(items: [
      for (final n in items)
        if (n.id == id) n.copyWith(read: true) else n,
    ]);

    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
    } catch (_) {
      await refresh();
    }
  }

  Future<void> markAllRead() async {
    if (state.items.every((n) => n.read)) return;

    state = state.copyWith(
      items: [for (final n in state.items) n.copyWith(read: true)],
    );

    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } catch (_) {
      await refresh();
    }
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsListState>(
      NotificationsController.new,
    );

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsControllerProvider).unreadCount;
});
