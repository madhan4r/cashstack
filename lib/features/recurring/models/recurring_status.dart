/// Mirrors the backend's `RecurringStatus` enum.
enum RecurringStatus {
  active('ACTIVE', 'Active'),
  paused('PAUSED', 'Paused'),
  completed('COMPLETED', 'Completed');

  final String jsonValue;
  final String label;

  const RecurringStatus(this.jsonValue, this.label);

  factory RecurringStatus.fromJson(String value) => RecurringStatus.values.firstWhere(
    (s) => s.jsonValue == value,
    orElse: () => RecurringStatus.active,
  );

  String toJson() => jsonValue;
}
