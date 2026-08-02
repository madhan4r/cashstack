import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../providers/detected_transactions_controller.dart';
import '../widgets/detected_transaction_tile.dart';

/// Lists pending transaction candidates detected from bank notifications
/// (see `notificationDetectionListenerProvider`) for the user to confirm
/// or dismiss — reached from the Dashboard's "detected" banner or the
/// detection notification itself.
class DetectedTransactionsScreen extends ConsumerWidget {
  const DetectedTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingDetectedTransactionsProvider);
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Detected Transactions'),
      body: pending.isEmpty
          ? ScrollableSingleChild(
              child: EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Nothing to review',
                description:
                    "Transactions detected from bank notifications will show up here for you to confirm.",
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: pending.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final transaction = pending[index];
                return DetectedTransactionTile(
                  transaction: transaction,
                  currencySymbol: currencySymbol,
                  onDismiss: () => ref
                      .read(detectedTransactionsControllerProvider.notifier)
                      .dismiss(transaction.id),
                  onAdd: () async {
                    ref
                        .read(detectedTransactionsControllerProvider.notifier)
                        .markAdded(transaction.id);
                    await context.push(
                      '${AppRoutes.addTransaction}'
                      '?type=${transaction.type.toJson()}'
                      '&amount=${transaction.amount}',
                    );
                  },
                );
              },
            ),
    );
  }
}
