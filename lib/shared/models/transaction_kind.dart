/// Mirrors the backend's `TransactionType` enum. Shared by every feature
/// that displays transactions (dashboard, transactions list, …) so the
/// income/expense/transfer taxonomy — and its wire format — lives in
/// exactly one place.
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

  String toJson() => switch (this) {
    TransactionKind.income => 'INCOME',
    TransactionKind.expense => 'EXPENSE',
    TransactionKind.transfer => 'TRANSFER',
  };
}
