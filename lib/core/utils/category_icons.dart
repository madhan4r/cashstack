import 'package:flutter/material.dart';

/// The backend stores category icons as plain string keys (see
/// `DEFAULT_CATEGORIES` in the backend), not Flutter [IconData]. This maps
/// those keys to Material icons; unknown keys (or `null`) fall back to a
/// generic icon so a category never renders without one.
IconData categoryIconFor(String? key) {
  return _icons[key] ?? Icons.category_outlined;
}

const _icons = <String, IconData>{
  'briefcase': Icons.work_outline_rounded,
  'store': Icons.storefront_outlined,
  'trending-up': Icons.trending_up_rounded,
  'plus-circle': Icons.add_circle_outline_rounded,
  'utensils': Icons.restaurant_outlined,
  'car': Icons.directions_car_outlined,
  'shopping-bag': Icons.shopping_bag_outlined,
  'file-text': Icons.receipt_long_outlined,
  'film': Icons.movie_outlined,
  'heart': Icons.favorite_outline_rounded,
  'more-horizontal': Icons.more_horiz_rounded,
};
