import 'package:equatable/equatable.dart';

import 'category_type.dart';

/// Client-side search + type + archived-visibility state for the
/// Categories list. `GET /categories` has no query params, so filtering
/// happens entirely against the cached list — see
/// `filteredCategoriesProvider`.
class CategoriesFilter extends Equatable {
  final String search;

  /// `null` shows both Expense and Income.
  final CategoryType? type;
  final bool showArchived;

  const CategoriesFilter({this.search = '', this.type, this.showArchived = false});

  CategoriesFilter copyWith({
    String? search,
    CategoryType? type,
    bool clearType = false,
    bool? showArchived,
  }) {
    return CategoriesFilter(
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
      showArchived: showArchived ?? this.showArchived,
    );
  }

  @override
  List<Object?> get props => [search, type, showArchived];
}
