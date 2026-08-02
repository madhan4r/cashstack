import 'package:equatable/equatable.dart';

/// Mirrors the backend's `SavingsGoalResponseDto`.
class SavingsGoal extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? icon;
  final String? color;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    this.icon,
    this.color,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);
  double get progress => targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String).toLocal(),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    targetAmount,
    currentAmount,
    targetDate,
    icon,
    color,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}
