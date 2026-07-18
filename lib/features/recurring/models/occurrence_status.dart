/// Mirrors the backend's `OccurrenceStatus` enum — history-log entries
/// only, never a "pending" state (not-yet-due occurrences are computed on
/// the fly for the upcoming preview, not persisted).
enum OccurrenceStatus {
  generated('GENERATED', 'Generated'),
  missed('MISSED', 'Missed');

  final String jsonValue;
  final String label;

  const OccurrenceStatus(this.jsonValue, this.label);

  factory OccurrenceStatus.fromJson(String value) => OccurrenceStatus.values.firstWhere(
    (s) => s.jsonValue == value,
    orElse: () => OccurrenceStatus.missed,
  );

  String toJson() => jsonValue;
}
