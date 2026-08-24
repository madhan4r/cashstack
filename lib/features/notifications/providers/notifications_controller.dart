import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../repositories/notifications_repository.dart';

/// The current user's notifications, newest first — backs both the
/// notification center screen and the dashboard bell's unread badge (see
/// [unreadNotificationCountProvider]), same "derive the count from the list
/// state" pattern as [pendingInvitesCountProvider].
class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final result = await ref.watch(notificationsRepositoryProvider).getNotifications();
    return result.items;
  }

  Future<void> refresh() async {
    final repository = ref.read(notificationsRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final result = await repository.getNotifications();
      return result.items;
    });
  }

  Future<void> markRead(String id) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic — the notification center should feel instant, and a
    // failed mark-read just means the item reverts on next refresh.
    state = AsyncData([
      for (final n in current)
        if (n.id == id) n.copyWith(read: true) else n,
    ]);

    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
    } catch (_) {
      await refresh();
    }
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData([for (final n in current) n.copyWith(read: true)]);

    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } catch (_) {
      await refresh();
    }
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
      NotificationsController.new,
    );

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsControllerProvider).value;
  return notifications?.where((n) => !n.read).length ?? 0;
});
