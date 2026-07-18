import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';

/// Placeholder settings screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CashStackAppBar(title: 'Settings', showBackButton: false),
      body: ListView(
        children: [
          AppListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: 'Accounts',
            subtitle: 'Manage your bank, cash, and card accounts',
            onTap: () => context.push(AppRoutes.accounts),
          ),
          AppListTile(
            leading: const Icon(Icons.category_outlined),
            title: 'Categories',
            subtitle: 'Manage income and expense categories',
            onTap: () => context.push(AppRoutes.categories),
          ),
          AppListTile(
            leading: const Icon(Icons.event_repeat_outlined),
            title: 'Recurring Transactions',
            subtitle: 'Automate bills, subscriptions, and salary',
            onTap: () => context.push(AppRoutes.recurring),
          ),
          const AppListTile(
            leading: Icon(Icons.dark_mode_outlined),
            title: 'Appearance',
            subtitle: 'Coming soon',
          ),
          const AppListTile(
            leading: Icon(Icons.notifications_outlined),
            title: 'Notifications',
            subtitle: 'Coming soon',
          ),
          const AppListTile(
            leading: Icon(Icons.language_outlined),
            title: 'Language',
            subtitle: 'English',
          ),
        ],
      ),
    );
  }
}
