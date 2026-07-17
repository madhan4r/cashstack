/// Mirrors the backend's `TransactionSort` enum.
enum TransactionSortOption {
  newest('newest', 'Newest'),
  oldest('oldest', 'Oldest'),
  amountHigh('amount', 'Highest Amount'),
  amountLow('amount_asc', 'Lowest Amount');

  final String queryValue;
  final String label;

  const TransactionSortOption(this.queryValue, this.label);
}
