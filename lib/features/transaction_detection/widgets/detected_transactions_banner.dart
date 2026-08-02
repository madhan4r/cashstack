import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../routes/app_routes.dart';
import '../providers/detected_transactions_controller.dart';

/// Dashboard banner surfacing pending transactions detected from bank
/// notifications (see Settings > Smart Transaction Detection). Renders
/// nothing when there's nothing pending.
class DetectedTransactionsBanner extends ConsumerWidget {
  const DetectedTransactionsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingDetectedTransactionsProvider);
    if (pending.isEmpty) return const SizedBox.shrink();

    return AppCard(
      onTap: () => context.push(AppRoutes.detectedTransactions),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined, color: context.colors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pending.length == 1
                      ? '1 transaction detected'
                      : '${pending.length} transactions detected',
                  style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Tap to review and add them',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
