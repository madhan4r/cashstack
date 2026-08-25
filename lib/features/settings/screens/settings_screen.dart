import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/biometric/biometric_auth_service.dart';
import '../../../core/biometric/biometric_lock_controller.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/home_widget/home_widget_screen.dart';
import '../../../core/notifications/notifications_enabled_controller.dart';
import '../../household/providers/household_controller.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../../transaction_detection/providers/smart_detection_enabled_controller.dart';
import '../widgets/currency_picker_sheet.dart';
import '../widgets/settings_section.dart';
import '../widgets/theme_mode_picker_sheet.dart';

/// Trailing chevron for a tappable (navigates elsewhere) row — [AppListTile]
/// doesn't add one on its own, so every navigable row below passes this
/// explicitly to signal it's tappable, and omits it for rows whose trailing
/// is already a [Switch].
const _navigationChevron = Icon(Icons.chevron_right_rounded);

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

  Future<void> _toggleNotifications(WidgetRef ref, bool enable) async {
    final notifier = ref.read(notificationsEnabledProvider.notifier);
    if (enable) {
      final granted = await notifier.enable();
      if (!granted) {
        ref
            .read(snackbarServiceProvider)
            .showError('Notifications permission was denied');
      }
    } else {
      await notifier.disable();
    }
  }

  Future<void> _toggleBiometricLock(WidgetRef ref, bool enable) async {
    final notifier = ref.read(biometricLockEnabledProvider.notifier);
    if (enable) {
      final verified = await notifier.enable();
      if (!verified) {
        ref
            .read(snackbarServiceProvider)
            .showError("Couldn't verify your fingerprint/Face ID");
      }
    } else {
      await notifier.disable();
    }
  }

  Future<void> _toggleSmartDetection(BuildContext context, WidgetRef ref, bool enable) async {
    final notifier = ref.read(smartDetectionEnabledProvider.notifier);
    if (enable) {
      final granted = await notifier.enable();
      if (!granted && context.mounted) {
        ref
            .read(snackbarServiceProvider)
            .showError('Notification access wasn\'t granted');
      }
    } else {
      await notifier.disable();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final biometricLockEnabled = ref.watch(biometricLockEnabledProvider);
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final smartDetectionEnabled = ref.watch(smartDetectionEnabledProvider);
    final household = ref.watch(householdControllerProvider).value;
    final user = ref.watch(authControllerProvider).user;

    final showBiometricRow = biometricAvailable.maybeWhen(
      data: (available) => available,
      orElse: () => false,
    );

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Settings', showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          SettingsSection(
            children: [
              AppListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: user?.fullName ?? 'Profile',
                subtitle: user?.email,
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.profile),
              ),
            ],
          ),
          SettingsSection(
            title: 'Manage your money',
            children: [
              AppListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: 'Accounts',
                subtitle: 'Manage your bank, cash, and card accounts',
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.accounts),
              ),
              AppListTile(
                leading: const Icon(Icons.category_outlined),
                title: 'Categories',
                subtitle: 'Manage income and expense categories',
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.categories),
              ),
              AppListTile(
                leading: const Icon(Icons.event_repeat_outlined),
                title: 'Recurring Transactions',
                subtitle: 'Automate bills, subscriptions, and salary',
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.recurring),
              ),
              AppListTile(
                leading: const Icon(Icons.donut_small_outlined),
                title: 'Category Budgets',
                subtitle: 'Set monthly limits per category',
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.categoryBudgets),
              ),
              AppListTile(
                leading: const Icon(Icons.savings_outlined),
                title: 'Savings Goals',
                subtitle: 'Track progress toward what you\'re saving for',
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.savingsGoals),
              ),
              AppListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: 'Export & Backup',
                subtitle: 'Download your transactions or a full data backup',
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.exportData),
              ),
              AppListTile(
                leading: const Icon(Icons.groups_outlined),
                title: 'Household',
                subtitle: household != null
                    ? '${household.members.length} ${household.members.length == 1 ? 'member' : 'members'} sharing finances'
                    : 'Share accounts and transactions with family',
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.household),
              ),
            ],
          ),
          if (showBiometricRow || Platform.isAndroid)
            SettingsSection(
              title: 'Security',
              children: [
                if (showBiometricRow)
                  AppListTile(
                    leading: const Icon(Icons.fingerprint_rounded),
                    title: 'App Lock',
                    subtitle: biometricLockEnabled
                        ? 'Unlock with fingerprint/Face ID'
                        : 'Off',
                    trailing: Switch(
                      value: biometricLockEnabled,
                      onChanged: (value) => _toggleBiometricLock(ref, value),
                    ),
                  ),
                if (Platform.isAndroid)
                  AppListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: 'Smart Transaction Detection',
                    subtitle: smartDetectionEnabled
                        ? 'Suggests transactions from bank notifications'
                        : 'Off',
                    trailing: Switch(
                      value: smartDetectionEnabled,
                      onChanged: (value) => _toggleSmartDetection(context, ref, value),
                    ),
                  ),
              ],
            ),
          SettingsSection(
            title: 'Notifications',
            children: [
              AppListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: 'Notifications',
                subtitle: notificationsEnabled
                    ? 'Reminders for upcoming recurring transactions'
                    : 'Off',
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) => _toggleNotifications(ref, value),
                ),
              ),
              AppListTile(
                leading: const Icon(Icons.tune_rounded),
                title: 'Notification Preferences',
                subtitle: 'Choose which alerts you receive',
                trailing: _navigationChevron,
                onTap: () => context.push(AppRoutes.notificationPreferences),
              ),
            ],
          ),
          SettingsSection(
            title: 'Preferences',
            children: [
              AppListTile(
                leading: const Icon(Icons.currency_exchange_rounded),
                title: 'Preferred Currency',
                subtitle: '${currency.symbol} ${currency.code} — ${currency.name}',
                trailing: _navigationChevron,
                onTap: () => _pickCurrency(context, ref),
              ),
              AppListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: 'Appearance',
                subtitle: _themeModeLabel(themeMode),
                trailing: _navigationChevron,
                onTap: () => _pickThemeMode(context, ref),
              ),
              if (isHomeWidgetSupportedPlatform)
                AppListTile(
                  leading: const Icon(Icons.widgets_outlined),
                  title: 'Home Screen Widgets',
                  subtitle: 'Balance glance and quick-add buttons',
                  trailing: _navigationChevron,
                  onTap: () => context.push(AppRoutes.homeScreenWidgets),
                ),
              const AppListTile(
                leading: Icon(Icons.language_outlined),
                title: 'Language',
                subtitle: 'English',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
