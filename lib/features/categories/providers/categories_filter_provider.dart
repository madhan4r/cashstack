import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories_filter.dart';
import '../models/category_type.dart';

/// The active search text + type + archived-visibility filters for the
/// Categories list.
class CategoriesFilterController extends Notifier<CategoriesFilter> {
  @override
  CategoriesFilter build() => const CategoriesFilter();

  void updateSearch(String search) {
    state = state.copyWith(search: search);
  }

  void setType(CategoryType? type) {
    state = state.copyWith(type: type, clearType: type == null);
  }

  void setShowArchived(bool showArchived) {
    state = state.copyWith(showArchived: showArchived);
  }
}

final categoriesFilterProvider =
    NotifierProvider<CategoriesFilterController, CategoriesFilter>(
      CategoriesFilterController.new,
    );
