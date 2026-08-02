import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../constants/app_spacing.dart';
import '../extensions/context_extensions.dart';
import '../widgets/buttons/app_primary_button.dart';
import '../widgets/navigation/app_bar.dart';

/// Explains the two home-screen widgets and, where the launcher supports
/// it (Android 8+ on most launchers), offers a direct "add to home
/// screen" button instead of making the user long-press their launcher
/// and find CashStack in the widget picker themselves.
class HomeWidgetScreen extends StatefulWidget {
  const HomeWidgetScreen({super.key});

  @override
  State<HomeWidgetScreen> createState() => _HomeWidgetScreenState();
}

class _HomeWidgetScreenState extends State<HomeWidgetScreen> {
  bool? _pinSupported;

  @override
  void initState() {
    super.initState();
    HomeWidget.isRequestPinWidgetSupported().then((supported) {
      if (mounted) setState(() => _pinSupported = supported ?? false);
    });
  }

  Future<void> _requestPin(String androidName) async {
    await HomeWidget.requestPinWidget(androidName: androidName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CashStackAppBar(title: 'Home Screen Widgets'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _WidgetTile(
            title: 'Balance & Budget',
            description:
                'Current balance, this month\'s income/expense, and your '
                'budget progress at a glance.',
            onAdd: _pinSupported == true
                ? () => _requestPin('BalanceWidgetProvider')
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _WidgetTile(
            title: 'Quick Add',
            description: 'Add Expense / Add Income buttons for fast entry.',
            onAdd: _pinSupported == true
                ? () => _requestPin('QuickAddWidgetProvider')
                : null,
          ),
          if (_pinSupported == false) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your launcher doesn\'t support adding widgets directly from '
              'apps — long-press an empty spot on your home screen, choose '
              'Widgets, and find CashStack in the list instead.',
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

class _WidgetTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onAdd;

  const _WidgetTile({required this.title, required this.description, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textStyles.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        if (onAdd != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppPrimaryButton(label: 'Add to Home Screen', fullWidth: false, onPressed: onAdd),
        ],
      ],
    );
  }
}

/// Whether this device is even a candidate for the entry point in Settings
/// — the widgets themselves are Android-only.
bool get isHomeWidgetSupportedPlatform => Platform.isAndroid;
