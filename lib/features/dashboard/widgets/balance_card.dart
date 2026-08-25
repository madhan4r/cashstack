import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../services/snackbar_service.dart';
import '../../household/models/household.dart';
import '../../household/providers/household_controller.dart';

/// The dashboard's hero card: current balance (large, animated count-up)
/// plus a three-way breakdown of this month's income/expense/savings.
class BalanceCard extends StatelessWidget {
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlySavings;
  final String currencySymbol;

  const BalanceCard({
    super.key,
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySavings,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final onPrimary = context.colors.onPrimary;

    // The blurred BoxShadow below is the most expensive thing to paint on
    // the whole dashboard — isolating it in its own GPU layer means
    // scrolling (or any sibling widget rebuilding) recomposites a cached
    // bitmap instead of repainting the blur every frame.
    return RepaintBoundary(child: _buildCard(context, primary, onPrimary));
  }

  Widget _buildCard(BuildContext context, Color primary, Color onPrimary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusXl,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, Color.lerp(primary, Colors.black, 0.35)!],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current Balance',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: onPrimary.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              _CombinedBalanceToggle(onPrimary: onPrimary),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _AnimatedAmount(
            value: currentBalance,
            symbol: currencySymbol,
            style: context.textStyles.displaySmall?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _BalanceStat(
                label: 'Income',
                value: monthlyIncome,
                icon: Icons.arrow_downward_rounded,
                iconColor: onPrimary,
                currencySymbol: currencySymbol,
              ),
              _StatDivider(color: onPrimary.withValues(alpha: 0.2)),
              _BalanceStat(
                label: 'Expense',
                value: monthlyExpense,
                icon: Icons.arrow_upward_rounded,
                iconColor: onPrimary,
                currencySymbol: currencySymbol,
              ),
              _StatDivider(color: onPrimary.withValues(alpha: 0.2)),
              _BalanceStat(
                label: 'Savings',
                value: monthlySavings,
                icon: Icons.savings_outlined,
                iconColor: onPrimary,
                currencySymbol: currencySymbol,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedAmount extends StatelessWidget {
  final double value;
  final String symbol;
  final TextStyle? style;

  const _AnimatedAmount({
    required this.value,
    required this.symbol,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text('$symbol${animatedValue.toAmount()}', style: style);
      },
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color iconColor;
  final String currencySymbol;

  const _BalanceStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = context.colors.onPrimary;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.textStyles.labelSmall?.copyWith(
                  color: onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$currencySymbol${value.toAmount()}',
            style: context.textStyles.titleSmall?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Quick-access shortcut for the same "Combine Household Data" preference
/// exposed on the Household screen (see `_ViewModeToggle` there) — flips
/// the signed-in user's [HouseholdViewMode], which is what decides whether
/// [BalanceCard.currentBalance] et al. are pooled across the household or
/// just this user's own. Renders nothing if they're not in a household.
class _CombinedBalanceToggle extends ConsumerStatefulWidget {
  final Color onPrimary;

  const _CombinedBalanceToggle({required this.onPrimary});

  @override
  ConsumerState<_CombinedBalanceToggle> createState() => _CombinedBalanceToggleState();
}

class _CombinedBalanceToggleState extends ConsumerState<_CombinedBalanceToggle> {
  bool _isSaving = false;

  Future<void> _toggle(HouseholdViewMode current) async {
    final next = current == HouseholdViewMode.combined
        ? HouseholdViewMode.separate
        : HouseholdViewMode.combined;

    setState(() => _isSaving = true);
    final result = await ref.read(householdControllerProvider.notifier).setViewMode(next);
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess(
        next == HouseholdViewMode.combined
            ? 'Now showing combined household balance'
            : 'Now showing only your own balance',
      ),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final household = switch (ref.watch(householdControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (household == null) return const SizedBox.shrink();

    final isCombined = household.viewMode == HouseholdViewMode.combined;

    if (_isSaving) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(widget.onPrimary.withValues(alpha: 0.8)),
        ),
      );
    }

    return IconButton(
      tooltip: isCombined ? 'Showing combined household balance' : 'Showing only your balance',
      visualDensity: VisualDensity.compact,
      icon: Icon(
        isCombined ? Icons.groups_rounded : Icons.person_rounded,
        color: widget.onPrimary.withValues(alpha: 0.9),
        size: 20,
      ),
      onPressed: () => _toggle(household.viewMode),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final Color color;

  const _StatDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: color,
    );
  }
}
