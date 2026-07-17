import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_ref.dart';
import '../models/category_ref.dart';
import '../repositories/reference_data_repository.dart';

/// Caches the user's accounts and categories for the lifetime of the
/// provider (small, rarely-changing lists) — used to enrich transaction
/// rows and populate the filter sheet's pickers without a lookup per row.
class ReferenceData {
  final List<AccountRef> accounts;
  final List<CategoryRef> categories;
  final Map<String, AccountRef> accountsById;
  final Map<String, CategoryRef> categoriesById;

  ReferenceData({required this.accounts, required this.categories})
    : accountsById = {for (final a in accounts) a.id: a},
      categoriesById = {for (final c in categories) c.id: c};
}

final referenceDataProvider = FutureProvider<ReferenceData>((ref) async {
  final repository = ref.watch(referenceDataRepositoryProvider);
  final results = await Future.wait([
    repository.getAccounts(),
    repository.getCategories(),
  ]);
  return ReferenceData(
    accounts: results[0] as List<AccountRef>,
    categories: results[1] as List<CategoryRef>,
  );
});
