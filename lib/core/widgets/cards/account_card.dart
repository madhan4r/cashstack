import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../extensions/num_extensions.dart';
import 'app_card.dart';

/// Card summarizing a single account — name, type label, balance, and an
/// accent icon. Purely presentational; the caller supplies already-computed
/// values (no balance calculation here).
class AccountCard extends StatelessWidget {
  final String name;
  final String typeLabel;
  final double balance;
  final String currencySymbol;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  /// Optional trailing line below the balance — e.g. "Updated 2h ago".
  /// Purely additive; omit for the original layout.
  final String? footer;

  const AccountCard({
    super.key,
    required this.name,
    required this.typeLabel,
    required this.balance,
    this.currencySymbol = '\$',
    this.icon = Icons.account_balance_wallet_outlined,
    this.color,
    this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: tint, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.textStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      typeLabel,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$currencySymbol${balance.toAmount()}',
            style: context.textStyles.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 6),
            Text(
              footer!,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
