import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/result.dart';
import '../repositories/notifications_repository.dart';

/// The signed-in user's per-category push/in-app notification preferences.
/// A category absent from the map is enabled by default (see the backend's
/// `isCategoryEnabled`), so [isEnabled] mirrors that rather than treating
/// "missing" as false.
class NotificationPreferencesController
    extends AsyncNotifier<Map<String, bool>> {
  @override
  Future<Map<String, bool>> build() {
    return ref.watch(notificationsRepositoryProvider).getNotificationPreferences();
  }

  bool isEnabled(String category) => state.value?[category] ?? true;

  Future<Result<void>> setEnabled(String category, bool enabled) async {
    final previous = state;
    // Optimistic — a settings toggle should feel instant.
    state = AsyncData({...?state.value, category: enabled});

    try {
      final updated = await ref
          .read(notificationsRepositoryProvider)
          .updateNotificationPreferences({category: enabled});
      state = AsyncData(updated);
      return const Result.ok(null);
    } catch (error) {
      state = previous;
      return Result.err(mapExceptionToFailure(error));
    }
  }
}

final notificationPreferencesControllerProvider = AsyncNotifierProvider<
  NotificationPreferencesController,
  Map<String, bool>
>(NotificationPreferencesController.new);
