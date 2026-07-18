import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/account_card.dart';
import '../models/account_ref.dart';

/// Account picker content: a scrollable list of [AccountCard]s (name,
/// current balance from the API, icon). [excludeAccountId] hides one
/// account entirely — used for a transfer's "To Account" picker so the
/// already-chosen "From Account" can't be selected again.
class AccountSelector extends StatelessWidget {
  final List<AccountRef> accounts;
  final String? selectedAccountId;
  final String? excludeAccountId;
  final ValueChanged<String> onSelected;

  const AccountSelector({
    super.key,
    required this.accounts,
    required this.onSelected,
    this.selectedAccountId,
    this.excludeAccountId,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAccounts = accounts
        .where((a) => !a.isArchived && a.id != excludeAccountId)
        .toList();

    if (visibleAccounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            'No accounts available',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (final account in visibleAccounts) ...[
              _SelectableAccountCard(
                account: account,
                isSelected: account.id == selectedAccountId,
                onTap: () => onSelected(account.id),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectableAccountCard extends StatelessWidget {
  final AccountRef account;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableAccountCard({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(account.color, fallback: context.colors.primary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: isSelected ? tint : Colors.transparent,
          width: 2,
        ),
      ),
      child: AccountCard(
        name: account.name,
        typeLabel: account.currency,
        balance: account.balance,
        color: tint,
        onTap: onTap,
      ),
    );
  }
}
