/// Mirrors the backend's `ReminderOption` enum.
enum ReminderOption {
  none('NONE', 'No reminder'),
  sameDay('SAME_DAY', 'Same day'),
  oneDayBefore('ONE_DAY_BEFORE', '1 day before'),
  threeDaysBefore('THREE_DAYS_BEFORE', '3 days before'),
  sevenDaysBefore('SEVEN_DAYS_BEFORE', '7 days before');

  final String jsonValue;
  final String label;

  const ReminderOption(this.jsonValue, this.label);

  factory ReminderOption.fromJson(String value) => ReminderOption.values.firstWhere(
    (r) => r.jsonValue == value,
    orElse: () => ReminderOption.none,
  );

  String toJson() => jsonValue;
}
