import 'package:flutter/material.dart';

import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/navigation/app_bar.dart';

/// Placeholder settings screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CashStackAppBar(title: 'Settings', showBackButton: false),
      body: ListView(
        children: const [
          AppListTile(
            leading: Icon(Icons.dark_mode_outlined),
            title: 'Appearance',
            subtitle: 'Coming soon',
          ),
          AppListTile(
            leading: Icon(Icons.notifications_outlined),
            title: 'Notifications',
            subtitle: 'Coming soon',
          ),
          AppListTile(
            leading: Icon(Icons.language_outlined),
            title: 'Language',
            subtitle: 'English',
          ),
        ],
      ),
    );
  }
}
