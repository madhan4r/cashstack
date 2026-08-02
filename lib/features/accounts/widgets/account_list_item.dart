import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/account_card.dart';
import '../../auth/providers/auth_controller.dart';
import '../models/account.dart';
import '../../../core/utils/currency.dart';

/// A single row on the Accounts list — thin adapter from the domain
/// [Account] model onto the shared [AccountCard], resolving its type
/// icon/label and currency symbol and adding the "last updated" footer and
/// an archived badge.
class AccountListItem extends ConsumerWidget {
  final Account account;
  final VoidCallback? onTap;

  const AccountListItem({super.key, required this.account, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUserId = ref.watch(authControllerProvider).user?.id;
    final isSharedItem = account.ownerId.isNotEmpty && account.ownerId != myUserId;

    return Opacity(
      opacity: account.isArchived ? 0.6 : 1,
      child: AccountCard(
        name: account.name,
        typeLabel: account.type.label,
        balance: account.balance,
        currencySymbol: currencySymbolFor(account.currency),
        icon: account.type.icon,
        color: colorFromHex(account.color, fallback: Theme.of(context).colorScheme.primary),
        onTap: onTap,
        footer:
            'Updated ${account.updatedAt.toRelativeLabel()}'
            '${account.isArchived ? ' • Archived' : ''}'
            '${isSharedItem ? ' • ${account.ownerName}\'s' : ''}',
      ),
    );
  }
}
