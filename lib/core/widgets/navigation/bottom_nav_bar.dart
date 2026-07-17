import 'package:flutter/material.dart';

/// One destination in [AppBottomNavBar].
class AppNavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Themed bottom navigation bar, generic over any set of
/// [AppNavDestination]s — used as the root shell nav (see
/// `routes/main_shell.dart`) so route wiring and visual styling stay
/// separate.
class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<AppNavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations
          .map(
            (destination) => NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
          )
          .toList(),
    );
  }
}
