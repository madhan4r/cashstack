import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/models/transaction_kind.dart';

/// Expense / Income / Transfer segmented control with a sliding selection
/// indicator. The rest of the form adapts to whichever segment is active.
class TransactionTypeSelector extends StatelessWidget {
  final TransactionKind value;
  final ValueChanged<TransactionKind> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _order = [
    TransactionKind.expense,
    TransactionKind.income,
    TransactionKind.transfer,
  ];

  Color _colorFor(BuildContext context, TransactionKind kind) {
    return switch (kind) {
      TransactionKind.expense => context.semanticColors.expense,
      TransactionKind.income => context.semanticColors.income,
      TransactionKind.transfer => context.colors.primary,
    };
  }

  String _labelFor(TransactionKind kind) {
    return switch (kind) {
      TransactionKind.expense => 'Expense',
      TransactionKind.income => 'Income',
      TransactionKind.transfer => 'Transfer',
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _order.indexOf(value);
    final activeColor = _colorFor(context, value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / _order.length;

        return Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: AppRadius.radiusPill,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: segmentWidth * selectedIndex,
                width: segmentWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: AppRadius.radiusPill,
                  ),
                ),
              ),
              Row(
                children: _order.map((kind) {
                  final isSelected = kind == value;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onChanged(kind),
                      borderRadius: AppRadius.radiusPill,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: (context.textStyles.labelLarge ??
                                  const TextStyle())
                              .copyWith(
                            color: isSelected
                                ? _onColor(activeColor)
                                : context.colors.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: Text(_labelFor(kind)),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _onColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
