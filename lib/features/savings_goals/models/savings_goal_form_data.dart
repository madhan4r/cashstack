/// The Add/Edit Savings Goal form's payload, matching the backend's
/// `CreateSavingsGoalDto`/`UpdateSavingsGoalDto` shape.
class SavingsGoalFormData {
  final String name;
  final double targetAmount;
  final DateTime? targetDate;
  final String? icon;
  final String? color;

  const SavingsGoalFormData({
    required this.name,
    required this.targetAmount,
    this.targetDate,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'targetAmount': targetAmount,
      if (targetDate != null) 'targetDate': targetDate!.toUtc().toIso8601String(),
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
    };
  }
}
