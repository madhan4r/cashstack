import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/notifications_enabled_controller.dart';
import '../../../shared/models/transaction_kind.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../models/recurring_filter.dart';
import '../models/recurring_status.dart';
import '../repositories/recurring_repository.dart';

const _reminderHour = 9;

/// Re-fetches every active recurring transaction (ignoring whatever status/
/// frequency filter the Recurring list screen currently has applied — a
/// filtered view must never be used to decide what to cancel) and
/// schedules a local reminder for each one that has [ReminderOption] set.
/// Cancels and replaces everything each time rather than diffing, since
/// the list is small and this only runs when the recurring list refetches.
/// Best-effort: notification failures never surface as an app-level error.
Future<void> rescheduleRecurringReminders(Ref ref) async {
  if (!ref.read(notificationsEnabledProvider)) return;

  final service = ref.read(notificationServiceProvider);
  try {
    final repository = ref.read(recurringRepositoryProvider);
    final all = await repository.getRecurring(const RecurringFilter());
    await service.cancelAll();

    final currencySymbol = ref.read(preferredCurrencySymbolProvider);
    for (final r in all) {
      if (r.status != RecurringStatus.active) continue;
      final offsetDays = r.reminder.offsetDays;
      if (offsetDays == null) continue;

      final dueDate = r.nextDueDate;
      final fireDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day - offsetDays,
        _reminderHour,
      );

      final amountLabel = '$currencySymbol${r.amount.toStringAsFixed(2)}';
      final verb = r.type == TransactionKind.expense ? 'due' : 'expected';
      final when = offsetDays == 0 ? 'today' : 'in $offsetDays day${offsetDays == 1 ? '' : 's'}';

      await service.scheduleReminder(
        id: r.id.hashCode,
        title: r.name,
        body: '$amountLabel $verb $when',
        scheduledDate: fireDate,
      );
    }
  } catch (_) {
    // Reminders are a convenience feature — a failure here (permission
    // revoked mid-session, plugin not ready, etc.) shouldn't block or
    // error out the recurring list itself.
  }
}
