import 'package:flutter/material.dart';

import '../../../core/widgets/cards/category_chip.dart';
import '../models/account_type.dart';

/// Selectable pill for an [AccountType] — thin wrapper around the shared
/// [CategoryChip] so the Accounts feature gets the same selected/unselected
/// styling used elsewhere in the app.
class AccountTypeChip extends StatelessWidget {
  final AccountType type;
  final bool selected;
  final VoidCallback? onTap;

  const AccountTypeChip({
    super.key,
    required this.type,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryChip(
      label: type.label,
      icon: type.icon,
      selected: selected,
      onTap: onTap,
    );
  }
}
