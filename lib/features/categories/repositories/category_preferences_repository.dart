import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/shared_preferences_provider.dart';

const _favoritesKey = 'categories.category_favorites';
const _recentsKey = 'categories.category_recents';
const _maxRecents = 8;

/// Favorite/recently-used categories for the Category Selector. There's no
/// backend concept of this — it's a pure client-side convenience, so it's
/// stored locally via [SharedPreferences] rather than round-tripping to
/// the API. Shared by every feature that uses the selector (Transactions'
/// Add/Edit form, this feature's own pickers).
class CategoryPreferencesRepository {
  final SharedPreferences _prefs;

  const CategoryPreferencesRepository(this._prefs);

  List<String> getFavoriteIds() => _prefs.getStringList(_favoritesKey) ?? const [];

  List<String> getRecentIds() => _prefs.getStringList(_recentsKey) ?? const [];

  Future<void> toggleFavorite(String categoryId) async {
    final favorites = getFavoriteIds().toList();
    if (!favorites.remove(categoryId)) {
      favorites.add(categoryId);
    }
    await _prefs.setStringList(_favoritesKey, favorites);
  }

  /// Moves [categoryId] to the front of the recents list, used whenever a
  /// category is selected in the picker.
  Future<void> recordUsed(String categoryId) async {
    final recents = getRecentIds().toList()..remove(categoryId);
    recents.insert(0, categoryId);
    if (recents.length > _maxRecents) {
      recents.removeRange(_maxRecents, recents.length);
    }
    await _prefs.setStringList(_recentsKey, recents);
  }
}

final categoryPreferencesRepositoryProvider =
    Provider<CategoryPreferencesRepository>((ref) {
  return CategoryPreferencesRepository(ref.watch(sharedPreferencesProvider));
});
