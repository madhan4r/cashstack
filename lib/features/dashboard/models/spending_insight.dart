/// Mirrors the backend's `SpendingInsightDto` — a category flagged as
/// spending significantly above its trailing-months average this month.
class SpendingInsight {
  final String categoryId;
  final String categoryName;
  final String message;
  final int percentageAboveAverage;

  const SpendingInsight({
    required this.categoryId,
    required this.categoryName,
    required this.message,
    required this.percentageAboveAverage,
  });

  factory SpendingInsight.fromJson(Map<String, dynamic> json) {
    return SpendingInsight(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      message: json['message'] as String,
      percentageAboveAverage: json['percentageAboveAverage'] as int,
    );
  }
}
