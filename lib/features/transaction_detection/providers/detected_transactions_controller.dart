import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/detected_transaction.dart';
import '../repositories/detected_transactions_repository.dart';
import '../services/native_capture_channel.dart';

/// All detected-transaction candidates (pending, added, and dismissed),
/// newest first. Kept in one list rather than pending-only so a dismissed
/// or already-added item doesn't get re-suggested if the same notification
/// somehow fires twice.
class DetectedTransactionsController extends Notifier<List<DetectedTransaction>> {
  @override
  List<DetectedTransaction> build() {
    return ref.watch(detectedTransactionsRepositoryProvider).getAll();
  }

  List<DetectedTransaction> get pending =>
      state.where((t) => t.status == DetectedTransactionStatus.pending).toList();

  /// Adds a newly detected candidate, unless a pending one with the same
  /// amount/type was already detected in the last two minutes — the same
  /// bank notification is sometimes posted more than once (updated then
  /// reposted) and would otherwise show up twice.
  Future<void> addDetected(DetectedTransaction candidate) async {
    final isDuplicate = state.any(
      (t) =>
          t.status == DetectedTransactionStatus.pending &&
          t.amount == candidate.amount &&
          t.type == candidate.type &&
          candidate.detectedAt.difference(t.detectedAt).inMinutes.abs() < 2,
    );
    if (isDuplicate) return;

    final updated = [candidate, ...state];
    state = updated;
    await ref.read(detectedTransactionsRepositoryProvider).saveAll(updated);
  }

  /// Pulls in anything captured natively while the app process wasn't alive
  /// to run the live EventChannel listener — see `NativeCaptureChannel`'s
  /// doc. Safe to call often; malformed or already-seen entries are
  /// silently dropped by the same dedup check `addDetected` already does.
  Future<void> drainNativeCaptures() async {
    final raw = await nativeCaptureChannel.drainPendingCaptures();
    for (final entry in raw) {
      try {
        final candidate = DetectedTransaction.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        );
        await addDetected(candidate);
      } catch (_) {
        // Malformed entry from the native side — skip rather than crash the
        // whole drain over one bad item.
      }
    }
  }

  Future<void> markAdded(String id) => _updateStatus(id, DetectedTransactionStatus.added);

  Future<void> dismiss(String id) => _updateStatus(id, DetectedTransactionStatus.dismissed);

  Future<void> _updateStatus(String id, DetectedTransactionStatus status) async {
    final updated = [
      for (final t in state) if (t.id == id) t.copyWith(status: status) else t,
    ];
    state = updated;
    await ref.read(detectedTransactionsRepositoryProvider).saveAll(updated);
  }
}

final detectedTransactionsControllerProvider =
    NotifierProvider<DetectedTransactionsController, List<DetectedTransaction>>(
      DetectedTransactionsController.new,
    );

final pendingDetectedTransactionsProvider = Provider<List<DetectedTransaction>>((ref) {
  return ref
      .watch(detectedTransactionsControllerProvider)
      .where((t) => t.status == DetectedTransactionStatus.pending)
      .toList();
});
