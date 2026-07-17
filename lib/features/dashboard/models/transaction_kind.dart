/// Mirrors the backend's `TransactionType` enum.
enum TransactionKind {
  income,
  expense,
  transfer;

  factory TransactionKind.fromJson(String value) {
    return switch (value) {
      'INCOME' => TransactionKind.income,
      'EXPENSE' => TransactionKind.expense,
      _ => TransactionKind.transfer,
    };
  }
}
