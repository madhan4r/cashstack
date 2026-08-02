import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../widgets/currency_picker_sheet.dart';
import '../widgets/theme_mode_picker_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final current = ref.read(preferredCurrencyProvider);
    final code = await showCurrencyPickerSheet(context: context, selectedCode: current.code);
    if (code == null || code == current.code || !context.mounted) return;

    final result = await ref.read(authControllerProvider.notifier).updatePreferredCurrency(code);
    if (!context.mounted) return;
    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess(
        'Preferred currency set to ${currencySymbolFor(code)} $code',
      ),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _pickThemeMode(BuildContext context, WidgetRef ref) async {
    final current = ref.read(themeModeControllerProvider);
    final mode = await showThemeModePickerSheet(context: context, selected: current);
    if (mode == null || !context.mounted) return;
    await ref.read(themeModeControllerProvider.notifier).setThemeMode(mode);
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System default',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

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
          AppListTile(
            leading: const Icon(Icons.currency_exchange_rounded),
            title: 'Preferred Currency',
            subtitle: '${currency.symbol} ${currency.code} — ${currency.name}',
            onTap: () => _pickCurrency(context, ref),
          ),
          AppListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: 'Appearance',
            subtitle: _themeModeLabel(themeMode),
            onTap: () => _pickThemeMode(context, ref),
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
