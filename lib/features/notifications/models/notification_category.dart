/// Mirrors the backend's `NotificationCategory` enum — the keys used in
/// the `notificationPreferences` map on `GET`/`PATCH
/// /users/me/notification-preferences`.
enum NotificationCategory {
  recurring('recurring', 'Recurring transaction reminders'),
  budget('budget', 'Budget alerts'),
  household('household', 'Household invites'),
  savingsGoal('savings_goal', 'Savings goal updates'),
  lowBalance('low_balance', 'Low balance alerts');

  final String key;
  final String label;

  const NotificationCategory(this.key, this.label);
}
