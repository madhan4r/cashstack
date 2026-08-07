import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../providers/member_accounts_provider.dart';

/// Read-only view of a single household member's accounts — reachable by
/// tapping a member on the Household screen. Works regardless of the
/// viewer's own combine/separate household view mode (see
/// `AccountsRepository.getAccountsForMember`), so you don't have to switch
/// your whole app to combined just to look at one person's accounts.
class MemberAccountsScreen extends ConsumerWidget {
  final String memberId;
  final String memberName;

  const MemberAccountsScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(memberAccountsProvider(memberId));

    return Scaffold(
      appBar: CashStackAppBar(title: "$memberName's Accounts"),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ScrollableSingleChild(
          child: ErrorState(
            message: error is Failure ? error.message : error.toString(),
            onRetry: () => ref.invalidate(memberAccountsProvider(memberId)),
          ),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No accounts to show'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: accounts.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(account.type.icon),
                  title: Text(account.name),
                  subtitle: Text(account.type.label),
                  trailing: Text(
                    '${currencySymbolFor(account.currency)}${account.balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
