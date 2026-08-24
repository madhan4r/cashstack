import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../models/notification_category.dart';
import '../providers/notification_preferences_controller.dart';

/// Per-category on/off switches for push/in-app notifications — separate
/// from the "Notifications" toggle in Settings, which is the OS-level
/// permission for locally-scheduled recurring reminders, not these
/// server-driven categories.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  Future<void> _toggle(
    WidgetRef ref,
    NotificationCategory category,
    bool enabled,
  ) async {
    final result = await ref
        .read(notificationPreferencesControllerProvider.notifier)
        .setEnabled(category.key, enabled);
    result.when(
      ok: (_) {},
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(notificationPreferencesControllerProvider);
    final controller = ref.watch(notificationPreferencesControllerProvider.notifier);

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Notification Preferences'),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              error is Failure ? error.message : error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (_) => ListView(
          children: [
            for (final category in NotificationCategory.values)
              AppListTile(
                title: category.label,
                trailing: Switch(
                  value: controller.isEnabled(category.key),
                  onChanged: (value) => _toggle(ref, category, value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
