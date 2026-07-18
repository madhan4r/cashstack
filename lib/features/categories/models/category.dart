import 'package:equatable/equatable.dart';

import 'category_type.dart';

/// A single category, as returned by `GET /categories` and
/// `GET /categories/:id`. Mirrors the backend's `CategoryResponseDto`,
/// including the ledger stats (`transactionCount`/`totalAmount`/
/// `lastUsedAt`) both endpoints attach.
class Category extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final String? description;
  final bool isDefault;
  final bool isArchived;
  final int transactionCount;
  final double totalAmount;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.description,
    required this.isDefault,
    required this.isArchived,
    this.transactionCount = 0,
    this.totalAmount = 0,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Default categories can't be edited or deleted (only archived) — the
  /// backend rejects those requests outright.
  bool get isEditable => !isDefault;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.fromJson(json['type'] as String),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      transactionCount: json['transactionCount'] as int? ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Category copyWith({bool? isArchived}) {
    return Category(
      id: id,
      name: name,
      type: type,
      icon: icon,
      color: color,
      description: description,
      isDefault: isDefault,
      isArchived: isArchived ?? this.isArchived,
      transactionCount: transactionCount,
      totalAmount: totalAmount,
      lastUsedAt: lastUsedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    icon,
    color,
    description,
    isDefault,
    isArchived,
    transactionCount,
    totalAmount,
    lastUsedAt,
    createdAt,
    updatedAt,
  ];
}
