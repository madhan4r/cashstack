/// Mirrors the backend's `RecurrenceFrequency` enum.
enum RecurrenceFrequency {
  daily('DAILY', 'Daily'),
  weekly('WEEKLY', 'Weekly'),
  monthly('MONTHLY', 'Monthly'),
  quarterly('QUARTERLY', 'Quarterly'),
  halfYearly('HALF_YEARLY', 'Half-Yearly'),
  yearly('YEARLY', 'Yearly'),
  custom('CUSTOM', 'Custom');

  final String jsonValue;
  final String label;

  const RecurrenceFrequency(this.jsonValue, this.label);

  factory RecurrenceFrequency.fromJson(String value) =>
      RecurrenceFrequency.values.firstWhere(
        (f) => f.jsonValue == value,
        orElse: () => RecurrenceFrequency.monthly,
      );

  String toJson() => jsonValue;
}
