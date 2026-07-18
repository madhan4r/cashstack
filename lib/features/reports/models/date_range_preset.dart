/// Quick date-range shortcuts for the Reports filter row. [custom] means the
/// user picked their own from/to dates via the filter sheet.
enum DateRangePreset {
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisYear('This Year'),
  custom('Custom');

  final String label;

  const DateRangePreset(this.label);

  /// The `[from, to]` window for this preset, both inclusive whole days.
  /// Returns `null` for [custom] — the caller supplies its own dates.
  (DateTime, DateTime)? dateRange({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());

    return switch (this) {
      DateRangePreset.today => (today, today),
      DateRangePreset.thisWeek => (
        today.subtract(Duration(days: today.weekday - 1)),
        today,
      ),
      DateRangePreset.thisMonth => (DateTime(today.year, today.month, 1), today),
      DateRangePreset.lastMonth => (
        DateTime(today.year, today.month - 1, 1),
        DateTime(today.year, today.month, 0),
      ),
      DateRangePreset.thisYear => (DateTime(today.year, 1, 1), today),
      DateRangePreset.custom => null,
    };
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
