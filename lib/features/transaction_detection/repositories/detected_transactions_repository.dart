import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/shared_preferences_provider.dart';
import '../models/detected_transaction.dart';

const _storageKey = 'transaction_detection.detected_transactions';
const _maxStored = 50;

/// Persists detected-transaction candidates on-device — there's no backend
/// concept of these (they aren't real transactions until confirmed), so
/// they live in [SharedPreferences] like the other local-only preferences
/// in this app.
class DetectedTransactionsRepository {
  final SharedPreferences _prefs;

  const DetectedTransactionsRepository(this._prefs);

  List<DetectedTransaction> getAll() {
    final raw = _prefs.getStringList(_storageKey) ?? const [];
    return raw
        .map((s) => DetectedTransaction.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<DetectedTransaction> items) async {
    // Cap storage so a long-running install with detection enabled doesn't
    // grow this list forever — oldest items drop off first.
    final trimmed = items.length > _maxStored
        ? items.sublist(items.length - _maxStored)
        : items;
    await _prefs.setStringList(
      _storageKey,
      trimmed.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }
}

final detectedTransactionsRepositoryProvider =
    Provider<DetectedTransactionsRepository>((ref) {
  return DetectedTransactionsRepository(ref.watch(sharedPreferencesProvider));
});
