import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/navigation/bottom_nav_bar.dart';

const _destinations = [
  AppNavDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Home',
  ),
  AppNavDestination(
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long_rounded,
    label: 'Transactions',
  ),
  AppNavDestination(
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart_rounded,
    label: 'Reports',
  ),
  AppNavDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

/// Bottom-navigation shell for the authenticated area of the app (Home,
/// Transactions, Reports, Settings). Used as the `builder` of a
/// [StatefulShellRoute] so each tab keeps its own navigation stack — Profile
/// is reached from within Settings instead of its own tab.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
