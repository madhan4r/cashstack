import 'package:equatable/equatable.dart';

import '../../../shared/models/transaction_kind.dart';

/// Minimal category reference used to enrich transaction rows (name/icon/
/// color) and to populate the category filter picker. Mirrors the
/// backend's `CategoryResponseDto`, trimmed to what the Transactions
/// feature needs.
class CategoryRef extends Equatable {
  final String id;
  final String name;
  final TransactionKind type;
  final String? icon;
  final String? color;

  const CategoryRef({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  factory CategoryRef.fromJson(Map<String, dynamic> json) {
    return CategoryRef(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TransactionKind.fromJson(json['type'] as String),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, type, icon, color];
}
