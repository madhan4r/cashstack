/// Mirrors the backend's `RecurringSort` enum.
enum RecurringSortOption {
  nextDue('next_due', 'Next Due'),
  amount('amount', 'Amount'),
  recent('recent', 'Recently Created');

  final String queryValue;
  final String label;

  const RecurringSortOption(this.queryValue, this.label);
}
