import 'package:flutter/material.dart';

/// The backend stores category icons as plain string keys (see
/// `DEFAULT_CATEGORIES` in the backend), not Flutter [IconData]. This maps
/// those keys to Material icons; unknown keys (or `null`) fall back to a
/// generic icon so a category never renders without one.
IconData categoryIconFor(String? key) {
  return _icons[key] ?? Icons.category_outlined;
}

const _icons = <String, IconData>{
  // Salary
  'briefcase': Icons.work_outline_rounded,
  'cash': Icons.payments_outlined,
  'wallet': Icons.account_balance_wallet_outlined,
  // Business / Other income
  'store': Icons.storefront_outlined,
  'plus-circle': Icons.add_circle_outline_rounded,
  // Investment
  'trending-up': Icons.trending_up_rounded,
  'chart': Icons.bar_chart_rounded,
  'coins': Icons.monetization_on_outlined,
  // Food
  'utensils': Icons.restaurant_outlined,
  'coffee': Icons.coffee_outlined,
  'pizza': Icons.local_pizza_outlined,
  'cake': Icons.cake_outlined,
  'fastfood': Icons.fastfood_outlined,
  // Transport
  'car': Icons.directions_car_outlined,
  'bus': Icons.directions_bus_outlined,
  'train': Icons.train_outlined,
  'bike': Icons.pedal_bike_outlined,
  'fuel': Icons.local_gas_station_outlined,
  'taxi': Icons.local_taxi_outlined,
  // Shopping
  'shopping-bag': Icons.shopping_bag_outlined,
  'shopping-cart': Icons.shopping_cart_outlined,
  'tag': Icons.sell_outlined,
  // Bills
  'file-text': Icons.receipt_long_outlined,
  'receipt': Icons.receipt_outlined,
  'zap': Icons.bolt_outlined,
  'wifi': Icons.wifi_rounded,
  'phone': Icons.phone_iphone_outlined,
  // Health
  'heart': Icons.favorite_outline_rounded,
  'pill': Icons.medication_outlined,
  'hospital': Icons.local_hospital_outlined,
  'fitness': Icons.fitness_center_outlined,
  // Entertainment
  'film': Icons.movie_outlined,
  'music': Icons.music_note_outlined,
  'gamepad': Icons.sports_esports_outlined,
  'ticket': Icons.confirmation_number_outlined,
  // Travel
  'plane': Icons.flight_outlined,
  'luggage': Icons.luggage_outlined,
  'map': Icons.map_outlined,
  'hotel': Icons.hotel_outlined,
  // Education
  'book': Icons.menu_book_outlined,
  'graduation-cap': Icons.school_outlined,
  'school': Icons.auto_stories_outlined,
  // Pets
  'paw': Icons.pets_outlined,
  'dog': Icons.cruelty_free_outlined,
  // Gifts
  'gift': Icons.card_giftcard_outlined,
  // Other
  'more-horizontal': Icons.more_horiz_rounded,
  'category': Icons.category_outlined,
  'question-mark': Icons.help_outline_rounded,
};
