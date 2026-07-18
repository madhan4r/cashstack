import 'package:flutter/material.dart';

/// CashStack's brand seed color and the semantic tokens that don't fit
/// naturally into Material's [ColorScheme] (success/warning/income/expense,
/// shimmer shades, …). The seed drives [ColorScheme.fromSeed]; the semantic
/// tokens are exposed per-brightness via [AppSemanticColors] so widgets
/// never hardcode a raw [Color].
class AppColors {
  const AppColors._();

  /// Brand primary — CashStack green.
  static const Color seed = Color(0xFF16A34A);

  // Light-mode semantic tokens.
  static const Color _successLight = Color(0xFF16A34A);
  static const Color _dangerLight = Color(0xFFDC2626);
  static const Color _warningLight = Color(0xFFD97706);
  static const Color _infoLight = Color(0xFF2563EB);
  static const Color _incomeLight = Color(0xFF16A34A);
  static const Color _expenseLight = Color(0xFFDC2626);
  static const Color _shimmerBaseLight = Color(0xFFE9E9EC);
  static const Color _shimmerHighlightLight = Color(0xFFF6F6F8);

  // Dark-mode semantic tokens — slightly desaturated so they don't glare on
  // a near-black surface (CRED/Revolut-style premium dark UI).
  static const Color _successDark = Color(0xFF4ADE80);
  static const Color _dangerDark = Color(0xFFF87171);
  static const Color _warningDark = Color(0xFFFBBF24);
  static const Color _infoDark = Color(0xFF60A5FA);
  static const Color _incomeDark = Color(0xFF4ADE80);
  static const Color _expenseDark = Color(0xFFF87171);
  static const Color _shimmerBaseDark = Color(0xFF232326);
  static const Color _shimmerHighlightDark = Color(0xFF2E2E32);

  static const AppSemanticColors light = AppSemanticColors(
    success: _successLight,
    danger: _dangerLight,
    warning: _warningLight,
    info: _infoLight,
    income: _incomeLight,
    expense: _expenseLight,
    shimmerBase: _shimmerBaseLight,
    shimmerHighlight: _shimmerHighlightLight,
  );

  /// Predefined swatches offered by any user-facing color picker (e.g. the
  /// category color picker) — deliberately a closed palette, no custom hex
  /// input, so every user-chosen color still looks intentional against the
  /// rest of the UI. A superset of the backend's default-category colors.
  static const List<Color> categoryPalette = [
    Color(0xFF22C55E),
    Color(0xFF16A34A),
    Color(0xFF15803D),
    Color(0xFF4ADE80),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF64748B),
    Color(0xFF3B82F6),
    Color(0xFF14B8A6),
    Color(0xFFA855F7),
    Color(0xFFF43F5E),
    Color(0xFFEAB308),
  ];

  static const AppSemanticColors dark = AppSemanticColors(
    success: _successDark,
    danger: _dangerDark,
    warning: _warningDark,
    info: _infoDark,
    income: _incomeDark,
    expense: _expenseDark,
    shimmerBase: _shimmerBaseDark,
    shimmerHighlight: _shimmerHighlightDark,
  );
}

/// Semantic colors layered on top of [ColorScheme] via [ThemeExtension], so
/// `Theme.of(context).extension<AppSemanticColors>()` always returns the
/// right shade for the current brightness.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color danger;
  final Color warning;
  final Color info;
  final Color income;
  final Color expense;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppSemanticColors({
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
    required this.income,
    required this.expense,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? danger,
    Color? warning,
    Color? info,
    Color? income,
    Color? expense,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
    );
  }
}
