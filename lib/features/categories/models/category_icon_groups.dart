/// Groups the icon keys from `core/utils/category_icons.dart` for the Icon
/// Picker. Keys here must exist in that file's map — it stays the single
/// source of truth for key→[IconData]; this is purely an organizational
/// grouping on top of it.
const categoryIconGroups = <String, List<String>>{
  'Food': ['utensils', 'coffee', 'pizza', 'cake', 'fastfood'],
  'Transport': ['car', 'bus', 'train', 'bike', 'fuel', 'taxi'],
  'Shopping': ['shopping-bag', 'shopping-cart', 'tag', 'store'],
  'Bills': ['file-text', 'receipt', 'zap', 'wifi', 'phone'],
  'Health': ['heart', 'pill', 'hospital', 'fitness'],
  'Entertainment': ['film', 'music', 'gamepad', 'ticket'],
  'Travel': ['plane', 'luggage', 'map', 'hotel'],
  'Salary': ['briefcase', 'cash', 'wallet'],
  'Investment': ['trending-up', 'chart', 'coins'],
  'Education': ['book', 'graduation-cap', 'school'],
  'Pets': ['paw', 'dog'],
  'Gifts': ['gift'],
  'Other': ['more-horizontal', 'category', 'question-mark', 'plus-circle'],
};
