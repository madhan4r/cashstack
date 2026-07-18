import 'package:equatable/equatable.dart';

import 'category.dart';

/// The minimal shape the reusable Category Selector needs — just enough to
/// render a grid tile and record favorites/recents. Deliberately decoupled
/// from both the Categories feature's own [Category] model and the
/// Transactions feature's `CategoryRef`, so the same selector widget works
/// for either caller without either feature depending on the other's model.
class CategorySelectorItem extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String? color;

  const CategorySelectorItem({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory CategorySelectorItem.fromCategory(Category category) {
    return CategorySelectorItem(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color];
}
