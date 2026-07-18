/// Mirrors the backend's `CategoryType` enum. Every category belongs to
/// exactly one type — there's no "transfer" category, unlike transactions.
enum CategoryType {
  expense('EXPENSE', 'Expense'),
  income('INCOME', 'Income');

  final String jsonValue;
  final String label;

  const CategoryType(this.jsonValue, this.label);

  factory CategoryType.fromJson(String value) => CategoryType.values.firstWhere(
    (type) => type.jsonValue == value,
    orElse: () => CategoryType.expense,
  );

  String toJson() => jsonValue;
}
